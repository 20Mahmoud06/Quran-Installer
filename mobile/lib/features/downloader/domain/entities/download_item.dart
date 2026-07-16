import 'package:equatable/equatable.dart';
import '../../../../features/surahs/domain/entities/surah.dart';
import '../../../../features/reciters/domain/entities/reciter.dart';

enum DownloadStatus { pending, downloading, paused, completed, failed, canceled }

class DownloadItem extends Equatable {
  final String id;
  final Surah surah;
  final Reciter reciter;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final String savePath;

  final double networkSpeed; // MB/s
  final Duration? timeRemaining;
  final bool isFullQuran;

  const DownloadItem({
    required this.id,
    required this.surah,
    required this.reciter,
    required this.savePath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.networkSpeed = 0.0,
    this.timeRemaining,
    this.isFullQuran = false,
  });

  DownloadItem copyWith({
    double? progress,
    DownloadStatus? status,
    String? savePath,
    double? networkSpeed,
    Duration? timeRemaining,
    bool? isFullQuran,
  }) {
    return DownloadItem(
      id: id,
      surah: surah,
      reciter: reciter,
      savePath: savePath ?? this.savePath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      networkSpeed: networkSpeed ?? this.networkSpeed,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isFullQuran: isFullQuran ?? this.isFullQuran,
    );
  }

  @override
  List<Object?> get props => [id, surah, reciter, progress, status, savePath, networkSpeed, timeRemaining, isFullQuran];
}
