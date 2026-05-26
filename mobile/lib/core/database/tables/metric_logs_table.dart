import 'package:drift/drift.dart';

class LocalMetricLogs extends Table {
  @override
  String get tableName => 'local_metric_logs';

  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get metricType => text()();
  TextColumn get metricSubtype => text().nullable()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  DateTimeColumn get loggedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
