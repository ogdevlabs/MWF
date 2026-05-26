import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/tables/sync_queue_table.dart';
import '../network/supabase_client.dart';

part 'sync_queue.g.dart';

/// Offline-first write queue.
///
/// All mutations go through this queue. Items are persisted locally in the
/// sync_queue table and replayed against Supabase when connectivity is available.
/// Items that fail 5 times are skipped (dead-lettered) until manually retried.
class SyncQueue {
  SyncQueue({
    required this.db,
    required this.supabase,
  });

  final AppDatabase db;
  final SupabaseClient supabase;

  /// Enqueue a write operation for later replay.
  ///
  /// [operation]: 'insert' | 'update' | 'delete'
  /// [targetTable]: Supabase table name (e.g., 'progress_records')
  /// [payload]: Row data as Map — will be JSON-encoded for storage
  Future<void> enqueue({
    required String operation,
    required String targetTable,
    required Map<String, dynamic> payload,
  }) async {
    await db.syncQueueDao.enqueue(
      SyncQueueCompanion(
        operation: Value(operation),
        targetTable: Value(targetTable),
        payload: Value(jsonEncode(payload)),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Process all pending queue items.
  ///
  /// Items are processed in FIFO order (by createdAt).
  /// On success: item is deleted from queue.
  /// On failure: retry_count incremented, last_error stored.
  /// Items with retry_count >= 5 are skipped (dead-lettered).
  ///
  /// Returns the number of successfully processed items.
  Future<int> processQueue() async {
    final items = await db.syncQueueDao.getPendingItems();
    int processed = 0;

    for (final item in items) {
      try {
        await _replayItem(item);
        await db.syncQueueDao.deleteById(item.id);
        processed++;
      } catch (e) {
        await db.syncQueueDao.incrementRetry(item.id, e.toString());
      }
    }

    return processed;
  }

  /// Replay a single queue item against Supabase.
  Future<void> _replayItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operation) {
      case 'insert':
        await supabase.from(item.targetTable).upsert(payload);
        break;
      case 'update':
        // Requires 'id' field in payload for WHERE clause
        final id = payload['id'];
        if (id == null) throw Exception('Update payload missing id field');
        await supabase.from(item.targetTable).update(payload).eq('id', id);
        break;
      case 'delete':
        final id = payload['id'];
        if (id == null) throw Exception('Delete payload missing id field');
        await supabase.from(item.targetTable).delete().eq('id', id);
        break;
      default:
        throw Exception('Unknown operation: ${item.operation}');
    }
  }

  /// Get count of pending items (retry_count < 5).
  Future<int> get pendingCount => db.syncQueueDao.pendingCount();
}

@Riverpod(keepAlive: true)
SyncQueue syncQueue(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return SyncQueue(db: db, supabase: supabase);
}
