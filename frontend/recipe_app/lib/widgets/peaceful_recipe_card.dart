import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class PeacefulRecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final int index;

  const PeacefulRecipeCard({
    Key? key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.index = 0,
  }) : super(key: key);

  @override
  _PeacefulRecipeCardState createState() => _PeacefulRecipeCardState();
}

class _PeacefulRecipeCardState extends State<PeacefulRecipeCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _hoverController;
  late AnimationController _favoriteController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    // Start animations with staggered delay
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });

    if (widget.isFavorite) {
      _favoriteController.forward();
    }
  }

  @override
  void didUpdateWidget(PeacefulRecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite && widget.isFavorite) {
      _favoriteController.forward().then((_) {
        _favoriteController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _hoverController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    _hoverController.forward();
  }

  void _onHoverExit() {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideAnimation,
        _fadeAnimation,
        _hoverAnimation,
        _favoriteAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: MouseRegion(
                onEnter: (_) => _onHoverEnter(),
                onExit: (_) => _onHoverExit(),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Frosted glass background
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                          
                          // Card content
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Recipe image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.recipe['image'] != null && 
                                           widget.recipe['image'].toString().isNotEmpty
                                        ? Image.network(
                                            widget.recipe['image'],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      ThemeProvider.softPeach,
                                                      ThemeProvider.lightLavender,
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.restaurant_menu_outlined,
                                                  color: ThemeProvider.softTeal,
                                                  size: 32,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  ThemeProvider.softPeach,
                                                  ThemeProvider.lightLavender,
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.restaurant_menu_outlined,
                                              color: ThemeProvider.softTeal,
                                              size: 32,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                SizedBox(width: 16),
                                
                                // Recipe details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        widget.recipe['title'] ?? 'Recipe Title',
                                        style: TextStyle(
                                          color: ThemeProvider.deepSlate,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      
                                      SizedBox(height: 8),
                                      
                                      // Cooking time
                                      if (widget.recipe['cookingTime'] != null)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_outlined,
                                              color: ThemeProvider.softTeal,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${widget.recipe['cookingTime']} min',
                                              style: TextStyle(
                                                color: ThemeProvider.softGray,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      
                                      SizedBox(height: 4),
                                      
                                      // Category and area
                                      if (widget.recipe['category'] != null || widget.recipe['area'] != null)
                                        Text(
                                          [widget.recipe['category'], widget.recipe['area']]
                                              .where((e) => e != null)
                                              .join(' • '),
                                          style: TextStyle(
                                            color: ThemeProvider.lightGray,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      
                                      SizedBox(height: 8),
                                      
                                      // Match score
                                      if (widget.recipe['matchScore'] != null && widget.recipe['matchPercentage'] != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: ThemeProvider.softTeal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: ThemeProvider.softTeal.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 12,
                                                color: widget.recipe['matchPercentage'] >= 80 
                                                    ? ThemeProvider.softTeal
                                                    : ThemeProvider.lightGray,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${widget.recipe['matchScore']} ingredients (${widget.recipe['matchPercentage']}%)',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: ThemeProvider.softGray,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Favorite button
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: widget.onFavorite,
                                      child: AnimatedBuilder(
                                        animation: _favoriteAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _favoriteAnimation.value,
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(22),
                                                border: Border.all(
                                                  color: widget.isFavorite 
                                                      ? ThemeProvider.gentleCoral
                                                      : Colors.white.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  if (widget.isFavorite)
                                                    BoxShadow(
                                                      color: ThemeProvider.gentleCoral.withOpacity(0.3),
                                                      blurRadius: 12,
                                                      spreadRadius: 0,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.1),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: widget.isTogglingFavorite
                                                  ? Center(
                                                      child: SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(
                                                              ThemeProvider.softTeal),
                                                        ),
                                                      ),
                                                    )
                                                  : Icon(
                                                      widget.isFavorite 
                                                          ? Icons.favorite 
                                                          : Icons.favorite_border_outlined,
                                                      color: widget.isFavorite 
                                                          ? ThemeProvider.gentleCoral
                                                          : ThemeProvider.lightGray,
                                                      size: 20,
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    // Arrow indicator
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: ThemeProvider.softTeal.withOpacity(0.6),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
