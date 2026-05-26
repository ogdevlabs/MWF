import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../network/supabase_client.dart';
import '../sync/connectivity_provider.dart';

part 'query_gateway.g.dart';

/// CQRS Query Gateway — read-only access to projection views.
///
/// Reads from Supabase projection views when online, falls back to local
/// Drift tables when offline. Feature layers consume this gateway for all
/// read operations instead of making direct Supabase queries.
///
/// Views consumed (defined in 003_cqrs_read_models.sql):
/// - program_catalog_view
/// - student_today_session_view
/// - session_playback_view
/// - student_progress_dashboard_view
/// - student_notifications_view
class QueryGateway {
  QueryGateway({
    required this.supabase,
    required this.db,
    required this.isOnline,
  });

  final SupabaseClient supabase;
  final AppDatabase db;
  final bool isOnline;

  /// Fetch the program catalog (published programs with enrollment overlay).
  Future<List<Map<String, dynamic>>> getProgramCatalog() async {
    if (isOnline) {
      try {
        final response =
            await supabase.from('program_catalog_view').select();
        return List<Map<String, dynamic>>.from(response as List);
      } catch (_) {
        // Fallback to local on network error
        return _localProgramCatalog();
      }
    }
    return _localProgramCatalog();
  }

  /// Fetch today's session for the current student.
  Future<List<Map<String, dynamic>>> getTodaySession() async {
    if (isOnline) {
      try {
        final response =
            await supabase.from('student_today_session_view').select();
        return List<Map<String, dynamic>>.from(response as List);
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Fetch session playback data (exercises with media readiness).
  Future<List<Map<String, dynamic>>> getSessionPlayback(
      String sessionId) async {
    if (isOnline) {
      try {
        final response = await supabase
            .from('session_playback_view')
            .select()
            .eq('session_id', sessionId)
            .order('display_order');
        return List<Map<String, dynamic>>.from(response as List);
      } catch (_) {
        return _localSessionPlayback(sessionId);
      }
    }
    return _localSessionPlayback(sessionId);
  }

  /// Fetch progress dashboard data.
  Future<List<Map<String, dynamic>>> getProgressDashboard() async {
    if (isOnline) {
      try {
        final response = await supabase
            .from('student_progress_dashboard_view')
            .select();
        return List<Map<String, dynamic>>.from(response as List);
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Fetch notifications (coach replies).
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (isOnline) {
      try {
        final response =
            await supabase.from('student_notifications_view').select();
        return List<Map<String, dynamic>>.from(response as List);
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  // -- Local fallbacks --

  Future<List<Map<String, dynamic>>> _localProgramCatalog() async {
    final programs = await db.programsDao.getAllPrograms();
    return programs
        .map((p) => {
              'id': p.id,
              'title': p.title,
              'description': p.description,
              'difficulty': p.difficulty,
              'duration_weeks': p.durationWeeks,
              'thumbnail_url': p.thumbnailUrl,
              'published_at': p.publishedAt?.toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _localSessionPlayback(
      String sessionId) async {
    final exercises =
        await db.exercisesDao.getExercisesBySession(sessionId);
    return exercises
        .map((e) => {
              'exercise_id': e.id,
              'display_order': e.displayOrder,
              'exercise_title': e.title,
              'cue_text': e.cueText,
              'mux_playback_id': e.muxPlaybackId,
              'mux_download_url': e.muxDownloadUrl,
              'model_asset_url': e.modelAssetUrl,
              'rep_count': e.repCount,
              'duration_seconds': e.durationSeconds,
              'video_version': e.videoVersion,
            })
        .toList();
  }
}

@riverpod
QueryGateway queryGateway(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final isOnline = ref.watch(connectivityProvider);
  return QueryGateway(supabase: supabase, db: db, isOnline: isOnline);
}
