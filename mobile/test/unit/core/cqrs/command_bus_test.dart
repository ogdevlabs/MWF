import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/core/cqrs/command_bus.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late AppDatabase db;
  late MockSupabaseClient mockSupabase;
  late SyncQueue syncQueue;
  late CommandBus commandBus;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    mockSupabase = MockSupabaseClient();
    syncQueue = SyncQueue(db: db, supabase: mockSupabase);
    commandBus = CommandBus(syncQueue);
  });

  tearDown(() async {
    await db.close();
  });

  test('dispatch completeSession enqueues to progress_records', () async {
    await commandBus.dispatch(
      CommandType.completeSession,
      {'id': 'uuid-1', 'student_id': 's1', 'session_id': 'sess1'},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.targetTable, 'progress_records');
    expect(items.first.operation, 'insert');
  });

  test('dispatch logMetric enqueues to metric_logs', () async {
    await commandBus.dispatch(
      CommandType.logMetric,
      {'id': 'uuid-2', 'student_id': 's1', 'value': 72.5},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.targetTable, 'metric_logs');
  });

  test('dispatch submitFeedback enqueues to feedback_threads', () async {
    await commandBus.dispatch(
      CommandType.submitFeedback,
      {'id': 'uuid-3', 'student_id': 's1', 'student_message': 'Great session!'},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.targetTable, 'feedback_threads');
  });

  test('dispatch enrollProgram enqueues to enrollments', () async {
    await commandBus.dispatch(
      CommandType.enrollProgram,
      {'id': 'uuid-4', 'student_id': 's1', 'program_id': 'p1'},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.targetTable, 'enrollments');
  });
}
