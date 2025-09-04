import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryShimmer extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final Color? shimmerColor;

  const LuxuryShimmer({
    Key? key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(seconds: 2),
    this.shimmerColor,
  }) : super(key: key);

  @override
  _LuxuryShimmerState createState() => _LuxuryShimmerState();
}

class _LuxuryShimmerState extends State<LuxuryShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LuxuryShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.transparent,
                widget.shimmerColor ?? ThemeProvider.luxuryGold.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class LuxuryGlowEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color? glowColor;
  final double intensity;

  const LuxuryGlowEffect({
    Key? key,
    required this.child,
    this.isActive = true,
    this.glowColor,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  _LuxuryGlowEffectState createState() => _LuxuryGlowEffectState();
}

class _LuxuryGlowEffectState extends State<LuxuryGlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LuxuryGlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: (widget.glowColor ?? ThemeProvider.luxuryGold)
                    .withOpacity(0.3 * widget.intensity * _animation.value),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class LuxuryHoverEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final Duration duration;

  const LuxuryHoverEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.05,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _LuxuryHoverEffectState createState() => _LuxuryHoverEffectState();
}

class _LuxuryHoverEffectState extends State<LuxuryHoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() {
      _isHovered = true;
    });
    _controller.forward();
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: ThemeProvider.luxuryGold
                                .withOpacity(0.2 * _glowAnimation.value),
                            blurRadius: 15 * _glowAnimation.value,
                            spreadRadius: 3 * _glowAnimation.value,
                          ),
                        ]
                      : null,
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
