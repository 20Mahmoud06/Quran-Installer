import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';

class PremiumOfflineBanner extends StatefulWidget {
  final Widget child;
  final bool connected;

  const PremiumOfflineBanner({
    super.key,
    required this.child,
    required this.connected,
  });

  @override
  State<PremiumOfflineBanner> createState() => _PremiumOfflineBannerState();
}

class _PremiumOfflineBannerState extends State<PremiumOfflineBanner>
    with TickerProviderStateMixin {
  bool _wasOffline = false;
  bool _showReconnected = false;
  Timer? _timer;

  late AnimationController _bannerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _retrySpinController;
  late Animation<double> _retrySpinAnimation;

  @override
  void initState() {
    super.initState();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: widget.connected ? 0.0 : 1.0,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _retrySpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _retrySpinAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _retrySpinController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(PremiumOfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.connected && !widget.connected) {
      _wasOffline = true;
      _showReconnected = false;
      _timer?.cancel();
      _pulseController.stop();
      _retrySpinController.reset();
      _bannerController.forward();
    } else if (!oldWidget.connected && widget.connected) {
      if (_wasOffline) {
        setState(() {
          _showReconnected = true;
          _wasOffline = false;
        });
        _pulseController.repeat(reverse: true);
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _pulseController.stop();
            _bannerController.reverse().then((value) {
              if (mounted) {
                setState(() {
                  _showReconnected = false;
                });
              }
            });
          }
        });
      }
    }
  }

  void _onRetry() {
    _retrySpinController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _retrySpinController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    _pulseController.dispose();
    _retrySpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showOffline = !widget.connected;
    final bool isVisible = showOffline || _showReconnected;

    final List<Color> gradientColors = showOffline
        ? AppColors.offlineGradient
        : AppColors.onlineGradient;
    final loc = AppLocalizationsProvider.of(context);
    final String bannerText = showOffline ? loc.noInternet : loc.backOnline;
    final String subtitleText = showOffline ? loc.downloadsPaused : loc.allRestored;
    final IconData bannerIcon = showOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: isVisible
                  ? AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) {
                        final pulse = _pulseAnimation.value;
                        return Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withValues(alpha:0.4 * pulse),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                height: 60.h,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: pulse,
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha:0.25),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(alpha:0.2 * pulse),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          bannerIcon,
                                          color: Colors.white,
                                          size: 18.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bannerText,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                              height: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            subtitleText,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha:0.8),
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (showOffline)
                                      GestureDetector(
                                        onTap: _onRetry,
                                        child: AnimatedBuilder(
                                          animation: _retrySpinAnimation,
                                          builder: (context, _) {
                                            return Transform.rotate(
                                              angle: _retrySpinAnimation.value,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha:0.2),
                                                  borderRadius: BorderRadius.circular(100.r),
                                                  border: Border.all(
                                                    color: Colors.white.withValues(alpha:0.3),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withValues(alpha:0.1),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.refresh_rounded,
                                                      color: Colors.white,
                                                      size: 16.sp,
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    Text(
                                                      loc.retry,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                  ],
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
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
