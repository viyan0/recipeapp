const express = require('express');
const { body, validationResult } = require('express-validator');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { pool } = require('../config/database');
const axios = require('axios');

// @route   POST /api/recipes/search
// @desc    Search recipes by ingredients and time constraints
// @access  Public
router.post('/search', [
  body('ingredients')
    .isArray({ min: 1 })
    .withMessage('At least one ingredient is required'),
  body('ingredients.*')
    .isString()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Each ingredient must be a string between 1 and 50 characters'),
  body('maxTimeMinutes')
    .isInt({ min: 1, max: 1440 })
    .withMessage('Max time must be between 1 and 1440 minutes'),
  body('isVegetarian')
    .optional()
    .isBoolean()
    .withMessage('isVegetarian must be a boolean value'),
  body('preferences')
    .optional()
    .isArray()
    .withMessage('Preferences must be an array'),
  body('requiredIngredients')
    .optional()
    .isArray()
    .withMessage('Required ingredients must be an array')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { ingredients, maxTimeMinutes, isVegetarian, preferences = [], requiredIngredients = [] } = req.body;

    // Improved search strategy: try multiple ingredients to get better results
    let allMeals = [];
    let searchedIngredients = [];
    
    // Try searching with up to 3 ingredients to get more comprehensive results
    const searchLimit = Math.min(3, ingredients.length);
    
    for (let i = 0; i < searchLimit; i++) {
      const ingredient = ingredients[i];
      searchedIngredients.push(ingredient);
      
      console.log(`Searching TheMealDB for: "${ingredient}"`);
      
      const apiUrl = `https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(ingredient)}`;
      
      try {
        const response = await axios.get(apiUrl, {
          timeout: 10000,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'RecipeApp/1.0'
          }
        });

        if (response.status === 200 && response.data.meals) {
          console.log(`Found ${response.data.meals.length} meals for "${ingredient}"`);
          allMeals.push(...response.data.meals);
        }
      } catch (searchError) {
        console.log(`Search failed for "${ingredient}":`, searchError.message);
        // Continue with other ingredients even if one fails
      }
    }
    
    // Remove duplicates based on meal ID
    const uniqueMeals = allMeals.reduce((unique, meal) => {
      if (!unique.find(m => m.idMeal === meal.idMeal)) {
        unique.push(meal);
      }
      return unique;
    }, []);
    
    console.log(`Total unique meals found: ${uniqueMeals.length}`);
    
    if (uniqueMeals.length === 0) {
      return res.json({
        status: 'success',
        message: 'No recipes found',
        data: {
          recipes: [],
          totalResults: 0
        }
      });
    }

    // Process and filter recipes based on constraints
    let recipes = uniqueMeals.map(meal => {
      // Extract ingredients
      const recipeIngredients = [];
      for (let i = 1; i <= 20; i++) {
        const ingredient = meal[`strIngredient${i}`];
        if (ingredient && ingredient.trim()) {
          recipeIngredients.push(ingredient.trim().toLowerCase());
        }
      }

      // Estimate cooking time (TheMealDB doesn't provide this, so we'll estimate)
      const estimatedTime = Math.min(45, Math.max(15, recipeIngredients.length * 3));

      // Calculate preference and required ingredient matches
      const matchingPreferences = preferences.filter(userIng => 
        recipeIngredients.some(recipeIng => 
          recipeIng.includes(userIng.toLowerCase()) || userIng.toLowerCase().includes(recipeIng)
        )
      );
      
      const matchingRequired = requiredIngredients.filter(userIng => 
        recipeIngredients.some(recipeIng => 
          recipeIng.includes(userIng.toLowerCase()) || userIng.toLowerCase().includes(recipeIng)
        )
      );
      
      // Combined scoring: required ingredients get double weight
      const preferenceScore = matchingPreferences.length;
      const requiredScore = matchingRequired.length * 2;
      const totalScore = preferenceScore + requiredScore;
      
      // Calculate match percentage based on all ingredients
      const totalIngredients = preferences.length + requiredIngredients.length;
      const matchPercentage = totalIngredients > 0 ? Math.round(((matchingPreferences.length + matchingRequired.length) / totalIngredients) * 100) : 0;

      return {
        id: meal.idMeal,
        title: meal.strMeal,
        cookingTime: estimatedTime,
        ingredients: recipeIngredients,
        image: meal.strMealThumb,
        category: meal.strCategory,
        area: meal.strArea,
        isVegetarian: !recipeIngredients.some(ing => 
          ['chicken', 'beef', 'pork', 'lamb', 'fish', 'shrimp', 'bacon', 'ham'].includes(ing)
        ),
        matchScore: matchingPreferences.length + matchingRequired.length,
        matchPercentage: matchPercentage,
        totalScore: totalScore,
        preferenceMatches: matchingPreferences.length,
        requiredMatches: matchingRequired.length,
        matchingIngredients: [...matchingPreferences, ...matchingRequired]
      };
    });

    // Filter logic: if there are required ingredients, prioritize recipes that have them
    if (requiredIngredients.length > 0) {
      // First, filter to recipes that have at least some required ingredients OR preferences
      recipes = recipes.filter(recipe => recipe.matchScore > 0);
      console.log(`Recipes with any ingredient matches: ${recipes.length}`);
    } else {
      // If no required ingredients, just need at least one preference match
      recipes = recipes.filter(recipe => recipe.preferenceMatches > 0);
      console.log(`Recipes with preference matches: ${recipes.length}`);
    }

    // Apply dietary filters
    if (isVegetarian !== undefined) {
      recipes = recipes.filter(recipe => recipe.isVegetarian === isVegetarian);
    }

    // Filter by time (keep recipes that can be made within the time limit)
    recipes = recipes.filter(recipe => recipe.cookingTime <= maxTimeMinutes);

    // Sort by relevance: prioritize recipes with required ingredients, then preferences
    recipes.sort((a, b) => {
      // Primary sort: recipes with more required ingredient matches first
      if (a.requiredMatches !== b.requiredMatches) {
        return b.requiredMatches - a.requiredMatches;
      }
      
      // Secondary sort: total score (includes weighted required ingredients)
      if (a.totalScore !== b.totalScore) {
        return b.totalScore - a.totalScore;
      }
      
      // Tertiary sort: higher match percentage first
      if (a.matchPercentage !== b.matchPercentage) {
        return b.matchPercentage - a.matchPercentage;
      }
      
      // Quaternary sort: faster recipes first
      return a.cookingTime - b.cookingTime;
    });

    // Limit results to top 20
    recipes = recipes.slice(0, 20);

    console.log(`After filtering and processing: ${recipes.length} recipes`);

    res.json({
      status: 'success',
      message: 'Recipes found successfully',
      data: {
        recipes: recipes,
        totalResults: recipes.length
      }
    });

  } catch (error) {
    console.error('Recipe search error:', error);
    
    if (error.code === 'ECONNABORTED') {
      return res.status(408).json({
        status: 'error',
        message: 'Request timeout - API is taking too long to respond'
      });
    }
    
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      return res.status(503).json({
        status: 'error',
        message: 'Recipe API is currently unavailable'
      });
    }

    res.status(500).json({
      status: 'error',
      message: 'Server error while searching recipes'
    });
  }
});

// @route   GET /api/recipes/search-recipes
// @desc    Search recipes from TheMealDB by name
// @access  Public
router.get('/search-recipes', async (req, res) => {
  try {
    const { query } = req.query;
    
    // Validate query parameter
    if (!query || query.trim().length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Query parameter is required'
      });
    }

    // Clean and validate query
    const searchQuery = query.trim();
    if (searchQuery.length > 100) {
      return res.status(400).json({
        status: 'error',
        message: 'Query parameter too long (max 100 characters)'
      });
    }

    // Make request to TheMealDB API
    const apiUrl = `https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(searchQuery)}`;
    
    const response = await axios.get(apiUrl, {
      timeout: 10000, // 10 second timeout
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'RecipeApp/1.0'
      }
    });

    // Check if API response is successful
    if (response.status !== 200) {
      throw new Error(`TheMealDB API returned status ${response.status}`);
    }

    const data = response.data;
    
    // Check if meals were found
    if (!data.meals || data.meals.length === 0) {
      return res.json({
        status: 'success',
        message: 'No recipes found',
        data: {
          query: searchQuery,
          recipes: [],
          totalResults: 0
        }
      });
    }

    // Process and format the recipes
    const recipes = data.meals.map(meal => {
      // Extract ingredients and measurements
      const ingredients = [];
      for (let i = 1; i <= 20; i++) {
        const ingredient = meal[`strIngredient${i}`];
        const measure = meal[`strMeasure${i}`];
        
        if (ingredient && ingredient.trim()) {
          ingredients.push({
            ingredient: ingredient.trim(),
            measure: measure ? measure.trim() : null
          });
        }
      }

      // Clean instructions
      const instructions = meal.strInstructions ? 
        meal.strInstructions.split('\n').filter(line => line.trim()).join('\n') : 
        'No instructions available';

      return {
        id: meal.idMeal,
        title: meal.strMeal,
        image: meal.strMealThumb,
        category: meal.strCategory,
        area: meal.strArea,
        ingredients: ingredients,
        instructions: instructions,
        tags: meal.strTags ? meal.strTags.split(',').map(tag => tag.trim()) : [],
        youtube: meal.strYoutube || null,
        source: meal.strSource || null
      };
    });

    res.json({
      status: 'success',
      message: 'Recipes found successfully',
      data: {
        query: searchQuery,
        recipes: recipes,
        totalResults: recipes.length
      }
    });

  } catch (error) {
    console.error('Recipe search error:', error);
    
    // Handle specific error types
    if (error.code === 'ECONNABORTED') {
      return res.status(408).json({
        status: 'error',
        message: 'Request timeout - TheMealDB API is taking too long to respond'
      });
    }
    
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      return res.status(503).json({
        status: 'error',
        message: 'TheMealDB API is currently unavailable'
      });
    }
    
    if (error.response) {
      // TheMealDB API returned an error response
      return res.status(error.response.status).json({
        status: 'error',
        message: `TheMealDB API error: ${error.response.statusText}`,
        data: {
          apiStatus: error.response.status,
          apiMessage: error.response.statusText
        }
      });
    }

    // Generic server error
    res.status(500).json({
      status: 'error',
      message: 'Server error while searching recipes'
    });
  }
});

// @route   POST /api/recipes/search-history
// @desc    Save user's search query to search history
// @access  Private (authenticated users only)
router.post('/search-history', [
  protect, // Require authentication for all searches
  body('search_query')
    .trim()
    .isLength({ min: 1, max: 500 })
    .withMessage('Search query must be between 1 and 500 characters')
    .escape() // Prevent XSS
    .customSanitizer(value => {
      // Remove excessive whitespace and normalize
      return value.replace(/\s+/g, ' ').trim();
    }),
  body('search_filters')
    .optional()
    .isObject()
    .withMessage('Search filters must be a valid JSON object'),
  body('results_count')
    .optional()
    .isInt({ min: 0, max: 10000 })
    .withMessage('Results count must be a positive integer between 0 and 10000')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { search_query, search_filters, results_count } = req.body;
    const userId = req.user.id; // User ID from authenticated request

    // Validate search query is not just whitespace
    if (!search_query || search_query.trim().length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query cannot be empty'
      });
    }

    // Check if this is a duplicate search (same query within 5 minutes for same user)
    const duplicateCheck = await pool.query(`
      SELECT id FROM search_history 
      WHERE user_id = $1 
      AND search_query = $2 
      AND search_timestamp > NOW() - INTERVAL '5 minutes'
    `, [userId, search_query]);

    if (duplicateCheck.rows.length > 0) {
      // Update timestamp of existing search instead of creating duplicate
      await pool.query(`
        UPDATE search_history 
        SET search_timestamp = CURRENT_TIMESTAMP 
        WHERE id = $1
      `, [duplicateCheck.rows[0].id]);

      return res.json({
        status: 'success',
        message: 'Search query updated',
        data: {
          searchId: duplicateCheck.rows[0].id,
          searchQuery: search_query,
          isDuplicate: true,
          updatedAt: new Date().toISOString()
        }
      });
    }

    // Insert new search query
    const result = await pool.query(`
      INSERT INTO search_history (user_id, search_query, search_filters, results_count) 
      VALUES ($1, $2, $3, $4) 
      RETURNING id, search_query, search_timestamp, results_count
    `, [userId, search_query, search_filters || null, results_count || null]);

    const searchRecord = result.rows[0];

    // Log search activity (for analytics)
    console.log(`Search saved: ${search_query} by user ${userId} at ${searchRecord.search_timestamp}`);

    res.status(201).json({
      status: 'success',
      message: 'Search query saved successfully',
      data: {
        searchId: searchRecord.id,
        searchQuery: searchRecord.search_query,
        searchTimestamp: searchRecord.search_timestamp,
        resultsCount: searchRecord.results_count,
        userId: userId
      }
    });

  } catch (error) {
    console.error('Save search error:', error);
    
    // Handle specific database errors
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({
        status: 'error',
        message: 'Search query already exists'
      });
    }
    
    if (error.code === '23503') { // Foreign key constraint violation
      return res.status(400).json({
        status: 'error',
        message: 'Invalid user ID provided'
      });
    }

    res.status(500).json({
      status: 'error',
      message: 'Server error while saving search query'
    });
  }
});

// @route   GET /api/recipes/:id
// @desc    Get recipe details by ID from TheMealDB
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Validate recipe ID
    if (!id || id.trim().length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Recipe ID is required'
      });
    }
    
    console.log(`Fetching recipe details for ID: ${id}`);
    
    // Make request to TheMealDB API to get recipe by ID
    const apiUrl = `https://www.themealdb.com/api/json/v1/1/lookup.php?i=${encodeURIComponent(id)}`;
    
    const response = await axios.get(apiUrl, {
      timeout: 10000,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'RecipeApp/1.0'
      }
    });
    
    if (response.status !== 200) {
      throw new Error(`TheMealDB API returned status ${response.status}`);
    }
    
    const data = response.data;
    
    if (!data.meals || data.meals.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Recipe not found'
      });
    }
    
    const meal = data.meals[0];
    
    // Format the recipe data to include all available information
    const recipeDetails = {
      id: meal.idMeal,
      title: meal.strMeal,
      image: meal.strMealThumb,
      category: meal.strCategory,
      area: meal.strArea,
      instructions: meal.strInstructions,
      tags: meal.strTags ? meal.strTags.split(',') : [],
      youtube: meal.strYoutube,
      source: meal.strSource,
      
      // Process ingredients and measurements
      ingredients: [],
      
      // Additional fields
      drinkAlternate: meal.strDrinkAlternate,
      creativeCommonsConfirmed: meal.strCreativeCommonsConfirmed,
      dateModified: meal.dateModified
    };
    
    // Extract ingredients and measurements
    for (let i = 1; i <= 20; i++) {
      const ingredient = meal[`strIngredient${i}`];
      const measure = meal[`strMeasure${i}`];
      
      if (ingredient && ingredient.trim()) {
        recipeDetails.ingredients.push({
          name: ingredient.trim(),
          measure: measure ? measure.trim() : '',
          full: measure && measure.trim() ? `${measure.trim()} ${ingredient.trim()}` : ingredient.trim()
        });
      }
    }
    
    console.log(`Successfully fetched recipe: ${meal.strMeal}`);
    
    res.json({
      status: 'success',
      message: 'Recipe details retrieved successfully',
      data: recipeDetails
    });
    
  } catch (error) {
    console.error('Get recipe by ID error:', error);
    
    if (error.code === 'ECONNABORTED') {
      return res.status(408).json({
        status: 'error',
        message: 'Request timeout - API is taking too long to respond'
      });
    }
    
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      return res.status(503).json({
        status: 'error',
        message: 'Recipe API is currently unavailable'
      });
    }
    
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching recipe details'
    });
  }
});

// @route   GET /api/recipes/search/history
// @desc    Get user's search history
// @access  Private
router.get('/search/history', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 20, offset = 0 } = req.query;

    // Validate pagination parameters
    const limitNum = Math.min(parseInt(limit) || 20, 100); // Max 100 results
    const offsetNum = Math.max(parseInt(offset) || 0, 0);

    const result = await pool.query(`
      SELECT id, search_query, search_filters, results_count, search_timestamp
      FROM search_history 
      WHERE user_id = $1 
      ORDER BY search_timestamp DESC 
      LIMIT $2 OFFSET $3
    `, [userId, limitNum, offsetNum]);

    // Get total count for pagination
    const countResult = await pool.query(`
      SELECT COUNT(*) as total 
      FROM search_history 
      WHERE user_id = $1
    `, [userId]);

    res.json({
      status: 'success',
      data: {
        searches: result.rows,
        pagination: {
          total: parseInt(countResult.rows[0].total),
          limit: limitNum,
          offset: offsetNum,
          hasMore: (offsetNum + limitNum) < parseInt(countResult.rows[0].total)
        }
      }
    });

  } catch (error) {
    console.error('Get search history error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching search history'
    });
  }
});

// @route   DELETE /api/recipes/search/history/:id
// @desc    Delete a specific search from user's history
// @access  Private
router.delete('/search/history/:id', protect, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Validate search ID
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        status: 'error',
        message: 'Invalid search ID'
      });
    }

    // Delete search (only if it belongs to the user)
    const result = await pool.query(`
      DELETE FROM search_history 
      WHERE id = $1 AND user_id = $2
    `, [id, userId]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Search not found or not authorized to delete'
      });
    }

    res.json({
      status: 'success',
      message: 'Search deleted successfully'
    });

  } catch (error) {
    console.error('Delete search error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while deleting search'
    });
  }
});

// @route   POST /api/recipes/:id/favorite
// @desc    Toggle favorite status for a recipe (external recipe ID)
// @access  Private
router.post('/:id/favorite', protect, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { notes, rating } = req.body;
    
    // Validate recipe ID
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        status: 'error',
        message: 'Invalid recipe ID'
      });
    }

    // Validate rating if provided
    if (rating !== undefined && (rating < 1 || rating > 5)) {
      return res.status(400).json({
        status: 'error',
        message: 'Rating must be between 1 and 5'
      });
    }
    
    // Check if already favorited
    const existingFavorite = await pool.query(
      'SELECT * FROM favourites WHERE user_id = $1 AND recipe_id = $2', 
      [userId, id]
    );
    
    if (existingFavorite.rows.length > 0) {
      // Remove from favourites
      await pool.query(
        'DELETE FROM favourites WHERE user_id = $1 AND recipe_id = $2', 
        [userId, id]
      );
      res.json({ 
        status: 'success', 
        message: 'Recipe removed from favourites', 
        data: { isFavorited: false } 
      });
    } else {
      // Add to favourites
      await pool.query(
        'INSERT INTO favourites (user_id, recipe_id, notes, rating) VALUES ($1, $2, $3, $4)', 
        [userId, id, notes || null, rating || null]
      );
      res.json({ 
        status: 'success', 
        message: 'Recipe added to favourites', 
        data: { isFavorited: true } 
      });
    }
  } catch (error) {
    console.error('Toggle favourite error:', error);
    
    // Handle specific database errors
    if (error.code === '23514') { // Check constraint violation
      return res.status(400).json({
        status: 'error',
        message: 'Invalid rating value'
      });
    }
    
    res.status(500).json({
      status: 'error',
      message: 'Server error while toggling favourite'
    });
  }
});

// @route   GET /api/recipes/favourites
// @desc    Get user's favourite recipes
// @access  Private
router.get('/favourites', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await pool.query(`
      SELECT f.*, f.recipe_id as external_recipe_id
      FROM favourites f
      WHERE f.user_id = $1
      ORDER BY f.added_at DESC
    `, [userId]);
    
    res.json({
      status: 'success',
      data: {
        favourites: result.rows
      }
    });
  } catch (error) {
    console.error('Get favourites error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching favourites'
    });
  }
});

module.exports = router;
