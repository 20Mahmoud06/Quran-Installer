import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localization.dart';

class QueueAppBar extends StatelessWidget {
  const QueueAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizationsProvider.of(context);

    return Row(
      children: [
        Icon(Icons.menu_book_rounded, color: isDark ? AppColors.iconDark : AppColors.iconLight),
        SizedBox(width: Dimensions.spaceSmall),
        Text(
          loc.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.emeraldGreen,
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: isDark ? AppColors.iconDark : AppColors.iconLight),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
