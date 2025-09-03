import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/favorites_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? fullRecipeData;
  bool isLoading = true;
  String errorMessage = '';
  bool isFavorited = false;
  bool isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
    _checkFavoriteStatus();
  }

  Future<void> _loadRecipeDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final recipeDetails = await RecipeService.getRecipeById(widget.recipe['id']);
      
      setState(() {
        fullRecipeData = recipeDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favoriteStatus = await FavoritesService.isFavorited(widget.recipe['id'].toString());
      setState(() {
        isFavorited = favoriteStatus;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      // Don't show error to user, just keep default false state
    }
  }

  Future<void> _toggleFavorite() async {
    if (isTogglingFavorite) return;

    setState(() {
      isTogglingFavorite = true;
    });

    try {
      final recipe = fullRecipeData ?? widget.recipe;
      final newStatus = await FavoritesService.toggleFavorite(
        recipeId: widget.recipe['id'].toString(),
        recipeTitle: recipe['title'] ?? recipe['strMeal'] ?? 'Unknown Recipe',
        recipeImage: recipe['image'] ?? recipe['strMealThumb'],
        recipeCategory: recipe['category'] ?? recipe['strCategory'],
        recipeArea: recipe['area'] ?? recipe['strArea'],
      );

      setState(() {
        isFavorited = newStatus;
        isTogglingFavorite = false;
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Added to favorites!' : 'Removed from favorites!',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        isTogglingFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = fullRecipeData ?? widget.recipe;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe['title'] ?? recipe['strMeal'] ?? 'Recipe Details',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: isTogglingFavorite
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
            onPressed: isTogglingFavorite ? null : _toggleFavorite,
            tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      SizedBox(height: 16),
                      Text(
                        'Error loading recipe details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRecipeDetails,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Image
                      if (recipe['image'] != null || recipe['strMealThumb'] != null)
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              recipe['image'] ?? recipe['strMealThumb'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.orange[100],
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 80,
                                    color: Colors.orange[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      SizedBox(height: 24),
                      
                      // Recipe Title
                      Text(
                        recipe['title'] ?? recipe['strMeal'] ?? 'Recipe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Recipe Info Row
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.access_time,
                            '${recipe['cookingTime'] ?? 'N/A'} min',
                            Colors.blue,
                          ),
                          SizedBox(width: 12),
                          if ((recipe['category'] ?? recipe['strCategory']) != null)
                            _buildInfoChip(
                              Icons.category,
                              recipe['category'] ?? recipe['strCategory'],
                              Colors.green,
                            ),
                          SizedBox(width: 12),
                          if ((recipe['area'] ?? recipe['strArea']) != null)
                            _buildInfoChip(
                              Icons.public,
                              recipe['area'] ?? recipe['strArea'],
                              Colors.purple,
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Ingredients Section
                      _buildSectionTitle('Ingredients'),
                      SizedBox(height: 12),
                      _buildIngredientsSection(recipe),
                      
                      SizedBox(height: 24),
                      
                      // Instructions Section
                      if (recipe['strInstructions'] != null || recipe['instructions'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Instructions'),
                            SizedBox(height: 12),
                            _buildInstructionsSection(recipe['strInstructions'] ?? recipe['instructions']),
                          ],
                        ),
                      
                      SizedBox(height: 24),
                      
                      // Additional Info - Video Tutorial (only if video exists)
                      if ((recipe['strYoutube'] != null && recipe['strYoutube'].toString().isNotEmpty) || 
                          (recipe['youtube'] != null && recipe['youtube'].toString().isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Video Tutorial'),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.play_circle_filled, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Watch on YouTube',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.open_in_new, color: Colors.red),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildIngredientsSection(Map<String, dynamic> recipe) {
    List<String> ingredients = [];
    
    // Try to get ingredients from different possible fields
    if (recipe['ingredients'] != null && recipe['ingredients'] is List) {
      final ingredientsList = recipe['ingredients'] as List;
      
      // Check if it's a list of objects (from backend API) or strings (from search)
      for (var ingredient in ingredientsList) {
        if (ingredient is Map<String, dynamic>) {
          // Backend API format with objects
          final full = ingredient['full']?.toString();
          if (full != null && full.isNotEmpty) {
            ingredients.add(full);
          }
        } else if (ingredient is String) {
          // Search result format with strings
          ingredients.add(ingredient);
        }
      }
    } else {
      // Parse ingredients from TheMealDB format (strIngredient1, strIngredient2, etc.)
      for (int i = 1; i <= 20; i++) {
        final ingredient = recipe['strIngredient$i'];
        final measure = recipe['strMeasure$i'];
        
        if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
          String ingredientText = ingredient.toString().trim();
          if (measure != null && measure.toString().trim().isNotEmpty) {
            ingredientText = '${measure.toString().trim()} $ingredientText';
          }
          ingredients.add(ingredientText);
        }
      }
    }
    
    if (ingredients.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No ingredients information available',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: ingredients.map((ingredient) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsSection(String instructions) {
    // Split instructions into steps if they contain numbered steps
    List<String> steps = [];
    
    if (instructions.contains(RegExp(r'\d+\.'))) {
      // Instructions contain numbered steps
      steps = instructions.split(RegExp(r'\d+\.')).where((s) => s.trim().isNotEmpty).toList();
    } else {
      // Split by periods or new lines for simple instructions
      steps = instructions.split(RegExp(r'[.\n]')).where((s) => s.trim().isNotEmpty).toList();
    }
    
    if (steps.isEmpty) {
      steps = [instructions];
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value.trim();
          
          return Padding(
            padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
