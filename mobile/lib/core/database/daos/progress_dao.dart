import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/progress_records_table.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [LocalProgressRecords])
class ProgressDao extends DatabaseAccessor<AppDatabase> with _$ProgressDaoMixin {
  ProgressDao(super.attachedDatabase);

  Stream<List<LocalProgressRecord>> watchProgressByStudent(String studentId) =>
      (select(localProgressRecords)
            ..where((t) => t.studentId.equals(studentId))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();

  Future<List<LocalProgressRecord>> getProgressByStudent(String studentId) =>
      (select(localProgressRecords)
            ..where((t) => t.studentId.equals(studentId)))
          .get();

  Future<LocalProgressRecord?> getByStudentAndSession(
          String studentId, String sessionId) =>
      (select(localProgressRecords)
            ..where((t) =>
                t.studentId.equals(studentId) & t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  Future<void> upsertProgress(LocalProgressRecordsCompanion entry) =>
      into(localProgressRecords).insertOnConflictUpdate(entry);
}
