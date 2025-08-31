require('dotenv').config({ path: './config.env' });
const { pool } = require('./config/database');

async function checkTables() {
  try {
    console.log('Checking database table structures...\n');
    
    // Check users table structure
    console.log('📋 Users table structure:');
    const usersStructure = await pool.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      ORDER BY ordinal_position
    `);
    
    usersStructure.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`);
    });
    
    console.log('\n📊 Users table data:');
    const usersData = await pool.query('SELECT * FROM users LIMIT 3');
    console.log('Sample users:', usersData.rows);
    
    // Check other tables
    console.log('\n📋 Recipes table structure:');
    const recipesStructure = await pool.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'recipes' 
      ORDER BY ordinal_position
    `);
    
    recipesStructure.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`);
    });
    
  } catch (error) {
    console.error('❌ Error checking tables:', error);
  } finally {
    await pool.end();
  }
}

checkTables();
