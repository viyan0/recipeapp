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
        backgroundColor: ThemeProvider.gentleLavender,
        foregroundColor: ThemeProvider.deepLavender,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: ThemeProvider.gentleLavender,
            border: Border(
              bottom: BorderSide(color: ThemeProvider.deepLavender, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeProvider.lavenderShadow.withOpacity(0.18),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Icon(Icons.favorite, color: ThemeProvider.pastelPink),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              tooltip: 'View Favorites',
            ),
          if (_selectedIndex == 1)
            IconButton(
              icon: Icon(Icons.refresh, color: ThemeProvider.deepLavender),
              onPressed: () {
                _favoritesKey.currentState?.loadFavorites();
              },
              tooltip: 'Refresh',
            ),
          IconButton(
            icon: Icon(Icons.settings, color: ThemeProvider.deepLavender),
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
