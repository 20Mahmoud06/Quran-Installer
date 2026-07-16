import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final bool hasDot;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.spaceMedium),
      child: Row(
        children: [
          if (hasDot) ...[
            Container(width: 4.w, height: 4.w, decoration: const BoxDecoration(color: AppColors.emeraldGreen, shape: BoxShape.circle)),
            SizedBox(width: 8.w),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
