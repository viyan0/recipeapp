const axios = require('axios');

const BASE_URL = 'http://localhost:3001';

// Test health endpoint
async function testHealth() {
  try {
    console.log('🏥 Testing health endpoint...');
    const response = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health check passed:', response.data);
    return true;
  } catch (error) {
    console.error('❌ Health check failed:', error.message);
    return false;
  }
}

// Test signup endpoint
async function testSignup() {
  try {
    console.log('📝 Testing signup endpoint...');
    const signupData = {
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      isVegetarian: true
    };
    
    const response = await axios.post(`${BASE_URL}/api/auth/signup`, signupData);
    console.log('✅ Signup test passed:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ Signup test failed:', error.response?.data || error.message);
    return null;
  }
}

// Test login endpoint
async function testLogin() {
  try {
    console.log('🔑 Testing login endpoint...');
    const loginData = {
      email: 'test@example.com',
      password: 'password123'
    };
    
    const response = await axios.post(`${BASE_URL}/api/auth/login`, loginData);
    console.log('✅ Login test passed:', response.data);
    return response.data;
  } catch (error) {
    console.error('❌ Login test failed:', error.response?.data || error.message);
    return null;
  }
}

// Test recipe search endpoint
async function testRecipeSearch() {
  try {
    console.log('🔍 Testing recipe search endpoint...');
    const searchData = {
      ingredients: ['onion', 'tomato'],
      maxTimeMinutes: 30,
      isVegetarian: true
    };
    
    const response = await axios.post(`${BASE_URL}/api/recipes/search`, searchData);
    console.log('✅ Recipe search test passed. Found', response.data.recipes?.length || 0, 'recipes');
    return true;
  } catch (error) {
    console.error('❌ Recipe search test failed:', error.response?.data || error.message);
    return false;
  }
}

// Main test function
async function runTests() {
  console.log('🚀 Starting backend connection tests...\n');
  
  // Test health endpoint
  const healthOk = await testHealth();
  if (!healthOk) {
    console.log('\n❌ Health check failed. Backend might not be running.');
    return;
  }
  
  console.log('\n' + '='.repeat(50) + '\n');
  
  // Test signup
  const user = await testSignup();
  
  console.log('\n' + '='.repeat(50) + '\n');
  
  // Test login
  const loginResult = await testLogin();
  
  console.log('\n' + '='.repeat(50) + '\n');
  
  // Test recipe search
  const searchOk = await testRecipeSearch();
  
  console.log('\n' + '='.repeat(50) + '\n');
  
  // Summary
  console.log('📊 Test Summary:');
  console.log(`Health Check: ${healthOk ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`Signup: ${user ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`Login: ${loginResult ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`Recipe Search: ${searchOk ? '✅ PASS' : '❌ FAIL'}`);
  
  if (healthOk && user && loginResult && searchOk) {
    console.log('\n🎉 All tests passed! Backend is working correctly.');
    console.log('\n📱 Your Flutter app should now be able to connect to the backend.');
  } else {
    console.log('\n⚠️  Some tests failed. Check the backend logs for more details.');
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests().catch(console.error);
}

module.exports = { runTests };
