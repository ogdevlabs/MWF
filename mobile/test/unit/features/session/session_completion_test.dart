import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/cqrs/command_bus.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/session/data/session_completion_service.dart';

class MockCommandBus extends Mock implements CommandBus {}

void main() {
  late AppDatabase db;
  late MockCommandBus mockCommandBus;
  late SessionCompletionService service;

  const studentId = 'student-1';
  const sessionId = 'session-1';
  const enrollmentId = 'enrollment-1';

  setUpAll(() {
    // mocktail requires fallback values for non-nullable types used with any()
    registerFallbackValue(CommandType.completeSession);
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
    service = SessionCompletionService(db, mockCommandBus);

    when(() => mockCommandBus.dispatch(any(), any()))
        .thenAnswer((_) async {});

    // Insert test enrollment so service can increment current_day
    await db.enrollmentsDao.upsertEnrollment(LocalEnrollmentsCompanion(
      id: const Value(enrollmentId),
      studentId: const Value(studentId),
      programId: const Value('program-1'),
      enrolledAt: Value(DateTime.now()),
      currentDay: const Value(1),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  group('Session completion', () {
    test('writes progress_record to Drift on completion', () async {
      await service.completeSession(
        studentId: studentId,
        sessionId: sessionId,
        enrollmentId: enrollmentId,
        currentDay: 1,
        durationSeconds: 300,
      );

      final records = await db.progressDao.getProgressByStudent(studentId);
      expect(records, hasLength(1));
      expect(records.first.sessionId, equals(sessionId));
      expect(records.first.durationSeconds, equals(300));
    });

    test('increments enrollment.currentDay by 1', () async {
      await service.completeSession(
        studentId: studentId,
        sessionId: sessionId,
        enrollmentId: enrollmentId,
        currentDay: 1,
        durationSeconds: 300,
      );

      final enrollment = await db.enrollmentsDao.getEnrollmentById(enrollmentId);
      expect(enrollment!.currentDay, equals(2));
    });

    test('dispatches completeSession command to CommandBus', () async {
      await service.completeSession(
        studentId: studentId,
        sessionId: sessionId,
        enrollmentId: enrollmentId,
        currentDay: 1,
        durationSeconds: 300,
      );

      verify(() => mockCommandBus.dispatch(
            CommandType.completeSession,
            any(that: containsPair('session_id', sessionId)),
          )).called(1);
    });

    test('clears session resume state after completion', () async {
      // First save a resume state
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 3);

      await service.completeSession(
        studentId: studentId,
        sessionId: sessionId,
        enrollmentId: enrollmentId,
        currentDay: 1,
        durationSeconds: 300,
      );

      final resumeState = await db.sessionResumeDao.getResumeState(sessionId);
      expect(resumeState, isNull);
    });

    test('returns computed streak value', () async {
      final streak = await service.completeSession(
        studentId: studentId,
        sessionId: sessionId,
        enrollmentId: enrollmentId,
        currentDay: 1,
        durationSeconds: 300,
      );

      // Single completion today = streak of 1
      expect(streak, equals(1));
    });
  });
}
