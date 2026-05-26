// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_dao.dart';

// ignore_for_file: type=lint
mixin _$FeedbackDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalFeedbackThreadsTable get localFeedbackThreads =>
      attachedDatabase.localFeedbackThreads;
  FeedbackDaoManager get managers => FeedbackDaoManager(this);
}

class FeedbackDaoManager {
  final _$FeedbackDaoMixin _db;
  FeedbackDaoManager(this._db);
  $$LocalFeedbackThreadsTableTableManager get localFeedbackThreads =>
      $$LocalFeedbackThreadsTableTableManager(
        _db.attachedDatabase,
        _db.localFeedbackThreads,
      );
}
