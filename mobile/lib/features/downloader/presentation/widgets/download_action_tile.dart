import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localization.dart';
import '../../cubit/downloader_cubit.dart';
class DownloadActionTile extends StatelessWidget {
  final DownloadItem item;
  final bool isDark;
  final bool isError;
  final bool isCompleted;

  const DownloadActionTile({
    super.key,
    required this.item,
    required this.isDark,
    this.isError = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final bgColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final iconBgColor = isError ? AppColors.errorLight.withValues(alpha: 0.1) : (isCompleted ? AppColors.emeraldGreen.withValues(alpha: 0.1) : (isDark ? AppColors.borderDark : AppColors.borderLight));
    final iconColor = isError ? AppColors.error : (isCompleted ? AppColors.emeraldGreen : (isDark ? AppColors.iconDark : AppColors.iconLight));
    final trailingBgColor = isCompleted ? AppColors.emeraldGreen : (isError ? AppColors.error : (isDark ? AppColors.borderDark : AppColors.borderLight));

    IconData icon = isCompleted ? Icons.check_circle_outline : (isError ? Icons.error_outline : Icons.hourglass_empty);
    IconData trailingIcon = (isCompleted || isError) ? Icons.delete_outline : Icons.cancel_outlined;

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.spaceSmall),
      child: Container(
        padding: EdgeInsets.all(Dimensions.spaceMedium),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: Dimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.surah.number.toString().padLeft(3, '0')}. ${item.surah.nameArabic}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isError ? loc.errorDownloading : (isCompleted ? loc.completed : loc.pending),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isError ? AppColors.error : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.spaceMedium),
            GestureDetector(
              onTap: () async {
                if (isCompleted) {
                  final surahName = item.surah.nameArabic;
                  await context.read<DownloaderCubit>().deleteDownload(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.surahRemoved(surahName))),
                    );
                  }
                } else if (isError) {
                  final surahName = item.surah.nameArabic;
                  await context.read<DownloaderCubit>().deleteDownload(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.surahRemoved(surahName))),
                    );
                  }
                } else {
                  context.read<DownloaderCubit>().cancelDownload(item.id);
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: trailingBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trailingIcon,
                  color: (isCompleted || isError) ? Colors.white : (isDark ? AppColors.iconDark : AppColors.iconLight),
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
