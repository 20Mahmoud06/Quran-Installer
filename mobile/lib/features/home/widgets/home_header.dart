import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/app_settings_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.emeraldGreen,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              loc.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : AppColors.emeraldGreen.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            onPressed: () => context.read<AppSettingsCubit>().toggleTheme(),
          ),
        ),
      ],
    );
  }
}
