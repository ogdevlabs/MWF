import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/metric_logs_table.dart';

part 'metric_logs_dao.g.dart';

@DriftAccessor(tables: [LocalMetricLogs])
class MetricLogsDao extends DatabaseAccessor<AppDatabase>
    with _$MetricLogsDaoMixin {
  MetricLogsDao(super.attachedDatabase);

  Stream<List<LocalMetricLog>> watchMetricsByType(
          String studentId, String metricType) =>
      (select(localMetricLogs)
            ..where((t) =>
                t.studentId.equals(studentId) &
                t.metricType.equals(metricType))
            ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
          .watch();

  Future<List<LocalMetricLog>> getMetricsByStudent(String studentId) =>
      (select(localMetricLogs)
            ..where((t) => t.studentId.equals(studentId))
            ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
          .get();

  Future<void> insertMetricLog(LocalMetricLogsCompanion entry) =>
      into(localMetricLogs).insert(entry);

  Future<void> upsertMetricLog(LocalMetricLogsCompanion entry) =>
      into(localMetricLogs).insertOnConflictUpdate(entry);
}
