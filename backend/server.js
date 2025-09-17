const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config({ path: __dirname + '/config.env' });

const { connectDB, closeDB, healthCheck, getPoolStatus } = require('./config/database');
const errorHandler = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/auth');
const recipeRoutes = require('./routes/recipes');
const userRoutes = require('./routes/users');
const emailRoutes = require('./routes/email');

const app = express();


const PORT = process.env.PORT || 3000;

// NOTE: Connect to the database only after the HTTP server starts successfully.
// This prevents initializing the DB when the port is already in use, which
// previously caused the pool to close during graceful shutdown and then be
// reused by startup tasks.

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

// CORS configuration - Allow Flutter app to connect
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] 
    : [
        'http://localhost:3001', 
        'http://localhost:8080', 
        'http://localhost:5000', 
        'http://127.0.0.1:3001',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:5000',
        'http://127.0.0.1:59788',
        'http://localhost:59788',
        // Flutter web development server
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        // Machine IP for Flutter web
        'http://192.168.28.245:3000',
        'http://192.168.28.245:3001',
        // Allow all origins in development for easier testing
        ...(process.env.NODE_ENV === 'development' ? ['*'] : [])
      ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Access-Control-Allow-Origin'],
  preflightContinue: false,
  optionsSuccessStatus: 204
};
app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    status: 'error',
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Health check endpoint with database monitoring
app.get('/health', async (req, res) => {
  try {
    const dbHealth = await healthCheck();
    const poolStatus = getPoolStatus();
    
    const healthData = {
      status: dbHealth.status === 'healthy' ? 'success' : 'warning',
      message: dbHealth.status === 'healthy' ? 'Server and database are running' : 'Server running, database issues detected',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      database: dbHealth,
      connectionPool: poolStatus
    };
    
    const statusCode = dbHealth.status === 'healthy' ? 200 : 503;
    res.status(statusCode).json(healthData);
  } catch (error) {
    res.status(503).json({
      status: 'error',
      message: 'Health check failed',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/users', userRoutes);
app.use('/api/email', emailRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: `Route ${req.originalUrl} not found`,
    timestamp: new Date().toISOString()
  });
});

// Error handling middleware
app.use(errorHandler);

// Start server - Bind to all network interfaces for Flutter web compatibility
const server = app.listen(PORT, '0.0.0.0', async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
  console.log(`🍳 Recipe endpoints: http://localhost:${PORT}/api/recipes`);
  console.log(`👤 User endpoints: http://localhost:${PORT}/api/users`);
  console.log(`📧 Email endpoints: http://localhost:${PORT}/api/email`);
  console.log(`🌐 Network access: http://192.168.28.245:${PORT}`);

  // Connect to database now that server has started
  try {
    await connectDB();
  } catch (e) {
    console.error('❌ Failed to initialize database after server start:', e);
    // Shut down gracefully if DB init fails
    await gracefulShutdown('DB_INIT_FAILURE');
  }
});

// Handle server "error" event (e.g., EADDRINUSE)
server.on('error', (err) => {
  console.error('Server startup error:', err);
});

// Graceful shutdown
const gracefulShutdown = async (signal) => {
  console.log(`\n${signal} received, shutting down gracefully`);
  
  // Close HTTP server
  server.close(async () => {
    console.log('HTTP server closed');
    
    // Close database connections
    try {
      await closeDB();
      console.log('Database connections closed');
      process.exit(0);
    } catch (error) {
      console.error('Error closing database connections:', error);
      process.exit(1);
    }
  });
  
  // Force close after 10 seconds
  setTimeout(() => {
    console.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  gracefulShutdown('UNCAUGHT_EXCEPTION');
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  gracefulShutdown('UNHANDLED_REJECTION');
});

module.exports = app;
