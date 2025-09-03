import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import '../services/auth_service.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _showMenuDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  _logout();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Find Recipes' : 'My Favorites'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
            icon: Icon(Icons.menu),
            onPressed: _showMenuDialog,
            tooltip: 'Menu',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
