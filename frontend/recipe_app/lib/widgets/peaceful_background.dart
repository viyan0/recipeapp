import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';

class PeacefulBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingShapes;
  final bool enableParticles;
  final double animationSpeed;

  const PeacefulBackground({
    Key? key,
    required this.child,
    this.showFloatingShapes = false,
    this.enableParticles = false,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  _PeacefulBackgroundState createState() => _PeacefulBackgroundState();
}

class _PeacefulBackgroundState extends State<PeacefulBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: Duration(seconds: (25 / widget.animationSpeed).round()), // Much slower
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: Duration(seconds: (40 / widget.animationSpeed).round()), // Much slower
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: (60 / widget.animationSpeed).round()), // Much slower
      vsync: this,
    );

    _waveController = AnimationController(
      duration: Duration(seconds: (30 / widget.animationSpeed).round()), // Much slower
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _gradientController.repeat(reverse: true);
    _waveController.repeat();
    if (widget.showFloatingShapes) {
      _floatingController.repeat();
    }
    if (widget.enableParticles) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Plain black background
          Container(color: Colors.black),

          // No overlays for plain design

          // Secondary flowing gradient overlay
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.cos(_waveAnimation.value) * 0.3,
                      math.sin(_waveAnimation.value * 1.5) * 0.2,
                    ),
                    radius: 0.8 + (math.sin(_waveAnimation.value * 2) * 0.3),
                    colors: [
                      ThemeProvider.mysticJade.withOpacity(0.1),
                      ThemeProvider.forestWhisper.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),
          
          // Floating peaceful shapes
          if (widget.showFloatingShapes)
            AnimatedBuilder(
              animation: Listenable.merge([_floatingAnimation, _waveAnimation]),
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                return Stack(
                  children: [
                    // Large floating emerald orb - much more visible
                    Positioned(
                      top: size.height * 0.15 + (80 * math.sin(_floatingAnimation.value * 2 * math.pi)),
                      left: size.width * 0.1 + (60 * math.cos(_floatingAnimation.value * 2 * math.pi)),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ThemeProvider.blushPink.withOpacity(0.15),
                              ThemeProvider.peacefulSage.withOpacity(0.1),
                              ThemeProvider.silverMist.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.4, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.blushPink.withOpacity(0.08),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: ThemeProvider.peacefulSage.withOpacity(0.05),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Medium sage circle - more visible
                    Positioned(
                      top: size.height * 0.4 + (50 * math.cos(_floatingAnimation.value * 3 * math.pi)),
                      right: size.width * 0.15 + (40 * math.sin(_floatingAnimation.value * 2.5 * math.pi)),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ThemeProvider.peacefulSage.withOpacity(0.7),
                              ThemeProvider.serenityMint.withOpacity(0.5),
                              ThemeProvider.whisperMint.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.peacefulSage.withOpacity(0.4),
                              blurRadius: 35,
                              spreadRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Small whisper green orb - more visible
                    Positioned(
                      bottom: size.height * 0.25 + (60 * math.sin(_floatingAnimation.value * 4 * math.pi)),
                      left: size.width * 0.2 + (45 * math.cos(_floatingAnimation.value * 3.5 * math.pi)),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ThemeProvider.silverMist.withOpacity(0.8),
                              ThemeProvider.whisperMint.withOpacity(0.6),
                              ThemeProvider.dreamyMint.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.silverMist.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Flowing forest wisp - much more visible
                    Positioned(
                      bottom: size.height * 0.1 + (40 * math.cos(_waveAnimation.value * 2)),
                      right: size.width * 0.25 + (70 * math.sin(_waveAnimation.value * 1.5)),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ThemeProvider.mysticJade.withOpacity(0.7),
                              ThemeProvider.forestWhisper.withOpacity(0.5),
                              ThemeProvider.blushPink.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.mysticJade.withOpacity(0.4),
                              blurRadius: 45,
                              spreadRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Beautiful floating particles - much more visible
                    ...List.generate(12, (index) {
                      final angle = (index * math.pi / 6) + (_particleAnimation.value * 2 * math.pi);
                      final radius = 50 + (index * 20);
                      return Positioned(
                        top: size.height * 0.6 + (radius * math.sin(angle * (1 + index * 0.1))),
                        right: size.width * 0.6 + (radius * math.cos(angle * (1 + index * 0.1))),
                        child: Container(
                          width: 15 + (index * 4),
                          height: 15 + (index * 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                [
                                  ThemeProvider.blushPink,
                                  ThemeProvider.peacefulSage,
                                  ThemeProvider.silverMist,
                                  ThemeProvider.mysticJade,
                                  ThemeProvider.serenityMint,
                                  ThemeProvider.whisperMint,
                                ][index % 6].withOpacity(0.6 - (index * 0.03)),
                                [
                                  ThemeProvider.blushPink,
                                  ThemeProvider.peacefulSage,
                                  ThemeProvider.silverMist,
                                  ThemeProvider.mysticJade,
                                  ThemeProvider.serenityMint,
                                  ThemeProvider.whisperMint,
                                ][index % 6].withOpacity(0.3 - (index * 0.02)),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                              color: [
                                ThemeProvider.blushPink,
                                ThemeProvider.peacefulSage,
                                ThemeProvider.silverMist,
                                ThemeProvider.mysticJade,
                                ThemeProvider.serenityMint,
                                ThemeProvider.whisperMint,
                              ][index % 6].withOpacity(0.2),
                                blurRadius: (15 + (index * 2)).toDouble(),
                                spreadRadius: (3 + index).toDouble(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Additional larger floating elements for more visible animation
                    ...List.generate(4, (index) {
                      final angle = (index * math.pi / 2) + (_waveAnimation.value * math.pi);
                      final radius = 60 + (index * 40);
                      return Positioned(
                        top: size.height * 0.3 + (radius * math.sin(angle)),
                        left: size.width * 0.4 + (radius * math.cos(angle)),
                        child: Container(
                          width: 40 + (index * 8),
                          height: 40 + (index * 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                [
                                  ThemeProvider.blushPink,
                                  ThemeProvider.peacefulSage,
                                  ThemeProvider.silverMist,
                                  ThemeProvider.mysticJade,
                                ][index].withOpacity(0.5),
                                [
                                  ThemeProvider.blushPink,
                                  ThemeProvider.peacefulSage,
                                  ThemeProvider.silverMist,
                                  ThemeProvider.mysticJade,
                                ][index].withOpacity(0.2),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: [
                                  ThemeProvider.blushPink,
                                  ThemeProvider.peacefulSage,
                                  ThemeProvider.silverMist,
                                  ThemeProvider.mysticJade,
                                ][index].withOpacity(0.3),
                                blurRadius: (25 + (index * 5)).toDouble(),
                                spreadRadius: (8 + (index * 2)).toDouble(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;

  const FrostedGlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeProvider.cottonCloud.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: ThemeProvider.blushPink.withOpacity(0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            ThemeProvider.dreamyMint.withOpacity(0.1),
            ThemeProvider.whisperMint.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.mysticJade.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, -8),
          ),
          BoxShadow(
            color: ThemeProvider.blushPink.withOpacity(0.1),
            blurRadius: 60,
            spreadRadius: 0,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PeacefulAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PeacefulAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.goldPrimary.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: leading ??
            (showBackButton
                ? IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeProvider.goldPrimary.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: ThemeProvider.goldLight,
                        size: 18,
                      ),
                    ),
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  )
                : null),
        actions: actions,
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);
}
