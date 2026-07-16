import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/downloader_cubit.dart';
import '../../connectivity/cubit/connectivity_cubit.dart';
import '../../../core/localization/app_localization.dart';
import 'widgets/queue_app_bar.dart';
import 'widgets/empty_queue_placeholder.dart';
import 'widgets/queue_control_buttons.dart';
import 'widgets/section_header.dart';
import 'widgets/active_download_card.dart';
import 'widgets/download_action_tile.dart';
import '../../../shared/widgets/connectivity_banner.dart';

class DownloadQueueScreen extends StatelessWidget {
  const DownloadQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizationsProvider.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Dimensions.spaceMedium,
            Dimensions.spaceMedium,
            Dimensions.spaceMedium,
            100.h,
          ),
          children: [
            const QueueAppBar(),
            SizedBox(height: Dimensions.spaceMedium),

            BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
              builder: (context, status) {
                return ConnectivityBanner(
                  isConnected: status == ConnectivityStatus.connected,
                );
              },
            ),

            BlocBuilder<DownloaderCubit, DownloaderState>(
              builder: (context, state) {
                if (state is! DownloaderReady || state.queue.isEmpty) {
                  return const EmptyQueuePlaceholder();
                }

                final active = state.queue.where((e) => e.status == DownloadStatus.downloading || e.status == DownloadStatus.paused).toList();
                final pending = state.queue.where((e) => e.status == DownloadStatus.pending).toList();
                final errors = state.queue.where((e) => e.status == DownloadStatus.failed).toList();
                final completed = state.queue.where((e) => e.status == DownloadStatus.completed).toList();

                final hasUnfinished = active.isNotEmpty || pending.isNotEmpty;
                final hasFullQuranActive = active.any((e) => e.isFullQuran);
                final hasPaused = active.any((e) => e.status == DownloadStatus.paused);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasUnfinished)
                      QueueControlButtons(
                        hasPaused: hasPaused,
                        hasFullQuranActive: hasFullQuranActive,
                      ),

                    if (active.isNotEmpty) ...[
                      SectionHeader(title: loc.activeDownload, isDark: isDark, hasDot: true),
                      ...active.map((item) => ActiveDownloadCard(item: item, isDark: isDark)),
                      SizedBox(height: Dimensions.spaceLarge),
                    ],

                    if (pending.isNotEmpty) ...[
                      SectionHeader(title: loc.upNext(pending.length), isDark: isDark),
                      ...pending.map((item) => DownloadActionTile(item: item, isDark: isDark)),
                      SizedBox(height: Dimensions.spaceLarge),
                    ],

                    if (errors.isNotEmpty) ...[
                      SectionHeader(title: loc.issues, isDark: isDark),
                      ...errors.map((item) => DownloadActionTile(item: item, isDark: isDark, isError: true)),
                      SizedBox(height: Dimensions.spaceLarge),
                    ],

                    if (completed.isNotEmpty) ...[
                      SectionHeader(title: loc.completed, isDark: isDark),
                      ...completed.map((item) => DownloadActionTile(item: item, isDark: isDark, isCompleted: true)),
                      SizedBox(height: Dimensions.spaceSmall),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final cubit = context.read<DownloaderCubit>();
                            await cubit.validateCompletedItems();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(loc.tr('Refresh', 'تحديث'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldGreen.withValues(alpha: 0.1),
                            foregroundColor: AppColors.emeraldGreen,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                              side: BorderSide(color: AppColors.emeraldGreen.withValues(alpha: 0.2)),
                            ),
                          ),
                        ),
                      ),
                      if (active.isEmpty && pending.isEmpty) ...[
                        SizedBox(height: Dimensions.spaceMedium),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final cubit = context.read<DownloaderCubit>();
                              await cubit.clearAll();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.allRemoved)),
                                );
                              }
                            },
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: Text(loc.clearAll, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
