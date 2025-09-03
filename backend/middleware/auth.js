const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');

const protect = async (req, res, next) => {
  let token;

  // Check for token in headers
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Validate token format
      if (!token || token === 'null' || token === 'undefined') {
        return res.status(401).json({
          status: 'error',
          message: 'Invalid token format'
        });
      }

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Validate decoded token
      if (!decoded || !decoded.id || typeof decoded.id !== 'number') {
        return res.status(401).json({
          status: 'error',
          message: 'Invalid token payload'
        });
      }

      // Get user from database
      const result = await pool.query(
        'SELECT id, username, email, full_name, avatar_url, is_vegetarian, email_verified, created_at FROM users WHERE id = $1 AND password_hash IS NOT NULL',
        [decoded.id]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({
          status: 'error',
          message: 'User not found or account deleted'
        });
      }

      const user = result.rows[0];

      // Check if user's email is verified
      if (!user.email_verified) {
        return res.status(403).json({
          status: 'error',
          message: 'Email not verified. Please verify your email before accessing this resource.',
          code: 'EMAIL_NOT_VERIFIED',
          data: {
            email: user.email,
            needsVerification: true
          }
        });
      }
      
      // Add user to request object
      req.user = user;
      
      // Add token info for potential use
      req.token = {
        id: decoded.id,
        issuedAt: decoded.iat,
        expiresAt: decoded.exp
      };

      next();
    } catch (error) {
      console.error('Token verification error:', error);
      
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          status: 'error',
          message: 'Token expired, please login again'
        });
      }
      
      if (error.name === 'JsonWebTokenError') {
        return res.status(401).json({
          status: 'error',
          message: 'Invalid token, please login again'
        });
      }

      return res.status(401).json({
        status: 'error',
        message: 'Not authorized, token failed'
      });
    }
  } else {
    // No token provided
    return res.status(401).json({
      status: 'error',
      message: 'Not authorized, no token provided'
    });
  }
};

// Optional auth middleware (doesn't fail if no token)
const optionalAuth = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      
      if (!token || token === 'null' || token === 'undefined') {
        return next();
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      if (!decoded || !decoded.id) {
        return next();
      }
      
      const result = await pool.query(
        'SELECT id, username, email, full_name, avatar_url, is_vegetarian FROM users WHERE id = $1 AND password_hash IS NOT NULL',
        [decoded.id]
      );

      if (result.rows.length > 0) {
        req.user = result.rows[0];
        req.token = {
          id: decoded.id,
          issuedAt: decoded.iat,
          expiresAt: decoded.exp
        };
      }
    } catch (error) {
      // Silently fail for optional auth
      console.log('Optional auth failed:', error.message);
    }
  }
  
  next();
};

// Role-based authorization (for future use)
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Not authorized'
      });
    }

    // For now, we don't have roles implemented, but this is ready for future use
    if (roles.length > 0 && !roles.includes(req.user.role)) {
      return res.status(403).json({
        status: 'error',
        message: 'User role not authorized'
      });
    }

    next();
  };
};

// Rate limiting for auth endpoints
const authRateLimit = (req, res, next) => {
  // This can be enhanced with Redis or in-memory storage for production
  const clientIP = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  
  // Simple in-memory rate limiting (not suitable for production with multiple instances)
  if (!req.app.locals.authAttempts) {
    req.app.locals.authAttempts = new Map();
  }
  
  const attempts = req.app.locals.authAttempts.get(clientIP) || { count: 0, resetTime: now + 15 * 60 * 1000 };
  
  if (now > attempts.resetTime) {
    attempts.count = 1;
    attempts.resetTime = now + 15 * 60 * 1000;
  } else {
    attempts.count++;
  }
  
  req.app.locals.authAttempts.set(clientIP, attempts);
  
  if (attempts.count > 5) {
    return res.status(429).json({
      status: 'error',
      message: 'Too many authentication attempts, please try again later'
    });
  }
  
  next();
};

module.exports = {
  protect,
  optionalAuth,
  authorize,
  authRateLimit
};
