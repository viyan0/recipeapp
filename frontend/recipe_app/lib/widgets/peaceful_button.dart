import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class PeacefulButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const PeacefulButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  _PeacefulButtonState createState() => _PeacefulButtonState();
}

class _PeacefulButtonState extends State<PeacefulButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _hoverController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  void _onHoverEnter() {
    _hoverController.forward();
  }

  void _onHoverExit() {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? ThemeProvider.darkGrey;
    final textColor = widget.textColor ?? Colors.white;
    
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rippleAnimation, _hoverAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverAnimation.value * _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height ?? 56,
                padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.isOutlined ? Colors.transparent : bgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: ThemeProvider.goldPrimary, width: widget.isOutlined ? 2 : 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeProvider.goldPrimary.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: ThemeProvider.goldLight.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 2,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Amazing ripple bloom effect
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: _rippleAnimation.value * 2.6,
                              colors: [
                                ThemeProvider.goldLight.withOpacity(0.25 * (1 - _rippleAnimation.value)),
                                ThemeProvider.goldPrimary.withOpacity(0.4 * (1 - _rippleAnimation.value)),
                                ThemeProvider.goldDeep.withOpacity(0.25 * (1 - _rippleAnimation.value)),
                                Colors.transparent,
                              ],
                              stops: [
                                0.0,
                                0.3 * _rippleAnimation.value,
                                0.6 * _rippleAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Shimmer effect overlay
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment(-1.0 + (2.0 * _rippleAnimation.value), -0.3),
                              end: Alignment(1.0 + (2.0 * _rippleAnimation.value), 0.3),
                              colors: [
                                Colors.transparent,
                                ThemeProvider.goldPrimary.withOpacity(0.35 * (1 - _rippleAnimation.value)),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Button content
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(textColor),
                              ),
                            )
                          else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: textColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
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
      ),
    );
  }
}

class PeacefulIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const PeacefulIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 24,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _PeacefulIconButtonState createState() => _PeacefulIconButtonState();
}

class _PeacefulIconButtonState extends State<PeacefulIconButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _hoverController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  void _onHoverEnter() {
    _hoverController.forward();
  }

  void _onHoverExit() {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? ThemeProvider.blushPink;
    final bgColor = widget.backgroundColor ?? Colors.white.withOpacity(0.2);
    
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rippleAnimation, _hoverAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _hoverAnimation.value * _scaleAnimation.value,
                child: Container(
                  width: widget.size + 20,
                  height: widget.size + 20,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                    // Main depth shadow
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                    // Inner glow effect
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, -4),
                    ),
                    // Outer magical glow
                    BoxShadow(
                      color: iconColor.withOpacity(0.15),
                      blurRadius: 35,
                      spreadRadius: 0,
                      offset: Offset(0, 12),
                    ),
                    // Top highlight
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: Offset(0, -8),
                    ),
                  ],
                  ),
                  child: Stack(
                    children: [
                      // Amazing ripple bloom effect
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: _rippleAnimation.value * 2.5,
                                colors: [
                                  Colors.white.withOpacity(0.7 * (1 - _rippleAnimation.value)),
                                  iconColor.withOpacity(0.5 * (1 - _rippleAnimation.value)),
                                  ThemeProvider.softBlush.withOpacity(0.2 * (1 - _rippleAnimation.value)),
                                  Colors.transparent,
                                ],
                                stops: [
                                  0.0,
                                  0.4 * _rippleAnimation.value,
                                  0.7 * _rippleAnimation.value,
                                  1.0,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Icon
                      Center(
                        child: Icon(
                          widget.icon,
                          color: iconColor,
                          size: widget.size,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
