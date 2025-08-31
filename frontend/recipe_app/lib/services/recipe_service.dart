import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RecipeService {
  static String get baseUrl => AppConfig.backendUrl;

  // Search recipes based on ingredients and time
  static Future<List<Map<String, dynamic>>> searchRecipes({
    required List<String> ingredients,
    required int maxTimeMinutes,
  }) async {
    try {
      final url = '$baseUrl/api/recipes/search';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'ingredients': ingredients,
          'maxTimeMinutes': maxTimeMinutes,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to search recipes');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search recipes');
      }
    } catch (e) {
      print('Recipe search error: $e');
      throw Exception('Failed to search recipes: $e');
    }
  }

  // Get recipe by ID
  static Future<Map<String, dynamic>> getRecipeById(String recipeId) async {
    try {
      final url = '$baseUrl/api/recipes/$recipeId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get recipe');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get recipe');
      }
    } catch (e) {
      print('Get recipe error: $e');
      throw Exception('Failed to get recipe: $e');
    }
  }
}
