const { pool } = require('./config/database');

async function checkFavoritesTable() {
  try {
    console.log('🔍 Checking favorites table...');
    
    // Check if favorites table exists
    const tableExistsQuery = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'favourites'
      );
    `;
    
    const tableExists = await pool.query(tableExistsQuery);
    console.log('Table exists:', tableExists.rows[0].exists);
    
    if (tableExists.rows[0].exists) {
      // Get table structure
      const structureQuery = `
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = 'favourites' 
        ORDER BY ordinal_position;
      `;
      
      const structure = await pool.query(structureQuery);
      console.log('\n📋 Favourites table structure:');
      structure.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type} (nullable: ${col.is_nullable})`);
      });
      
      // Get sample data
      const dataQuery = 'SELECT * FROM favourites LIMIT 5';
      const data = await pool.query(dataQuery);
      console.log('\n📊 Favourites table data:');
      console.log('Row count:', data.rowCount);
      if (data.rows.length > 0) {
        console.log('Sample data:', JSON.stringify(data.rows, null, 2));
      } else {
        console.log('No data in table');
      }
    } else {
      console.log('❌ Favourites table does not exist!');
    }
    
  } catch (error) {
    console.error('❌ Error checking favorites table:', error);
  } finally {
    await pool.end();
  }
}

checkFavoritesTable();


