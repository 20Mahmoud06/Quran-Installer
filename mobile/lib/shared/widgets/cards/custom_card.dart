import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glass;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glass = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card;

    if (glass) {
      card = Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: isDark
                ? AppColors.glassBorderDark
                : AppColors.glassBorderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.emeraldGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: padding ?? EdgeInsets.all(Dimensions.spaceMedium),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.glassDark
                    : AppColors.glassWhite,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1.2,
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
    } else {
      card = Card(
        elevation: glass ? 0 : 2,
        child: Container(
          height: height,
          padding: padding ?? EdgeInsets.all(Dimensions.spaceMedium),
          child: child,
        ),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: card,
      );
    }
    return card;
  }
}
