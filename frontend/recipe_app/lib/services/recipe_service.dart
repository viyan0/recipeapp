import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RecipeService {
  static String get baseUrl => AppConfig.backendUrl;

  // Search recipes based on ingredients and time
  static Future<List<Map<String, dynamic>>> searchRecipes({
    required List<String> ingredients,
    required int maxTimeMinutes,
    List<String>? preferences,
    List<String>? requiredIngredients,
  }) async {
    http.Response? response;
    try {
      final url = '$baseUrl/api/recipes/search';
      print('Making request to: $url');
      
      response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'ingredients': ingredients,
          'maxTimeMinutes': maxTimeMinutes,
          'preferences': preferences ?? [],
          'requiredIngredients': requiredIngredients ?? [],
        }),
      ).timeout(Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timeout - please check your internet connection');
      });

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Extract the recipes array from the nested data structure
          final data = responseData['data'];
          if (data['recipes'] != null) {
            print('Found ${data['recipes'].length} recipes');
            return List<Map<String, dynamic>>.from(data['recipes']);
          } else {
            // Fallback for direct array response
            return List<Map<String, dynamic>>.from(data);
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to search recipes');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error (${response.statusCode})');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Please try again');
        }
      }
    } catch (e) {
      print('Recipe search error: $e');
      
      // Handle specific error types for better user feedback
      if (e.toString().contains('timeout')) {
        rethrow; // Already has a good timeout message
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('Network is unreachable')) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      } else if (e.toString().contains('Connection refused')) {
        throw Exception('Server is not available. Please try again later.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response from server. Please try again.');
      } else {
        // For any other errors, provide a generic message
        throw Exception('Failed to search recipes. Please try again.');
      }
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

      print('Recipe detail response status: ${response.statusCode}');
      print('Recipe detail response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          print('Recipe detail data structure: ${responseData['data'].runtimeType}');
          print('Recipe detail keys: ${responseData['data'].keys}');
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
