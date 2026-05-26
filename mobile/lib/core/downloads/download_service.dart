import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';

part 'download_service.g.dart';

/// Manages background downloads of exercise media (video + 3D model).
///
/// Uses background_downloader for cross-platform background downloads.
/// Stores relative paths in download_manifest (not absolute — iOS paths change).
/// Resolves actual file path at playback time via BaseDirectory.applicationDocuments.
///
/// NOTE: iOS requires "Background Fetch" capability in Xcode Signing & Capabilities.
/// Without it, downloads won't resume when the app is backgrounded.
class DownloadService {
  DownloadService({required this.db});

  final AppDatabase db;
  final _progressController = StreamController<DownloadProgress>.broadcast();

  /// Stream of download progress updates.
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Initialize the download service — must be called once at app startup.
  /// Sets up the global status/progress listener on FileDownloader.
  void initialize() {
    FileDownloader().updates.listen((update) {
      if (update is TaskStatusUpdate) {
        _handleStatusUpdate(update);
      }
      if (update is TaskProgressUpdate) {
        _progressController.add(DownloadProgress(
          exerciseId: update.task.metaData,
          progress: update.progress,
        ));
      }
    });
  }

  /// Download exercise media (video and/or 3D model).
  ///
  /// [exerciseId]: UUID of the exercise
  /// [videoUrl]: Mux signed download URL for the video (nullable if no video)
  /// [modelUrl]: Supabase Storage URL for the GLB model (nullable if no model)
  /// [videoVersion]: Current video version for staleness detection
  Future<void> downloadExerciseMedia({
    required String exerciseId,
    String? videoUrl,
    String? modelUrl,
    required int videoVersion,
  }) async {
    // Update manifest to in_progress
    await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
      exerciseId: Value(exerciseId),
      videoVersion: Value(videoVersion),
      downloadStatus: const Value('in_progress'),
    ));

    // Enqueue video download if URL available
    if (videoUrl != null && videoUrl.isNotEmpty) {
      final videoTask = DownloadTask(
        taskId: 'exercise_${exerciseId}_video',
        url: videoUrl,
        filename: '${exerciseId}_video.mp4',
        directory: 'exercises/$exerciseId',
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        requiresWiFi: false,
        retries: 3,
        allowPause: true,
        metaData: exerciseId,
      );
      await FileDownloader().enqueue(videoTask);
    }

    // Enqueue model download if URL available
    if (modelUrl != null && modelUrl.isNotEmpty) {
      final modelTask = DownloadTask(
        taskId: 'exercise_${exerciseId}_model',
        url: modelUrl,
        filename: '${exerciseId}_model.glb',
        directory: 'exercises/$exerciseId',
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        requiresWiFi: false,
        retries: 3,
        allowPause: true,
        metaData: exerciseId,
      );
      await FileDownloader().enqueue(modelTask);
    }
  }

  /// Cancel all downloads for a specific exercise.
  Future<void> cancelDownload(String exerciseId) async {
    await FileDownloader().cancelTaskWithId('exercise_${exerciseId}_video');
    await FileDownloader().cancelTaskWithId('exercise_${exerciseId}_model');
    await db.downloadManifestDao.updateStatus(exerciseId, 'pending');
  }

  /// Resume all paused/pending downloads.
  /// Called on reconnect via ConnectivityProvider.
  ///
  /// Actual re-download logic requires URLs from exercise data and is
  /// implemented in SyncService.sync() in Phase 2-06.
  /// This method serves as the resume signal entry point.
  Future<void> resumeQueue() async {
    // pending entries are checked — actual URL re-resolution done in SyncService
    await db.downloadManifestDao.getPendingDownloads();
    // No-op until Phase 3 wires exercise URLs here.
  }

  /// Handle download status changes — update manifest in Drift.
  Future<void> _handleStatusUpdate(TaskStatusUpdate update) async {
    final exerciseId = update.task.metaData;
    if (exerciseId.isEmpty) return;

    switch (update.status) {
      case TaskStatus.complete:
        // Determine which file completed (video or model) from taskId
        final isVideo = update.task.taskId.contains('_video');
        final relativePath = 'exercises/$exerciseId/${update.task.filename}';

        if (isVideo) {
          await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
            exerciseId: Value(exerciseId),
            videoLocalPath: Value(relativePath),
            downloadStatus: const Value('complete'),
            downloadedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ));
        } else {
          await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
            exerciseId: Value(exerciseId),
            modelLocalPath: Value(relativePath),
            downloadStatus: const Value('complete'),
            downloadedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ));
        }
        break;
      case TaskStatus.failed:
        await db.downloadManifestDao.updateStatus(exerciseId, 'failed');
        break;
      case TaskStatus.canceled:
        await db.downloadManifestDao.updateStatus(exerciseId, 'pending');
        break;
      default:
        break;
    }
  }

  /// Dispose resources.
  void dispose() {
    _progressController.close();
  }
}

/// Download progress event for UI consumption.
class DownloadProgress {
  const DownloadProgress({
    required this.exerciseId,
    required this.progress,
  });

  final String exerciseId;
  final double progress; // 0.0 to 1.0
}

@Riverpod(keepAlive: true)
DownloadService downloadService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = DownloadService(db: db);
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
}
