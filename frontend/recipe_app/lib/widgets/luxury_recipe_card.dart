import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class LuxuryRecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final int index;

  const LuxuryRecipeCard({
    Key? key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.index = 0,
  }) : super(key: key);

  @override
  _LuxuryRecipeCardState createState() => _LuxuryRecipeCardState();
}

class _LuxuryRecipeCardState extends State<LuxuryRecipeCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _parallaxController;
  late AnimationController _hoverController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _parallaxAnimation;
  late Animation<double> _hoverAnimation;

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
    
    _parallaxController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.3, 0),
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

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.linear,
    ));

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Start animations with staggered delay
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
        _parallaxController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _parallaxController.dispose();
    _hoverController.dispose();
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
        _parallaxAnimation,
        _hoverAnimation,
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
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ThemeProvider.richBlack,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeProvider.luxuryGold.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProvider.luxuryGold.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Parallax background effect
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _parallaxAnimation,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(
                                        -1.0 + (_parallaxAnimation.value * 0.1),
                                        -1.0,
                                      ),
                                      end: Alignment(
                                        1.0 + (_parallaxAnimation.value * 0.1),
                                        1.0,
                                      ),
                                      colors: [
                                        ThemeProvider.luxuryGold.withOpacity(0.05),
                                        Colors.transparent,
                                        ThemeProvider.luxuryGold.withOpacity(0.02),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Card content
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Recipe image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ThemeProvider.luxuryGold.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeProvider.luxuryGold.withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: widget.recipe['image'] != null && 
                                           widget.recipe['image'].toString().isNotEmpty
                                        ? Image.network(
                                            widget.recipe['image'],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: ThemeProvider.charcoal,
                                                child: Icon(
                                                  Icons.restaurant,
                                                  color: ThemeProvider.luxuryGold,
                                                  size: 32,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: ThemeProvider.charcoal,
                                            child: Icon(
                                              Icons.restaurant,
                                              color: ThemeProvider.luxuryGold,
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
                                          color: ThemeProvider.platinum,
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
                                              Icons.access_time,
                                              color: ThemeProvider.silver,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${widget.recipe['cookingTime']} min',
                                              style: TextStyle(
                                                color: ThemeProvider.silver,
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
                                            color: ThemeProvider.silver.withOpacity(0.8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      
                                      SizedBox(height: 8),
                                      
                                      // Match score
                                      if (widget.recipe['matchScore'] != null && widget.recipe['matchPercentage'] != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: ThemeProvider.luxuryGold.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: ThemeProvider.luxuryGold.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 12,
                                                color: widget.recipe['matchPercentage'] >= 80 
                                                    ? ThemeProvider.luxuryGold
                                                    : ThemeProvider.silver,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${widget.recipe['matchScore']} ingredients (${widget.recipe['matchPercentage']}%)',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: ThemeProvider.silver,
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
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: ThemeProvider.richBlack,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: widget.isFavorite 
                                                ? ThemeProvider.luxuryGold
                                                : ThemeProvider.luxuryGold.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            if (widget.isFavorite)
                                              BoxShadow(
                                                color: ThemeProvider.luxuryGold.withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                                offset: Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: widget.isTogglingFavorite
                                            ? Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                        ThemeProvider.luxuryGold),
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                widget.isFavorite 
                                                    ? Icons.favorite 
                                                    : Icons.favorite_border,
                                                color: widget.isFavorite 
                                                    ? ThemeProvider.luxuryGold
                                                    : ThemeProvider.silver,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    // Arrow indicator
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: ThemeProvider.luxuryGold.withOpacity(0.6),
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
