import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false; // Default to beautiful peaceful greenish light theme
  static const String _themeKey = 'isDarkMode';

  // Beautiful Peaceful Greenish Palette - Enhanced with your perfect shades
  static const Color dreamyMint = Color(0xFFF0F8F4);
  static const Color whisperGreen = Color(0xFFE8F6EC);
  static const Color serenityGreen = Color(0xFFD8F0DF);
  static const Color peacefulSage = Color(0xFFB5C8AC);  // Your perfect #B5C8AC
  static const Color enchantedEmerald = Color(0xFF90A76A);  // Your perfect #90A76A
  static const Color mysticJade = Color(0xFF60774C);  // Your perfect #60774C
  static const Color forestWhisper = Color(0xFF3A5231);  // Your perfect #3A5231
  static const Color deepForest = Color(0xFF2A3F24);
  static const Color silverMist = Color(0xFF8EA186);  // Your perfect #8EA186 - lighter and nicer
  
  // Complementary Gentle Colors
  static const Color softPeach = Color(0xFFFFE5D9);
  static const Color lightLavender = Color(0xFFE8D5F2);
  static const Color skyBlue = Color(0xFFB8E6FF);
  static const Color mintGreen = Color(0xFFD4F1D4);
  static const Color warmCream = Color(0xFFFFF8F0);
  static const Color softPink = Color(0xFFFFE5F1);
  static const Color lilac = Color(0xFFE0C7FF);
  static const Color powderBlue = Color(0xFFE0F2FF);
  static const Color cottonCloud = Color(0xFFF9FCFA);
  static const Color moonlightGlow = Color(0xFFF5FBF8);
  
  // Beautiful Text colors
  static const Color deepSlate = Color(0xFF2D3748);
  static const Color softGray = Color(0xFF4A5568);
  static const Color lightGray = Color(0xFF718096);
  static const Color whisperWhite = Color(0xFFF7FAFC);
  static const Color emeraldText = Color(0xFF1B4D3E);
  static const Color sageDark = Color(0xFF2F5D4F);
  
  // Magical Accent colors
  static const Color gentleCoral = Color(0xFFFF8A80);
  static const Color softTeal = Color(0xFF4CAF93); // Updated to match our green theme
  static const Color warmAmber = Color(0xFFFFB74D);
  static const Color peacefulPurple = Color(0xFF9575CD);
  static const Color rosePetal = Color(0xFFFFB3C1);
  static const Color goldDust = Color(0xFFFFE08A);

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false; // Default to peaceful theme
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: mysticJade,
      scaffoldBackgroundColor: moonlightGlow,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: emeraldText,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: emeraldText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: enchantedEmerald,
          foregroundColor: whisperWhite,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 12,
          shadowColor: enchantedEmerald.withOpacity(0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: enchantedEmerald,
          side: BorderSide(color: enchantedEmerald, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cottonCloud.withOpacity(0.9),
        elevation: 16,
        shadowColor: enchantedEmerald.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: emeraldText, fontWeight: FontWeight.w500, letterSpacing: 0.3),
        bodyMedium: TextStyle(color: sageDark, fontWeight: FontWeight.w400, letterSpacing: 0.2),
        headlineLarge: TextStyle(color: emeraldText, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        headlineMedium: TextStyle(color: emeraldText, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        titleLarge: TextStyle(color: emeraldText, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        titleMedium: TextStyle(color: sageDark, fontWeight: FontWeight.w500, letterSpacing: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: serenityGreen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: mysticJade, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: peacefulSage, width: 1.5),
        ),
        fillColor: cottonCloud.withOpacity(0.7),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: softTeal,
      scaffoldBackgroundColor: deepSlate,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: whisperWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softTeal,
          foregroundColor: whisperWhite,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: softTeal.withOpacity(0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.1),
        elevation: 12,
        shadowColor: softTeal.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: whisperWhite, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: lightGray, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: whisperWhite, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: whisperWhite, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: whisperWhite, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightGray, fontWeight: FontWeight.w500),
      ),
      dividerColor: softTeal.withOpacity(0.3),
      iconTheme: IconThemeData(color: softTeal),
      primaryIconTheme: IconThemeData(color: softTeal),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: softTeal.withOpacity(0.2),
        labelStyle: TextStyle(color: whisperWhite),
        secondaryLabelStyle: TextStyle(color: deepSlate),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: softTeal.withOpacity(0.3), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: softTeal,
        foregroundColor: whisperWhite,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedItemColor: softTeal,
        unselectedItemColor: lightGray,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
