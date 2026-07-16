import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';

class ConnectivityBanner extends StatefulWidget {
  final bool isConnected;

  const ConnectivityBanner({super.key, required this.isConnected});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _showReconnected = false;
  Timer? _timer;

  @override
  void didUpdateWidget(ConnectivityBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConnected && !widget.isConnected) {
      _timer?.cancel();
      setState(() => _showReconnected = false);
    } else if (!oldWidget.isConnected && widget.isConnected) {
      setState(() => _showReconnected = true);
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showReconnected = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);

    if (!widget.isConnected) {
      return _buildBanner(
        backgroundColor: const Color(0xFF2B1616),
        borderColor: const Color(0xFF3B1F1F),
        textColor: AppColors.errorLight,
        icon: Icons.wifi_off,
        title: loc.waitingForInternet,
        subtitle: loc.resumeAuto,
      );
    }

    if (_showReconnected) {
      return _buildBanner(
        backgroundColor: const Color(0xFF162B1A),
        borderColor: const Color(0xFF1F3B24),
        textColor: const Color(0xFF4CAF50),
        icon: Icons.wifi,
        title: loc.backOnline,
        subtitle: loc.allRestored,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBanner({
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.spaceLarge),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.spaceMedium, vertical: Dimensions.spaceMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(icon, color: textColor, size: 16),
          ),
          SizedBox(width: Dimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
