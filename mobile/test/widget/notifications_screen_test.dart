import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/coach_chat/data/feedback_providers.dart';
import 'package:mwf_mobile/features/coach_chat/presentation/notifications_screen.dart';

/// Builds a fake [LocalFeedbackThread] with a coach reply for notifications tests.
LocalFeedbackThread _fakeReply({
  String id = 'thread-1',
  String studentId = 'test-student',
  String sessionId = 'session-abc',
  String message = 'Great session!',
  String coachReply = 'Nice work today, keep it up!',
}) {
  final now = DateTime(2026, 5, 29, 9, 0);
  return LocalFeedbackThread(
    id: id,
    studentId: studentId,
    sessionId: sessionId,
    studentMessage: message,
    photoUrl: null,
    coachReply: coachReply,
    repliedAt: now,
    notificationSent: false,
    createdAt: now,
    updatedAt: now,
    status: 'sent',
    localPhotoPath: null,
  );
}

void main() {
  Widget buildSubject({
    List<LocalFeedbackThread> replies = const [],
    List<GoRoute> extraRoutes = const [],
    List<String> navigatedRoutes = const [],
  }) {
    // Record navigation events
    final recorded = <String>[];

    final router = GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/coach-chat',
          name: 'coach-chat',
          builder: (context, state) => Scaffold(
            body: Text('coach-chat:${state.uri.queryParameters['sessionId']}'),
          ),
        ),
        ...extraRoutes,
      ],
    );

    return ProviderScope(
      overrides: [
        coachRepliesProvider.overrideWith((ref) => Stream.value(replies)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('NotificationsScreen', () {
    testWidgets('renders "Coach replied" for each reply in stream',
        (tester) async {
      final replies = [
        _fakeReply(id: 'thread-1', sessionId: 'session-aaa'),
        _fakeReply(id: 'thread-2', sessionId: 'session-bbb'),
      ];

      await tester.pumpWidget(buildSubject(replies: replies));
      await tester.pumpAndSettle();

      expect(find.text('Coach replied'), findsNWidgets(2));
    });

    testWidgets('empty state shows "No notifications yet"', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('tapping a reply navigates to /coach-chat with sessionId',
        (tester) async {
      final replies = [
        _fakeReply(id: 'thread-1', sessionId: 'session-xyz'),
      ];

      await tester.pumpWidget(buildSubject(replies: replies));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Coach replied').first);
      await tester.pumpAndSettle();

      // After navigation the route renders "coach-chat:session-xyz"
      expect(find.textContaining('coach-chat:session-xyz'), findsOneWidget);
    });
  });
}
