import 'package:flutter/material.dart';
import '../widgets/peaceful_background.dart';
import '../widgets/peaceful_button.dart';
import '../widgets/peaceful_transitions.dart';
import '../providers/theme_provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PeacefulBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                  MediaQuery.of(context).padding.top - 
                  MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // Beautiful app icon with animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              ThemeProvider.dreamyLavender,
                              ThemeProvider.gentleLavender,
                              ThemeProvider.pastelPink,
                            ],
                            stops: [0.0, 0.7, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.lavenderShadow.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 1,
                              offset: Offset(0, 15),
                            ),
                            BoxShadow(
                              color: ThemeProvider.pastelPink.withOpacity(0.18),
                              blurRadius: 60,
                              spreadRadius: 2,
                              offset: Offset(0, 25),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 60,
                          color: ThemeProvider.deepLavender,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
                
                // Beautiful welcome message
                FrostedGlassCard(
                  padding: EdgeInsets.all(24),
                  backgroundColor: ThemeProvider.cardBackground,
                  child: Column(
                    children: [
                      Text(
                        'Oh, let\'s make delicious food!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: ThemeProvider.deepLavender,
                          letterSpacing: 1.2,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      
                      Text(
                        'Discover amazing recipes based on what you have in your kitchen',
                        style: TextStyle(
                          fontSize: 18,
                          color: ThemeProvider.gentleLavender,
                          letterSpacing: 0.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                
                // Beautiful buttons
                Column(
                  children: [
                    PeacefulButton(
                      text: 'Start Your Culinary Journey',
                      icon: Icons.restaurant_rounded,
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth', arguments: {'mode': 'signup'});
                      },
                      width: double.infinity,
                      height: 64,
                      backgroundColor: ThemeProvider.dreamyLavender,
                    ),
                    SizedBox(height: 20),
                    
                    PeacefulButton(
                      text: 'Welcome Back, Chef!',
                      icon: Icons.login_rounded,
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth', arguments: {'mode': 'login'});
                      },
                      width: double.infinity,
                      height: 64,
                      backgroundColor: ThemeProvider.pastelPink,
                      isOutlined: false,
                    ),
                  ],
                ),
                SizedBox(height: 30),
                
                // Subtle footer
                Text(
                  '✨ Let\'s create magic in your kitchen ✨',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeProvider.deepLavender,
                    letterSpacing: 0.8,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
