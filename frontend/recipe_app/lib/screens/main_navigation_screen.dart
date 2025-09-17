import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<FavoritesScreenState> _favoritesKey = GlobalKey<FavoritesScreenState>();
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SearchScreen(),
      FavoritesScreen(key: _favoritesKey),
    ];
  }



  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Find Recipes' : 'My Favorites'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: ThemeProvider.darkGrey,
            border: Border(
              bottom: BorderSide(color: ThemeProvider.goldPrimary, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeProvider.goldPrimary.withOpacity(0.25),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          if (_selectedIndex == 0) // Show favorites button on search tab
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              tooltip: 'View Favorites',
            ),
          if (_selectedIndex == 1) // Show refresh only on favorites tab
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _favoritesKey.currentState?.loadFavorites();
              },
              tooltip: 'Refresh',
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _goToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}
