import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Fake query builder that returns an immediately-resolved Future for upsert.
///
/// We can't use thenReturn for a Future-implementing class like
/// PostgrestFilterBuilder, so we stub the builder via a Fake instead.
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> upsertedPayloads = [];

  @override
  PostgrestFilterBuilder<PostgrestList> upsert(
    Object values, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = true,
    String? count,
  }) {
    if (values is Map<String, dynamic>) {
      upsertedPayloads.add(values);
    }
    // Return a completed future that resolves to an empty list
    return _CompletedFilterBuilder();
  }
}

/// A minimal stub that completes successfully when awaited.
class _CompletedFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) async {
    // Simulate successful empty response
    return onValue([]);
  }

  @override
  Future<PostgrestList> catchError(Function onError,
          {bool Function(Object error)? test}) =>
      Future.value([]);

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      Future.value([]);

  @override
  Future<PostgrestList> timeout(Duration timeLimit,
          {FutureOr<PostgrestList> Function()? onTimeout}) =>
      Future.value([]);

  @override
  Stream<PostgrestList> asStream() => Stream.value([]);
}

void main() {
  late AppDatabase db;
  late MockSupabaseClient mockSupabase;
  late SyncQueue syncQueue;
  late _FakeQueryBuilder fakeQueryBuilder;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    mockSupabase = MockSupabaseClient();
    fakeQueryBuilder = _FakeQueryBuilder();
    syncQueue = SyncQueue(db: db, supabase: mockSupabase);
  });

  tearDown(() async {
    await db.close();
  });

  group('Offline sync integration', () {
    test(
        'offline completion enqueues to sync_queue and replays on reconnect',
        () async {
      // Wire up mock so from('progress_records') returns our fake builder
      when(() => mockSupabase.from('progress_records'))
          .thenAnswer((_) => fakeQueryBuilder);

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

      // Process the queue (reconnect replay)
      await syncQueue.processQueue();

      // After replay, queue should be empty
      final afterItems = await db.syncQueueDao.getPendingItems();
      expect(afterItems, isEmpty);

      // Verify upsert was called with the correct payload
      expect(fakeQueryBuilder.upsertedPayloads, hasLength(1));
      expect(fakeQueryBuilder.upsertedPayloads.first['id'], equals('pr-1'));
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
  });
}
