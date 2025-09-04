import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxurySnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? ThemeProvider.luxuryGold,
                size: 20,
              ),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? ThemeProvider.platinum,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: ThemeProvider.luxuryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor ?? ThemeProvider.richBlack,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: ThemeProvider.luxuryGold.withOpacity(0.3),
            width: 1,
          ),
        ),
                 margin: EdgeInsets.all(16),
         elevation: 8,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon ?? Icons.check_circle,
      backgroundColor: ThemeProvider.richBlack,
      textColor: ThemeProvider.luxuryGold,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon ?? Icons.error,
      backgroundColor: ThemeProvider.richBlack,
      textColor: Colors.red[300],
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon ?? Icons.info,
      backgroundColor: ThemeProvider.richBlack,
      textColor: ThemeProvider.silver,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon ?? Icons.warning,
      backgroundColor: ThemeProvider.richBlack,
      textColor: Colors.orange[300],
      duration: duration,
    );
  }
}

class LuxuryToast extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  final Duration duration;
  final VoidCallback? onDismiss;

  const LuxuryToast({
    Key? key,
    required this.message,
    this.icon,
    this.color,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  }) : super(key: key);

  @override
  _LuxuryToastState createState() => _LuxuryToastState();
}

class _LuxuryToastState extends State<LuxuryToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ThemeProvider.richBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (widget.color ?? ThemeProvider.luxuryGold).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? ThemeProvider.luxuryGold).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.color ?? ThemeProvider.luxuryGold,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: ThemeProvider.platinum,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: ThemeProvider.silver,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
