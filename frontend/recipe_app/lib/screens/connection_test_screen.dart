import 'package:flutter/material.dart';
import '../services/connection_test.dart';
import '../providers/theme_provider.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({Key? key}) : super(key: key);

  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  Map<String, dynamic>? _connectionResult;
  Map<String, dynamic>? _authResult;
  Map<String, dynamic>? _recipeResult;
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ConnectionTestService.testConnection();
      setState(() {
        _connectionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _connectionResult = {
          'success': false,
          'message': 'Error: $e',
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuthEndpoint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ConnectionTestService.testAuthEndpoint();
      setState(() {
        _authResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _authResult = {
          'success': false,
          'message': 'Error: $e',
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _testRecipeEndpoint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ConnectionTestService.testRecipeEndpoint();
      setState(() {
        _recipeResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _recipeResult = {
          'success': false,
          'message': 'Error: $e',
        };
        _isLoading = false;
      });
    }
  }

  Widget _buildResultCard(String title, Map<String, dynamic>? result) {
    if (result == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: result['success'] == true ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result['message'] ?? 'No message',
                style: TextStyle(
                  color: result['success'] == true ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
            if (result['statusCode'] != null) ...[
              const SizedBox(height: 8),
              Text('Status Code: ${result['statusCode']}'),
            ],
            if (result['data'] != null) ...[
              const SizedBox(height: 8),
              Text('Data: ${result['data']}'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test your connection to the backend server',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Basic Connection'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuthEndpoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test Auth Endpoint'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testRecipeEndpoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeProvider.enchantedEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test Recipe Endpoint'),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildResultCard('Basic Connection Test', _connectionResult),
                    _buildResultCard('Auth Endpoint Test', _authResult),
                    _buildResultCard('Recipe Endpoint Test', _recipeResult),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
