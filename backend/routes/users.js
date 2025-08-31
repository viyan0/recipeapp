const express = require('express');
const { query, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { protect } = require('../middleware/auth');

const router = express.Router();

// @route   PUT /api/users/:id/dietary-preference
// @desc    Update user's dietary preference
// @access  Private
router.put('/:id/dietary-preference', [
  protect,
  query('isVegetarian')
    .isBoolean()
    .withMessage('isVegetarian must be a boolean value')
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

    const { id } = req.params;
    const { isVegetarian } = req.query;
    const userId = req.user.id;

    // Ensure user can only update their own preference
    if (parseInt(id) !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Not authorized to update this user'
      });
    }

    // Update dietary preference
    const result = await pool.query(
      'UPDATE users SET is_vegetarian = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id, username, email, is_vegetarian, created_at',
      [isVegetarian, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    const user = result.rows[0];

    res.json({
      id: user.id,
      email: user.email,
      username: user.username,
      isVegetarian: user.is_vegetarian,
      createdAt: user.created_at
    });
  } catch (error) {
    console.error('Update dietary preference error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while updating dietary preference'
    });
  }
});

// @route   GET /api/users/profile
// @desc    Get user profile with stats
// @access  Private
router.get('/profile', protect, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user profile with stats
    const result = await pool.query(`
      SELECT 
        u.id,
        u.username,
        u.email,
        u.full_name,
        u.avatar_url,
        u.is_vegetarian,
        u.created_at,
        COUNT(DISTINCT f.id) as favourite_count,
        COUNT(DISTINCT sh.id) as search_count
      FROM users u
      LEFT JOIN favourites f ON u.id = f.user_id
      LEFT JOIN search_history sh ON u.id = sh.user_id
      WHERE u.id = $1
      GROUP BY u.id
    `, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        profile: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching profile'
    });
  }
});

// @route   GET /api/users/favourites
// @desc    Get user's favourite recipes
// @access  Private
router.get('/favourites', [
  protect,
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
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

    const { page = 1, limit = 10 } = req.query;
    const userId = req.user.id;
    const offset = (page - 1) * limit;

    // Get favourite recipes
    const favouritesQuery = `
      SELECT 
        f.id,
        f.recipe_id,
        f.notes,
        f.rating,
        f.added_at
      FROM favourites f
      WHERE f.user_id = $1
      ORDER BY f.added_at DESC
      LIMIT $2 OFFSET $3
    `;

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total
      FROM favourites f
      WHERE f.user_id = $1
    `;

    // Execute queries
    const [favouritesResult, countResult] = await Promise.all([
      pool.query(favouritesQuery, [userId, parseInt(limit), offset]),
      pool.query(countQuery, [userId])
    ]);

    const favourites = favouritesResult.rows;
    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / limit);

    res.json({
      status: 'success',
      data: {
        favourites,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          total,
          limit: parseInt(limit),
          hasNext: page < totalPages,
          hasPrev: page > 1
        }
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

// @route   GET /api/users/search-history
// @desc    Get user's search history
// @access  Private
router.get('/search-history', [
  protect,
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
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

    const { page = 1, limit = 10 } = req.query;
    const userId = req.user.id;
    const offset = (page - 1) * limit;

    // Get search history
    const searchHistoryQuery = `
      SELECT 
        sh.id,
        sh.search_query,
        sh.search_filters,
        sh.results_count,
        sh.search_timestamp
      FROM search_history sh
      WHERE sh.user_id = $1
      ORDER BY sh.search_timestamp DESC
      LIMIT $2 OFFSET $3
    `;

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total
      FROM search_history sh
      WHERE sh.user_id = $1
    `;

    // Execute queries
    const [searchHistoryResult, countResult] = await Promise.all([
      pool.query(searchHistoryQuery, [userId, parseInt(limit), offset]),
      pool.query(countQuery, [userId])
    ]);

    const searchHistory = searchHistoryResult.rows;
    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / limit);

    res.json({
      status: 'success',
      data: {
        searchHistory,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          total,
          limit: parseInt(limit),
          hasNext: page < totalPages,
          hasPrev: page > 1
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

// @route   GET /api/users/:username
// @desc    Get public user profile
// @access  Public
router.get('/:username', async (req, res) => {
  try {
    const { username } = req.params;

    // Get public user profile
    const result = await pool.query(`
      SELECT 
        u.id,
        u.username,
        u.full_name,
        u.avatar_url,
        u.is_vegetarian,
        u.created_at,
        COUNT(DISTINCT f.id) as favourite_count,
        COUNT(DISTINCT sh.id) as search_count
      FROM users u
      LEFT JOIN favourites f ON u.id = f.user_id
      LEFT JOIN search_history sh ON u.id = sh.user_id
      WHERE u.username = $1
      GROUP BY u.id
    `, [username]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    const user = result.rows[0];

    res.json({
      status: 'success',
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Get public user error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error while fetching user profile'
    });
  }
});

module.exports = router;
