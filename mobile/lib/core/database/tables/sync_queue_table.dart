import 'package:drift/drift.dart';

class SyncQueue extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get targetTable => text().named('table_name')();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}
