import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/features/metrics/data/metric_providers.dart';
import 'package:mwf_mobile/features/metrics/data/metric_repository.dart';
import 'package:mwf_mobile/features/metrics/presentation/metric_log_bottom_sheet.dart';

class MockSyncQueue extends Mock implements SyncQueue {}

void main() {
  late AppDatabase db;
  late MockSyncQueue mockSyncQueue;
  late MetricRepository metricRepository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockSyncQueue = MockSyncQueue();
    metricRepository = MetricRepository(
      db: db,
      syncQueue: mockSyncQueue,
      studentId: 'test-student',
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

  group('MetricLogBottomSheet', () {
    Widget buildSubject() {
      return ProviderScope(
        overrides: [
          metricRepositoryProvider.overrideWithValue(metricRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MetricLogBottomSheet(),
          ),
        ),
      );
    }

    testWidgets('renders metric type selector', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      // DropdownButtonFormField shows 'Weight' as default selected type
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('renders value text field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Log button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.text('Log'), findsOneWidget);
    });

    testWidgets('renders Log Metric title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.text('Log Metric'), findsOneWidget);
    });
  });
}
