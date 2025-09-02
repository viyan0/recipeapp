import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import 'recipe_results_screen.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _selectedIngredients = [];
  int _selectedTimeMinutes = AppConfig.defaultSearchTimeMinutes;
  bool _isSearching = false;
  String _errorMessage = '';
  User? _currentUser;

  // Categorized ingredients as preferences - 5 ingredients each
  final Map<String, List<String>> _ingredientCategories = {
    'Vegetables': ['onion', 'garlic', 'tomato', 'potato', 'carrot'],
    'Proteins': ['chicken', 'beef', 'eggs', 'tofu', 'fish'],
    'Staples': ['rice', 'pasta', 'flour', 'oats', 'bread']
  };

  // Track which categories are expanded
  final Set<String> _expandedCategories = <String>{};

  final List<String> _selectedPreferences = [];
  final List<String> _requiredIngredients = [];

  // Time options
  final List<Map<String, dynamic>> _timeOptions = AppConfig.availableTimeOptions.map((minutes) {
    String label;
    if (minutes == 30) {
      label = '30 minutes';
    } else if (minutes == 60) {
      label = '1 hour';
    } else if (minutes == 120) {
      label = '2 hours';
    } else {
      label = '${minutes} min';
    }
    return {'label': label, 'minutes': minutes};
  }).toList();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUserData();
    setState(() {
      _currentUser = user;
    });
  }

  void _addIngredient(String ingredient) {
    if (!_requiredIngredients.contains(ingredient) && !_selectedPreferences.contains(ingredient)) {
      setState(() {
        _requiredIngredients.add(ingredient);
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _requiredIngredients.remove(ingredient);
      _selectedPreferences.remove(ingredient);
    });
  }

  void _addCustomIngredient() {
    final ingredient = _searchController.text.trim().toLowerCase();
    if (ingredient.isNotEmpty && !_requiredIngredients.contains(ingredient) && !_selectedPreferences.contains(ingredient)) {
      setState(() {
        _requiredIngredients.add(ingredient);
        _searchController.clear();
      });
    }
  }

  void _togglePreference(String ingredient) {
    setState(() {
      if (_selectedPreferences.contains(ingredient)) {
        _selectedPreferences.remove(ingredient);
      } else {
        _selectedPreferences.add(ingredient);
        // Remove from required if it was there
        _requiredIngredients.remove(ingredient);
      }
    });
  }

  Future<void> _searchRecipes() async {
    // Combine required ingredients and preferences for search
    final allIngredients = [..._requiredIngredients, ..._selectedPreferences];
    
    if (allIngredients.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one ingredient or select preferences';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final recipes = await RecipeService.searchRecipes(
        ingredients: allIngredients,
        preferences: _selectedPreferences,
        requiredIngredients: _requiredIngredients,
        maxTimeMinutes: _selectedTimeMinutes,
      );

      setState(() {
        _isSearching = false;
      });

      // Navigate to results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeResultsScreen(
            recipes: recipes,
            searchedIngredients: allIngredients,
            preferences: _selectedPreferences,
            requiredIngredients: _requiredIngredients,
            maxTimeMinutes: _selectedTimeMinutes,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSearching = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Type ingredient name...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _addCustomIngredient(),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomIngredient,
                        child: Text('Add'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Time filter
                  Text(
                    'How much time do you have?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _timeOptions.map((timeOption) {
                      final isSelected = _selectedTimeMinutes == timeOption['minutes'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeMinutes = timeOption['minutes'];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange[600] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.orange[600]! : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            timeOption['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchRecipes,
                      child: _isSearching
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Find Recipes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Selected ingredients
            if (_requiredIngredients.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.red[600], size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Required Ingredients:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _requiredIngredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () => _removeIngredient(ingredient),
                          backgroundColor: Colors.red[100],
                          labelStyle: TextStyle(color: Colors.red[800]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Ingredient preferences by category
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_outline, color: Colors.orange[600], size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ingredient Preferences: Select ingredients you prefer (optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Category sections
                  ..._ingredientCategories.entries.map((category) {
                    final isExpanded = _expandedCategories.contains(category.key);
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category header
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCategories.remove(category.key);
                                } else {
                                  _expandedCategories.add(category.key);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isExpanded ? Colors.blue[50] : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isExpanded ? Colors.blue[200]! : Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${category.key} (5)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isExpanded ? Colors.blue[700] : Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    isExpanded ? 'showing all' : 'showing 2',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: isExpanded ? Colors.blue[600] : Colors.grey[600],
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          
                          // Ingredient chips
                          if (isExpanded) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: category.value.map((ingredient) {
                                final isSelected = _selectedPreferences.contains(ingredient);
                                return GestureDetector(
                                  onTap: () => _togglePreference(ingredient),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.orange[100] : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? Colors.orange[400]! : Colors.grey[300]!,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      ingredient,
                                      style: TextStyle(
                                        color: isSelected ? Colors.orange[700] : Colors.grey[600],
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            // Show top 2 ingredients when collapsed (out of 5 total)
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: category.value.take(2).map((ingredient) {
                                      final isSelected = _selectedPreferences.contains(ingredient);
                                      return GestureDetector(
                                        onTap: () => _togglePreference(ingredient),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.orange[100] : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected ? Colors.orange[400]! : Colors.grey[300]!,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                              color: isSelected ? Colors.orange[700] : Colors.grey[600],
                                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // Always show "+ 3 more" since each category has exactly 5 ingredients
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedCategories.add(category.key);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.blue[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '+ 3 more',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.blue[700],
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),

            // Search prompt when not searching
            if (!_isSearching)
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select ingredients and time to find recipes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Searching for recipes...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
