const axios = require('axios');
const { pool } = require('./config/database');

const BASE_URL = 'http://localhost:3001';
let authToken = null;
let testUserId = null;

// Test utilities
const log = (message, type = 'info') => {
  const timestamp = new Date().toISOString();
  const emoji = type === 'success' ? '✅' : type === 'error' ? '❌' : type === 'warning' ? '⚠️' : 'ℹ️';
  console.log(`${emoji} [${timestamp}] ${message}`);
};

const testEndpoint = async (method, endpoint, data = null, headers = {}) => {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    if (data && method !== 'GET') {
      config.data = data;
    }

    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data || error.message, 
      status: error.response?.status || 500 
    };
  }
};

// Test functions
const testHealthCheck = async () => {
  log('Testing health check endpoint...');
  const result = await testEndpoint('GET', '/health');
  
  if (result.success && result.status === 200) {
    log('Health check passed', 'success');
    return true;
  } else {
    log(`Health check failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testDatabaseConnection = async () => {
  log('Testing database connection...');
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time');
    client.release();
    
    log(`Database connection successful: ${result.rows[0].current_time}`, 'success');
    return true;
  } catch (error) {
    log(`Database connection failed: ${error.message}`, 'error');
    return false;
  }
};

const testUserSignup = async () => {
  log('Testing user signup...');
  const testUser = {
    username: `testuser_${Date.now()}`,
    email: `test_${Date.now()}@example.com`,
    password: 'testpassword123',
    isVegetarian: false
  };

  const result = await testEndpoint('POST', '/api/auth/signup', testUser);
  
  if (result.success && result.status === 201) {
    log('User signup successful', 'success');
    authToken = result.data.token;
    testUserId = result.data.data.id;
    return true;
  } else {
    log(`User signup failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testUserLogin = async () => {
  log('Testing user login...');
  const loginData = {
    email: `test_${Date.now() - 1000}@example.com`, // Use email from signup
    password: 'testpassword123'
  };

  const result = await testEndpoint('POST', '/api/auth/login', loginData);
  
  if (result.success && result.status === 200) {
    log('User login successful', 'success');
    authToken = result.data.token;
    return true;
  } else {
    log(`User login failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testRecipeSearch = async () => {
  log('Testing recipe search...');
  const searchData = {
    ingredients: ['chicken', 'rice'],
    maxTimeMinutes: 60,
    isVegetarian: false
  };

  const result = await testEndpoint('POST', '/api/recipes/search', searchData);
  
  if (result.success && result.status === 200) {
    log(`Recipe search successful: Found ${result.data.data.recipes.length} recipes`, 'success');
    return true;
  } else {
    log(`Recipe search failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testRecipeSearchByName = async () => {
  log('Testing recipe search by name...');
  const result = await testEndpoint('GET', '/api/recipes/search-recipes?query=pasta');
  
  if (result.success && result.status === 200) {
    log(`Recipe search by name successful: Found ${result.data.data.recipes.length} recipes`, 'success');
    return true;
  } else {
    log(`Recipe search by name failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testUserProfile = async () => {
  if (!authToken) {
    log('Skipping user profile test - no auth token', 'warning');
    return false;
  }

  log('Testing user profile endpoint...');
  const result = await testEndpoint('GET', '/api/users/profile', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (result.success && result.status === 200) {
    log('User profile retrieval successful', 'success');
    return true;
  } else {
    log(`User profile retrieval failed: ${JSON.stringify(result.error)}`, 'error');
    return false;
  }
};

const testFavorites = async () => {
  if (!authToken) {
    log('Skipping favorites test - no auth token', 'warning');
    return false;
  }

  log('Testing favorites functionality...');
  
  // Add to favorites
  const addResult = await testEndpoint('POST', '/api/recipes/123/favorite', {
    notes: 'Test favorite',
    rating: 5
  }, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (addResult.success && addResult.status === 200) {
    log('Add to favorites successful', 'success');
  } else {
    log(`Add to favorites failed: ${JSON.stringify(addResult.error)}`, 'error');
    return false;
  }

  // Get favorites
  const getResult = await testEndpoint('GET', '/api/recipes/favourites', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (getResult.success && getResult.status === 200) {
    log('Get favorites successful', 'success');
    return true;
  } else {
    log(`Get favorites failed: ${JSON.stringify(getResult.error)}`, 'error');
    return false;
  }
};

const testSearchHistory = async () => {
  if (!authToken) {
    log('Skipping search history test - no auth token', 'warning');
    return false;
  }

  log('Testing search history...');
  
  // Save search
  const saveResult = await testEndpoint('POST', '/api/recipes/search-history', {
    search_query: 'test search query',
    results_count: 5
  }, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (saveResult.success && saveResult.status === 201) {
    log('Save search history successful', 'success');
  } else {
    log(`Save search history failed: ${JSON.stringify(saveResult.error)}`, 'error');
    return false;
  }

  // Get search history
  const getResult = await testEndpoint('GET', '/api/recipes/search/history', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (getResult.success && getResult.status === 200) {
    log('Get search history successful', 'success');
    return true;
  } else {
    log(`Get search history failed: ${JSON.stringify(getResult.error)}`, 'error');
    return false;
  }
};

const testInvalidEndpoints = async () => {
  log('Testing invalid endpoints...');
  
  const result = await testEndpoint('GET', '/api/nonexistent');
  
  if (!result.success && result.status === 404) {
    log('404 handling working correctly', 'success');
    return true;
  } else {
    log('404 handling not working correctly', 'error');
    return false;
  }
};

const testRateLimiting = async () => {
  log('Testing rate limiting...');
  
  const promises = [];
  for (let i = 0; i < 105; i++) {
    promises.push(testEndpoint('GET', '/health'));
  }
  
  try {
    const results = await Promise.all(promises);
    const rateLimited = results.some(r => r.status === 429);
    
    if (rateLimited) {
      log('Rate limiting working correctly', 'success');
      return true;
    } else {
      log('Rate limiting not working correctly', 'warning');
      return false;
    }
  } catch (error) {
    log(`Rate limiting test failed: ${error.message}`, 'error');
    return false;
  }
};

// Main test runner
const runTests = async () => {
  log('🚀 Starting backend tests...', 'info');
  log('', 'info');
  
  const tests = [
    { name: 'Health Check', fn: testHealthCheck },
    { name: 'Database Connection', fn: testDatabaseConnection },
    { name: 'User Signup', fn: testUserSignup },
    { name: 'User Login', fn: testUserLogin },
    { name: 'Recipe Search', fn: testRecipeSearch },
    { name: 'Recipe Search by Name', fn: testRecipeSearchByName },
    { name: 'User Profile', fn: testUserProfile },
    { name: 'Favorites', fn: testFavorites },
    { name: 'Search History', fn: testSearchHistory },
    { name: 'Invalid Endpoints', fn: testInvalidEndpoints },
    { name: 'Rate Limiting', fn: testRateLimiting }
  ];

  let passed = 0;
  let failed = 0;
  let skipped = 0;

  for (const test of tests) {
    try {
      const result = await test.fn();
      if (result === true) {
        passed++;
      } else if (result === false) {
        failed++;
      } else {
        skipped++;
      }
    } catch (error) {
      log(`Test ${test.name} crashed: ${error.message}`, 'error');
      failed++;
    }
    
    // Small delay between tests
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  log('', 'info');
  log('📊 Test Results:', 'info');
  log(`✅ Passed: ${passed}`, 'success');
  log(`❌ Failed: ${failed}`, failed > 0 ? 'error' : 'success');
  log(`⚠️ Skipped: ${skipped}`, skipped > 0 ? 'warning' : 'success');
  
  if (failed === 0) {
    log('🎉 All tests passed!', 'success');
  } else {
    log('💥 Some tests failed!', 'error');
  }

  // Cleanup
  if (testUserId) {
    try {
      const client = await pool.connect();
      await client.query('DELETE FROM search_history WHERE user_id = $1', [testUserId]);
      await client.query('DELETE FROM favourites WHERE user_id = $1', [testUserId]);
      await client.query('DELETE FROM users WHERE id = $1', [testUserId]);
      client.release();
      log('Test data cleaned up', 'success');
    } catch (error) {
      log(`Cleanup failed: ${error.message}`, 'warning');
    }
  }

  process.exit(failed === 0 ? 0 : 1);
};

// Run tests if this file is executed directly
if (require.main === module) {
  runTests().catch(error => {
    log(`Test runner crashed: ${error.message}`, 'error');
    process.exit(1);
  });
}

module.exports = {
  runTests,
  testEndpoint,
  log
};
