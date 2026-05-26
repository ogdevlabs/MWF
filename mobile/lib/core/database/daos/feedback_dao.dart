import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/feedback_threads_table.dart';

part 'feedback_dao.g.dart';

@DriftAccessor(tables: [LocalFeedbackThreads])
class FeedbackDao extends DatabaseAccessor<AppDatabase>
    with _$FeedbackDaoMixin {
  FeedbackDao(super.attachedDatabase);

  Stream<List<LocalFeedbackThread>> watchFeedbackByStudent(String studentId) =>
      (select(localFeedbackThreads)
            ..where((t) => t.studentId.equals(studentId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<LocalFeedbackThread?> getByStudentAndSession(
          String studentId, String sessionId) =>
      (select(localFeedbackThreads)
            ..where((t) =>
                t.studentId.equals(studentId) &
                t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  Future<void> upsertFeedback(LocalFeedbackThreadsCompanion entry) =>
      into(localFeedbackThreads).insertOnConflictUpdate(entry);

  Stream<List<LocalFeedbackThread>> watchReplies(String studentId) =>
      (select(localFeedbackThreads)
            ..where((t) =>
                t.studentId.equals(studentId) & t.coachReply.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.repliedAt)]))
          .watch();
}
