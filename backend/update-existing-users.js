// Script to update existing users with email verification fields
require('dotenv').config({ path: './config.env' });
const { pool } = require('./config/database');

async function updateExistingUsers() {
  try {
    console.log('🔄 Updating existing users for email verification...\n');
    
    // First, let's see how many users we have
    const countResult = await pool.query('SELECT COUNT(*) FROM users');
    const userCount = parseInt(countResult.rows[0].count);
    
    console.log(`Found ${userCount} existing users`);
    
    if (userCount === 0) {
      console.log('No existing users to update.');
      return;
    }

    // For existing users, we'll mark them as verified so they can continue using the app
    // In production, you might want to handle this differently
    const updateResult = await pool.query(`
      UPDATE users 
      SET email_verified = true 
      WHERE email_verified IS NULL OR email_verified = false
    `);
    
    console.log(`✅ Updated ${updateResult.rowCount} users to verified status`);
    
    // Show updated user status
    const verifiedUsers = await pool.query(`
      SELECT username, email, email_verified, created_at 
      FROM users 
      ORDER BY created_at DESC 
      LIMIT 5
    `);
    
    console.log('\n📊 Sample user verification status:');
    verifiedUsers.rows.forEach(user => {
      console.log(`  ${user.username} (${user.email}): ${user.email_verified ? '✅ Verified' : '❌ Not Verified'}`);
    });
    
    console.log('\n🎉 All existing users have been updated!');
    console.log('📝 Note: Existing users are marked as verified for continuity.');
    console.log('🆕 New signups will require email verification.');
    
  } catch (error) {
    console.error('❌ Error updating users:', error);
  } finally {
    await pool.end();
  }
}

// Ask for confirmation
console.log('This script will update existing users to be email verified.');
console.log('This ensures existing users can continue using the app while new users must verify their email.');
console.log('\nPress Enter to continue or Ctrl+C to cancel...');

// Simple way to wait for user input
process.stdin.once('data', () => {
  updateExistingUsers();
});
