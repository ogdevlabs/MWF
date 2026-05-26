import 'package:drift/drift.dart';

class LocalEnrollments extends Table {
  @override
  String get tableName => 'local_enrollments';

  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get programId => text()();
  DateTimeColumn get enrolledAt => dateTime()();
  IntColumn get currentDay => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
