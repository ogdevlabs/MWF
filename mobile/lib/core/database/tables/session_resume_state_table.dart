import 'package:drift/drift.dart';

class SessionResumeState extends Table {
  @override
  String get tableName => 'session_resume_state';

  TextColumn get sessionId => text()();
  TextColumn get studentId => text()();
  IntColumn get exerciseIndex =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sessionId};
}
