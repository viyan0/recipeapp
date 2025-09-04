import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const LuxuryChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  _LuxuryChipState createState() => _LuxuryChipState();
}

class _LuxuryChipState extends State<LuxuryChip>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
      _glowController.forward();
    }
  }

  @override
  void didUpdateWidget(LuxuryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
        _glowController.forward();
      } else {
        _pulseController.stop();
        _pulseController.reset();
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, child) {
          final glowIntensity = widget.isSelected ? _glowAnimation.value : 0.0;
          final pulseScale = widget.isSelected ? _pulseAnimation.value : 1.0;
          
          return Transform.scale(
            scale: pulseScale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? ThemeProvider.luxuryGold.withOpacity(0.2)
                    : ThemeProvider.richBlack,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected 
                      ? ThemeProvider.luxuryGold
                      : ThemeProvider.luxuryGold.withOpacity(0.5),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: ThemeProvider.luxuryGold.withOpacity(0.4 * glowIntensity),
                      blurRadius: 8 * glowIntensity,
                      spreadRadius: 2 * glowIntensity,
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isSelected 
                          ? ThemeProvider.luxuryGold
                          : ThemeProvider.silver,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected 
                          ? ThemeProvider.luxuryGold
                          : ThemeProvider.platinum,
                      fontSize: 14,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LuxuryFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const LuxuryFilterChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  }) : super(key: key);

  @override
  _LuxuryFilterChipState createState() => _LuxuryFilterChipState();
}

class _LuxuryFilterChipState extends State<LuxuryFilterChip>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
      _glowController.forward();
    }
  }

  @override
  void didUpdateWidget(LuxuryFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
        _glowController.forward();
      } else {
        _pulseController.stop();
        _pulseController.reset();
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelected?.call(!widget.isSelected),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, child) {
          final glowIntensity = widget.isSelected ? _glowAnimation.value : 0.0;
          final pulseScale = widget.isSelected ? _pulseAnimation.value : 1.0;
          
          return Transform.scale(
            scale: pulseScale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? ThemeProvider.luxuryGold.withOpacity(0.15)
                    : ThemeProvider.richBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected 
                      ? ThemeProvider.luxuryGold
                      : ThemeProvider.luxuryGold.withOpacity(0.4),
                  width: widget.isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: ThemeProvider.luxuryGold.withOpacity(0.3 * glowIntensity),
                      blurRadius: 6 * glowIntensity,
                      spreadRadius: 1 * glowIntensity,
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isSelected 
                          ? ThemeProvider.luxuryGold
                          : ThemeProvider.silver,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected 
                          ? ThemeProvider.luxuryGold
                          : ThemeProvider.platinum,
                      fontSize: 12,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
