import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ConnectionTestService {
  static String get baseUrl => AppConfig.backendUrl;

  // Test basic connection to backend
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': jsonDecode(response.body),
          'message': 'Connection successful'
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'data': null,
          'message': 'Connection failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'data': null,
        'message': 'Connection error: $e'
      };
    }
  }

  // Test auth endpoint availability
  static Future<Map<String, dynamic>> testAuthEndpoint() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth'),
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.body,
        'message': 'Auth endpoint accessible'
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'data': null,
        'message': 'Auth endpoint error: $e'
      };
    }
  }

  // Test recipe endpoint availability
  static Future<Map<String, dynamic>> testRecipeEndpoint() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes'),
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.body,
        'message': 'Recipe endpoint accessible'
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'data': null,
        'message': 'Recipe endpoint error: $e'
      };
    }
  }
}
