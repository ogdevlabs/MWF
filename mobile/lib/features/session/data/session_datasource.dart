import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/session_model.dart';

part 'session_datasource.g.dart';

/// Reads session and exercise data from local Drift database.
/// Derives lock state purely from local enrollment.currentDay vs session.dayNumber.
class SessionDatasource {
  SessionDatasource(this._db);
  final AppDatabase _db;

  /// Get all sessions for a program with their lock state and exercise count.
  /// Per D-09: derives state from enrollment.currentDay.
  Future<List<SessionModel>> getSessionsWithState({
    required String programId,
    required int currentDay,
  }) async {
    final sessions = await _db.sessionsDao.getSessionsByProgram(programId);
    final result = <SessionModel>[];
    for (final s in sessions) {
      final count = await _db.exercisesDao.getExerciseCountBySession(s.id);
      result.add(SessionModel(
        id: s.id,
        programId: s.programId,
        dayNumber: s.dayNumber,
        title: s.title,
        description: s.description,
        exerciseCount: count,
        state: deriveSessionState(
          dayNumber: s.dayNumber,
          currentDay: currentDay,
        ),
      ));
    }
    return result;
  }

  /// Get all exercises for a session, ordered by displayOrder.
  Future<List<ExerciseModel>> getExercisesBySession(String sessionId) async {
    final exercises = await _db.exercisesDao.getExercisesBySession(sessionId);
    return exercises
        .map((e) => ExerciseModel(
              id: e.id,
              sessionId: e.sessionId,
              displayOrder: e.displayOrder,
              title: e.title,
              cueText: e.cueText,
              muxPlaybackId: e.muxPlaybackId,
              modelAssetUrl: e.modelAssetUrl,
              repCount: e.repCount,
              durationSeconds: e.durationSeconds,
              videoVersion: e.videoVersion,
              localVideoPath: e.localVideoPath,
              localModelPath: e.localModelPath,
            ))
        .toList();
  }
}

@riverpod
SessionDatasource sessionDatasource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionDatasource(db);
}
