import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';

class BreathingCircle extends StatefulWidget {
  final double size;
  final Duration breathingDuration;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showPulse;
  final bool showRipple;

  const BreathingCircle({
    Key? key,
    this.size = 120.0,
    this.breathingDuration = const Duration(seconds: 4),
    this.primaryColor,
    this.secondaryColor,
    this.showPulse = true,
    this.showRipple = true,
  }) : super(key: key);

  @override
  _BreathingCircleState createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main breathing animation - slow and calming
    _breathingController = AnimationController(
      duration: widget.breathingDuration,
      vsync: this,
    );
    
    // Pulse animation for inner glow
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Ripple animation for outer waves
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _breathingController.repeat(reverse: true);
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
    if (widget.showRipple) {
      _rippleController.repeat();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? ThemeProvider.roseGold;
    final secondaryColor = widget.secondaryColor ?? ThemeProvider.softLavender;
    
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingAnimation,
          _pulseAnimation,
          _rippleAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple waves
              if (widget.showRipple) ...[
                ...List.generate(3, (index) {
                  final delay = index * 0.3;
                  final rippleValue = (_rippleAnimation.value - delay).clamp(0.0, 1.0);
                  final scale = 1.0 + (rippleValue * 0.8);
                  final opacity = (1.0 - rippleValue) * 0.3;
                  
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(opacity),
                          width: 2.0,
                        ),
                      ),
                    ),
                  );
                }),
              ],
              
              // Main breathing circle
              Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.9),
                        primaryColor.withOpacity(0.7),
                        secondaryColor.withOpacity(0.5),
                        secondaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                    ),
                    boxShadow: [
                      // Main glow
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      // Outer soft glow
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.2),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: -5,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Inner pulsing glow
              if (widget.showPulse)
                Transform.scale(
                  scale: 0.6 + (_pulseAnimation.value * 0.4),
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.8 * _pulseAnimation.value),
                          primaryColor.withOpacity(0.6 * _pulseAnimation.value),
                          secondaryColor.withOpacity(0.4 * _pulseAnimation.value),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              
              // Center breathing dot
              Transform.scale(
                scale: 0.3 + (_breathingAnimation.value * 0.1),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BreathingCircleOverlay extends StatelessWidget {
  final Widget child;
  final bool showBreathingCircle;
  final double circleSize;
  final Duration breathingDuration;

  const BreathingCircleOverlay({
    Key? key,
    required this.child,
    this.showBreathingCircle = true,
    this.circleSize = 100.0,
    this.breathingDuration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showBreathingCircle)
          Positioned(
            top: 50,
            right: 20,
            child: BreathingCircle(
              size: circleSize,
              breathingDuration: breathingDuration,
              primaryColor: ThemeProvider.roseGold,
              secondaryColor: ThemeProvider.softLavender,
            ),
          ),
      ],
    );
  }
}

class BreathingCircleBackground extends StatelessWidget {
  final Widget child;
  final bool showBreathingCircles;
  final int numberOfCircles;

  const BreathingCircleBackground({
    Key? key,
    required this.child,
    this.showBreathingCircles = true,
    this.numberOfCircles = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showBreathingCircles) {
      return child;
    }

    return Stack(
      children: [
        child,
        // Multiple breathing circles in background
        ...List.generate(numberOfCircles, (index) {
          final size = 80.0 + (index * 40.0);
          final duration = Duration(seconds: 4 + (index * 2));
          final colors = [
            [ThemeProvider.roseGold, ThemeProvider.softLavender],
            [ThemeProvider.blushPink, ThemeProvider.dreamyMint],
            [ThemeProvider.softRoseGold, ThemeProvider.gentleMint],
          ];
          
          return Positioned(
            top: 100.0 + (index * 150.0),
            left: 50.0 + (index * 100.0),
            child: BreathingCircle(
              size: size,
              breathingDuration: duration,
              primaryColor: colors[index % colors.length][0],
              secondaryColor: colors[index % colors.length][1],
              showPulse: index % 2 == 0,
              showRipple: true,
            ),
          );
        }),
      ],
    );
  }
}
