import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryFavoritesHeart extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final bool isToggling;
  final double size;

  const LuxuryFavoritesHeart({
    Key? key,
    required this.isFavorite,
    this.onTap,
    this.isToggling = false,
    this.size = 24,
  }) : super(key: key);

  @override
  _LuxuryFavoritesHeartState createState() => _LuxuryFavoritesHeartState();
}

class _LuxuryFavoritesHeartState extends State<LuxuryFavoritesHeart>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _fillController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.isFavorite) {
      _fillController.forward();
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(LuxuryFavoritesHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _fillController.forward();
        _pulseController.repeat(reverse: true);
        _shimmerController.repeat();
        _rippleController.forward().then((_) {
          _rippleController.reset();
        });
      } else {
        _fillController.reverse();
        _pulseController.stop();
        _pulseController.reset();
        _shimmerController.stop();
        _shimmerController.reset();
      }
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.isToggling) {
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: widget.size + 16,
        height: widget.size + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return Container(
                  width: (widget.size + 16) * (1 + _rippleAnimation.value * 0.5),
                  height: (widget.size + 16) * (1 + _rippleAnimation.value * 0.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ThemeProvider.luxuryGold.withOpacity(0.3 * (1 - _rippleAnimation.value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Heart container
            AnimatedBuilder(
              animation: Listenable.merge([
                _fillAnimation,
                _pulseAnimation,
                _shimmerAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isFavorite ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: widget.size + 8,
                    height: widget.size + 8,
                    decoration: BoxDecoration(
                      color: ThemeProvider.richBlack,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.isFavorite 
                            ? ThemeProvider.luxuryGold
                            : ThemeProvider.luxuryGold.withOpacity(0.3),
                        width: widget.isFavorite ? 2 : 1,
                      ),
                      boxShadow: [
                        if (widget.isFavorite)
                          BoxShadow(
                            color: ThemeProvider.luxuryGold.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shimmer effect
                        if (widget.isFavorite)
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment(_shimmerAnimation.value - 1, 0),
                                    end: Alignment(_shimmerAnimation.value, 0),
                                    colors: [
                                      Colors.transparent,
                                      ThemeProvider.luxuryGold.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Heart icon
                        Center(
                          child: widget.isToggling
                              ? SizedBox(
                                  width: widget.size * 0.6,
                                  height: widget.size * 0.6,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeProvider.luxuryGold),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    // Liquid fill effect
                                    if (widget.isFavorite)
                                      AnimatedBuilder(
                                        animation: _fillAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            width: widget.size,
                                            height: widget.size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  ThemeProvider.luxuryGold.withOpacity(0.8 * _fillAnimation.value),
                                                  ThemeProvider.luxuryGold.withOpacity(0.4 * _fillAnimation.value),
                                                  Colors.transparent,
                                                ],
                                                stops: [
                                                  0.0,
                                                  0.7 * _fillAnimation.value,
                                                  1.0,
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    
                                    // Heart icon
                                    Icon(
                                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: widget.isFavorite 
                                          ? ThemeProvider.luxuryGold
                                          : ThemeProvider.silver,
                                      size: widget.size,
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
