import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../downloader/cubit/downloader_cubit.dart';

class DownloadButton extends StatelessWidget {
  final bool isFullQuran;
  final VoidCallback onDownloadTap;

  const DownloadButton({
    super.key,
    required this.isFullQuran,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);

    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, state) {
        final downloading = state is DownloaderReady &&
            state.queue.any((e) => e.status == DownloadStatus.downloading);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: downloading ? null : onDownloadTap,
            icon: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
              firstChild: const SizedBox(
                width: 18,
                height: 18,
                child: Icon(Icons.download),
              ),
              secondChild: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              crossFadeState: downloading
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            label: Text(
              downloading
                  ? loc.downloading
                  : (isFullQuran ? loc.downloadQuran : loc.downloadSurah),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: downloading
                  ? AppColors.emeraldGreen.withValues(alpha: 0.6)
                  : AppColors.emeraldGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.emeraldGreen.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white70,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              ),
            ),
          ),
        );
      },
    );
  }
}
