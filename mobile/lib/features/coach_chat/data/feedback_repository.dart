import 'dart:io';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue.dart';
import '../domain/feedback_message_model.dart';

/// CQRS repository for coach chat / feedback operations.
/// Command side: writes to Drift + enqueues to SyncQueue.
/// Query side: reads reactive stream from FeedbackDao.
class FeedbackRepository {
  FeedbackRepository({
    required this.db,
    required this.syncQueue,
    required this.studentId,
    this.supabase,
  });

  final AppDatabase db;
  final SyncQueue syncQueue;
  final SupabaseClient? supabase;
  final String studentId;

  /// Upload photo to Supabase Storage 'feedback-photos' bucket.
  /// Returns the storage path (not a full URL).
  /// Throws on failure (caller handles offline case before calling this).
  Future<String> uploadPhoto(File photo) async {
    if (supabase == null) throw StateError('SupabaseClient required for photo upload');
    final fileName = '${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'feedback/$studentId/$fileName';
    await supabase!.storage.from('feedback-photos').upload(path, photo);
    return path;
  }

  /// Command: submit feedback message.
  /// - [sessionId]: actual session UUID (from FeedbackComposeBottomSheet)
  ///   or [kGeneralSessionId] (from compose bar free-form DM).
  /// - [photoUrl]: Supabase Storage path if photo was uploaded online.
  /// - [localPhotoPath]: local file path if offline (photo upload deferred).
  /// - [isOnline]: determines status ('sent' vs 'pending').
  Future<void> submitFeedback({
    required String sessionId,
    required String message,
    String? photoUrl,
    String? localPhotoPath,
    bool isOnline = true,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final status = isOnline ? FeedbackStatus.sent.name : FeedbackStatus.pending.name;

    // 1. Local write (immediate)
    await db.feedbackDao.upsertFeedback(LocalFeedbackThreadsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      studentMessage: Value(message),
      photoUrl: Value(photoUrl),
      localPhotoPath: Value(localPhotoPath),
      status: Value(status),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // 2. Enqueue remote write (SyncQueue handles replay)
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'feedback_threads',
      payload: {
        'id': id,
        'student_id': studentId,
        'session_id': sessionId,
        'student_message': message,
        'photo_url': photoUrl,
        'created_at': now.toUtc().toIso8601String(),
        'updated_at': now.toUtc().toIso8601String(),
      },
    );
  }

  /// Query: reactive stream of all messages for this student (chat view).
  Stream<List<LocalFeedbackThread>> watchThread() =>
      db.feedbackDao.watchFeedbackByStudent(studentId);

  /// Query: reactive stream of coach replies only (notifications screen).
  Stream<List<LocalFeedbackThread>> watchReplies() =>
      db.feedbackDao.watchReplies(studentId);

  /// Check if a thread already exists for a given session (UNIQUE constraint guard).
  Future<LocalFeedbackThread?> getBySession(String sessionId) =>
      db.feedbackDao.getByStudentAndSession(studentId, sessionId);
}
