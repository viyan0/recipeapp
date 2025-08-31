require('dotenv').config({ path: './config.env' });
const { Pool } = require('pg');

console.log('Testing database connection...');
console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'Set' : 'Not set');

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
      max: 20
    };
  } catch (error) {
    console.error('Error parsing DATABASE_URL:', error);
    throw new Error('Invalid DATABASE_URL format');
  }
};

async function testDB() {
  try {
    const config = parseDatabaseUrl(process.env.DATABASE_URL);
    console.log('Connection config:', {
      user: config.user,
      host: config.host,
      port: config.port,
      database: config.database,
      ssl: config.ssl
    });
    
    const pool = new Pool(config);
    
    console.log('Attempting to connect...');
    const client = await pool.connect();
    console.log('✅ Database connected successfully!');
    
    // Test a simple query
    const result = await client.query('SELECT NOW() as current_time');
    console.log('Query test result:', result.rows[0]);
    
    client.release();
    await pool.end();
    
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    console.error('Full error:', error);
  }
}

testDB();
