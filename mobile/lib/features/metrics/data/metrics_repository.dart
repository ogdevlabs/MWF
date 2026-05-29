import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/cqrs/command_bus.dart';
import '../../../core/database/app_database.dart';
import '../domain/metric_log_model.dart';

part 'metrics_repository.g.dart';

/// Repository for body metric logging (FR-008).
///
/// Write flow (offline-first):
/// 1. Write to local Drift immediately
/// 2. Enqueue to CommandBus for Supabase sync via logMetric command
///
/// Read flow:
/// - Reads directly from local Drift (reactive streams for UI)
class MetricsRepository {
  MetricsRepository(this._db, this._commandBus);

  final AppDatabase _db;
  final CommandBus _commandBus;

  /// Log a body metric entry.
  ///
  /// Writes to local Drift and enqueues to CommandBus for Supabase sync.
  /// Safe to call offline — sync happens when connectivity is restored.
  Future<void> logMetric({
    required String studentId,
    required String metricType,
    String? metricSubtype,
    required double value,
    required String unit,
    DateTime? loggedAt,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final date = loggedAt ?? now;

    await _db.metricLogsDao.upsertMetricLog(LocalMetricLogsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      metricType: Value(metricType),
      metricSubtype: Value(metricSubtype),
      value: Value(value),
      unit: Value(unit),
      loggedAt: Value(date),
      createdAt: Value(now),
    ));

    await _commandBus.dispatch(CommandType.logMetric, {
      'id': id,
      'student_id': studentId,
      'metric_type': metricType,
      'metric_subtype': metricSubtype,
      'value': value,
      'unit': unit,
      'logged_at': date.toIso8601String(),
      'created_at': now.toIso8601String(),
    });
  }

  /// Watch a metric stream by type — reactive, updates on new inserts.
  Stream<List<MetricLog>> watchMetrics(
          String studentId, String metricType) =>
      _db.metricLogsDao
          .watchMetricsByType(studentId, metricType)
          .map((rows) => rows.map(MetricLog.fromDrift).toList());

  /// Get all metrics for a student, filtered by metric type.
  Future<List<MetricLog>> getMetrics(
      String studentId, String metricType) async {
    final rows = await _db.metricLogsDao.getMetricsByStudent(studentId);
    return rows
        .where((r) => r.metricType == metricType)
        .map(MetricLog.fromDrift)
        .toList();
  }
}

@riverpod
MetricsRepository metricsRepository(Ref ref) {
  return MetricsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(commandBusProvider),
  );
}

/// Reactive metric log stream for UI consumption (FR-009).
@riverpod
Stream<List<MetricLog>> metricLogsStream(
    Ref ref, String studentId, String metricType) {
  return ref
      .watch(metricsRepositoryProvider)
      .watchMetrics(studentId, metricType);
}
