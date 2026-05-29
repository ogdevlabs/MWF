import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue.dart';

/// CQRS repository for metric log operations.
/// Command side: writes to Drift + enqueues to SyncQueue.
/// Query side: reads reactive stream from MetricLogsDao.
class MetricRepository {
  MetricRepository({
    required this.db,
    required this.syncQueue,
    required this.studentId,
  });

  final AppDatabase db;
  final SyncQueue syncQueue;
  final String studentId;

  /// Command: insert metric log locally and enqueue remote write.
  /// CRITICAL: logged_at serialized as YYYY-MM-DD for Supabase date column.
  Future<void> logMetric({
    required String metricType,
    String? metricSubtype,
    required double value,
    required String unit,
    required DateTime loggedAt,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // 1. Local write (immediate) — per D-16
    await db.metricLogsDao.upsertMetricLog(LocalMetricLogsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      metricType: Value(metricType),
      metricSubtype: Value(metricSubtype),
      value: Value(value),
      unit: Value(unit),
      loggedAt: Value(loggedAt),
      createdAt: Value(now),
    ));

    // 2. Enqueue remote write — per D-16
    // Table name is 'metric_logs' (confirmed in migration 001_initial_schema.sql)
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'metric_logs',
      payload: {
        'id': id,
        'student_id': studentId,
        'metric_type': metricType,
        'metric_subtype': metricSubtype,
        'value': value,
        'unit': unit,
        // Supabase metric_logs.logged_at is DATE type — must be YYYY-MM-DD
        'logged_at':
            '${loggedAt.year.toString().padLeft(4, '0')}'
            '-${loggedAt.month.toString().padLeft(2, '0')}'
            '-${loggedAt.day.toString().padLeft(2, '0')}',
        'created_at': now.toUtc().toIso8601String(),
      },
    );
  }

  /// Query: reactive stream of metrics by type, ordered by loggedAt asc.
  /// Delegates to MetricLogsDao.watchMetricsByType.
  Stream<List<LocalMetricLog>> watchMetricsByType(String metricType) =>
      db.metricLogsDao.watchMetricsByType(studentId, metricType);
}
