import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

/// Lock state of a session row in the program detail list (D-09, D-10).
enum SessionState { complete, current, locked }

/// Domain model for a session row in the session list.
@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String programId,
    required int dayNumber,
    required String title,
    String? description,
    required int exerciseCount,
    required SessionState state,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}

/// Domain model for an individual exercise within a session.
@freezed
abstract class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    required String id,
    required String sessionId,
    required int displayOrder,
    required String title,
    String? cueText,
    String? muxPlaybackId,
    String? modelAssetUrl,
    int? repCount,
    int? durationSeconds,
    int? videoVersion,
    String? localVideoPath,
    String? localModelPath,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);
}

/// Helper to derive session state from day number vs enrollment current day.
SessionState deriveSessionState({
  required int dayNumber,
  required int currentDay,
}) {
  if (dayNumber < currentDay) return SessionState.complete;
  if (dayNumber == currentDay) return SessionState.current;
  return SessionState.locked;
}
