import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tables/programs_table.dart';
import 'tables/sessions_table.dart';
import 'tables/exercises_table.dart';
import 'tables/enrollments_table.dart';
import 'tables/progress_records_table.dart';
import 'tables/metric_logs_table.dart';
import 'tables/feedback_threads_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/download_manifest_table.dart';

import 'daos/programs_dao.dart';
import 'daos/sessions_dao.dart';
import 'daos/exercises_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/metric_logs_dao.dart';
import 'daos/feedback_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/download_manifest_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalPrograms,
    LocalSessions,
    LocalExercises,
    LocalEnrollments,
    LocalProgressRecords,
    LocalMetricLogs,
    LocalFeedbackThreads,
    SyncQueue,
    DownloadManifest,
  ],
  daos: [
    ProgramsDao,
    SessionsDao,
    ExercisesDao,
    ProgressDao,
    MetricLogsDao,
    FeedbackDao,
    SyncQueueDao,
    DownloadManifestDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database.
  ///
  /// Accepts an optional [QueryExecutor] for test injection.
  /// In tests, pass `DatabaseConnection(NativeDatabase.memory())`.
  /// In production, uses `driftDatabase(name: 'mwf_local')`.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mwf_local');
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
