import 'package:drift/drift.dart';

class LocalFeedbackThreads extends Table {
  @override
  String get tableName => 'local_feedback_threads';

  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get sessionId => text()();
  TextColumn get studentMessage => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get coachReply => text().nullable()();
  DateTimeColumn get repliedAt => dateTime().nullable()();
  BoolColumn get notificationSent =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
