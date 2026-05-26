import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

/// Domain model representing a student user profile.
/// Maps to the `students` table in Supabase.
@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default('UTC') String timezone,
    required DateTime createdAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  /// Create from Supabase students table row.
  factory Student.fromSupabaseRow(Map<String, dynamic> row) => Student(
        id: row['id'] as String,
        email: row['email'] as String,
        displayName: row['display_name'] as String?,
        avatarUrl: row['avatar_url'] as String?,
        timezone: (row['timezone'] as String?) ?? 'UTC',
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}
