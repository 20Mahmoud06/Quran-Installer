import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  DownloadService() {
    _init();
  }

  void _init() {
    FileDownloader().configureNotificationForGroup(
      FileDownloader.defaultGroup,
      running: const TaskNotification('Downloading Quran', '{filename} - {progress}'),
      complete: const TaskNotification('Download Complete', '{filename}'),
      error: const TaskNotification('Download Failed', '{filename}'),
      paused: const TaskNotification('Download Paused', '{filename}'),
      progressBar: true,
    );
  }

  void registerCallbacks() {
    FileDownloader().registerCallbacks(
      taskProgressCallback: (update) {
        if (onProgress != null) {
          onProgress!(update.task.taskId, update.progress, update.networkSpeed, update.timeRemaining);
        }
      },
      taskStatusCallback: (update) {
        if (onStatusUpdate != null) {
          onStatusUpdate!(update.task.taskId, update.status, update.task);
        }
      },
    );
  }

  Function(String taskId, double progress, double networkSpeed, Duration timeRemaining)? onProgress;
  Function(String taskId, TaskStatus status, Task? task)? onStatusUpdate;

  Future<void> startDownload({
    required String taskId,
    required String url,
    required String directory,
    required String fileName,
    required String metaData,
    bool requiresWiFi = false,
  }) async {
    final task = DownloadTask(
      taskId: taskId,
      url: url,
      filename: fileName,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: 'quran_temp/$directory',
      updates: Updates.statusAndProgress,
      requiresWiFi: requiresWiFi,
      retries: 3,
      allowPause: true,
      metaData: metaData,
    );

    await FileDownloader().enqueue(task);
  }

  Future<String?> moveToSharedStorage(String taskId, String relativeSubDir, {Task? task}) async {
    DownloadTask? downloadTask;

    if (task != null) {
      downloadTask = _toDownloadTask(task);
    }

    if (downloadTask == null) {
      for (int i = 1; i <= 50; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final record = await FileDownloader().database.recordForId(taskId);
        if (record != null && record.status == TaskStatus.complete) {
          downloadTask = _toDownloadTask(record.task);
          break;
        }
      }
    }

    if (downloadTask == null) {
      return null;
    }

    if (Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      final path = '${docDir.path}/quran_temp/$relativeSubDir/${downloadTask.filename}';
      final file = File(path);
      if (!await file.exists()) return null;

      try {
        final updatedData = jsonDecode(downloadTask.metaData);
        updatedData['movedToShared'] = true;
        updatedData['finalPath'] = path;
        final updatedTask = downloadTask.copyWith(metaData: jsonEncode(updatedData));
        await FileDownloader().database.updateRecord(
          TaskRecord(updatedTask, TaskStatus.complete, 1.0, -1, null),
        );
      } catch (e) {}

      return path;
    }

    try {
      final String? result = await FileDownloader().moveToSharedStorage(
        downloadTask,
        SharedStorage.downloads,
        directory: relativeSubDir,
        mimeType: 'audio/mpeg',
      );

      if (result == null) {
        return null;
      }

      try {
        final updatedData = jsonDecode(downloadTask.metaData);
        updatedData['movedToShared'] = true;
        updatedData['finalPath'] = result;
        final updatedTask = downloadTask.copyWith(metaData: jsonEncode(updatedData));
        await FileDownloader().database.updateRecord(
          TaskRecord(updatedTask, TaskStatus.complete, 1.0, -1, null),
        );
      } catch (e) {}

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Coerce a [Task] back into a [DownloadTask].
  ///
  /// The library serializes the concrete type but may deserialise
  /// [TaskRecord.task] as the base [Task] class.  We rebuild a [DownloadTask]
  /// from its fields so that [moveToSharedStorage] (which requires
  /// [DownloadTask]) can work.
  DownloadTask? _toDownloadTask(Task task) {
    if (task is DownloadTask) return task;
    try {
      return DownloadTask(
        taskId: task.taskId,
        url: task.url,
        filename: task.filename,
        baseDirectory: task.baseDirectory,
        directory: task.directory,
        updates: task.updates,
        requiresWiFi: task.requiresWiFi,
        retries: task.retries,
        allowPause: task.allowPause,
        metaData: task.metaData,
        options: task.options,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isTaskCompleted(String taskId) async {
    try {
      final record = await FileDownloader().database.recordForId(taskId);
      if (record == null || record.status != TaskStatus.complete) return false;
      final data = jsonDecode(record.task.metaData);
      if (data['movedToShared'] != true) return false;

      final finalPath = data['finalPath'] as String?;
      if (finalPath != null && finalPath.isNotEmpty) {
        final file = File(finalPath);
        if (!await file.exists()) {
          await FileDownloader().database.deleteRecordWithId(taskId);
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearCompletedTask(String taskId) async {
    try {
      await FileDownloader().database.deleteRecordWithId(taskId);
    } catch (_) {}
  }

  Future<void> pauseDownload(String taskId) async {
    final task = await FileDownloader().taskForId(taskId);
    if (task != null && task is DownloadTask) {
      await FileDownloader().pause(task);
    }
  }

  Future<void> resumeDownload(String taskId) async {
    final task = await FileDownloader().taskForId(taskId);
    if (task != null && task is DownloadTask) {
      await FileDownloader().resume(task);
    }
  }

  Future<void> cancelDownload(String taskId) async {
    await FileDownloader().cancelTaskWithId(taskId);
  }
}
