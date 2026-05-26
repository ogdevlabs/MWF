// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalProgressRecordsTable get localProgressRecords =>
      attachedDatabase.localProgressRecords;
  ProgressDaoManager get managers => ProgressDaoManager(this);
}

class ProgressDaoManager {
  final _$ProgressDaoMixin _db;
  ProgressDaoManager(this._db);
  $$LocalProgressRecordsTableTableManager get localProgressRecords =>
      $$LocalProgressRecordsTableTableManager(
        _db.attachedDatabase,
        _db.localProgressRecords,
      );
}
