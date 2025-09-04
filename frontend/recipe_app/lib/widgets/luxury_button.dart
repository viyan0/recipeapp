import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const LuxuryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  _LuxuryButtonState createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _rippleController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTap: widget.onPressed,
      child: Container(
        width: widget.width,
        height: widget.height ?? 56,
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: ThemeProvider.richBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeProvider.luxuryGold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeProvider.luxuryGold.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment(_shimmerAnimation.value - 1, 0),
                      end: Alignment(_shimmerAnimation.value, 0),
                      colors: [
                        Colors.transparent,
                        ThemeProvider.luxuryGold.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Ripple effect
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: _rippleAnimation.value * 2,
                      colors: [
                        ThemeProvider.luxuryGold.withOpacity(0.3 * (1 - _rippleAnimation.value)),
                        Colors.transparent,
                      ],
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
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeProvider.luxuryGold),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: ThemeProvider.luxuryGold,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: ThemeProvider.luxuryGold,
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
  }
}

class LuxuryIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  const LuxuryIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  _LuxuryIconButtonState createState() => _LuxuryIconButtonState();
}

class _LuxuryIconButtonState extends State<LuxuryIconButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _rippleController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTap: widget.onPressed,
        child: Container(
          width: widget.size + 16,
          height: widget.size + 16,
          decoration: BoxDecoration(
            color: ThemeProvider.richBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemeProvider.luxuryGold.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeProvider.luxuryGold.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                        colors: [
                          Colors.transparent,
                          ThemeProvider.luxuryGold.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Ripple effect
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: _rippleAnimation.value * 1.5,
                        colors: [
                          ThemeProvider.luxuryGold.withOpacity(0.4 * (1 - _rippleAnimation.value)),
                          Colors.transparent,
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
                  color: widget.color ?? ThemeProvider.luxuryGold,
                  size: widget.size,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
