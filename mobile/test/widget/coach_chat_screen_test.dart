import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/features/auth/data/subscription_provider.dart';
import 'package:mwf_mobile/features/coach_chat/data/feedback_providers.dart';
import 'package:mwf_mobile/features/coach_chat/data/feedback_repository.dart';
import 'package:mwf_mobile/features/coach_chat/presentation/coach_chat_screen.dart';
import 'package:mwf_mobile/features/coach_chat/presentation/widgets/chat_bubble.dart';

class MockSyncQueue extends Mock implements SyncQueue {}

/// Builds a fake [LocalFeedbackThread] for widget tests.
LocalFeedbackThread _fakeThread({
  String id = 'thread-1',
  String studentId = 'test-student',
  String sessionId = '00000000-0000-0000-0000-000000000000',
  String message = 'Test message',
  String status = 'sent',
  String? coachReply,
}) {
  final now = DateTime(2026, 5, 29, 9, 0);
  return LocalFeedbackThread(
    id: id,
    studentId: studentId,
    sessionId: sessionId,
    studentMessage: message,
    photoUrl: null,
    coachReply: coachReply,
    repliedAt: coachReply != null ? now : null,
    notificationSent: false,
    createdAt: now,
    updatedAt: now,
    status: status,
    localPhotoPath: null,
  );
}

void main() {
  late AppDatabase db;
  late MockSyncQueue mockSyncQueue;
  late FeedbackRepository feedbackRepository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockSyncQueue = MockSyncQueue();
    feedbackRepository = FeedbackRepository(
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

  Widget buildSubject({
    List<LocalFeedbackThread> threads = const [],
    String? sessionId,
  }) {
    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(feedbackRepository),
        feedbackThreadProvider.overrideWith((ref) => Stream.value(threads)),
        isSubscribedProvider.overrideWith((ref) async => true),
      ],
      child: MaterialApp(
        home: CoachChatScreen(sessionId: sessionId),
      ),
    );
  }

  group('CoachChatScreen', () {
    testWidgets('renders welcome message when thread is empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Hi! Complete a session'), findsOneWidget);
    });

    testWidgets('renders chat bubbles when stream emits data', (tester) async {
      final threads = [_fakeThread()];

      await tester.pumpWidget(buildSubject(threads: threads));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ChatBubble), findsAtLeastNWidgets(1));
    });

    testWidgets('pending message shows clock icon', (tester) async {
      final threads = [_fakeThread(status: 'pending')];

      await tester.pumpWidget(buildSubject(threads: threads));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets(
        'compose bar disables send when text is empty and no photo attached',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 50));

      final filledButtons = find.byType(FilledButton);
      expect(filledButtons, findsOneWidget);

      final button = tester.widget<FilledButton>(filledButtons);
      expect(button.onPressed, isNull);
    });

    testWidgets('compose bar enables send when text is entered', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextField), 'Hello coach');
      await tester.pump();

      final filledButtons = find.byType(FilledButton);
      expect(filledButtons, findsOneWidget);

      final button = tester.widget<FilledButton>(filledButtons);
      expect(button.onPressed, isNotNull);
    });
  });
}
