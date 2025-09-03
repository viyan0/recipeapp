// Script to immediately delete all user accounts (no confirmation needed)
require('dotenv').config({ path: './config.env' });
const { pool } = require('./config/database');

async function deleteAllUsersNow() {
  try {
    console.log('🧹 Deleting all user accounts...\n');
    
    // Check current count
    const countResult = await pool.query('SELECT COUNT(*) FROM users');
    const userCount = parseInt(countResult.rows[0].count);
    console.log(`Found ${userCount} users to delete`);
    
    if (userCount === 0) {
      console.log('✅ No users to delete!');
      return;
    }
    
    // Delete related data first
    console.log('🔄 Deleting related data...');
    await pool.query('DELETE FROM favourites WHERE user_id IS NOT NULL');
    await pool.query('DELETE FROM search_history WHERE user_id IS NOT NULL');
    console.log('  ✅ Related data deleted');
    
    // Delete all users
    console.log('🗑️  Deleting all users...');
    const result = await pool.query('DELETE FROM users');
    console.log(`  ✅ Deleted ${result.rowCount} users`);
    
    // Reset sequences
    await pool.query('ALTER SEQUENCE users_id_seq RESTART WITH 1');
    await pool.query('ALTER SEQUENCE search_history_id_seq RESTART WITH 1');
    await pool.query('ALTER SEQUENCE favourites_id_seq RESTART WITH 1');
    console.log('  ✅ ID sequences reset');
    
    // Verify
    const finalCount = await pool.query('SELECT COUNT(*) FROM users');
    console.log(`\n🎉 Done! Users remaining: ${finalCount.rows[0].count}`);
    console.log('✅ All users deleted - you can now test fresh signups!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

deleteAllUsersNow();
