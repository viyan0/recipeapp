import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryLoadingIndicator extends StatefulWidget {
  final double size;
  final String? message;
  final Color? color;

  const LuxuryLoadingIndicator({
    Key? key,
    this.size = 50,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  _LuxuryLoadingIndicatorState createState() => _LuxuryLoadingIndicatorState();
}

class _LuxuryLoadingIndicatorState extends State<LuxuryLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _rotationAnimation,
            _pulseAnimation,
            _glowAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.color ?? ThemeProvider.luxuryGold)
                          .withOpacity(0.4 * _glowAnimation.value),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: LuxurySpinnerPainter(
                    progress: _rotationAnimation.value,
                    color: widget.color ?? ThemeProvider.luxuryGold,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: ThemeProvider.platinum,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class LuxurySpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  LuxurySpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.14159 / 180); // Start from top
    final sweepAngle = 270 * progress * (3.14159 / 180); // 3/4 circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glowing dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(LuxurySpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class LuxuryProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final Duration animationDuration;

  const LuxuryProgressBar({
    Key? key,
    required this.progress,
    this.height = 6,
    this.color,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _LuxuryProgressBarState createState() => _LuxuryProgressBarState();
}

class _LuxuryProgressBarState extends State<LuxuryProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(LuxuryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? ThemeProvider.charcoal,
        borderRadius: BorderRadius.circular(widget.height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                colors: [
                  widget.color ?? ThemeProvider.luxuryGold,
                  widget.color ?? ThemeProvider.warmGold,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? ThemeProvider.luxuryGold).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * _animation.value,
          );
        },
      ),
    );
  }
}


