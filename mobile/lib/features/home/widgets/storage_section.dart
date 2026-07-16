import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../../shared/widgets/cards/custom_card.dart';
import '../../downloader/cubit/downloader_cubit.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, state) {
        final freeSpace = state is DownloaderReady ? state.freeSpaceMB : 0.0;
        final totalSpace = state is DownloaderReady ? state.totalSpaceMB : 1.0;
        final usedSpace = totalSpace - freeSpace;

        final freeSpaceGB = (freeSpace / 1024).toStringAsFixed(1);
        final totalSpaceGB = (totalSpace / 1024).toStringAsFixed(1);
        final usedSpaceFlex =
            (totalSpace > 0) ? (usedSpace / totalSpace * 100).toInt() : 60;
        final freeSpaceFlex =
            (totalSpace > 0) ? (freeSpace / totalSpace * 100).toInt() : 40;

        return Column(
          children: [
            CustomCard(
              glass: true,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_outlined, color: Colors.white),
                  ),
                  SizedBox(width: Dimensions.spaceMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.downloadLocation,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          loc.downloadPathDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.spaceMedium),
            CustomCard(
              glass: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sd_storage_outlined, color: Colors.white),
                      ),
                      SizedBox(width: Dimensions.spaceMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.internalStorage,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              '$freeSpaceGB GB Free / $totalSpaceGB GB',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.spaceLarge),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: SizedBox(
                      height: 8.h,
                      child: Row(
                        children: [
                          Expanded(
                            flex: usedSpaceFlex,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: freeSpaceFlex,
                            child: Container(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.spaceMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8.w, height: 8.w,
                              decoration: const BoxDecoration(
                                  color: AppColors.emeraldGreen, shape: BoxShape.circle)),
                          SizedBox(width: 4.w),
                          Text(loc.system,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontSize: 10.sp)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 8.w, height: 8.w,
                              decoration: BoxDecoration(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  shape: BoxShape.circle)),
                          SizedBox(width: 4.w),
                          Text(loc.free,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontSize: 10.sp)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
