import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'otp_verification_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isSignUp = false;
  bool _isVegetarian = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isSignUp = args['mode'] == 'signup';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSignUp) {
        // Handle signup with OTP verification
        final signupResult = await AuthService.signUp(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          isVegetarian: _isVegetarian,
        );

        if (signupResult['success'] == true && signupResult['needsVerification'] == true) {
          // Check if email was sent or if we have a development OTP
          String? developmentOTP = signupResult['developmentOTP'];
          bool emailSent = signupResult['verificationEmailSent'] ?? false;
          
          // Show appropriate message
          if (!emailSent && developmentOTP != null) {
            // Development mode - show OTP in dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Development Mode'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email could not be sent (Resend restriction).'),
                    SizedBox(height: 8),
                    Text('Your verification code is:'),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        developmentOTP,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to OTP verification screen
                      _navigateToOTPVerification(signupResult);
                    },
                    child: Text('Continue to Verification'),
                  ),
                ],
              ),
            );
          } else {
            // Normal flow - navigate directly to verification
            _navigateToOTPVerification(signupResult);
          }
        }
      } else {
        // Handle login
        User user = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Navigate to search screen
        Navigator.pushReplacementNamed(context, '/search');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToOTPVerification(Map<String, dynamic> signupResult) async {
    final verificationResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          email: signupResult['email'],
          username: signupResult['username'],
        ),
      ),
    );

    if (verificationResult == true) {
      // Email verified successfully, show success message and switch to login
      setState(() {
        _isSignUp = false;
        _errorMessage = '';
        _passwordController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email verified successfully! Please log in to continue.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Log In'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  _isSignUp ? 'Create Your Account' : 'Welcome Back',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _isSignUp 
                    ? 'Join us to discover amazing recipes'
                    : 'Sign in to continue cooking',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Username field (only for signup)
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.trim().length < AppConfig.minUsernameLength) {
                        return 'Username must be at least ${AppConfig.minUsernameLength} characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (_isSignUp && value.length < AppConfig.minPasswordLength) {
                      return 'Password must be at least ${AppConfig.minPasswordLength} characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Dietary preference (only for signup)
                if (_isSignUp) ...[
                  Text(
                    'Dietary Preference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isVegetarian = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _isVegetarian ? Colors.orange[100] : Colors.grey[100],
                              border: Border.all(
                                color: _isVegetarian ? Colors.orange[600]! : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.eco,
                                  color: _isVegetarian ? Colors.orange[600] : Colors.grey[600],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Vegetarian',
                                  style: TextStyle(
                                    color: _isVegetarian ? Colors.orange[600] : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isVegetarian = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: !_isVegetarian ? Colors.orange[100] : Colors.grey[100],
                              border: Border.all(
                                color: !_isVegetarian ? Colors.orange[600]! : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: !_isVegetarian ? Colors.orange[600] : Colors.grey[600],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Non-Vegetarian',
                                  style: TextStyle(
                                    color: !_isVegetarian ? Colors.orange[600] : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],

                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_errorMessage.isNotEmpty) SizedBox(height: 16),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isSignUp ? 'Sign Up' : 'Log In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                ),
                SizedBox(height: 16),

                // Toggle between login/signup
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _errorMessage = '';
                      _emailController.clear();
                      _usernameController.clear();
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    _isSignUp 
                      ? 'Already have an account? Log In'
                      : 'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.orange[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
