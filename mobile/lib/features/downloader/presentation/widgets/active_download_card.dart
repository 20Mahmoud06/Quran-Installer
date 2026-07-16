import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localization.dart';
import '../../cubit/downloader_cubit.dart';
class ActiveDownloadCard extends StatelessWidget {
  final DownloadItem item;
  final bool isDark;

  const ActiveDownloadCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.spaceMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(Dimensions.spaceMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: item.status == DownloadStatus.paused ? Colors.orange : AppColors.emeraldGreen,
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                                child: Text(
                                  item.status == DownloadStatus.paused ? loc.paused : loc.downloadingStatus,
                                  style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: Dimensions.spaceSmall),
                              Expanded(
                                child: Text(
                                  item.reciter.name,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.isFullQuran)
                          GestureDetector(
                            onTap: () {
                              if (item.status == DownloadStatus.paused) {
                                context.read<DownloaderCubit>().resumeDownload(item.id);
                              } else {
                                context.read<DownloaderCubit>().pauseDownload(item.id);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.status == DownloadStatus.paused ? Icons.play_arrow : Icons.pause,
                                color: AppColors.emeraldGreen,
                                size: 18.sp,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => context.read<DownloaderCubit>().cancelDownload(item.id),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.error,
                                size: 18.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Dimensions.spaceMedium),
                    Text('${item.surah.number.toString().padLeft(3, '0')}. ${item.surah.nameArabic}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: Dimensions.spaceMedium),
                    Row(
                      children: [
                        Expanded(child: _buildProgressStat(loc.progress, '${(item.progress * 100).toStringAsFixed(1)} %', isDark)),
                        Expanded(child: _buildProgressStat(loc.speed, '${item.networkSpeed.toStringAsFixed(1)} MB/s', isDark)),
                        Expanded(child: _buildProgressStat(loc.remaining, item.timeRemaining != null ? _formatDuration(item.timeRemaining!) : '--:--', isDark)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(flex: (item.progress * 100).toInt(), child: Container(height: 3.h, color: AppColors.emeraldGreen)),
                  Expanded(flex: 100 - (item.progress * 100).toInt(), child: Container(height: 3.h, color: Colors.transparent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        SizedBox(height: 2.h),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
