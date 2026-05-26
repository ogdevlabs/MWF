import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/student_model.dart';

part 'student_remote_datasource.g.dart';

/// Manages student profile in Supabase `students` table.
///
/// IMPORTANT: No DB trigger exists for creating student rows on auth signup.
/// This datasource must be called explicitly after every successful sign-up
/// or social login. Uses onConflict: 'id' for idempotency on re-login.
///
/// RLS policy `students_insert_own` requires: id = auth.uid().
class StudentRemoteDatasource {
  StudentRemoteDatasource(this._supabase);
  final SupabaseClient _supabase;

  /// Upsert student profile after sign-up or social login.
  ///
  /// Uses onConflict: 'id' so returning users don't get 409.
  /// RLS enforces id = auth.uid() — passing any other ID returns 403.
  Future<void> upsertStudentProfile({
    required String userId,
    required String email,
    String? displayName,
    String? avatarUrl,
  }) async {
    await _supabase.from('students').upsert({
      'id': userId,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'timezone': 'UTC',
    }, onConflict: 'id');
  }

  /// Fetch student profile by ID.
  Future<Student?> getStudentProfile(String userId) async {
    final response = await _supabase
        .from('students')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Student.fromSupabaseRow(response);
  }
}

@riverpod
StudentRemoteDatasource studentRemoteDatasource(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StudentRemoteDatasource(supabase);
}
