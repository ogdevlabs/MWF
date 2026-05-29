import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/cqrs/command_bus.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/metrics/data/metrics_repository.dart';

class MockCommandBus extends Mock implements CommandBus {}

void main() {
  late AppDatabase db;
  late MockCommandBus mockCommandBus;
  late MetricsRepository repository;

  const studentId = 'student-metrics-1';

  setUpAll(() {
    registerFallbackValue(CommandType.logMetric);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    mockCommandBus = MockCommandBus();
    repository = MetricsRepository(db, mockCommandBus);

    when(() => mockCommandBus.dispatch(any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('MetricsRepository', () {
    test('logMetric writes entry to local Drift', () async {
      await repository.logMetric(
        studentId: studentId,
        metricType: 'weight',
        value: 70.5,
        unit: 'kg',
      );

      final rows = await db.metricLogsDao.getMetricsByStudent(studentId);
      expect(rows, hasLength(1));
      expect(rows.first.metricType, equals('weight'));
      expect(rows.first.value, equals(70.5));
      expect(rows.first.unit, equals('kg'));
      expect(rows.first.studentId, equals(studentId));
    });

    test('logMetric dispatches logMetric command to CommandBus', () async {
      await repository.logMetric(
        studentId: studentId,
        metricType: 'weight',
        value: 70.5,
        unit: 'kg',
      );

      verify(() => mockCommandBus.dispatch(
            CommandType.logMetric,
            any(that: containsPair('student_id', studentId)),
          )).called(1);
    });

    test('getMetrics returns only entries matching requested metric_type',
        () async {
      // Insert weight entry
      await repository.logMetric(
        studentId: studentId,
        metricType: 'weight',
        value: 70.0,
        unit: 'kg',
      );
      // Insert flexibility entry
      await repository.logMetric(
        studentId: studentId,
        metricType: 'flexibility',
        value: 45.0,
        unit: 'degrees',
      );

      final weightLogs = await repository.getMetrics(studentId, 'weight');
      expect(weightLogs, hasLength(1));
      expect(weightLogs.first.metricType, equals('weight'));

      final flexLogs = await repository.getMetrics(studentId, 'flexibility');
      expect(flexLogs, hasLength(1));
      expect(flexLogs.first.metricType, equals('flexibility'));
    });

    test('watchMetrics emits updated list when new entry inserted', () async {
      // Start watching
      final stream = repository.watchMetrics(studentId, 'weight');

      // First emission is empty
      final initial = await stream.first;
      expect(initial, isEmpty);

      // Insert an entry
      await repository.logMetric(
        studentId: studentId,
        metricType: 'weight',
        value: 68.0,
        unit: 'kg',
      );

      // Second emission should have 1 entry
      final updated = await stream.first;
      expect(updated, hasLength(1));
      expect(updated.first.value, equals(68.0));
    });

    test('logMetric stores metricSubtype when provided', () async {
      await repository.logMetric(
        studentId: studentId,
        metricType: 'measurement',
        metricSubtype: 'waist',
        value: 80.0,
        unit: 'cm',
      );

      final logs = await repository.getMetrics(studentId, 'measurement');
      expect(logs, hasLength(1));
      expect(logs.first.metricSubtype, equals('waist'));
    });
  });
}
