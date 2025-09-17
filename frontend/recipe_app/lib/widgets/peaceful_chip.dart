import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class PeacefulChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const PeacefulChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  _PeacefulChipState createState() => _PeacefulChipState();
}

class _PeacefulChipState extends State<PeacefulChip>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _glowController.forward();
    }
  }

  @override
  void didUpdateWidget(PeacefulChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? ThemeProvider.goldPrimary;
    final unselectedColor = widget.unselectedColor ?? ThemeProvider.goldLight.withOpacity(0.6);
    final currentColor = widget.isSelected ? selectedColor : unselectedColor;
    
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _glowAnimation, _scaleAnimation]),
        builder: (context, child) {
          final glowIntensity = widget.isSelected ? _glowAnimation.value : 0.0;
          final bounceScale = _bounceAnimation.value * _scaleAnimation.value;
          
          return Transform.scale(
            scale: bounceScale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? currentColor.withOpacity(0.18)
                    : Colors.black,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: currentColor.withOpacity(widget.isSelected ? 0.9 : 0.4),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: currentColor.withOpacity(0.3 * glowIntensity),
                      blurRadius: 15 * glowIntensity,
                      spreadRadius: 2 * glowIntensity,
                    ),
                  BoxShadow(
                    color: ThemeProvider.goldPrimary.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: currentColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: currentColor,
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

class PeacefulFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final Color? color;

  const PeacefulFilterChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  _PeacefulFilterChipState createState() => _PeacefulFilterChipState();
}

class _PeacefulFilterChipState extends State<PeacefulFilterChip>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  // Pastel colors for different chip types
  static const List<Color> _pastelColors = [
    ThemeProvider.mintGreen,
    ThemeProvider.softPeach,
    ThemeProvider.lilac,
    ThemeProvider.skyBlue,
    ThemeProvider.gentleCoral,
    ThemeProvider.warmAmber,
    ThemeProvider.peacefulPurple,
    ThemeProvider.softTeal,
  ];

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _glowController.forward();
    }
  }

  @override
  void didUpdateWidget(PeacefulFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onSelected?.call(!widget.isSelected);
  }

  Color _getChipColor() {
    if (widget.color != null) return widget.color!;
    
    // Use label hash to consistently assign colors
    final hash = widget.label.hashCode;
    return _pastelColors[hash.abs() % _pastelColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = ThemeProvider.goldPrimary;
    final currentColor = widget.isSelected ? chipColor : ThemeProvider.goldLight;
    
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _glowAnimation, _scaleAnimation]),
        builder: (context, child) {
          final glowIntensity = widget.isSelected ? _glowAnimation.value : 0.0;
          final bounceScale = _bounceAnimation.value * _scaleAnimation.value;
          
          return Transform.scale(
            scale: bounceScale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? ThemeProvider.darkGrey
                    : ThemeProvider.darkGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentColor.withOpacity(widget.isSelected ? 0.9 : 0.5),
                  width: widget.isSelected ? 1.5 : 1.2,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: currentColor.withOpacity(0.25 * glowIntensity),
                      blurRadius: 12 * glowIntensity,
                      spreadRadius: 1 * glowIntensity,
                    ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: currentColor,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: currentColor,
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
