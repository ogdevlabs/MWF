import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../sync/sync_queue.dart';

part 'command_bus.g.dart';

/// Command types known at Phase 2.
/// Additional commands will be added as feature phases are implemented.
enum CommandType {
  completeSession,
  logMetric,
  submitFeedback,
  enrollProgram,
}

/// CQRS Command Bus — dispatches command intents into the sync queue.
///
/// All write operations in the app go through this bus. It maps command types
/// to their target Supabase tables and enqueues them for eventual consistency.
/// This ensures offline-first behavior: commands are persisted locally
/// immediately and replayed to the server when online.
///
/// Usage:
/// ```dart
/// ref.read(commandBusProvider).dispatch(
///   CommandType.completeSession,
///   {'id': uuid, 'student_id': userId, 'session_id': sessionId, ...},
/// );
/// ```
class CommandBus {
  CommandBus(this._syncQueue);
  final SyncQueue _syncQueue;

  /// Dispatch a command to the sync queue.
  ///
  /// The command is immediately persisted in the local queue and will be
  /// replayed to Supabase when connectivity is available.
  Future<void> dispatch(
      CommandType type, Map<String, dynamic> payload) async {
    final targetTable = _resolveTable(type);
    final operation = _resolveOperation(type);

    await _syncQueue.enqueue(
      operation: operation,
      targetTable: targetTable,
      payload: payload,
    );
  }

  /// Map command type to target Supabase table.
  String _resolveTable(CommandType type) {
    return switch (type) {
      CommandType.completeSession => 'progress_records',
      CommandType.logMetric => 'metric_logs',
      CommandType.submitFeedback => 'feedback_threads',
      CommandType.enrollProgram => 'enrollments',
    };
  }

  /// Map command type to operation type.
  /// Most commands are inserts; future commands may use update/delete.
  String _resolveOperation(CommandType type) {
    return switch (type) {
      CommandType.completeSession => 'insert',
      CommandType.logMetric => 'insert',
      CommandType.submitFeedback => 'insert',
      CommandType.enrollProgram => 'insert',
    };
  }
}

@Riverpod(keepAlive: true)
CommandBus commandBus(Ref ref) {
  final syncQueue = ref.watch(syncQueueProvider);
  return CommandBus(syncQueue);
}
