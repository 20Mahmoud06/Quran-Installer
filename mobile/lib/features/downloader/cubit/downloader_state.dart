import 'package:equatable/equatable.dart';
import '../domain/entities/download_item.dart';

abstract class DownloaderState extends Equatable {
  const DownloaderState();
  @override
  List<Object> get props => [];
}

class DownloaderInitial extends DownloaderState {}

class DownloaderReady extends DownloaderState {
  final List<DownloadItem> queue;
  final String savePath;
  final bool hasInternet;
  final double freeSpaceMB;
  final double totalSpaceMB;

  const DownloaderReady({
    required this.queue,
    required this.savePath,
    this.hasInternet = true,
    this.freeSpaceMB = 0.0,
    this.totalSpaceMB = 0.0,
  });

  DownloaderReady copyWith({
    List<DownloadItem>? queue,
    String? savePath,
    bool? hasInternet,
    double? freeSpaceMB,
    double? totalSpaceMB,
  }) {
    return DownloaderReady(
      queue: queue ?? this.queue,
      savePath: savePath ?? this.savePath,
      hasInternet: hasInternet ?? this.hasInternet,
      freeSpaceMB: freeSpaceMB ?? this.freeSpaceMB,
      totalSpaceMB: totalSpaceMB ?? this.totalSpaceMB,
    );
  }

  @override
  List<Object> get props => [queue, savePath, hasInternet, freeSpaceMB, totalSpaceMB];
}
