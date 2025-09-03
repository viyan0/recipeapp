const express = require('express');
const { body, validationResult } = require('express-validator');
const EmailService = require('../services/emailService');
const router = express.Router();

// Middleware to check for validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation errors',
      errors: errors.array()
    });
  }
  next();
};

/**
 * @route POST /api/email/test
 * @desc Send a test email to verify Resend integration
 * @access Public (for testing purposes)
 */
router.post('/test', [
  body('to')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
], handleValidationErrors, async (req, res) => {
  try {
    const { to } = req.body;
    
    console.log(`Sending test email to: ${to}`);
    
    const result = await EmailService.sendTestEmail(to);
    
    if (result.success) {
      res.json({
        success: true,
        message: 'Test email sent successfully',
        data: {
          to: to,
          from: process.env.RESEND_FROM_EMAIL,
          timestamp: new Date().toISOString(),
          resendResponse: result.data
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send test email',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in test email endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route POST /api/email/welcome
 * @desc Send a welcome email to new users
 * @access Public (for testing purposes)
 */
router.post('/welcome', [
  body('to')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  body('username')
    .isLength({ min: 1, max: 50 })
    .withMessage('Username must be between 1 and 50 characters')
    .trim()
    .escape(),
], handleValidationErrors, async (req, res) => {
  try {
    const { to, username } = req.body;
    
    console.log(`Sending welcome email to: ${to} for user: ${username}`);
    
    const result = await EmailService.sendWelcomeEmail(to, username);
    
    if (result.success) {
      res.json({
        success: true,
        message: 'Welcome email sent successfully',
        data: {
          to: to,
          username: username,
          from: process.env.RESEND_FROM_EMAIL,
          timestamp: new Date().toISOString(),
          resendResponse: result.data
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send welcome email',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in welcome email endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route POST /api/email/password-reset
 * @desc Send a password reset email
 * @access Public (for testing purposes)
 */
router.post('/password-reset', [
  body('to')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  body('resetToken')
    .isLength({ min: 1 })
    .withMessage('Reset token is required'),
  body('resetUrl')
    .isURL()
    .withMessage('Please provide a valid reset URL'),
], handleValidationErrors, async (req, res) => {
  try {
    const { to, resetToken, resetUrl } = req.body;
    
    console.log(`Sending password reset email to: ${to}`);
    
    const result = await EmailService.sendPasswordResetEmail(to, resetToken, resetUrl);
    
    if (result.success) {
      res.json({
        success: true,
        message: 'Password reset email sent successfully',
        data: {
          to: to,
          from: process.env.RESEND_FROM_EMAIL,
          timestamp: new Date().toISOString(),
          resendResponse: result.data
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send password reset email',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in password reset email endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route POST /api/email/share-recipe
 * @desc Send a recipe sharing email
 * @access Public (for testing purposes)
 */
router.post('/share-recipe', [
  body('to')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  body('fromUsername')
    .isLength({ min: 1, max: 50 })
    .withMessage('Username must be between 1 and 50 characters')
    .trim()
    .escape(),
  body('recipeTitle')
    .isLength({ min: 1, max: 100 })
    .withMessage('Recipe title must be between 1 and 100 characters')
    .trim()
    .escape(),
  body('recipeUrl')
    .isURL()
    .withMessage('Please provide a valid recipe URL'),
], handleValidationErrors, async (req, res) => {
  try {
    const { to, fromUsername, recipeTitle, recipeUrl } = req.body;
    
    console.log(`Sending recipe share email to: ${to} from: ${fromUsername}`);
    
    const result = await EmailService.sendRecipeShareEmail(to, fromUsername, recipeTitle, recipeUrl);
    
    if (result.success) {
      res.json({
        success: true,
        message: 'Recipe share email sent successfully',
        data: {
          to: to,
          fromUsername: fromUsername,
          recipeTitle: recipeTitle,
          recipeUrl: recipeUrl,
          from: process.env.RESEND_FROM_EMAIL,
          timestamp: new Date().toISOString(),
          resendResponse: result.data
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send recipe share email',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in recipe share email endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route POST /api/email/custom
 * @desc Send a custom email with user-defined content
 * @access Public (for testing purposes)
 */
router.post('/custom', [
  body('to')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  body('subject')
    .isLength({ min: 1, max: 100 })
    .withMessage('Subject must be between 1 and 100 characters')
    .trim()
    .escape(),
  body('htmlContent')
    .isLength({ min: 1 })
    .withMessage('HTML content is required'),
  body('textContent')
    .optional()
    .isLength({ min: 1 })
    .withMessage('Text content must not be empty if provided'),
], handleValidationErrors, async (req, res) => {
  try {
    const { to, subject, htmlContent, textContent } = req.body;
    
    console.log(`Sending custom email to: ${to} with subject: ${subject}`);
    
    const result = await EmailService.sendEmail(to, subject, htmlContent, textContent);
    
    if (result.success) {
      res.json({
        success: true,
        message: 'Custom email sent successfully',
        data: {
          to: to,
          subject: subject,
          from: process.env.RESEND_FROM_EMAIL,
          timestamp: new Date().toISOString(),
          resendResponse: result.data
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send custom email',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in custom email endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * @route GET /api/email/status
 * @desc Get email service status and configuration
 * @access Public
 */
router.get('/status', (req, res) => {
  try {
    const status = {
      success: true,
      message: 'Email service status',
      data: {
        service: 'Resend',
        configured: !!process.env.RESEND_API_KEY,
        fromEmail: process.env.RESEND_FROM_EMAIL || 'Not configured',
        timestamp: new Date().toISOString(),
        endpoints: {
          test: 'POST /api/email/test',
          welcome: 'POST /api/email/welcome',
          passwordReset: 'POST /api/email/password-reset',
          shareRecipe: 'POST /api/email/share-recipe',
          custom: 'POST /api/email/custom'
        }
      }
    };
    
    res.json(status);
  } catch (error) {
    console.error('Error in email status endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

module.exports = router;
