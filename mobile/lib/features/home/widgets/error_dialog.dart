import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        loc.error,
        style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      content: Text(
        message,
        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(loc.ok, style: const TextStyle(color: AppColors.emeraldGreen)),
        ),
      ],
    );
  }
}
