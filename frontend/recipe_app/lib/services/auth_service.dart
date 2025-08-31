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

  // Sign up with dietary preference
  static Future<User> signUp({
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
          throw Exception(responseData['message'] ?? 'Sign up failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Sign up failed');
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
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/dietary-preference'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isVegetarian': isVegetarian,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final userData = responseData['data'];
          final user = User(
            id: userData['id'].toString(),
            email: userData['email'],
            username: userData['username'],
            isVegetarian: userData['isVegetarian'] ?? false,
            createdAt: DateTime.parse(userData['createdAt']),
            token: token,
          );
          await saveUserData(user);
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Update failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
