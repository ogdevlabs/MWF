import 'package:drift/drift.dart';

class LocalSessions extends Table {
  @override
  String get tableName => 'local_sessions';

  TextColumn get id => text()();
  TextColumn get programId => text()();
  IntColumn get dayNumber => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
