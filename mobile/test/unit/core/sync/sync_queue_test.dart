import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late AppDatabase db;
  late MockSupabaseClient mockSupabase;
  late SyncQueue syncQueue;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    mockSupabase = MockSupabaseClient();
    syncQueue = SyncQueue(db: db, supabase: mockSupabase);
  });

  tearDown(() async {
    await db.close();
  });

  test('enqueue stores operation in database', () async {
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'progress_records',
      payload: {'id': 'uuid-1', 'student_id': 'student-1'},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.targetTable, 'progress_records');
  });

  test('enqueue stores JSON-encoded payload', () async {
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'metric_logs',
      payload: {'id': 'uuid-2', 'value': 75.5},
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.first.payload, contains('"value":75.5'));
  });

  test('processQueue returns 0 when queue is empty', () async {
    final result = await syncQueue.processQueue();
    expect(result, 0);
  });
}
