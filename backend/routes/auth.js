const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { protect } = require('../middleware/auth');
const EmailService = require('../services/emailService');

const router = express.Router();

// @route   POST /signup
// @desc    User signup endpoint
// @access  Public
router.post('/signup', [
  body('username')
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  body('isVegetarian')
    .optional()
    .isBoolean()
    .withMessage('isVegetarian must be a boolean value')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, email, password, isVegetarian = false } = req.body;

    // Check if email already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Email already exists'
      });
    }

    // Check if username already exists
    const existingUsername = await pool.query(
      'SELECT id FROM users WHERE username = $1',
      [username]
    );

    if (existingUsername.rows.length > 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Username already exists'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Generate 6-digit OTP code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes from now

    // Create user with OTP verification fields
    const result = await pool.query(
      'INSERT INTO users (username, email, password_hash, is_vegetarian, email_verification_otp, otp_expires_at, email_verification_sent_at, otp_attempts) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id, username, email, is_vegetarian, created_at',
      [username, email, passwordHash, isVegetarian, otpCode, otpExpires, new Date(), 0]
    );

    const user = result.rows[0];

    // Send email verification with OTP
    let emailSent = false;
    try {
      const emailResult = await EmailService.sendEmailVerification(email, username, otpCode);
      if (emailResult.success) {
        console.log(`✅ Verification email with OTP sent to ${email}`);
        emailSent = true;
      } else {
        console.error('❌ Failed to send verification email:', emailResult.error);
        // Check if it's a Resend restriction error
        if (emailResult.error && emailResult.error.includes('testing emails')) {
          console.log('🔧 Development mode: Email restriction detected');
        }
      }
    } catch (emailError) {
      console.error('❌ Failed to send verification email:', emailError);
    }

    res.status(201).json({
      status: 'success',
      message: emailSent 
        ? 'Account created successfully! Please check your email to verify your account before logging in.'
        : 'Account created successfully! Please use the verification code in development mode or contact support.',
      data: {
        id: user.id,
        email: user.email,
        username: user.username,
        isVegetarian: user.is_vegetarian,
        createdAt: user.created_at,
        emailVerified: false,
        verificationEmailSent: emailSent,
        developmentOTP: process.env.NODE_ENV === 'development' && !emailSent ? otpCode : undefined
      }
      // No token provided - user must verify email first
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during signup'
    });
  }
});

// @route   POST /login
// @desc    User login endpoint
// @access  Public
router.post('/login', [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;

    // Check if email exists in users table
    const result = await pool.query(
      'SELECT id, username, email, password_hash, is_vegetarian, email_verified, created_at FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    const user = result.rows[0];

    // Compare the hashed password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check if email is verified
    if (!user.email_verified) {
      return res.status(403).json({
        status: 'error',
        message: 'Please verify your email address before logging in. Check your inbox for the verification email.',
        code: 'EMAIL_NOT_VERIFIED',
        data: {
          email: user.email,
          needsVerification: true
        }
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({
      status: 'success',
      message: 'Login successful',
      data: {
        id: user.id,
        email: user.email,
        username: user.username,
        isVegetarian: user.is_vegetarian,
        createdAt: user.created_at
      },
      token: token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during login'
    });
  }
});

// @route   GET /api/auth/me
// @desc    Get current user profile
// @access  Private
router.get('/me', protect, async (req, res) => {
  try {
    res.json({
      status: 'success',
      data: {
        user: req.user
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching profile'
    });
  }
});

// @route   PUT /api/auth/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', [
  protect,
  body('fullName')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Full name must be less than 100 characters'),
  body('avatarUrl')
    .optional()
    .isURL()
    .withMessage('Please provide a valid URL for avatar')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { fullName, avatarUrl } = req.body;
    const userId = req.user.id;

    // Update user profile
    const result = await pool.query(
      'UPDATE users SET full_name = COALESCE($1, full_name), avatar_url = COALESCE($2, avatar_url), updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING id, username, email, full_name, avatar_url, updated_at',
      [fullName, avatarUrl, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.json({
      status: 'success',
      message: 'Profile updated successfully',
      data: {
        user: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while updating profile'
    });
  }
});

// @route   POST /verify-email
// @desc    Verify user email with OTP code
// @access  Public
router.post('/verify-email', [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address'),
  body('otp')
    .notEmpty()
    .withMessage('OTP code is required')
    .isLength({ min: 6, max: 6 })
    .withMessage('OTP code must be exactly 6 digits')
    .isNumeric()
    .withMessage('OTP code must contain only numbers')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, otp } = req.body;

    // Find user with this email and OTP
    const result = await pool.query(
      'SELECT id, username, email, otp_expires_at, otp_attempts FROM users WHERE email = $1 AND email_verification_otp = $2',
      [email, otp]
    );

    if (result.rows.length === 0) {
      // Increment failed attempts for this email
      await pool.query(
        'UPDATE users SET otp_attempts = otp_attempts + 1 WHERE email = $1',
        [email]
      );
      
      return res.status(400).json({
        status: 'error',
        message: 'Invalid OTP code. Please check the code and try again.',
        code: 'INVALID_OTP'
      });
    }

    const user = result.rows[0];

    // Check if too many attempts
    if (user.otp_attempts >= 5) {
      return res.status(429).json({
        status: 'error',
        message: 'Too many failed attempts. Please request a new OTP code.',
        code: 'TOO_MANY_ATTEMPTS'
      });
    }

    // Check if OTP has expired
    if (new Date() > new Date(user.otp_expires_at)) {
      return res.status(400).json({
        status: 'error',
        message: 'OTP code has expired. Please request a new verification email.',
        code: 'OTP_EXPIRED',
        data: {
          email: user.email
        }
      });
    }

    // Update user as verified and clear OTP fields
    await pool.query(
      'UPDATE users SET email_verified = true, email_verification_otp = NULL, otp_expires_at = NULL, otp_attempts = 0 WHERE id = $1',
      [user.id]
    );

    // Send welcome email
    try {
      await EmailService.sendWelcomeEmail(user.email, user.username);
      console.log(`✅ Welcome email sent to ${user.email}`);
    } catch (emailError) {
      console.error('❌ Failed to send welcome email:', emailError);
      // Continue even if welcome email fails
    }

    res.json({
      status: 'success',
      message: 'Email verified successfully! You can now log in to your account.',
      data: {
        email: user.email,
        username: user.username,
        verified: true
      }
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during email verification'
    });
  }
});

// @route   POST /resend-verification
// @desc    Resend email verification
// @access  Public
router.post('/resend-verification', [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email } = req.body;

    // Find user with this email
    const result = await pool.query(
      'SELECT id, username, email, email_verified, email_verification_sent_at FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'No account found with this email address'
      });
    }

    const user = result.rows[0];

    // Check if already verified
    if (user.email_verified) {
      return res.status(400).json({
        status: 'error',
        message: 'Email is already verified. You can log in now.'
      });
    }

    // Check rate limiting - only allow resend every 2 minutes
    const lastSent = new Date(user.email_verification_sent_at);
    const now = new Date();
    const timeDiff = now - lastSent;
    const twoMinutes = 2 * 60 * 1000;

    if (timeDiff < twoMinutes) {
      const remainingTime = Math.ceil((twoMinutes - timeDiff) / 1000);
      return res.status(429).json({
        status: 'error',
        message: `Please wait ${remainingTime} seconds before requesting another verification email.`,
        code: 'RATE_LIMITED',
        data: {
          retryAfter: remainingTime
        }
      });
    }

    // Generate new OTP code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes from now

    // Update user with new OTP
    await pool.query(
      'UPDATE users SET email_verification_otp = $1, otp_expires_at = $2, email_verification_sent_at = $3, otp_attempts = 0 WHERE id = $4',
      [otpCode, otpExpires, new Date(), user.id]
    );

    // Send verification email with OTP
    try {
      await EmailService.sendEmailVerification(email, user.username, otpCode);
      console.log(`✅ Verification email with new OTP sent to ${email}`);
    } catch (emailError) {
      console.error('❌ Failed to resend verification email:', emailError);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to send verification email. Please try again later.'
      });
    }

    res.json({
      status: 'success',
      message: 'Verification email sent! Please check your inbox.',
      data: {
        email: email,
        verificationSent: true
      }
    });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during resend verification'
    });
  }
});

module.exports = router;
