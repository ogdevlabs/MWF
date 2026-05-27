import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/session_model.dart';
import 'session_datasource.dart';

part 'session_providers.g.dart';

/// Provider for sessions with lock state for a given program.
/// Parameters: programId and currentDay (from enrollment).
@riverpod
Future<List<SessionModel>> sessionsWithState(
  Ref ref, {
  required String programId,
  required int currentDay,
}) async {
  final datasource = ref.watch(sessionDatasourceProvider);
  return datasource.getSessionsWithState(
    programId: programId,
    currentDay: currentDay,
  );
}

/// Provider for exercises in a session, ordered by displayOrder.
@riverpod
Future<List<ExerciseModel>> sessionExercises(
  Ref ref, {
  required String sessionId,
}) async {
  final datasource = ref.watch(sessionDatasourceProvider);
  return datasource.getExercisesBySession(sessionId);
}
