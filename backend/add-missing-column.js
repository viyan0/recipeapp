const { pool } = require('./config/database');

async function addMissingColumn() {
  const client = await pool.connect();
  
  try {
    console.log('🔄 Adding missing recipe_area column...');
    
    // Add the missing recipe_area column
    await client.query(`
      ALTER TABLE favourites 
      ADD COLUMN IF NOT EXISTS recipe_area VARCHAR(100);
    `);
    
    console.log('✅ recipe_area column added successfully!');
    
    // Verify the updated structure
    const structureQuery = `
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'favourites' 
      ORDER BY ordinal_position;
    `;
    
    const structure = await client.query(structureQuery);
    console.log('\n📋 Updated favourites table structure:');
    structure.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`);
    });
    
  } catch (error) {
    console.error('❌ Error adding column:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

addMissingColumn().catch(console.error);



