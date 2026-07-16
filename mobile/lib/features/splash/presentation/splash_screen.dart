import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/routing/routes.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fade animation for text and logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale/Bounce animation for the logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Line width animation (starts as a dot and expands)
    _lineWidthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    // Navigate to home after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(Routes.home);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated App Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.asset(
                              'assets/images/Quran Downloader.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: Dimensions.spaceLarge),
                
                // Animated Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.emeraldGreen,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      SizedBox(height: Dimensions.spaceExtraSmall),
                      Text(
                        'Download Holy Quran Audio',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Animated Bottom Line (Expanding Dot)
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _lineWidthAnimation,
                builder: (context, child) {
                  // Minimum width is 4 (so it looks like a dot initially), expands to 200.w
                  final currentWidth = 4.0 + (196.w * _lineWidthAnimation.value);
                  return Container(
                    height: 3.h,
                    width: currentWidth,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
