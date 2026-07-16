import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localization.dart';
import '../../cubit/downloader_cubit.dart';

class QueueControlButtons extends StatelessWidget {
  final bool hasPaused;
  final bool hasFullQuranActive;

  const QueueControlButtons({
    super.key,
    required this.hasPaused,
    required this.hasFullQuranActive,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.spaceMedium),
      child: Row(
        children: [
          if (hasFullQuranActive)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cubit = context.read<DownloaderCubit>();
                  hasPaused ? cubit.resumeAll() : cubit.pauseAll();
                },
                icon: Icon(hasPaused ? Icons.play_arrow : Icons.pause, size: 18),
                label: Text(
                  hasPaused ? loc.resumeAll : loc.pauseAll,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldGreen.withValues(alpha: 0.15),
                  foregroundColor: AppColors.emeraldGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                    side: BorderSide(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          if (hasFullQuranActive) SizedBox(width: Dimensions.spaceSmall),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.read<DownloaderCubit>().cancelAll(),
              icon: const Icon(Icons.stop_circle_outlined, size: 18),
              label: Text(loc.cancelAll, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                foregroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
