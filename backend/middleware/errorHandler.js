const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error for debugging
  console.error('Error:', {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString(),
    userAgent: req.get('User-Agent'),
    ip: req.ip || req.connection.remoteAddress
  });

  // PostgreSQL unique constraint violation
  if (err.code === '23505') {
    const message = 'Duplicate field value entered';
    error = { message, statusCode: 400 };
  }

  // PostgreSQL foreign key constraint violation
  if (err.code === '23503') {
    const message = 'Referenced record does not exist';
    error = { message, statusCode: 400 };
  }

  // PostgreSQL check constraint violation
  if (err.code === '23514') {
    const message = 'Invalid data provided';
    error = { message, statusCode: 400 };
  }

  // PostgreSQL not null constraint violation
  if (err.code === '23502') {
    const message = 'Required field is missing';
    error = { message, statusCode: 400 };
  }

  // PostgreSQL invalid text representation
  if (err.code === '22P02') {
    const message = 'Invalid input format';
    error = { message, statusCode: 400 };
  }

  // PostgreSQL insufficient privileges
  if (err.code === '42501') {
    const message = 'Insufficient privileges';
    error = { message, statusCode: 403 };
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = { message, statusCode: 400 };
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = { message, statusCode: 401 };
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = { message, statusCode: 401 };
  }

  // Cast errors (invalid ObjectId)
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = { message, statusCode: 404 };
  }

  // Syntax errors
  if (err.name === 'SyntaxError') {
    const message = 'Invalid JSON format';
    error = { message, statusCode: 400 };
  }

  // Multer errors (file upload)
  if (err.code === 'LIMIT_FILE_SIZE') {
    const message = 'File too large';
    error = { message, statusCode: 400 };
  }

  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    const message = 'Unexpected file field';
    error = { message, statusCode: 400 };
  }

  // Rate limiting errors
  if (err.status === 429) {
    const message = 'Too many requests';
    error = { message, statusCode: 429 };
  }

  // Network errors
  if (err.code === 'ECONNREFUSED') {
    const message = 'Service temporarily unavailable';
    error = { message, statusCode: 503 };
  }

  if (err.code === 'ENOTFOUND') {
    const message = 'Service not found';
    error = { message, statusCode: 503 };
  }

  if (err.code === 'ECONNABORTED') {
    const message = 'Request timeout';
    error = { message, statusCode: 408 };
  }

  // Default error
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  // Don't leak error details in production
  const response = {
    status: 'error',
    message: message,
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    method: req.method
  };

  // Add stack trace in development
  if (process.env.NODE_ENV === 'development') {
    response.stack = err.stack;
    response.error = err;
  }

  res.status(statusCode).json(response);
};

module.exports = errorHandler;
