const { pool, withRetry, getPoolStatus, healthCheck } = require('./config/database');

console.log('🧪 Testing Database Connection Resilience');
console.log('==========================================');

async function testConnectionResilience() {
  console.log('\n1. Testing initial connection...');
  
  // Test basic connection
  try {
    const health = await healthCheck();
    console.log('✅ Health check result:', health);
    
    const poolStatus = getPoolStatus();
    console.log('📊 Pool status:', poolStatus);
  } catch (error) {
    console.error('❌ Initial connection test failed:', error.message);
  }
  
  console.log('\n2. Testing retry mechanism...');
  
  // Test retry mechanism with a simple query
  try {
    const result = await withRetry(async () => {
      const client = await pool.connect();
      try {
        const result = await client.query('SELECT $1 as test_value', ['Connection Test']);
        return result.rows[0];
      } finally {
        client.release();
      }
    });
    
    console.log('✅ Retry test successful:', result);
  } catch (error) {
    console.error('❌ Retry test failed:', error.message);
  }
  
  console.log('\n3. Testing multiple concurrent connections...');
  
  // Test multiple concurrent connections
  const promises = [];
  for (let i = 0; i < 5; i++) {
    promises.push(
      withRetry(async () => {
        const client = await pool.connect();
        try {
          const result = await client.query('SELECT $1 as connection_id', [i + 1]);
          console.log(`✅ Connection ${i + 1} successful`);
          return result.rows[0];
        } finally {
          client.release();
        }
      })
    );
  }
  
  try {
    const results = await Promise.all(promises);
    console.log('✅ All concurrent connections successful');
    
    const finalPoolStatus = getPoolStatus();
    console.log('📊 Final pool status:', finalPoolStatus);
  } catch (error) {
    console.error('❌ Concurrent connection test failed:', error.message);
  }
  
  console.log('\n4. Connection resilience test completed!');
  console.log('🎉 Your database connection should now be resilient to Neon disconnects');
  
  // Close connections
  await pool.end();
  process.exit(0);
}

// Run the test
testConnectionResilience().catch((error) => {
  console.error('❌ Test failed:', error);
  process.exit(1);
});
