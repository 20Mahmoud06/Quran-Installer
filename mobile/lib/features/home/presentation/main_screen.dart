import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../downloader/presentation/download_queue_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _screens = [
      HomeScreen(onNavigateToQueue: () => _onNavTap(1)),
      const DownloadQueueScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                return Container(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 8.h,
                    bottom: bottomInset + 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                        Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withValues(alpha: 0.86)
                              : AppColors.cardLight.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(100.r),
                          border: Border.all(
                            color: isDark
                                ? AppColors.glassBorderDark
                                : AppColors.glassBorderLight,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emeraldGreen.withValues(alpha: 0.15 * _glowAnimation.value),
                              blurRadius: 24.r,
                              spreadRadius: 1.r,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(4.w),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gap = 8.w;
                            final tabWidth = (constraints.maxWidth - gap) / 2;

                            return Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  left: _currentIndex == 0 ? 0 : tabWidth + gap,
                                  top: 0,
                                  bottom: 0,
                                  width: tabWidth,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.emeraldGreen,
                                          AppColors.forestGreen,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(100.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.emeraldGreen.withValues(alpha: 0.4 * _glowAnimation.value),
                                          blurRadius: 12.r,
                                          spreadRadius: 1.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _NavItem(
                                        icon: Icons.download_rounded,
                                        label: loc.home.toUpperCase(),
                                        isSelected: _currentIndex == 0,
                                        onTap: () => _onNavTap(0),
                                      ),
                                    ),
                                    SizedBox(width: gap),
                                    Expanded(
                                      child: _NavItem(
                                        icon: Icons.format_list_bulleted_rounded,
                                        label: loc.queue.toUpperCase(),
                                        isSelected: _currentIndex == 1,
                                        onTap: () => _onNavTap(1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1 : 0.95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.r),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
