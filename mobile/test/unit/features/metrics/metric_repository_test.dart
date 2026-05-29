import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/features/metrics/data/metric_repository.dart';

class MockSyncQueue extends Mock implements SyncQueue {}

void main() {
  late AppDatabase db;
  late MockSyncQueue mockSyncQueue;
  late MetricRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockSyncQueue = MockSyncQueue();
    repo = MetricRepository(
      db: db,
      syncQueue: mockSyncQueue,
      studentId: 'student-1',
    );
    when(
      () => mockSyncQueue.enqueue(
        operation: any(named: 'operation'),
        targetTable: any(named: 'targetTable'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('MetricRepository.logMetric', () {
    test('inserts into local_metric_logs via Drift', () async {
      await repo.logMetric(
        metricType: 'weight',
        value: 75.0,
        unit: 'kg',
        loggedAt: DateTime(2026, 5, 28),
      );

      final logs = await db.metricLogsDao.getMetricsByStudent('student-1');
      expect(logs, hasLength(1));
      expect(logs.first.value, equals(75.0));
      expect(logs.first.metricType, equals('weight'));
    });

    test("enqueues to sync_queue with target table 'metric_logs'", () async {
      await repo.logMetric(
        metricType: 'weight',
        value: 75.0,
        unit: 'kg',
        loggedAt: DateTime(2026, 5, 28),
      );

      verify(
        () => mockSyncQueue.enqueue(
          operation: 'insert',
          targetTable: 'metric_logs',
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });

    test('payload logged_at is YYYY-MM-DD date string, not full ISO-8601',
        () async {
      final Map<String, dynamic> capturedPayload = {};

      when(
        () => mockSyncQueue.enqueue(
          operation: any(named: 'operation'),
          targetTable: any(named: 'targetTable'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((invocation) async {
        capturedPayload.addAll(
          invocation.namedArguments[const Symbol('payload')]
              as Map<String, dynamic>,
        );
      });

      await repo.logMetric(
        metricType: 'weight',
        value: 75.0,
        unit: 'kg',
        loggedAt: DateTime(2026, 5, 28),
      );

      expect(capturedPayload['logged_at'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(capturedPayload['logged_at'], equals('2026-05-28'));
    });
  });
}
