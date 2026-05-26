import 'package:drift/drift.dart';

class LocalProgressRecords extends Table {
  @override
  String get tableName => 'local_progress_records';

  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get syncedFromOffline =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
