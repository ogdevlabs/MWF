import 'package:drift/drift.dart';

class DownloadManifest extends Table {
  @override
  String get tableName => 'download_manifest';

  TextColumn get exerciseId => text()();
  IntColumn get videoVersion => integer()();
  TextColumn get videoLocalPath => text().nullable()();
  TextColumn get modelLocalPath => text().nullable()();
  TextColumn get downloadStatus =>
      text().withDefault(const Constant('pending'))();
  IntColumn get downloadedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
