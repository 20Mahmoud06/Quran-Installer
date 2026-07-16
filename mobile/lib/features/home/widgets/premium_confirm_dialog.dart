import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';

class PremiumConfirmDialog extends StatelessWidget {
  final bool isDark;
  final String reciterName;
  final int existingCount;
  final int totalCount;

  const PremiumConfirmDialog({
    super.key,
    required this.isDark,
    required this.reciterName,
    required this.existingCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.all(Dimensions.spaceLarge),
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDark : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline, color: Colors.white, size: 32.sp),
                ),
                SizedBox(height: Dimensions.spaceMedium),
                Text(
                  loc.alreadyDownloaded,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                ),
                SizedBox(height: Dimensions.spaceSmall),
                Text(
                  loc.alreadyExists(existingCount, totalCount, reciterName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                ),
                SizedBox(height: Dimensions.spaceLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(loc.downloadAgain,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldGreen,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.spaceSmall),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(loc.cancel,
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
