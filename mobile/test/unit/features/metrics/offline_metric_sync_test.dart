import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/features/metrics/data/metric_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Fake query builder — same pattern as offline_sync_integration_test.dart
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
    return _CompletedFilterBuilder();
  }
}

class _CompletedFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) async {
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
  late MetricRepository repo;
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
    repo = MetricRepository(
      db: db,
      syncQueue: syncQueue,
      studentId: 'student-1',
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Offline metric log -> sync -> replay', () {
    test(
        'logMetric inserts locally and enqueues, processQueue replays to Supabase',
        () async {
      when(() => mockSupabase.from('metric_logs'))
          .thenAnswer((_) => fakeQueryBuilder);

      // Log metric offline
      await repo.logMetric(
        metricType: 'weight',
        value: 75.0,
        unit: 'kg',
        loggedAt: DateTime(2026, 5, 28),
      );

      // Verify local insert
      final logs = await db.metricLogsDao.getMetricsByStudent('student-1');
      expect(logs, hasLength(1));

      // Verify item is in sync queue
      final beforeItems = await db.syncQueueDao.getPendingItems();
      expect(beforeItems, hasLength(1));
      expect(beforeItems.first.targetTable, equals('metric_logs'));

      // Replay queue (simulates reconnect)
      await syncQueue.processQueue();

      // After replay, queue should be empty
      final afterItems = await db.syncQueueDao.getPendingItems();
      expect(afterItems, isEmpty);

      // Verify upsert was called with correct payload
      expect(fakeQueryBuilder.upsertedPayloads, hasLength(1));
      expect(
          fakeQueryBuilder.upsertedPayloads.first['metric_type'], equals('weight'));
      // logged_at must be YYYY-MM-DD (date only, not full ISO-8601)
      expect(
          fakeQueryBuilder.upsertedPayloads.first['logged_at'], equals('2026-05-28'));
    });
  });
}
