import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue.dart';
import 'feedback_repository.dart';

part 'feedback_providers.g.dart';

@Riverpod(keepAlive: true)
FeedbackRepository feedbackRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncQueue = ref.watch(syncQueueProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final studentId = supabase.auth.currentUser?.id ?? '';
  return FeedbackRepository(
    db: db,
    syncQueue: syncQueue,
    supabase: supabase,
    studentId: studentId,
  );
}

/// Stream provider for the full chat thread (all messages ordered by createdAt desc).
/// Uses manual Riverpod API (not generated) because riverpod_generator cannot
/// resolve Drift-generated LocalFeedbackThread type for code generation.
final feedbackThreadProvider =
    StreamProvider<List<LocalFeedbackThread>>((ref) {
  final repo = ref.watch(feedbackRepositoryProvider);
  return repo.watchThread();
});

/// Stream provider for coach replies only (notifications screen).
final coachRepliesProvider =
    StreamProvider<List<LocalFeedbackThread>>((ref) {
  final repo = ref.watch(feedbackRepositoryProvider);
  return repo.watchReplies();
});
