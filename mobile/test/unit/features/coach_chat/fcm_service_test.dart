import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mwf_mobile/features/coach_chat/data/fcm_service.dart';

// ---------------------------------------------------------------------------
// Mocks / Fakes
// ---------------------------------------------------------------------------

class MockGoRouter extends Mock implements GoRouter {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Fake SupabaseQueryBuilder that captures update() calls.
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> updatedPayloads = [];

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map values) {
    updatedPayloads.add(Map<String, dynamic>.from(values));
    return _FakeFilterBuilder();
  }
}

/// Fake filter builder that completes successfully.
class _FakeFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) => this;

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockGoRouter mockRouter;
  late MockSupabaseClient mockSupabase;
  late _FakeQueryBuilder fakeQueryBuilder;
  late FcmService fcmService;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRouter = MockGoRouter();
    mockSupabase = MockSupabaseClient();
    fakeQueryBuilder = _FakeQueryBuilder();
    fcmService = FcmService(
      supabase: mockSupabase,
      router: mockRouter,
    );
  });

  group('FcmService', () {
    group('registerTokenDirect', () {
      test(
          'registers token by calling supabase update on students table',
          () async {
        // Arrange — from() returns a SupabaseQueryBuilder (not a Future)
        when(() => mockSupabase.from('students'))
            .thenAnswer((_) => fakeQueryBuilder);

        // Act — use the testable overload that bypasses FirebaseMessaging
        await fcmService.registerTokenDirect(
          studentId: 'student-123',
          token: 'fcm-token-abc',
        );

        // Assert
        expect(fakeQueryBuilder.updatedPayloads.length, 1);
        expect(
          fakeQueryBuilder.updatedPayloads.first['fcm_token'],
          'fcm-token-abc',
        );
      });

      test('does nothing when token is null', () async {
        // Act — pass null token, no supabase call should happen
        await fcmService.registerTokenDirect(
          studentId: 'student-123',
          token: null,
        );

        // Assert
        verifyNever(() => mockSupabase.from(any()));
      });
    });

    group('handleMessageNavigation', () {
      test('navigates to /coach-chat when type is coach_reply', () {
        // Act
        fcmService.handleMessageNavigation({'type': 'coach_reply'});

        // Assert — verify router.go was called with '/coach-chat'
        verify(() => mockRouter.go('/coach-chat')).called(1);
      });

      test('does not navigate when type is not coach_reply', () {
        // Act
        fcmService.handleMessageNavigation({'type': 'other_type'});

        // Assert
        verifyNever(() => mockRouter.go(any()));
      });
    });

    group('onNotificationTap', () {
      test('navigates to /coach-chat when payload contains coach_reply type',
          () {
        // Arrange
        final payload = jsonEncode({'type': 'coach_reply'});
        final response = NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: payload,
        );

        // Act
        fcmService.onNotificationTap(response);

        // Assert
        verify(() => mockRouter.go('/coach-chat')).called(1);
      });

      test('does not navigate when payload is null', () {
        // Arrange
        final response = NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: null,
        );

        // Act
        fcmService.onNotificationTap(response);

        // Assert
        verifyNever(() => mockRouter.go(any()));
      });
    });
  });
}
