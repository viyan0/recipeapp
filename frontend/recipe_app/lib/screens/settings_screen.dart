import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _currentUser;
  bool _isVegetarian = false;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUserData();
    setState(() {
      _currentUser = user;
      _isVegetarian = user?.isVegetarian ?? false;
    });
  }

  Future<void> _updateDietaryPreference(bool isVegetarian) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = await AuthService.updateDietaryPreference(
        userId: _currentUser!.id,
        isVegetarian: isVegetarian,
      );
      
      setState(() {
        _currentUser = updatedUser;
        _isVegetarian = isVegetarian;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVegetarian 
              ? 'Dietary preference updated to Vegetarian' 
              : 'Dietary preference updated to Non-Vegetarian',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update dietary preference: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout? Your account data will remain in the database.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout', style: TextStyle(color: ThemeProvider.enchantedEmerald)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Future<void> _deleteAccount() async {
    if (_currentUser == null) return;

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account', style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to permanently delete your account?'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ This action cannot be undone!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• All your data will be permanently deleted from the database\n'
                      '• Your favorites and preferences will be lost\n'
                      '• You will need to create a new account to use the app again',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete Account', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        final success = await AuthService.deleteAccount(userId: _currentUser!.id);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      } catch (e) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentUser != null) ...[
                _buildProfileInfo('Username', _currentUser!.username),
                _buildProfileInfo('Email', _currentUser!.email),
                _buildProfileInfo('Dietary Preference', 
                  _currentUser!.isVegetarian ? 'Vegetarian' : 'Non-Vegetarian'),
                _buildProfileInfo('Member Since', 
                  '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}'),
              ] else
                Text('No user data available'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: ThemeProvider.enchantedEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: ThemeProvider.enchantedEmerald, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_currentUser != null) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: ThemeProvider.whisperGreen.withOpacity(0.3),
                        child: Text(
                          _currentUser!.username.isNotEmpty 
                            ? _currentUser!.username[0].toUpperCase()
                            : 'U',
                          style: TextStyle(
                            color: ThemeProvider.enchantedEmerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        _currentUser!.username,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_currentUser!.email),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showProfileDialog,
                    ),
                  ] else
                    Text(
                      'No user data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Dietary Preferences Section
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: ThemeProvider.enchantedEmerald, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Dietary Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Vegetarian'),
                    subtitle: Text('Enable to see only vegetarian recipes'),
                    value: _isVegetarian,
                    onChanged: _isLoading ? null : (bool value) {
                      _updateDietaryPreference(value);
                    },
                    activeColor: ThemeProvider.enchantedEmerald,
                    secondary: Icon(
                      _isVegetarian ? Icons.eco : Icons.restaurant,
                      color: _isVegetarian ? Colors.green : Colors.grey[600],
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ThemeProvider.enchantedEmerald!),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Updating preference...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Theme Section
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: ThemeProvider.enchantedEmerald, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Switch between light and dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      themeProvider.setTheme(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value 
                              ? 'Switched to dark mode' 
                              : 'Switched to light mode'
                          ),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    activeColor: ThemeProvider.enchantedEmerald,
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: themeProvider.isDarkMode ? Colors.amber : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Account Actions Section
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle, color: ThemeProvider.enchantedEmerald, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Logout option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout, color: ThemeProvider.enchantedEmerald),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: ThemeProvider.enchantedEmerald,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('Sign out of your account (data remains in database)'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _logout,
                  ),
                  
                  Divider(),
                  
                  // Delete account option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _isDeleting 
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : Icon(Icons.delete_forever, color: Colors.red[600]),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('Permanently delete your account and all data'),
                    trailing: _isDeleting ? null : Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _isDeleting ? null : _deleteAccount,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Recipe App',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}