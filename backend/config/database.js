require('dotenv').config({ path: './config.env' });
const { Pool } = require('pg');

// Parse the DATABASE_URL to extract connection parameters
const parseDatabaseUrl = (url) => {
  try {
    const urlObj = new URL(url);
    return {
      user: urlObj.username,
      password: urlObj.password,
      host: urlObj.hostname,
      port: urlObj.port || 5432,
      database: urlObj.pathname.slice(1),
      ssl: {
        rejectUnauthorized: false,
        require: true
      },
      connectionTimeoutMillis: 10000,
      idleTimeoutMillis: 30000,
      max: 20,
      min: 2,
      acquireTimeoutMillis: 30000,
      createTimeoutMillis: 30000,
      destroyTimeoutMillis: 5000,
      reapIntervalMillis: 1000,
      createRetryIntervalMillis: 200
    };
  } catch (error) {
    console.error('Error parsing DATABASE_URL:', error);
    throw new Error('Invalid DATABASE_URL format');
  }
};

// Create connection pool
const pool = new Pool(parseDatabaseUrl(process.env.DATABASE_URL));

// Pool error handling
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Pool connect event
pool.on('connect', (client) => {
  console.log('New client connected to database');
});

// Test database connection
const testConnection = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Database connected successfully');
    
    // Test a simple query
    const result = await client.query('SELECT NOW() as current_time');
    console.log(`📅 Database time: ${result.rows[0].current_time}`);
    
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
};

// Initialize database tables
const initTables = async () => {
  try {
    const client = await pool.connect();
    
    // Create users table with dietary preference
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100),
        avatar_url TEXT,
        is_vegetarian BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create recipes table
    await client.query(`
      CREATE TABLE IF NOT EXISTS recipes (
        id SERIAL PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        description TEXT,
        ingredients JSONB NOT NULL,
        instructions JSONB NOT NULL,
        cooking_time_minutes INTEGER NOT NULL,
        difficulty_level VARCHAR(20) DEFAULT 'medium',
        servings INTEGER DEFAULT 2,
        is_vegetarian BOOLEAN DEFAULT false,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create search_history table
    await client.query(`
      CREATE TABLE IF NOT EXISTS search_history (
        id SERIAL PRIMARY KEY,
        user_id INTEGER,
        search_query TEXT NOT NULL,
        search_filters JSONB,
        results_count INTEGER,
        search_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    `);

    // Create favourites table
    await client.query(`
      CREATE TABLE IF NOT EXISTS favourites (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        rating INTEGER CHECK (rating >= 1 AND rating <= 5),
        UNIQUE(user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )
    `);

    // Create indexes for better performance
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
      CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON search_history(user_id);
      CREATE INDEX IF NOT EXISTS idx_search_history_timestamp ON search_history(search_timestamp);
      CREATE INDEX IF NOT EXISTS idx_favourites_user_id ON favourites(user_id);
      CREATE INDEX IF NOT EXISTS idx_favourites_recipe_id ON favourites(recipe_id);
    `);

    console.log('✅ Database tables initialized successfully');
    client.release();
  } catch (error) {
    console.error('❌ Error initializing tables:', error);
    throw error;
  }
};

// Get database statistics
const getDatabaseStats = async () => {
  try {
    const client = await pool.connect();
    
    const stats = await client.query(`
      SELECT 
        (SELECT COUNT(*) FROM users) as user_count,
        (SELECT COUNT(*) FROM recipes) as recipe_count,
        (SELECT COUNT(*) FROM search_history) as search_count,
        (SELECT COUNT(*) FROM favourites) as favourite_count
    `);
    
    client.release();
    return stats.rows[0];
  } catch (error) {
    console.error('Error getting database stats:', error);
    return null;
  }
};

// Health check for database
const healthCheck = async () => {
  try {
    const client = await pool.connect();
    await client.query('SELECT 1');
    client.release();
    return { status: 'healthy', timestamp: new Date().toISOString() };
  } catch (error) {
    return { 
      status: 'unhealthy', 
      error: error.message, 
      timestamp: new Date().toISOString() 
    };
  }
};

// Connect to database and initialize
const connectDB = async () => {
  try {
    await testConnection();
    await initTables();
    
    // Log database statistics
    const stats = await getDatabaseStats();
    if (stats) {
      console.log('📊 Database statistics:', stats);
    }
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    process.exit(1);
  }
};

// Graceful shutdown for database
const closeDB = async () => {
  try {
    await pool.end();
    console.log('✅ Database connections closed');
  } catch (error) {
    console.error('❌ Error closing database connections:', error);
  }
};

module.exports = {
  pool,
  connectDB,
  closeDB,
  testConnection,
  healthCheck,
  getDatabaseStats
};
