import 'dart:async';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/tables/programs_table.dart';
import '../database/tables/sessions_table.dart';
import '../database/tables/exercises_table.dart';
import '../database/tables/enrollments_table.dart';
import '../database/tables/progress_records_table.dart';
import '../database/tables/feedback_threads_table.dart';
import '../downloads/download_service.dart';
import '../network/supabase_client.dart';
import 'sync_queue.dart';
import 'connectivity_provider.dart';

part 'sync_service.g.dart';

/// Orchestrates full bidirectional sync between local Drift DB and Supabase.
///
/// Sync cycle:
/// 1. Pull: Fetch rows modified since last sync timestamp from Supabase
/// 2. Upsert: Write pulled data into local Drift tables
/// 3. Push: Process outgoing sync_queue items
/// 4. Update: Store new last-sync timestamp
///
/// Triggered by:
/// - ConnectivityProvider on reconnect
/// - Manual pull-to-refresh in UI
/// - App startup (if online)
class SyncService {
  SyncService({
    required this.db,
    required this.supabase,
    required this.syncQueue,
  });

  final AppDatabase db;
  final SupabaseClient supabase;
  final SyncQueue syncQueue;

  static const _lastSyncKey = 'last_sync_timestamp';
  bool _isSyncing = false;

  /// Run a full sync cycle. No-op if already syncing.
  Future<SyncResult> sync() async {
    if (_isSyncing) return SyncResult(pulled: 0, pushed: 0, skipped: true);
    _isSyncing = true;

    try {
      final pulled = await _pullRemoteChanges();
      final pushed = await syncQueue.processQueue();
      await _updateLastSyncTimestamp();
      return SyncResult(pulled: pulled, pushed: pushed, skipped: false);
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull remote changes since last sync.
  /// Fetches from all mirrored tables and upserts into Drift.
  Future<int> _pullRemoteChanges() async {
    final lastSync = await _getLastSyncTimestamp();
    int totalPulled = 0;

    // Pull published programs
    totalPulled += await _pullTable(
      tableName: 'programs',
      since: lastSync,
      filter: (query) => query.eq('published', true),
      upsert: (rows) async {
        for (final row in rows) {
          await db.programsDao.upsertProgram(LocalProgramsCompanion(
            id: Value(row['id'] as String),
            title: Value(row['title'] as String),
            description: Value(row['description'] as String?),
            difficulty: Value(row['difficulty'] as String),
            durationWeeks: Value(row['duration_weeks'] as int),
            thumbnailUrl: Value(row['thumbnail_url'] as String?),
            published: Value(row['published'] as bool? ?? false),
            publishedAt: Value(row['published_at'] != null
                ? DateTime.parse(row['published_at'] as String)
                : null),
            createdBy: Value(row['created_by'] as String?),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
          ));
        }
      },
    );

    // Pull sessions for enrolled programs
    totalPulled += await _pullTable(
      tableName: 'sessions',
      since: lastSync,
      upsert: (rows) async {
        for (final row in rows) {
          await db.sessionsDao.upsertSession(LocalSessionsCompanion(
            id: Value(row['id'] as String),
            programId: Value(row['program_id'] as String),
            dayNumber: Value(row['day_number'] as int),
            title: Value(row['title'] as String),
            description: Value(row['description'] as String?),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
          ));
        }
      },
    );

    // Pull exercises
    totalPulled += await _pullTable(
      tableName: 'exercises',
      since: lastSync,
      upsert: (rows) async {
        for (final row in rows) {
          await db.exercisesDao.upsertExercise(LocalExercisesCompanion(
            id: Value(row['id'] as String),
            sessionId: Value(row['session_id'] as String),
            displayOrder: Value(row['display_order'] as int),
            title: Value(row['title'] as String),
            cueText: Value(row['cue_text'] as String?),
            muxAssetId: Value(row['mux_asset_id'] as String?),
            muxPlaybackId: Value(row['mux_playback_id'] as String?),
            muxDownloadUrl: Value(row['mux_download_url'] as String?),
            modelAssetUrl: Value(row['model_asset_url'] as String?),
            repCount: Value(row['rep_count'] as int?),
            durationSeconds: Value(row['duration_seconds'] as int?),
            videoVersion: Value(row['video_version'] as int? ?? 1),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
          ));
        }
      },
    );

    // Pull enrollments for current user
    totalPulled += await _pullTable(
      tableName: 'enrollments',
      since: lastSync,
      upsert: (rows) async {
        for (final row in rows) {
          await db.into(db.localEnrollments).insertOnConflictUpdate(
            LocalEnrollmentsCompanion(
              id: Value(row['id'] as String),
              studentId: Value(row['student_id'] as String),
              programId: Value(row['program_id'] as String),
              enrolledAt:
                  Value(DateTime.parse(row['enrolled_at'] as String)),
              currentDay: Value(row['current_day'] as int? ?? 1),
            ),
          );
        }
      },
    );

    // Pull progress records
    totalPulled += await _pullTable(
      tableName: 'progress_records',
      since: lastSync,
      upsert: (rows) async {
        for (final row in rows) {
          await db.progressDao.upsertProgress(LocalProgressRecordsCompanion(
            id: Value(row['id'] as String),
            studentId: Value(row['student_id'] as String),
            sessionId: Value(row['session_id'] as String),
            completedAt:
                Value(DateTime.parse(row['completed_at'] as String)),
            durationSeconds: Value(row['duration_seconds'] as int?),
            syncedFromOffline:
                Value(row['synced_from_offline'] as bool? ?? false),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
          ));
        }
      },
    );

    // Pull feedback threads
    totalPulled += await _pullTable(
      tableName: 'feedback_threads',
      since: lastSync,
      upsert: (rows) async {
        for (final row in rows) {
          await db.feedbackDao.upsertFeedback(LocalFeedbackThreadsCompanion(
            id: Value(row['id'] as String),
            studentId: Value(row['student_id'] as String),
            sessionId: Value(row['session_id'] as String),
            studentMessage: Value(row['student_message'] as String),
            photoUrl: Value(row['photo_url'] as String?),
            coachReply: Value(row['coach_reply'] as String?),
            repliedAt: Value(row['replied_at'] != null
                ? DateTime.parse(row['replied_at'] as String)
                : null),
            notificationSent:
                Value(row['notification_sent'] as bool? ?? false),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
          ));
        }
      },
    );

    return totalPulled;
  }

  /// Generic pull helper: fetch rows where updated_at >= since from Supabase.
  ///
  /// [filter] is an optional extra filter applied after the timestamp filter.
  /// Each table pull is wrapped in try/catch — one failure does not abort
  /// the entire sync cycle.
  Future<int> _pullTable({
    required String tableName,
    required String? since,
    dynamic Function(dynamic query)? filter,
    required Future<void> Function(List<Map<String, dynamic>> rows) upsert,
  }) async {
    try {
      dynamic query = supabase.from(tableName).select();

      if (since != null) {
        query = query.gte('updated_at', since);
      }

      if (filter != null) {
        query = filter(query);
      }

      final response = await query;
      final rows = List<Map<String, dynamic>>.from(response as List);

      if (rows.isNotEmpty) {
        await upsert(rows);
      }

      return rows.length;
    } catch (e) {
      // Log but don't fail entire sync if one table fails
      // ignore: avoid_print
      print('[SyncService] Failed to pull $tableName: $e');
      return 0;
    }
  }

  Future<String?> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncKey);
  }

  Future<void> _updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }
}

/// Result of a sync operation.
class SyncResult {
  const SyncResult({
    required this.pulled,
    required this.pushed,
    this.skipped = false,
  });

  final int pulled;
  final int pushed;
  final bool skipped;
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final queue = ref.watch(syncQueueProvider);

  final service = SyncService(db: db, supabase: supabase, syncQueue: queue);

  // Wire up connectivity-based sync trigger.
  // ConnectivityNotifier state is bool: true = online, false = offline.
  // On transition from offline (false) to online (true): run full sync
  // AND resume any paused downloads.
  ref.listen(connectivityProvider, (previous, next) {
    final wasOffline = previous == false;
    final isNowOnline = next;
    if (wasOffline && isNowOnline) {
      service.sync();
      ref.read(downloadServiceProvider).resumeQueue();
    }
  });

  return service;
}
