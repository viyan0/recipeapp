const { pool } = require('./config/database');
const fs = require('fs');
const path = require('path');

async function migrateFavoritesTable() {
  const client = await pool.connect();
  
  try {
    console.log('🔄 Starting favorites table migration...');
    
    // Read the SQL migration file
    const migrationSQL = fs.readFileSync(path.join(__dirname, 'migrate-favorites-table.sql'), 'utf8');
    
    // Execute the migration
    await client.query(migrationSQL);
    
    console.log('✅ Favorites table migration completed successfully!');
    
    // Verify the new structure
    const structureQuery = `
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'favourites' 
      ORDER BY ordinal_position;
    `;
    
    const structure = await client.query(structureQuery);
    console.log('\n📋 New favourites table structure:');
    structure.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`);
    });
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

migrateFavoritesTable().catch(console.error);


