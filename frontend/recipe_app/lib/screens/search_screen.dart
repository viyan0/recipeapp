import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import 'recipe_results_screen.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import '../providers/theme_provider.dart';

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

  // Current multi-select dropdown selections
  List<String> _selectedVegetables = [];
  List<String> _selectedProteins = [];
  List<String> _selectedStaples = [];

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

  Widget _buildCategoryDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label,
            style: TextStyle(color: ThemeProvider.gentleLavender, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ThemeProvider.softLavender.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeProvider.deepLavender, width: 1.2),
            boxShadow: [
              BoxShadow(color: ThemeProvider.lavenderShadow.withOpacity(0.18), blurRadius: 14, offset: Offset(0, 6)),
              BoxShadow(color: ThemeProvider.pastelPink.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: ThemeProvider.inputBackground,
              style: TextStyle(color: ThemeProvider.deepLavender),
              icon: Icon(Icons.arrow_drop_down_rounded, color: ThemeProvider.deepLavender),
              hint: Text('Select', style: TextStyle(color: ThemeProvider.gentleLavender)),
              items: options
                  .map((opt) => DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown({
    required String label,
    required List<String> selectedValues,
    required List<String> options,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label,
            style: TextStyle(color: ThemeProvider.gentleLavender, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ThemeProvider.softLavender.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeProvider.deepLavender, width: 1.2),
            boxShadow: [
              BoxShadow(color: ThemeProvider.lavenderShadow.withOpacity(0.18), blurRadius: 14, offset: Offset(0, 6)),
              BoxShadow(color: ThemeProvider.pastelPink.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...selectedValues.map((v) => Chip(
                    label: Text(v, style: TextStyle(color: ThemeProvider.deepLavender)),
                    backgroundColor: ThemeProvider.inputBackground,
                    deleteIcon: Icon(Icons.close, size: 18, color: ThemeProvider.gentleLavender),
                    onDeleted: () {
                      final vals = List<String>.from(selectedValues)..remove(v);
                      onChanged(vals);
                    },
                    shape: StadiumBorder(side: BorderSide(color: ThemeProvider.deepLavender)),
                  )),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: null,
                  hint: Text('Add', style: TextStyle(color: ThemeProvider.gentleLavender)),
                  dropdownColor: ThemeProvider.inputBackground,
                  icon: Icon(Icons.add_circle_outline, color: ThemeProvider.deepLavender),
                  items: options
                      .where((opt) => !selectedValues.contains(opt))
                      .map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final vals = List<String>.from(selectedValues)..add(val);
                      onChanged(vals);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeProvider.softLavender.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: ThemeProvider.deepLavender, width: 1.4)),
                boxShadow: [
                  BoxShadow(
                    color: ThemeProvider.lavenderShadow.withOpacity(0.18),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: ThemeProvider.pastelPink.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeProvider.dreamyLavender.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: ThemeProvider.lavenderShadow.withOpacity(0.18), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Icon(Icons.kitchen_rounded, color: ThemeProvider.deepLavender, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "What's in your kitchen?",
                          style: TextStyle(
                            color: ThemeProvider.deepLavender,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Search bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Type ingredient name...',
                            hintStyle: TextStyle(color: ThemeProvider.gentleLavender),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: ThemeProvider.deepLavender),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: ThemeProvider.gentleLavender.withOpacity(0.7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: ThemeProvider.deepLavender, width: 2),
                            ),
                            fillColor: ThemeProvider.inputBackground,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: TextStyle(color: ThemeProvider.deepLavender),
                          onSubmitted: (_) => _addCustomIngredient(),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomIngredient,
                        child: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.dreamyLavender,
                          foregroundColor: ThemeProvider.white,
                          side: BorderSide(color: ThemeProvider.deepLavender, width: 1.2),
                          elevation: 14,
                          shadowColor: ThemeProvider.lavenderShadow.withOpacity(0.25),
                        ),
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
                      color: ThemeProvider.deepLavender,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _timeOptions.map((timeOption) {
                      final isSelected = _selectedTimeMinutes == timeOption['minutes'];
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTimeMinutes = timeOption['minutes'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(horizontal: isSelected ? 22 : 16, vertical: isSelected ? 11 : 8),
                            decoration: BoxDecoration(
                              color: isSelected ? ThemeProvider.dreamyLavender : ThemeProvider.softLavender,
                              border: Border.all(
                                color: isSelected ? ThemeProvider.deepLavender : ThemeProvider.gentleLavender,
                                width: isSelected ? 2.0 : 1.2,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeProvider.lavenderShadow.withOpacity(isSelected ? 0.18 : 0.10),
                                  blurRadius: isSelected ? 18 : 12,
                                  offset: Offset(0, isSelected ? 8 : 5),
                                ),
                                if (isSelected)
                                  BoxShadow(
                                    color: ThemeProvider.dreamyLavender.withOpacity(0.18),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Text(
                              timeOption['label'],
                              style: TextStyle(
                                color: isSelected ? ThemeProvider.white : ThemeProvider.deepLavender,
                                fontWeight: FontWeight.w700,
                              ),
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
                              valueColor: AlwaysStoppedAnimation<Color>(ThemeProvider.white),
                            ),
                          )
                        : Text(
                            'Find Recipes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeProvider.dreamyLavender,
                        foregroundColor: ThemeProvider.white,
                        side: BorderSide(color: ThemeProvider.deepLavender, width: 1.2),
                        elevation: 16,
                        shadowColor: ThemeProvider.lavenderShadow.withOpacity(0.25),
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
                        Icon(Icons.star, color: ThemeProvider.deepLavender, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Required Ingredients:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeProvider.gentleLavender,
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
                          deleteIcon: Icon(Icons.close, size: 18, color: ThemeProvider.deepLavender),
                          onDeleted: () => _removeIngredient(ingredient),
                          backgroundColor: ThemeProvider.pastelPink.withOpacity(0.18),
                          labelStyle: TextStyle(color: ThemeProvider.deepLavender),
                          shape: StadiumBorder(side: BorderSide(color: ThemeProvider.deepLavender)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Ingredient preferences - 3 horizontal dropdowns
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_outline, color: ThemeProvider.deepLavender, size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ingredient Preferences (optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeProvider.deepLavender,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMultiSelectDropdown(
                          label: 'Vegetables',
                          selectedValues: _selectedVegetables,
                          options: _ingredientCategories['Vegetables']!,
                          onChanged: (vals) {
                            setState(() {
                              _selectedVegetables = vals;
                              _selectedPreferences.removeWhere((e) => _ingredientCategories['Vegetables']!.contains(e));
                              _selectedPreferences.addAll(vals);
                              _requiredIngredients.removeWhere((e) => vals.contains(e));
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildMultiSelectDropdown(
                          label: 'Proteins',
                          selectedValues: _selectedProteins,
                          options: _ingredientCategories['Proteins']!,
                          onChanged: (vals) {
                            setState(() {
                              _selectedProteins = vals;
                              _selectedPreferences.removeWhere((e) => _ingredientCategories['Proteins']!.contains(e));
                              _selectedPreferences.addAll(vals);
                              _requiredIngredients.removeWhere((e) => vals.contains(e));
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildMultiSelectDropdown(
                          label: 'Staples',
                          selectedValues: _selectedStaples,
                          options: _ingredientCategories['Staples']!,
                          onChanged: (vals) {
                            setState(() {
                              _selectedStaples = vals;
                              _selectedPreferences.removeWhere((e) => _ingredientCategories['Staples']!.contains(e));
                              _selectedPreferences.addAll(vals);
                              _requiredIngredients.removeWhere((e) => vals.contains(e));
                            });
                          },
                        ),
                      ),
                    ],
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
                  color: ThemeProvider.pastelPink.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ThemeProvider.pastelPink.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: ThemeProvider.deepLavender),
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
                        color: ThemeProvider.gentleLavender,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select ingredients and time to find recipes',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeProvider.gentleLavender,
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
                          color: ThemeProvider.gentleLavender,
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
