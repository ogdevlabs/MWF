import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/cqrs/command_bus.dart';
import '../../../core/database/app_database.dart';
import 'streak_calculator.dart';

part 'session_completion_service.g.dart';

/// Coordinates all side effects of completing a session (D-13):
/// 1. Write progress_record to Drift
/// 2. Dispatch completeSession command to CommandBus (sync queue)
/// 3. Increment enrollment.current_day locally
/// 4. Clear session resume state
/// 5. Compute and return current streak
class SessionCompletionService {
  SessionCompletionService(this._db, this._commandBus);
  final AppDatabase _db;
  final CommandBus _commandBus;

  /// Complete a session. Returns the computed streak value for the completion screen.
  /// Per RESEARCH.md Pitfall 5: streak is computed synchronously after Drift write,
  /// NOT via reactive invalidation, to ensure correct value on completion screen.
  Future<int> completeSession({
    required String studentId,
    required String sessionId,
    required String enrollmentId,
    required int currentDay,
    required int durationSeconds,
  }) async {
    final now = DateTime.now();
    final progressId = const Uuid().v4();

    // 1. Write progress_record to Drift (local source of truth)
    await _db.progressDao.upsertProgress(LocalProgressRecordsCompanion(
      id: Value(progressId),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      completedAt: Value(now),
      durationSeconds: Value(durationSeconds),
      createdAt: Value(now),
    ));

    // 2. Enqueue to CommandBus for Supabase sync
    await _commandBus.dispatch(CommandType.completeSession, {
      'id': progressId,
      'student_id': studentId,
      'session_id': sessionId,
      'completed_at': now.toIso8601String(),
      'duration_seconds': durationSeconds,
    });

    // 3. Increment enrollment current_day locally
    await _db.enrollmentsDao.updateCurrentDay(enrollmentId, currentDay + 1);

    // 4. Clear resume state (FR-013)
    await _db.sessionResumeDao.clearResumeState(sessionId);

    // 5. Compute streak (FR-014)
    final records = await _db.progressDao.getProgressByStudent(studentId);
    final completedDates = records.map((r) => r.completedAt).toList();
    return computeCurrentStreak(completedDates);
  }
}

@riverpod
SessionCompletionService sessionCompletionService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final commandBus = ref.watch(commandBusProvider);
  return SessionCompletionService(db, commandBus);
}
