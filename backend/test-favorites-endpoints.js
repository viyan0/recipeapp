const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// Test token - you'll need to replace this with a real token from login
const TEST_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwiaWF0IjoxNzU'; // Truncated from your terminal output

async function testFavoritesEndpoints() {
  console.log('🧪 Testing Favorites Endpoints...\n');

  try {
    // Test 1: Health check
    console.log('1️⃣  Testing health endpoint...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health check passed:', healthResponse.data.status);
  } catch (error) {
    console.error('❌ Health check failed:', error.message);
    return;
  }

  try {
    // Test 2: Check favorite status for a recipe
    console.log('\n2️⃣  Testing favorite status check...');
    const recipeId = '52874'; // A sample recipe ID from TheMealDB
    const statusResponse = await axios.get(`${BASE_URL}/api/recipes/${recipeId}/favorite-status`, {
      headers: {
        'Authorization': `Bearer ${TEST_TOKEN}`,
        'Content-Type': 'application/json',
      }
    });
    console.log('✅ Favorite status check passed:', statusResponse.data);
  } catch (error) {
    console.error('❌ Favorite status check failed:', error.response?.data || error.message);
  }

  try {
    // Test 3: Add a recipe to favorites
    console.log('\n3️⃣  Testing add to favorites...');
    const recipeId = '52874';
    const addResponse = await axios.post(`${BASE_URL}/api/recipes/${recipeId}/favorite`, {
      recipe_title: 'Test Recipe',
      recipe_image: 'https://example.com/image.jpg',
      recipe_category: 'Test Category',
      recipe_area: 'Test Area'
    }, {
      headers: {
        'Authorization': `Bearer ${TEST_TOKEN}`,
        'Content-Type': 'application/json',
      }
    });
    console.log('✅ Add to favorites passed:', addResponse.data);
  } catch (error) {
    console.error('❌ Add to favorites failed:', error.response?.data || error.message);
  }

  try {
    // Test 4: Get favorites list
    console.log('\n4️⃣  Testing get favorites list...');
    const favoritesResponse = await axios.get(`${BASE_URL}/api/recipes/favourites`, {
      headers: {
        'Authorization': `Bearer ${TEST_TOKEN}`,
        'Content-Type': 'application/json',
      }
    });
    console.log('✅ Get favorites list passed:', favoritesResponse.data);
  } catch (error) {
    console.error('❌ Get favorites list failed:', error.response?.data || error.message);
  }

  console.log('\n🏁 Test completed!');
}

// Run the test
testFavoritesEndpoints();


