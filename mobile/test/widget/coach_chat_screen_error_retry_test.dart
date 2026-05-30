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

class _MockSyncQueue extends Mock implements SyncQueue {}

void main() {
  late AppDatabase db;
  late FeedbackRepository feedbackRepository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final mockSyncQueue = _MockSyncQueue();
    when(
      () => mockSyncQueue.enqueue(
        operation: any(named: 'operation'),
        targetTable: any(named: 'targetTable'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    feedbackRepository = FeedbackRepository(
      db: db,
      syncQueue: mockSyncQueue,
      studentId: 'test-student',
    );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows error and retry on network failure', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(feedbackRepository),
          feedbackThreadProvider.overrideWith(
            (ref) => Stream.error(Exception('Network error')),
          ),
          isSubscribedProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(
          home: CoachChatScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsAtLeastNWidgets(1));
    expect(find.text('Retry'), findsAtLeastNWidgets(1));
  });
}
