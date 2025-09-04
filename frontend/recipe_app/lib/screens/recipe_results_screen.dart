import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/peaceful_recipe_card.dart';
import '../widgets/peaceful_chip.dart';
import '../widgets/peaceful_button.dart';
import '../widgets/peaceful_transitions.dart';
import '../widgets/peaceful_background.dart';
import '../widgets/peaceful_snackbar.dart';
import '../providers/theme_provider.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;
  final List<String> searchedIngredients;
  final List<String> preferences;
  final List<String> requiredIngredients;
  final int maxTimeMinutes;

  const RecipeResultsScreen({
    Key? key,
    required this.recipes,
    required this.searchedIngredients,
    required this.preferences,
    required this.requiredIngredients,
    required this.maxTimeMinutes,
  }) : super(key: key);

  @override
  _RecipeResultsScreenState createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends State<RecipeResultsScreen> {
  Map<String, bool> _favoriteStatus = {};
  Map<String, bool> _togglingFavorites = {};

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatuses();
  }

  Future<void> _checkFavoriteStatuses() async {
    for (final recipe in widget.recipes) {
      final recipeId = recipe['id'].toString();
      try {
        final isFavorited = await FavoritesService.isFavorited(recipeId);
        setState(() {
          _favoriteStatus[recipeId] = isFavorited;
        });
      } catch (e) {
        // If error checking status, default to false
        setState(() {
          _favoriteStatus[recipeId] = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(String recipeId, Map<String, dynamic> recipe) async {
    if (_togglingFavorites[recipeId] == true) return;

    setState(() {
      _togglingFavorites[recipeId] = true;
    });

    try {
      final newStatus = await FavoritesService.toggleFavorite(
        recipeId: recipeId,
        recipeTitle: recipe['title'] ?? 'Unknown Recipe',
        recipeImage: recipe['image'],
        recipeCategory: recipe['category'],
        recipeArea: recipe['area'],
      );

      setState(() {
        _favoriteStatus[recipeId] = newStatus;
        _togglingFavorites[recipeId] = false;
      });

      // Show feedback to user
      PeacefulSnackBar.showSuccess(
        context,
        message: newStatus ? 'Added to favorites!' : 'Removed from favorites!',
        icon: newStatus ? Icons.favorite : Icons.favorite_border_outlined,
      );
    } catch (e) {
      setState(() {
        _togglingFavorites[recipeId] = false;
      });

      PeacefulSnackBar.showError(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  String _getTimeFilterText(int minutes) {
    if (minutes <= 30) return '30 minutes';
    if (minutes <= 60) return '1 hour';
    return '2 hours';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PeacefulBackground(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: ThemeProvider.deepSlate,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Recipe Results',
                      style: TextStyle(
                        color: ThemeProvider.deepSlate,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PeacefulIconButton(
                    icon: Icons.logout_outlined,
                    onPressed: _logout,
                    tooltip: 'Logout',
                    size: 20,
                    color: ThemeProvider.deepSlate,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            
            // Search Summary Header
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.search_outlined,
                        color: ThemeProvider.softTeal,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.deepSlate,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Ingredients
                      ...widget.searchedIngredients.map((ingredient) => PeacefulFilterChip(
                        label: ingredient,
                        isSelected: true,
                        icon: Icons.local_dining_outlined,
                      )),
                      // Time filter
                      PeacefulFilterChip(
                        label: _getTimeFilterText(widget.maxTimeMinutes),
                        isSelected: true,
                        icon: Icons.access_time_outlined,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ThemeProvider.softTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeProvider.softTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Found ${widget.recipes.length} recipe${widget.recipes.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeProvider.deepSlate,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            
            // Results List
            Expanded(
              child: widget.recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_outlined,
                                  size: 64,
                                  color: ThemeProvider.softTeal,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No recipes found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeProvider.deepSlate,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Try different ingredients or increase the time limit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeProvider.softGray,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                PeacefulButton(
                                  text: 'Search Again',
                                  icon: Icons.search_outlined,
                                  onPressed: () => Navigator.pop(context),
                                  width: 200,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: widget.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = widget.recipes[index];
                        return PeacefulRecipeCard(
                          recipe: recipe,
                          index: index,
                          isFavorite: _favoriteStatus[recipe['id'].toString()] == true,
                          isTogglingFavorite: _togglingFavorites[recipe['id'].toString()] == true,
                          onTap: () {
                            Navigator.push(
                              context,
                              PeacefulRouteTransitions.fadeSlideTransition(
                                RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          onFavorite: () => _toggleFavorite(recipe['id'].toString(), recipe),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeProvider.softTeal.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: ThemeProvider.softTeal,
          foregroundColor: ThemeProvider.whisperWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.search_outlined, size: 24),
          tooltip: 'New Search',
        ),
      ),
    );
  }
}
