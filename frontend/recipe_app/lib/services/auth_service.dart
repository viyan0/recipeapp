import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.backendUrl;
  
  // Store user data locally
  static Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setBool('isLoggedIn', true);
    
    // Store token separately for easy access
    if (user.token != null) {
      await prefs.setString('authToken', user.token!);
    }
  }

  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('authToken');
    await prefs.setBool('isLoggedIn', false);
  }

  // Sign up with dietary preference - now returns token directly
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String username,
    required String password,
    required bool isVegetarian,
  }) async {
    try {
      final url = '$baseUrl/api/auth/signup';
      print('Attempting to connect to: $url'); // Debug log
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'isVegetarian': isVegetarian,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Build user and save immediately (auto-login)
          final userData = responseData['data'];
          final user = User(
            id: userData['id'].toString(),
            email: userData['email'],
            username: userData['username'],
            isVegetarian: userData['isVegetarian'] ?? false,
            createdAt: DateTime.parse(userData['createdAt']),
            token: responseData['token'],
          );
          await saveUserData(user);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Account created successfully',
            'token': responseData['token'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Sign up failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Sign up failed';
        
        // Handle validation errors more clearly
        if (errorData['errors'] != null && errorData['errors'] is List) {
          List<String> validationErrors = [];
          for (var error in errorData['errors']) {
            if (error['msg'] != null) {
              validationErrors.add(error['msg']);
            }
          }
          if (validationErrors.isNotEmpty) {
            errorMessage = validationErrors.join('\n');
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Sign up error: $e'); // Debug log
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the backend is running on port 3001.');
      }
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot resolve localhost. Please check your network connection.');
      }
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. The server might be overloaded or not responding.');
      }
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('CORS error. Please check if the backend CORS configuration allows requests from this origin.');
      }
      throw Exception('Network error: $e');
    }
  }

  // OTP verification and resend removed

  // Login
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/api/auth/login';
      print('Attempting to connect to: $url'); // Debug log
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle the backend response format
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final userData = responseData['data'];
          final user = User(
            id: userData['id'].toString(),
            email: userData['email'],
            username: userData['username'],
            isVegetarian: userData['isVegetarian'] ?? false,
            createdAt: DateTime.parse(userData['createdAt']),
            token: responseData['token'],
          );
          await saveUserData(user);
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the backend is running on port 3001.');
      }
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot resolve localhost. Please check your network connection.');
      }
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. The server might be overloaded or not responding.');
      }
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('CORS error. Please check if the backend CORS configuration allows requests from this origin.');
      }
      throw Exception('Network error: $e');
    }
  }

  // Update dietary preference
  static Future<User> updateDietaryPreference({
    required String userId,
    required bool isVegetarian,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      // Build URL with query parameter
      final uri = Uri.parse('$baseUrl/api/users/$userId/dietary-preference').replace(
        queryParameters: {
          'isVegetarian': isVegetarian.toString(),
        },
      );
      
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // The backend returns the user data directly, not wrapped in a 'data' field
        final user = User(
          id: responseData['id'].toString(),
          email: responseData['email'],
          username: responseData['username'],
          isVegetarian: responseData['isVegetarian'] ?? false,
          createdAt: DateTime.parse(responseData['createdAt']),
          token: token,
        );
        await saveUserData(user);
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Update failed');
      }
    } catch (e) {
      print('Update dietary preference error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // Delete user account
  static Future<bool> deleteAccount({
    required String userId,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Clear local data after successful deletion
          await logout();
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Account deletion failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Account deletion failed');
      }
    } catch (e) {
      print('Delete account error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }
}
