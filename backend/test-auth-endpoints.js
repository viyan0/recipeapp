const axios = require('axios');

const BASE_URL = 'http://localhost:3001';

async function testAuthEndpoints() {
  console.log('🧪 Testing Auth Endpoints...\n');

  try {
    // Test signup
    console.log('1. Testing Signup...');
    const signupData = {
      email: 'test@example.com',
      username: 'testuser',
      password: 'password123',
      isVegetarian: true
    };

    const signupResponse = await axios.post(`${BASE_URL}/api/auth/signup`, signupData, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    console.log('✅ Signup successful!');
    console.log('Status:', signupResponse.status);
    console.log('Response:', JSON.stringify(signupResponse.data, null, 2));
    console.log('');

    // Test login
    console.log('2. Testing Login...');
    const loginData = {
      email: 'test@example.com',
      password: 'password123'
    };

    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, loginData, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    console.log('✅ Login successful!');
    console.log('Status:', loginResponse.status);
    console.log('Response:', JSON.stringify(loginResponse.data, null, 2));
    console.log('');

    // Test invalid login
    console.log('3. Testing Invalid Login...');
    const invalidLoginData = {
      email: 'test@example.com',
      password: 'wrongpassword'
    };

    try {
      const invalidLoginResponse = await axios.post(`${BASE_URL}/api/auth/login`, invalidLoginData, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });
    } catch (error) {
      console.log('✅ Invalid login correctly rejected!');
      console.log('Status:', error.response.status);
      console.log('Response:', JSON.stringify(error.response.data, null, 2));
    }

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Response:', error.response.data);
    }
  }
}

// Run the test
testAuthEndpoints();
