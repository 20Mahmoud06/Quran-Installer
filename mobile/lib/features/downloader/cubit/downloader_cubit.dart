import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:hive/hive.dart';
import 'downloader_state.dart';
import '../domain/entities/download_item.dart';
import '../domain/services/download_service.dart';
import '../../surahs/domain/entities/surah.dart';
import '../../reciters/domain/entities/reciter.dart';

export 'downloader_state.dart';
export '../domain/entities/download_item.dart';

class DownloaderCubit extends Cubit<DownloaderState> {
  final DownloadService downloadService;
  final Box settingsBox;
  final Set<String> _moveInProgressIds = {};
  final List<DownloadItem> _pendingQueue = [];

  static const String _baseRelativeDir = 'Quran_Downloads';

  DownloaderCubit({
    required this.downloadService,
    required this.settingsBox,
  }) : super(DownloaderInitial()) {
    downloadService.onProgress = _onProgress;
    downloadService.onStatusUpdate = _onStatusUpdate;
    _init().then((_) => downloadService.registerCallbacks());
  }

  void _onProgress(String taskId, double progress, double networkSpeed, Duration timeRemaining) {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final effectiveProgress = progress < 0
        ? (currentState.queue.where((e) => e.id == taskId).firstOrNull?.progress ?? 0.0)
        : progress;
    final effectiveSpeed = networkSpeed < 0
        ? (currentState.queue.where((e) => e.id == taskId).firstOrNull?.networkSpeed ?? 0.0)
        : networkSpeed;

    final newQueue = currentState.queue.map((item) {
      if (item.id == taskId) {
        return item.copyWith(
          progress: effectiveProgress,
          networkSpeed: effectiveSpeed,
          timeRemaining: timeRemaining,
        );
      }
      return item;
    }).toList();

    emit(currentState.copyWith(queue: newQueue));
  }

  void _onStatusUpdate(String taskId, TaskStatus status, Task? task) {
    if (state is! DownloaderReady) return;

    if (status == TaskStatus.enqueued) {
      final existing = (state as DownloaderReady).queue.firstWhere(
        (e) => e.id == taskId,
        orElse: () => DownloadItem(id: '', surah: Surah(number: 0, nameArabic: ''), reciter: Reciter(name: '', serverUrl: ''), status: DownloadStatus.pending, savePath: ''),
      );
      if (existing.status == DownloadStatus.downloading) return;
    }

    DownloadStatus appStatus = DownloadStatus.downloading;
    if (status == TaskStatus.complete) appStatus = DownloadStatus.completed;
    if (status == TaskStatus.failed || status == TaskStatus.notFound || status == TaskStatus.canceled) appStatus = DownloadStatus.failed;
    if (status == TaskStatus.paused) appStatus = DownloadStatus.paused;
    if (status == TaskStatus.enqueued) appStatus = DownloadStatus.pending;

    _updateItemStatus(taskId, appStatus);

    if (status == TaskStatus.complete) {
      _moveInProgressIds.add(taskId);
      _moveToShared(taskId, task: task).then((_) {
        _moveInProgressIds.remove(taskId);
        _startNextPendingDownload();
      });
    } else if (status == TaskStatus.failed || status == TaskStatus.notFound || status == TaskStatus.canceled) {
      _startNextPendingDownload();
    }
  }

  Future<void> _moveToShared(String taskId, {Task? task}) async {
    final stateNow = state;
    if (stateNow is! DownloaderReady) return;
    final item = stateNow.queue.where((e) => e.id == taskId).firstOrNull;
    if (item == null) return;

    final relativeSubDir = '$_baseRelativeDir/${item.reciter.name.replaceAll(' ', '_')}';

    final finalPath = await downloadService.moveToSharedStorage(taskId, relativeSubDir, task: task);

    if (finalPath != null && state is DownloaderReady) {
      final currentState = state as DownloaderReady;
      final newQueue = currentState.queue.map((e) {
        if (e.id == taskId) {
          return e.copyWith(savePath: finalPath);
        }
        return e;
      }).toList();
      emit(currentState.copyWith(queue: newQueue));
    }
  }

  Future<void> _init() async {
    List<DownloadItem> restoredQueue = [];
    final records = await FileDownloader().database.allRecords();

    for (var record in records) {
      if (record.status == TaskStatus.canceled) continue;

      String reciterName = 'Unknown Reciter';
      String surahName = 'Unknown Surah';
      int surahNumber = 1;
      bool isFullQuranItem = false;

      try {
        final data = jsonDecode(record.task.metaData);
        reciterName = data['reciterName'] ?? reciterName;
        surahName = data['surahName'] ?? surahName;
        surahNumber = data['surahNumber'] ?? surahNumber;
        isFullQuranItem = data['isFullQuran'] ?? false;
      } catch (_) {}

      if (record.status == TaskStatus.complete) {
        try {
          final data = jsonDecode(record.task.metaData);
          if (data['movedToShared'] == true) continue;
        } catch (_) {
          continue;
        }

        final relativeSubDir = '$_baseRelativeDir/${reciterName.replaceAll(' ', '_')}';
        await downloadService.moveToSharedStorage(record.taskId, relativeSubDir);
        continue;
      }

      DownloadStatus appStatus = DownloadStatus.pending;
      if (record.status == TaskStatus.running) appStatus = DownloadStatus.downloading;
      if (record.status == TaskStatus.paused) appStatus = DownloadStatus.paused;
      if (record.status == TaskStatus.failed) appStatus = DownloadStatus.failed;

      restoredQueue.add(DownloadItem(
        id: record.taskId,
        surah: Surah(number: surahNumber, nameArabic: surahName),
        reciter: Reciter(name: reciterName, serverUrl: ''),
        savePath: _baseRelativeDir,
        status: appStatus,
        progress: record.progress,
        isFullQuran: isFullQuranItem,
      ));
    }

    double freeSpace = 0;
    double totalSpace = 0;
    try {
      final diskSpace = DiskSpacePlus();
      freeSpace = await diskSpace.getFreeDiskSpace ?? 0.0;
      totalSpace = await diskSpace.getTotalDiskSpace ?? 0.0;
    } catch (e) {}

    emit(DownloaderReady(
      queue: restoredQueue,
      savePath: _baseRelativeDir,
      freeSpaceMB: freeSpace,
      totalSpaceMB: totalSpace,
    ));
  }

  Future<void> startDownload({
    required Reciter reciter,
    required List<Surah> surahs,
    bool isFullQuran = false,
    bool forceRedownload = false,
  }) async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    List<DownloadItem> newItems = [];
    final taskIdsToRedownload = <String>{};

    for (var surah in surahs) {
      final taskId = '${reciter.name}_${surah.number}';

      final existingInQueue = currentState.queue.where((e) => e.id == taskId).toList();
      if (existingInQueue.any((e) =>
          e.status == DownloadStatus.downloading ||
          e.status == DownloadStatus.pending ||
          e.status == DownloadStatus.paused)) {
        continue;
      }

      if (forceRedownload) {
        await downloadService.clearCompletedTask(taskId);
      } else {
        final alreadyCompleted = await downloadService.isTaskCompleted(taskId);
        if (alreadyCompleted) continue;
      }

      taskIdsToRedownload.add(taskId);
      newItems.add(DownloadItem(
        id: taskId,
        surah: surah,
        reciter: reciter,
        savePath: _baseRelativeDir,
        status: DownloadStatus.pending,
        isFullQuran: isFullQuran,
      ));
    }

    if (newItems.isEmpty) return;

    final firstItem = newItems.removeAt(0);
    _pendingQueue.addAll(newItems);

    final filtered = currentState.queue.where((e) => !taskIdsToRedownload.contains(e.id)).toList();
    final newQueue = [...filtered, firstItem];
    emit(currentState.copyWith(queue: newQueue));

    _startNextPendingDownload();
  }

  void _startNextPendingDownload() {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    DownloadItem? nextPending;

    if (_pendingQueue.isNotEmpty) {
      nextPending = _pendingQueue.removeAt(0);
      final newQueue = [...currentState.queue, nextPending];
      emit(currentState.copyWith(queue: newQueue));
    } else {
      final pending = currentState.queue.where((e) => e.status == DownloadStatus.pending).toList();
      if (pending.isEmpty) return;
      nextPending = pending.first;
    }

    final surahNumStr = nextPending.surah.number.toString().padLeft(3, '0');
    final fileName = '$surahNumStr - ${nextPending.surah.nameArabic}.mp3';
    final relativeDir = '$_baseRelativeDir/${nextPending.reciter.name.replaceAll(' ', '_')}';

    final metaData = jsonEncode({
      'reciterName': nextPending.reciter.name,
      'surahName': nextPending.surah.nameArabic,
      'surahNumber': nextPending.surah.number,
      'isFullQuran': nextPending.isFullQuran,
    });

    final requiresWiFi = settingsBox.get('wifiOnly', defaultValue: false) as bool;

    _updateItemStatus(nextPending.id, DownloadStatus.downloading);

    downloadService.startDownload(
      taskId: nextPending.id,
      url: downloadUrl(nextPending.reciter, surahNumStr),
      directory: relativeDir,
      fileName: fileName,
      metaData: metaData,
      requiresWiFi: requiresWiFi,
    );
  }

  String downloadUrl(Reciter reciter, String surahNumStr) =>
      '${reciter.serverUrl.replaceAll(RegExp(r'/$'), '')}/$surahNumStr.mp3';

  Future<void> pauseDownload(String taskId) async {
    _updateItemStatus(taskId, DownloadStatus.paused);
    await downloadService.pauseDownload(taskId);
  }

  Future<void> resumeDownload(String taskId) async {
    _updateItemStatus(taskId, DownloadStatus.downloading);
    await downloadService.resumeDownload(taskId);
  }

  Future<void> cancelDownload(String taskId) async {
    _updateItemStatus(taskId, DownloadStatus.canceled);
    await downloadService.cancelDownload(taskId);
  }

  Future<void> cancelAll() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;
    final toCancel = currentState.queue.where(
      (e) => e.status == DownloadStatus.downloading || e.status == DownloadStatus.pending || e.status == DownloadStatus.paused,
    ).toList();
    if (toCancel.isEmpty) return;

    final ids = toCancel.map((e) => e.id).toSet();
    final newQueue = currentState.queue.where((e) => !ids.contains(e.id)).toList();
    _pendingQueue.clear();
    emit(currentState.copyWith(queue: newQueue));

    await Future.wait(toCancel.map((e) => downloadService.cancelDownload(e.id)));
  }

  void _updateItemStatus(String taskId, DownloadStatus status) {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final newQueue = currentState.queue.map((item) {
      if (item.id == taskId) {
        return item.copyWith(status: status);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(queue: newQueue));
  }

  Future<void> pauseAll() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final toPause = currentState.queue.where(
      (e) => e.status == DownloadStatus.downloading || e.status == DownloadStatus.pending,
    ).toList();
    if (toPause.isEmpty) return;

    final ids = toPause.map((e) => e.id).toSet();
    final newQueue = currentState.queue.map((item) {
      if (ids.contains(item.id)) {
        return item.copyWith(status: DownloadStatus.paused);
      }
      return item;
    }).toList();
    emit(currentState.copyWith(queue: newQueue));

    await Future.wait(toPause.map((e) => downloadService.pauseDownload(e.id)));
  }

  Future<void> resumeAll() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final paused = currentState.queue.where(
      (e) => e.status == DownloadStatus.paused,
    ).toList();
    if (paused.isEmpty) return;

    // Only resume the first paused item; set the rest back to pending
    // so _startNextPendingDownload picks them one at a time
    final first = paused.first;
    final restIds = paused.skip(1).map((e) => e.id).toSet();
    final newQueue = currentState.queue.map((item) {
      if (item.id == first.id) {
        return item.copyWith(status: DownloadStatus.downloading);
      }
      if (restIds.contains(item.id)) {
        return item.copyWith(status: DownloadStatus.pending);
      }
      return item;
    }).toList();
    emit(currentState.copyWith(queue: newQueue));

    final record = await FileDownloader().database.recordForId(first.id);
    if (record != null) {
      await downloadService.resumeDownload(first.id);
    } else {
      await retryDownload(first);
    }
  }

  Future<void> retryDownload(DownloadItem item) async {
    final surahNumStr = item.surah.number.toString().padLeft(3, '0');
    final fileName = '$surahNumStr - ${item.surah.nameArabic}.mp3';
    final relativeDir = '$_baseRelativeDir/${item.reciter.name.replaceAll(' ', '_')}';

    final metaData = jsonEncode({
      'reciterName': item.reciter.name,
      'surahName': item.surah.nameArabic,
      'surahNumber': item.surah.number,
      'isFullQuran': item.isFullQuran,
    });

    final requiresWiFi = settingsBox.get('wifiOnly', defaultValue: false) as bool;

    _updateItemStatus(item.id, DownloadStatus.downloading);

    await downloadService.startDownload(
      taskId: item.id,
      url: downloadUrl(item.reciter, surahNumStr),
      directory: relativeDir,
      fileName: fileName,
      metaData: metaData,
      requiresWiFi: requiresWiFi,
    );
  }

  Future<bool> isTaskCompleted(String taskId) async {
    if (_moveInProgressIds.contains(taskId)) return true;
    return downloadService.isTaskCompleted(taskId);
  }

  Future<void> deleteDownload(DownloadItem item) async {
    try {
      await FileDownloader().database.deleteRecordWithId(item.id);
    } catch (_) {}

    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final newQueue = currentState.queue.where((i) => i.id != item.id).toList();
    emit(currentState.copyWith(queue: newQueue));
  }

  Future<void> validateCompletedItems() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;
    final completed = currentState.queue.where((e) => e.status == DownloadStatus.completed).toList();

    List<DownloadItem> valid = [];
    List<DownloadItem> invalid = [];

    for (var item in completed) {
      final exists = await downloadService.isTaskCompleted(item.id);
      if (exists) {
        valid.add(item);
      } else {
        invalid.add(item);
        try {
          await FileDownloader().database.deleteRecordWithId(item.id);
        } catch (_) {}
      }
    }

    if (invalid.isEmpty) return;

    final nonCompleted = currentState.queue.where((e) => e.status != DownloadStatus.completed).toList();
    emit(currentState.copyWith(queue: [...nonCompleted, ...valid]));
  }

  Future<void> clearAll() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    for (var item in currentState.queue) {
      if (item.status == DownloadStatus.downloading || item.status == DownloadStatus.paused) {
        await downloadService.cancelDownload(item.id);
      }
      try {
        await FileDownloader().database.deleteRecordWithId(item.id);
      } catch (_) {}
    }

    _pendingQueue.clear();
    emit(currentState.copyWith(queue: []));
  }

  Future<void> retryFailedItems() async {
    if (state is! DownloaderReady) return;
    final currentState = state as DownloaderReady;

    final toRetry = currentState.queue.where(
      (e) => e.status == DownloadStatus.failed,
    ).toList();
    if (toRetry.isEmpty) return;

    await Future.wait(toRetry.map((e) => retryDownload(e)));
  }
}
