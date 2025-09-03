const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function quickTest() {
  console.log('🔍 Quick Backend Test...\n');

  // Test 1: Health check
  try {
    console.log('Testing health endpoint...');
    const response = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Backend is running!');
    console.log('Status:', response.data.status);
    console.log('Database:', response.data.database.status);
  } catch (error) {
    console.error('❌ Backend is not running or not accessible');
    console.error('Error:', error.message);
    if (error.code === 'ECONNREFUSED') {
      console.log('💡 Tip: Make sure the backend server is started with "npm start"');
    }
    return;
  }

  // Test 2: Login to get a token
  try {
    console.log('\nTesting login...');
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'viyanfarooq0@gmail.com', // Using the email from your database
      password: 'yourpassword' // You'll need to provide the correct password
    });
    
    const token = loginResponse.data.token;
    console.log('✅ Login successful!');
    console.log('Token preview:', token.substring(0, 50) + '...');
    
    // Test 3: Test favorites endpoints with real token
    console.log('\nTesting favorite status...');
    const statusResponse = await axios.get(`${BASE_URL}/api/recipes/52874/favorite-status`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('✅ Favorite status endpoint working:', statusResponse.data);
    
  } catch (error) {
    console.error('❌ Login/favorites test failed:', error.response?.data?.message || error.message);
  }
}

quickTest();


