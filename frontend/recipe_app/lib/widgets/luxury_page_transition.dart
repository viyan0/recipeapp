import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String transitionType;

  LuxuryPageRoute({
    required this.child,
    this.transitionType = 'slide',
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: 800),
          reverseTransitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case 'slide':
                return _buildSlideTransition(animation, secondaryAnimation, child);
              case 'fade':
                return _buildFadeTransition(animation, secondaryAnimation, child);
              case 'scale':
                return _buildScaleTransition(animation, secondaryAnimation, child);
              case 'parallax':
                return _buildParallaxTransition(animation, secondaryAnimation, child);
              default:
                return _buildSlideTransition(animation, secondaryAnimation, child);
            }
          },
        );

  static Widget _buildSlideTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide transition with blur effect
    final slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    final blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return Stack(
      children: [
        // Background blur effect
        AnimatedBuilder(
          animation: secondaryAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: ThemeProvider.deepBlack.withOpacity(0.8 * secondaryAnimation.value),
              ),
            );
          },
        ),
        
        // Main content
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        ),
      ],
    );
  }

  static Widget _buildFadeTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }

  static Widget _buildScaleTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    ));

    final rotationAnimation = Tween<double>(
      begin: 0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return Transform.scale(
      scale: scaleAnimation.value,
      child: Transform.rotate(
        angle: rotationAnimation.value,
        child: child,
      ),
    );
  }

  static Widget _buildParallaxTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    final parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    return Stack(
      children: [
        // Parallax background
        AnimatedBuilder(
          animation: parallaxAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeProvider.luxuryGold.withOpacity(0.1 * parallaxAnimation.value),
                    ThemeProvider.deepBlack,
                    ThemeProvider.luxuryGold.withOpacity(0.05 * parallaxAnimation.value),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Main content with parallax effect
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, -20 * (1 - parallaxAnimation.value)),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class LuxuryHeroRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;

  LuxuryHeroRoute({
    required this.child,
    required this.heroTag,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: 1000),
          reverseTransitionDuration: Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildHeroTransition(animation, secondaryAnimation, child);
          },
        );

  static Widget _buildHeroTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    final glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return Stack(
      children: [
        // Glow effect
        AnimatedBuilder(
          animation: glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    ThemeProvider.luxuryGold.withOpacity(0.2 * glowAnimation.value),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Main content
        ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        ),
      ],
    );
  }
}

// Custom route transitions for different navigation patterns
class LuxuryRouteTransitions {
  static Route<T> slideTransition<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return LuxuryPageRoute<T>(
      child: page,
      transitionType: 'slide',
      settings: settings,
    );
  }

  static Route<T> fadeTransition<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return LuxuryPageRoute<T>(
      child: page,
      transitionType: 'fade',
      settings: settings,
    );
  }

  static Route<T> scaleTransition<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return LuxuryPageRoute<T>(
      child: page,
      transitionType: 'scale',
      settings: settings,
    );
  }

  static Route<T> parallaxTransition<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return LuxuryPageRoute<T>(
      child: page,
      transitionType: 'parallax',
      settings: settings,
    );
  }

  static Route<T> heroTransition<T extends Object?>(
    Widget page, {
    required String heroTag,
    RouteSettings? settings,
  }) {
    return LuxuryHeroRoute<T>(
      child: page,
      heroTag: heroTag,
      settings: settings,
    );
  }
}
