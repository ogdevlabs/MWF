import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionResumeDao', () {
    const sessionId = 'session-1';
    const studentId = 'student-1';

    test('saveResumeState persists exercise index', () async {
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 3);

      final state = await db.sessionResumeDao.getResumeState(sessionId);
      expect(state, isNotNull);
      expect(state!.exerciseIndex, equals(3));
      expect(state.studentId, equals(studentId));
    });

    test('getResumeState returns saved index', () async {
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 5);

      final state = await db.sessionResumeDao.getResumeState(sessionId);
      expect(state, isNotNull);
      expect(state!.exerciseIndex, equals(5));
    });

    test('saveResumeState updates existing entry (upsert)', () async {
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 2);
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 7);

      final state = await db.sessionResumeDao.getResumeState(sessionId);
      expect(state!.exerciseIndex, equals(7));
    });

    test('clearResumeState removes entry', () async {
      await db.sessionResumeDao.saveResumeState(sessionId, studentId, 4);
      await db.sessionResumeDao.clearResumeState(sessionId);

      final state = await db.sessionResumeDao.getResumeState(sessionId);
      expect(state, isNull);
    });

    test('getResumeState returns null when no entry exists', () async {
      final state = await db.sessionResumeDao.getResumeState('nonexistent');
      expect(state, isNull);
    });
  });
}
