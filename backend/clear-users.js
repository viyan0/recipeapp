// Script to safely delete all user accounts from the database
require('dotenv').config({ path: './config.env' });
const { pool } = require('./config/database');

async function clearAllUsers() {
  try {
    console.log('🧹 Clearing all user accounts from database...\n');
    
    // First, let's see what we have
    const countResult = await pool.query('SELECT COUNT(*) FROM users');
    const userCount = parseInt(countResult.rows[0].count);
    
    console.log(`Found ${userCount} existing users`);
    
    if (userCount === 0) {
      console.log('✅ No users to delete - database is already clean!');
      return;
    }

    // Show existing users before deletion
    const existingUsers = await pool.query(`
      SELECT username, email, created_at 
      FROM users 
      ORDER BY created_at DESC
    `);
    
    console.log('\n📊 Current users in database:');
    existingUsers.rows.forEach((user, index) => {
      console.log(`  ${index + 1}. ${user.username} (${user.email}) - Created: ${user.created_at.toDateString()}`);
    });
    
    console.log('\n⚠️  WARNING: This will permanently delete ALL user accounts!');
    console.log('This action cannot be undone.');
    
    // Delete related data first (to maintain referential integrity)
    console.log('\n🔄 Deleting related data...');
    
    // Delete favourites first
    const deleteFavourites = await pool.query('DELETE FROM favourites WHERE user_id IS NOT NULL');
    console.log(`  ✅ Deleted ${deleteFavourites.rowCount} favourite records`);
    
    // Delete search history
    const deleteSearchHistory = await pool.query('DELETE FROM search_history WHERE user_id IS NOT NULL');
    console.log(`  ✅ Deleted ${deleteSearchHistory.rowCount} search history records`);
    
    // Delete user-created recipes (if any)
    const deleteRecipes = await pool.query('DELETE FROM recipes WHERE id IN (SELECT id FROM recipes)');
    console.log(`  ✅ Deleted ${deleteRecipes.rowCount} recipe records`);
    
    // Finally, delete all users
    console.log('\n🗑️  Deleting all user accounts...');
    const deleteUsers = await pool.query('DELETE FROM users');
    console.log(`  ✅ Deleted ${deleteUsers.rowCount} user accounts`);
    
    // Reset auto-increment sequences
    console.log('\n🔄 Resetting ID sequences...');
    await pool.query('ALTER SEQUENCE users_id_seq RESTART WITH 1');
    await pool.query('ALTER SEQUENCE recipes_id_seq RESTART WITH 1');
    await pool.query('ALTER SEQUENCE search_history_id_seq RESTART WITH 1');
    await pool.query('ALTER SEQUENCE favourites_id_seq RESTART WITH 1');
    console.log('  ✅ ID sequences reset');
    
    // Verify cleanup
    const finalCount = await pool.query('SELECT COUNT(*) FROM users');
    const finalUserCount = parseInt(finalCount.rows[0].count);
    
    console.log('\n🎉 Database cleanup complete!');
    console.log(`   Users remaining: ${finalUserCount}`);
    console.log('   ✅ All user accounts deleted');
    console.log('   ✅ All related data cleaned up');
    console.log('   ✅ ID sequences reset');
    console.log('\n🆕 You can now test fresh signups with email verification!');
    
  } catch (error) {
    console.error('❌ Error clearing users:', error);
    console.log('\n💡 If you get foreign key errors, make sure no other tables reference users.');
  } finally {
    await pool.end();
  }
}

// Confirmation prompt
console.log('🚨 USER ACCOUNT DELETION SCRIPT 🚨');
console.log('=====================================');
console.log('This script will PERMANENTLY DELETE ALL user accounts and related data.');
console.log('This includes:');
console.log('  - All user profiles');
console.log('  - All favourites');
console.log('  - All search history');
console.log('  - All user-created recipes');
console.log('');
console.log('⚠️  This action CANNOT be undone!');
console.log('');
console.log('Are you sure you want to continue?');
console.log('Press Enter to CONFIRM deletion or Ctrl+C to cancel...');

// Wait for user confirmation
process.stdin.once('data', () => {
  clearAllUsers();
});
