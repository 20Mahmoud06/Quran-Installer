import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localization.dart';

class EmptyQueuePlaceholder extends StatelessWidget {
  const EmptyQueuePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizationsProvider.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 64.sp,
              color: isDark ? AppColors.iconDark.withValues(alpha: 0.4) : AppColors.iconLight.withValues(alpha: 0.4),
            ),
            SizedBox(height: Dimensions.spaceLarge),
            Text(
              loc.noDownloads,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.spaceSmall),
            Text(
              loc.tr('Start by selecting a surah to download', 'ابدأ باختيار سورة للتحميل'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.6) : AppColors.textSecondaryLight.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
