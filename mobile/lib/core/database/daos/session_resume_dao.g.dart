// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_resume_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionResumeDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionResumeStateTable get sessionResumeState =>
      attachedDatabase.sessionResumeState;
  SessionResumeDaoManager get managers => SessionResumeDaoManager(this);
}

class SessionResumeDaoManager {
  final _$SessionResumeDaoMixin _db;
  SessionResumeDaoManager(this._db);
  $$SessionResumeStateTableTableManager get sessionResumeState =>
      $$SessionResumeStateTableTableManager(
        _db.attachedDatabase,
        _db.sessionResumeState,
      );
}
