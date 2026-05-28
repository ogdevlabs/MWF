import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  group(
    'Offline sync integration',
    skip: 'Wave 0 stub — production code not yet created',
    () {
      test(
          'offline completion enqueues to sync_queue and replays on reconnect',
          () async {
        // Enqueue a progress_record write (simulates offline completion)
        await syncQueue.enqueue(
          operation: 'insert',
          targetTable: 'progress_records',
          payload: {
            'id': 'pr-1',
            'student_id': 'student-1',
            'session_id': 'session-1',
            'completed_at': DateTime.now().toIso8601String(),
          },
        );

        // Verify item is in queue before replay
        final beforeItems = await db.syncQueueDao.getPendingItems();
        expect(beforeItems, hasLength(1));

        // Mock Supabase upsert succeeds (simulates reconnect + replay)
        when(() => mockSupabase.from('progress_records'))
            .thenReturn(mockSupabase as dynamic);

        // Process the queue (reconnect replay)
        await syncQueue.processQueue();

        // After replay, queue should be empty
        final afterItems = await db.syncQueueDao.getPendingItems();
        expect(afterItems, isEmpty);
      });

      test('sync queue processes items in FIFO order', () async {
        // Enqueue 2 items at different times
        final t1 = DateTime.now().millisecondsSinceEpoch;
        await db.syncQueueDao.enqueue(
          SyncQueueCompanion(
            operation: const Value('insert'),
            targetTable: const Value('progress_records'),
            payload: const Value('{"id":"first"}'),
            createdAt: Value(t1),
          ),
        );

        final t2 = t1 + 1000; // 1 second later
        await db.syncQueueDao.enqueue(
          SyncQueueCompanion(
            operation: const Value('insert'),
            targetTable: const Value('progress_records'),
            payload: const Value('{"id":"second"}'),
            createdAt: Value(t2),
          ),
        );

        // Items must be returned in FIFO (ascending createdAt) order
        final items = await db.syncQueueDao.getPendingItems();
        expect(items.length, equals(2));
        expect(items.first.createdAt, lessThan(items.last.createdAt));
        expect(items.first.payload, contains('"first"'));
        expect(items.last.payload, contains('"second"'));
      });
    },
  );
}
