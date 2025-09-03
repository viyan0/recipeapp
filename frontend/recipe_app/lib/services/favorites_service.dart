import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class FavoritesService {
  static String get baseUrl => AppConfig.backendUrl;

  // Toggle favorite status for a recipe
  static Future<bool> toggleFavorite({
    required String recipeId,
    required String recipeTitle,
    String? recipeImage,
    String? recipeCategory,
    String? recipeArea,
    String? notes,
    int? rating,
  }) async {
    try {
      print('🔄 FavoritesService: Starting toggleFavorite for recipe $recipeId');
      
      final token = await AuthService.getAuthToken();
      if (token == null) {
        print('❌ FavoritesService: No auth token found');
        throw Exception('Authentication required');
      }
      
      print('✅ FavoritesService: Auth token found: ${token.substring(0, 20)}...');

      final url = '$baseUrl/api/recipes/$recipeId/favorite';
      print('📡 FavoritesService: Making request to: $url');
      
      final requestBody = {
        'recipe_title': recipeTitle,
        'recipe_image': recipeImage,
        'recipe_category': recipeCategory,
        'recipe_area': recipeArea,
        'notes': notes,
        'rating': rating,
      };
      print('📦 FavoritesService: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipe_title': recipeTitle,
          'recipe_image': recipeImage,
          'recipe_category': recipeCategory,
          'recipe_area': recipeArea,
          'notes': notes,
          'rating': rating,
        }),
      );

      print('📨 FavoritesService: Response status: ${response.statusCode}');
      print('📨 FavoritesService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return responseData['data']['isFavorited'] ?? false;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to toggle favorite');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication expired. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error (${response.statusCode})');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Please try again');
        }
      }
    } catch (e) {
      print('Toggle favorite error: $e');
      
      if (e.toString().contains('Authentication')) {
        rethrow;
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('Network is unreachable')) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      } else if (e.toString().contains('Connection refused')) {
        throw Exception('Server is not available. Please try again later.');
      } else {
        throw Exception('Failed to update favorite. Please try again.');
      }
    }
  }

  // Check if a recipe is favorited
  static Future<bool> isFavorited(String recipeId) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) {
        return false; // Not authenticated, so can't have favorites
      }

      final url = '$baseUrl/api/recipes/$recipeId/favorite-status';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return responseData['data']['isFavorited'] ?? false;
        }
      }
      
      return false;
    } catch (e) {
      print('Check favorite status error: $e');
      return false;
    }
  }

  // Get user's favorite recipes
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      print('🔄 FavoritesService: Starting getFavorites');
      
      final token = await AuthService.getAuthToken();
      if (token == null) {
        print('❌ FavoritesService: No auth token found for getFavorites');
        throw Exception('Authentication required');
      }
      
      print('✅ FavoritesService: Auth token found for getFavorites');

      final url = '$baseUrl/api/recipes/favourites';
      print('📡 FavoritesService: Making getFavorites request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📨 FavoritesService: getFavorites response status: ${response.statusCode}');
      print('📨 FavoritesService: getFavorites response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final favorites = responseData['data']['favourites'] as List;
          return favorites.map((favorite) => {
            'id': favorite['external_recipe_id'],
            'title': favorite['recipe_title'],
            'image': favorite['recipe_image'],
            'category': favorite['recipe_category'],
            'area': favorite['recipe_area'],
            'added_at': favorite['added_at'],
            'notes': favorite['notes'],
            'rating': favorite['rating'],
            'favoriteId': favorite['id'], // Internal ID for removal
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get favorites');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication expired. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error (${response.statusCode})');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Please try again');
        }
      }
    } catch (e) {
      print('Get favorites error: $e');
      
      if (e.toString().contains('Authentication')) {
        rethrow;
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('Network is unreachable')) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      } else if (e.toString().contains('Connection refused')) {
        throw Exception('Server is not available. Please try again later.');
      } else {
        throw Exception('Failed to get favorites. Please try again.');
      }
    }
  }

  // Remove a recipe from favorites
  static Future<bool> removeFavorite(String recipeId) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = '$baseUrl/api/recipes/$recipeId/favorite';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}), // Empty body for removal
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return !responseData['data']['isFavorited']; // Return true if successfully removed
        } else {
          throw Exception(responseData['message'] ?? 'Failed to remove favorite');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication expired. Please log in again.');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error (${response.statusCode})');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Please try again');
        }
      }
    } catch (e) {
      print('Remove favorite error: $e');
      
      if (e.toString().contains('Authentication')) {
        rethrow;
      } else {
        throw Exception('Failed to remove favorite. Please try again.');
      }
    }
  }
}
