const http = require('http');

// Test the health endpoint
const testHealth = () => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 3001,
      path: '/health',
      method: 'GET',
      timeout: 5000
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({
            status: res.statusCode,
            data: jsonData,
            success: res.statusCode === 200
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: data,
            success: res.statusCode === 200
          });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    req.end();
  });
};

// Test the auth endpoint
const testAuth = () => {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: 3001,
      path: '/api/auth/signup',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 5000
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({
            status: res.statusCode,
            data: jsonData,
            success: res.statusCode < 400
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: data,
            success: res.statusCode < 400
          });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    // Send test data
    req.write(JSON.stringify({
      email: 'test@example.com',
      username: 'testuser',
      password: 'testpass123',
      isVegetarian: false
    }));
    req.end();
  });
};

// Run tests
const runTests = async () => {
  console.log('🧪 Testing backend server...\n');

  try {
    console.log('1. Testing health endpoint...');
    const healthResult = await testHealth();
    console.log(`   Status: ${healthResult.status}`);
    console.log(`   Success: ${healthResult.success ? '✅' : '❌'}`);
    if (healthResult.success) {
      console.log(`   Response: ${JSON.stringify(healthResult.data, null, 2)}`);
    }
    console.log('');

    console.log('2. Testing auth endpoint...');
    const authResult = await testAuth();
    console.log(`   Status: ${authResult.status}`);
    console.log(`   Success: ${authResult.success ? '✅' : '❌'}`);
    if (authResult.data) {
      console.log(`   Response: ${JSON.stringify(authResult.data, null, 2)}`);
    }
    console.log('');

    if (healthResult.success) {
      console.log('🎉 Backend server is running and accessible!');
    } else {
      console.log('❌ Backend server is not responding properly.');
    }

  } catch (error) {
    console.log(`❌ Error testing backend: ${error.message}`);
    console.log('\n💡 Make sure the backend server is running with: npm run dev');
  }
};

runTests();
