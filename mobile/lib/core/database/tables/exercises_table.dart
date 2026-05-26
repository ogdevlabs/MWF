import 'package:drift/drift.dart';

class LocalExercises extends Table {
  @override
  String get tableName => 'local_exercises';

  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  IntColumn get displayOrder => integer()();
  TextColumn get title => text()();
  TextColumn get cueText => text().nullable()();
  TextColumn get muxAssetId => text().nullable()();
  TextColumn get muxPlaybackId => text().nullable()();
  TextColumn get muxDownloadUrl => text().nullable()();
  TextColumn get modelAssetUrl => text().nullable()();
  IntColumn get repCount => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get videoVersion => integer().withDefault(const Constant(1))();
  TextColumn get localVideoPath => text().nullable()();
  TextColumn get localModelPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
