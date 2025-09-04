import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import '../widgets/peaceful_background.dart';
import '../widgets/peaceful_button.dart';
import '../providers/theme_provider.dart';
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
                        color: ThemeProvider.whisperGreen.withOpacity(0.3),
                        border: Border.all(color: ThemeProvider.peacefulSage),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        developmentOTP,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: ThemeProvider.emeraldText,
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
        Navigator.pushReplacementNamed(context, '/main');
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
      body: PeacefulBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Beautiful header section
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 40),
                  child: Row(
                    children: [
                      PeacefulIconButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onPressed: () => Navigator.pop(context),
                        size: 20,
                        color: ThemeProvider.emeraldText,
                        backgroundColor: ThemeProvider.cottonCloud.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ThemeProvider.emeraldText,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 44), // Balance the back button
                    ],
                  ),
                ),

                // Main form card
                FrostedGlassCard(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header text
                        Text(
                          _isSignUp 
                            ? 'Join our culinary community'
                            : 'Continue your cooking journey',
                          style: TextStyle(
                            fontSize: 18,
                            color: ThemeProvider.sageDark,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),

                        // Username field (only for signup)
                        if (_isSignUp) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeProvider.enchantedEmerald.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _usernameController,
                              style: TextStyle(
                                color: ThemeProvider.emeraldText,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                  color: ThemeProvider.peacefulSage,
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: ThemeProvider.enchantedEmerald,
                                ),
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
                          ),
                          SizedBox(height: 24),
                        ],

                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeProvider.enchantedEmerald.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: ThemeProvider.emeraldText,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: ThemeProvider.peacefulSage,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: ThemeProvider.enchantedEmerald,
                              ),
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
                        ),
                        SizedBox(height: 24),

                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeProvider.enchantedEmerald.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              color: ThemeProvider.emeraldText,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: ThemeProvider.peacefulSage,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: ThemeProvider.enchantedEmerald,
                              ),
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
                        ),
                        SizedBox(height: 32),

                        // Dietary preference (only for signup)
                        if (_isSignUp) ...[
                          Text(
                            'Dietary Preference',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ThemeProvider.emeraldText,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isVegetarian = true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: _isVegetarian 
                                          ? LinearGradient(
                                              colors: [
                                                ThemeProvider.enchantedEmerald.withOpacity(0.2),
                                                ThemeProvider.mysticJade.withOpacity(0.1),
                                              ],
                                            )
                                          : null,
                                      color: _isVegetarian ? null : ThemeProvider.cottonCloud.withOpacity(0.5),
                                      border: Border.all(
                                        color: _isVegetarian ? ThemeProvider.enchantedEmerald : ThemeProvider.peacefulSage,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: _isVegetarian ? [
                                        BoxShadow(
                                          color: ThemeProvider.enchantedEmerald.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ] : [],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.eco_rounded,
                                          color: _isVegetarian ? ThemeProvider.enchantedEmerald : ThemeProvider.peacefulSage,
                                          size: 28,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Vegetarian',
                                          style: TextStyle(
                                            color: _isVegetarian ? ThemeProvider.emeraldText : ThemeProvider.sageDark,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isVegetarian = false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: !_isVegetarian 
                                          ? LinearGradient(
                                              colors: [
                                                ThemeProvider.enchantedEmerald.withOpacity(0.2),
                                                ThemeProvider.mysticJade.withOpacity(0.1),
                                              ],
                                            )
                                          : null,
                                      color: !_isVegetarian ? null : ThemeProvider.cottonCloud.withOpacity(0.5),
                                      border: Border.all(
                                        color: !_isVegetarian ? ThemeProvider.enchantedEmerald : ThemeProvider.peacefulSage,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: !_isVegetarian ? [
                                        BoxShadow(
                                          color: ThemeProvider.enchantedEmerald.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ] : [],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.restaurant_menu_rounded,
                                          color: !_isVegetarian ? ThemeProvider.enchantedEmerald : ThemeProvider.peacefulSage,
                                          size: 28,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Non-Vegetarian',
                                          style: TextStyle(
                                            color: !_isVegetarian ? ThemeProvider.emeraldText : ThemeProvider.sageDark,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                        ],

                        // Error message
                        if (_errorMessage.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red[50]!.withOpacity(0.8),
                                  Colors.red[25]!.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red[300]!, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[600],
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        // Submit button
                        PeacefulButton(
                          text: _isSignUp ? 'Create Account' : 'Sign In',
                          icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                          onPressed: _isLoading ? null : _submitForm,
                          isLoading: _isLoading,
                          width: double.infinity,
                          height: 64,
                          backgroundColor: ThemeProvider.enchantedEmerald,
                        ),
                        SizedBox(height: 24),

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
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _isSignUp 
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Create One',
                            style: TextStyle(
                              color: ThemeProvider.enchantedEmerald,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
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
