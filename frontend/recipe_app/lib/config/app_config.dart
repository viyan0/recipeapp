import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Backend configuration - Handle different platforms
  static String get backendUrl {
    if (kIsWeb) {
      // Flutter web - use localhost
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      try {
        // Try to connect to localhost first (for emulator)
        return 'http://10.0.2.2:3000';
      } catch (e) {
        // Fallback to localhost
        return 'http://localhost:3000';
      }
    } else if (Platform.isIOS) {
      // iOS simulator - use localhost
      return 'http://localhost:3000';
    } else {
      // Windows, macOS, Linux - use localhost
      return 'http://localhost:3000';
    }
  }

  // Alternative URLs for different scenarios
  static const String localhostUrl = 'http://localhost:3000';
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String networkUrl =
      'http://192.168.28.245:3000'; // Your network IP

  // API endpoints
  static const String authSignupEndpoint = '/api/auth/signup';
  static const String authLoginEndpoint = '/api/auth/login';
  static const String userDietaryPreferenceEndpoint = '/api/users';
  static const String recipeSearchEndpoint = '/api/recipes/search';
  static const String recipeByIdEndpoint = '/api/recipes';
  static const String popularRecipesEndpoint = '/api/recipes/popular';

  // App settings
  static const String appName = 'Recipe App';
  static const String appVersion = '1.0.0';

  // UI settings
  static const int defaultSearchTimeMinutes = 30;
  static const List<int> availableTimeOptions = [30, 60, 120];

  // Validation settings
  static const int minUsernameLength = 3;
  
  static const int minPasswordLength = 6;
}
