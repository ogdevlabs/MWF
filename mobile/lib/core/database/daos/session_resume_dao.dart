import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/session_resume_state_table.dart';

part 'session_resume_dao.g.dart';

@DriftAccessor(tables: [SessionResumeState])
class SessionResumeDao extends DatabaseAccessor<AppDatabase>
    with _$SessionResumeDaoMixin {
  SessionResumeDao(super.attachedDatabase);

  /// Returns the saved resume state for a session, or null if none exists.
  Future<SessionResumeStateData?> getResumeState(String sessionId) =>
      (select(sessionResumeState)
            ..where((t) => t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  /// Saves (or updates) the resume state for a session.
  Future<void> saveResumeState(
    String sessionId,
    String studentId,
    int exerciseIndex,
  ) =>
      into(sessionResumeState).insertOnConflictUpdate(
        SessionResumeStateCompanion(
          sessionId: Value(sessionId),
          studentId: Value(studentId),
          exerciseIndex: Value(exerciseIndex),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Removes the resume state for a session.
  Future<void> clearResumeState(String sessionId) async {
    await (delete(sessionResumeState)
          ..where((t) => t.sessionId.equals(sessionId)))
        .go();
  }
}
