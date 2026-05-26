// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$MetricLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalMetricLogsTable get localMetricLogs => attachedDatabase.localMetricLogs;
  MetricLogsDaoManager get managers => MetricLogsDaoManager(this);
}

class MetricLogsDaoManager {
  final _$MetricLogsDaoMixin _db;
  MetricLogsDaoManager(this._db);
  $$LocalMetricLogsTableTableManager get localMetricLogs =>
      $$LocalMetricLogsTableTableManager(
        _db.attachedDatabase,
        _db.localMetricLogs,
      );
}
