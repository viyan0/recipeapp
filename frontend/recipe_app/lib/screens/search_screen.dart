import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import 'recipe_detail_screen.dart';
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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';
  User? _currentUser;

  // Common ingredients as chips
  final List<String> _commonIngredients = [
    'onion', 'garlic', 'tomato', 'potato', 'carrot', 'bell pepper',
    'salt', 'pepper', 'oil', 'butter', 'flour', 'rice', 'pasta',
    'chicken', 'beef', 'fish', 'eggs', 'milk', 'cheese', 'bread',
    'lemon', 'ginger', 'chili', 'cumin', 'oregano', 'basil'
  ];

  // Time options
  final List<Map<String, dynamic>> _timeOptions = AppConfig.availableTimeOptions.map((minutes) {
    String label = minutes == 60 ? '1 hour' : '${minutes} min';
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
    if (!_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
  }

  void _addCustomIngredient() {
    final ingredient = _searchController.text.trim().toLowerCase();
    if (ingredient.isNotEmpty && !_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _searchController.clear();
      });
    }
  }

  Future<void> _searchRecipes() async {
    if (_selectedIngredients.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one ingredient';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final recipes = await RecipeService.searchRecipes(
        ingredients: _selectedIngredients,
        maxTimeMinutes: _selectedTimeMinutes,
      );

      setState(() {
        _searchResults = recipes;
        _isSearching = false;
      });
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
            if (_selectedIngredients.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Ingredients:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedIngredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () => _removeIngredient(ingredient),
                          backgroundColor: Colors.orange[100],
                          labelStyle: TextStyle(color: Colors.orange[800]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Common ingredients
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Common Ingredients:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonIngredients.map((ingredient) {
                      final isSelected = _selectedIngredients.contains(ingredient);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            _removeIngredient(ingredient);
                          } else {
                            _addIngredient(ingredient);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange[600] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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

            // Search results
            if (_searchResults.isNotEmpty || _isSearching)
              Container(
                height: 400, // Fixed height for results section
                child: _isSearching
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final recipe = _searchResults[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: recipe['image'] != null && recipe['image'].toString().isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recipe['image'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.restaurant,
                                          color: Colors.orange[600],
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.restaurant,
                                    color: Colors.orange[600],
                                  ),
                            ),
                            title: Text(
                              recipe['title'] ?? 'Recipe Title',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipe['cookingTime'] != null)
                                  Text('Cooking time: ${recipe['cookingTime']} minutes'),
                                if (recipe['matchScore'] != null && recipe['matchPercentage'] != null)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: recipe['matchPercentage'] >= 80 
                                              ? Colors.green 
                                              : recipe['matchPercentage'] >= 50 
                                                  ? Colors.orange 
                                                  : Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${recipe['matchScore']}/${_selectedIngredients.length} ingredients (${recipe['matchPercentage']}%)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (recipe['ingredients'] != null)
                                  Text('Recipe ingredients: ${(recipe['ingredients'] as List).take(3).join(', ')}...'),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Navigate to recipe details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
              )
            else if (!_isSearching)
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
              ),
          ],
        ),
      ),
    );
  }
}
