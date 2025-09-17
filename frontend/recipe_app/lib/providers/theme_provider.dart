import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false; // Default to beautiful peaceful greenish light theme
  static const String _themeKey = 'isDarkMode';

  // Calm and Peaceful Lavender-to-Mint Gradient Palette
  static const Color softLavender = Color(0xFFE8D5F2);  // Light lavender
  static const Color gentleLavender = Color(0xFFD4C4E8);  // Medium lavender
  static const Color dreamyMint = Color(0xFFD4F1D4);  // Light mint
  static const Color whisperMint = Color(0xFFB8E6D1);  // Soft mint
  static const Color serenityMint = Color(0xFF9FD3C7);  // Medium mint
  static const Color peacefulSage = Color(0xFF7FB3B3);  // Sage-mint blend
  static const Color enchantedEmerald = Color(0xFF6B9B9B);  // Deeper mint
  static const Color mysticJade = Color(0xFF5A8A8A);  // Dark mint
  static const Color forestWhisper = Color(0xFF4A7A7A);  // Deep mint
  static const Color deepForest = Color(0xFF3A6A6A);  // Darkest mint
  static const Color silverMist = Color(0xFFA8C8C8);  // Silver-mint blend
  
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
  
  // Charcoal Gray Text Colors for Calm Design
  static const Color deepSlate = Color(0xFF2D3748);  // Charcoal gray
  static const Color softGray = Color(0xFF4A5568);  // Medium charcoal
  static const Color lightGray = Color(0xFF718096);  // Light charcoal
  static const Color whisperWhite = Color(0xFFF7FAFC);  // Soft white
  static const Color emeraldText = Color(0xFF2D3748);  // Charcoal gray for main text
  static const Color sageDark = Color(0xFF4A5568);  // Medium charcoal for secondary text
  
  // Blush Pink Button Colors for Calm Design
  static const Color blushPink = Color(0xFFFFB3C1);  // Main blush pink
  static const Color softBlush = Color(0xFFFFC7D1);  // Light blush pink
  static const Color gentleBlush = Color(0xFFFFD1DB);  // Very light blush
  static const Color deepBlush = Color(0xFFFF9FB1);  // Deeper blush pink
  static const Color rosePetal = Color(0xFFFFB3C1);  // Rose petal pink
  static const Color warmAmber = Color(0xFFFFB74D);  // Warm accent
  static const Color peacefulPurple = Color(0xFF9575CD);  // Purple accent
  static const Color goldDust = Color(0xFFFFE08A);  // Gold accent
  // Gold palette for black theme
  static const Color goldPrimary = Color(0xFFFFC107); // amber 500
  static const Color goldLight = Color(0xFFFFD54F);   // amber 300
  static const Color goldDeep = Color(0xFFFFB300);    // amber 700
  static const Color darkGrey = Color(0xFF1E1E1E);
  static const Color midGrey = Color(0xFF2A2A2A);

  // Backwards-compatible aliases to avoid breaking existing widgets
  // Map previous green/teal names to the new calm palette
  static const Color softTeal = deepBlush;          // previously teal accents → use deeper blush
  static const Color gentleCoral = blushPink;       // coral accents → blush pink
  static const Color whisperGreen = whisperMint;    // old name mapped to new mint
  static const Color serenityGreen = serenityMint;  // old name mapped to new mint

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
      primarySwatch: Colors.amber,
      primaryColor: goldPrimary,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: goldLight,
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
          backgroundColor: darkGrey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 12,
          shadowColor: goldPrimary.withOpacity(0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: BorderSide(color: goldPrimary, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkGrey,
        elevation: 16,
        shadowColor: goldPrimary.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: goldPrimary, width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.3),
        bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 0.2),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: goldPrimary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: goldLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: goldPrimary, width: 1.5),
        ),
        fillColor: darkGrey,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: deepBlush,
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
          backgroundColor: deepBlush,
          foregroundColor: whisperWhite,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: deepBlush.withOpacity(0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.1),
        elevation: 12,
        shadowColor: deepBlush.withOpacity(0.1),
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
      dividerColor: deepBlush.withOpacity(0.3),
      iconTheme: IconThemeData(color: deepBlush),
      primaryIconTheme: IconThemeData(color: deepBlush),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: deepBlush.withOpacity(0.2),
        labelStyle: TextStyle(color: whisperWhite),
        secondaryLabelStyle: TextStyle(color: deepSlate),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: deepBlush.withOpacity(0.3), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: deepBlush,
        foregroundColor: whisperWhite,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedItemColor: deepBlush,
        unselectedItemColor: lightGray,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
