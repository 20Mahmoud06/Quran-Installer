import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import 'toggle_item.dart';

class ModeToggle extends StatelessWidget {
  final bool isFullQuran;
  final ValueChanged<int> onToggle;

  const ModeToggle({
    super.key,
    required this.isFullQuran,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 52.h,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassWhite,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.emeraldGreen.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gap = 4.w;
              final tabWidth = (constraints.maxWidth - gap) / 2;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    left: isFullQuran ? 0 : tabWidth + gap,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ToggleItem(
                          icon: Icons.library_books_outlined,
                          label: loc.fullQuran,
                          isSelected: isFullQuran,
                          onTap: () => onToggle(0),
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: ToggleItem(
                          icon: Icons.queue_music_outlined,
                          label: loc.specificSurah,
                          isSelected: !isFullQuran,
                          onTap: () => onToggle(1),
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
    );
  }
}
