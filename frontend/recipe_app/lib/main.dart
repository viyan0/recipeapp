import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/search_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(RecipeApp());
}

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Recipe App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: ThemeMode.light, // Use our beautiful peaceful greenish theme
            home: WelcomeScreen(),
            routes: {
              '/welcome': (context) => WelcomeScreen(),
              '/auth': (context) => AuthScreen(),
              '/search': (context) => SearchScreen(),
              '/main': (context) => MainNavigationScreen(),
              '/settings': (context) => SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
