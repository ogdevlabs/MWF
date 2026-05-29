import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/features/coach_chat/data/feedback_repository.dart';
import 'package:mwf_mobile/features/coach_chat/domain/feedback_message_model.dart';

class MockSyncQueue extends Mock implements SyncQueue {}

void main() {
  late AppDatabase db;
  late MockSyncQueue mockSyncQueue;
  late FeedbackRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockSyncQueue = MockSyncQueue();
    repo = FeedbackRepository(
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

  group('FeedbackRepository', () {
    test(
        'submitFeedback writes to Drift with correct fields (status=sent online)',
        () async {
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'Great session!',
        isOnline: true,
      );

      final threads = await db.feedbackDao
          .watchFeedbackByStudent('student-1')
          .first;
      expect(threads, hasLength(1));
      final thread = threads.first;
      expect(thread.studentId, equals('student-1'));
      expect(thread.sessionId, equals(kGeneralSessionId));
      expect(thread.studentMessage, equals('Great session!'));
      expect(thread.status, equals('sent'));
    });

    test(
        "submitFeedback enqueues SyncQueue with operation='insert' and targetTable='feedback_threads'",
        () async {
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'Test message',
        isOnline: true,
      );

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

      // Re-run to capture payload
      await repo.submitFeedback(
        sessionId: 'session-abc',
        message: 'payload check',
        isOnline: true,
      );

      verify(
        () => mockSyncQueue.enqueue(
          operation: 'insert',
          targetTable: 'feedback_threads',
          payload: any(named: 'payload'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    test('submitFeedback sets status=pending when isOnline=false', () async {
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'Offline message',
        isOnline: false,
      );

      final threads = await db.feedbackDao
          .watchFeedbackByStudent('student-1')
          .first;
      expect(threads, hasLength(1));
      expect(threads.first.status, equals('pending'));
    });

    test('submitFeedback stores localPhotoPath in Drift when offline',
        () async {
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'Photo message',
        localPhotoPath: '/local/photos/photo.jpg',
        isOnline: false,
      );

      final threads = await db.feedbackDao
          .watchFeedbackByStudent('student-1')
          .first;
      expect(threads, hasLength(1));
      expect(threads.first.localPhotoPath, equals('/local/photos/photo.jpg'));
    });

    test('watchThread delegates to feedbackDao.watchFeedbackByStudent',
        () async {
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'Msg 1',
        isOnline: true,
      );
      await repo.submitFeedback(
        sessionId: 'session-other',
        message: 'Msg 2',
        isOnline: true,
      );

      final threads = await repo.watchThread().first;
      expect(threads, hasLength(2));
    });

    test('watchReplies delegates to feedbackDao.watchReplies', () async {
      // Insert a message with no reply — should not appear in watchReplies
      await repo.submitFeedback(
        sessionId: kGeneralSessionId,
        message: 'No reply yet',
        isOnline: true,
      );

      final replies = await repo.watchReplies().first;
      expect(replies, isEmpty);
    });

    test('kGeneralSessionId constant equals 00000000-0000-0000-0000-000000000000',
        () {
      expect(
        kGeneralSessionId,
        equals('00000000-0000-0000-0000-000000000000'),
      );
    });
  });
}
