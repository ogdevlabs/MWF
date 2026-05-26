import 'package:drift/drift.dart';

class LocalPrograms extends Table {
  @override
  String get tableName => 'local_programs';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get difficulty => text()();
  IntColumn get durationWeeks => integer()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get published => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
