import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_model.freezed.dart';
part 'program_model.g.dart';

/// Domain model representing a program in the catalog.
///
/// Maps from program_catalog_view which returns:
/// id, title, description, difficulty, duration_weeks, thumbnail_url,
/// published_at, enrollment_id, current_day, is_subscribed
@freezed
abstract class ProgramModel with _$ProgramModel {
  const factory ProgramModel({
    required String id,
    required String title,
    String? description,
    required String difficulty,
    required int durationWeeks,
    String? thumbnailUrl,
    DateTime? publishedAt,
    String? enrollmentId,
    @Default(1) int currentDay,
    @Default(false) bool isSubscribed,
  }) = _ProgramModel;

  factory ProgramModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramModelFromJson(json);

  /// Create from program_catalog_view row (QueryGateway output).
  factory ProgramModel.fromCatalogRow(Map<String, dynamic> row) =>
      ProgramModel(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String?,
        difficulty: (row['difficulty'] as String?) ?? 'beginner',
        durationWeeks: (row['duration_weeks'] as int?) ?? 4,
        thumbnailUrl: row['thumbnail_url'] as String?,
        publishedAt: row['published_at'] != null
            ? DateTime.parse(row['published_at'] as String)
            : null,
        enrollmentId: row['enrollment_id'] as String?,
        currentDay: (row['current_day'] as int?) ?? 1,
        isSubscribed: (row['is_subscribed'] as bool?) ?? false,
      );
}

/// Convenience extensions for program lock/access state.
extension ProgramAccessState on ProgramModel {
  /// Whether this program is currently enrolled (has an enrollment_id).
  bool get isEnrolled => enrollmentId != null;

  /// Whether this program is locked (not subscribed).
  bool get isLocked => !isSubscribed;

  /// Whether user can access content (subscribed, regardless of enrollment).
  bool get canAccess => isSubscribed;
}
