---
phase: 07-us5-private-feedback
plan: 03
subsystem: notifications
tags: [firebase, fcm, flutter_local_notifications, push-notifications, go_router, supabase]

# Dependency graph
requires:
  - phase: 07-us5-private-feedback/07-01
    provides: Wave 0 test stubs including fcm_service_test.dart Wave 0 scaffold

provides:
  - FcmService class with initialize(), registerToken(), token refresh listener
  - Top-level firebaseMessagingBackgroundHandler for separate FCM isolate
  - Android notification channel 'coach_replies' created at app init
  - Foreground push notification display via flutter_local_notifications
  - Deep-link navigation to /coach-chat on notification tap
  - Firebase.initializeApp() called in main.dart before runApp

affects: [07-04, 07-05]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - registerTokenDirect(@visibleForTesting) pattern — separates Firebase platform call from Supabase upsert for unit testability
    - Top-level FCM background handler with @pragma('vm:entry-point') annotation
    - _FakeQueryBuilder + _FakeFilterBuilder Fake chain pattern for Supabase update().eq() calls in tests

key-files:
  created:
    - mobile/lib/features/coach_chat/data/fcm_service.dart
  modified:
    - mobile/lib/main.dart
    - mobile/test/unit/features/coach_chat/fcm_service_test.dart

key-decisions:
  - "FcmService.registerTokenDirect(@visibleForTesting) bypasses FirebaseMessaging.instance for unit testability — registerToken() calls it internally after getToken()"
  - "handleMessageNavigation and onNotificationTap exposed as non-private with @visibleForTesting for direct unit test calls — avoids need for RemoteMessage mocking"
  - "Firebase.initializeApp() in main.dart; FcmService.initialize() deferred to post-auth Riverpod provider (Plan 07-04)"

patterns-established:
  - "visibleForTesting split pattern: FirebaseMessaging calls in the public method, testable business logic in a @visibleForTesting method called internally"
  - "Supabase update() Fake: _FakeQueryBuilder.update(Map values) with minimal signature matching postgrest 2.7.0"

requirements-completed: [FR-011]

# Metrics
duration: 4min
completed: 2026-05-29
---

# Phase 7 Plan 03: FCM Push Notification Service Summary

**FcmService with Firebase init in main.dart, token registration, foreground/background message handling, and deep-link navigation to /coach-chat — all 6 unit tests passing**

## Performance

- **Duration:** 4 min
- **Started:** 2026-05-29T16:11:17Z
- **Completed:** 2026-05-29T16:15:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- FcmService class implemented with full FCM pipeline: permission request, Android channel creation, token registration, token refresh listener, foreground notification display, background handler registration, and deep-link navigation
- Top-level `firebaseMessagingBackgroundHandler` function with `@pragma('vm:entry-point')` for FCM background isolate
- Firebase.initializeApp() wired into main.dart, replacing the Phase 7 TODO comment
- 6 unit tests passing using injectable dependencies (SupabaseClient, GoRouter) and Fake pattern for Supabase query builder chain

## Task Commits

Each task was committed atomically:

1. **Task 1: FcmService implementation** - `01239a4` (feat)
2. **Task 2: Wire Firebase init into main.dart** - `f38e722` (feat)

## Files Created/Modified

- `mobile/lib/features/coach_chat/data/fcm_service.dart` - FcmService class, firebaseMessagingBackgroundHandler top-level function, coachRepliesChannel constant
- `mobile/lib/main.dart` - Added firebase_core import, firebase_options.dart import, Firebase.initializeApp() call replacing TODO
- `mobile/test/unit/features/coach_chat/fcm_service_test.dart` - 6 unit tests: registerTokenDirect (token present/null), handleMessageNavigation (coach_reply/other), onNotificationTap (with/without payload)

## Decisions Made

- `registerTokenDirect(@visibleForTesting)` separates FirebaseMessaging platform channel calls from the Supabase upsert logic, making the business logic fully unit-testable without Firebase test infrastructure
- `handleMessageNavigation` and `onNotificationTap` exposed with `@visibleForTesting` instead of being private `_` methods — allows direct unit test invocation of navigation logic
- Firebase.initializeApp() called in main.dart before `runApp()`; FcmService.initialize() and registerToken() are intentionally deferred to a post-auth Riverpod provider (`fcmInitProvider`) in Plan 07-04, because registerToken needs the studentId which is only available after sign-in

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed Supabase Fake update() signature mismatch**
- **Found during:** Task 1 (FcmService implementation — GREEN phase)
- **Issue:** Initial `_FakeQueryBuilder.update()` had extra parameters (defaultToNull, count, returning) not present in postgrest 2.7.0 which only has `update(Map values)` — caused update payloads list to remain empty
- **Fix:** Changed fake override to match actual postgrest signature: `PostgrestFilterBuilder<PostgrestList> update(Map values)`
- **Files modified:** mobile/test/unit/features/coach_chat/fcm_service_test.dart
- **Verification:** All 6 tests pass after fix
- **Committed in:** 01239a4 (Task 1 commit)

**2. [Rule 1 - Bug] Changed thenReturn to thenAnswer for SupabaseQueryBuilder mock**
- **Found during:** Task 1 (GREEN phase, first test run)
- **Issue:** mocktail rejected `thenReturn` for `SupabaseQueryBuilder` because it implements Future-like interface — requires `thenAnswer`
- **Fix:** Changed `when(() => mockSupabase.from('students')).thenReturn(...)` to `thenAnswer((_) => fakeQueryBuilder)`
- **Files modified:** mobile/test/unit/features/coach_chat/fcm_service_test.dart
- **Verification:** Tests pass after fix
- **Committed in:** 01239a4 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (2 Rule 1 - Bug fixes during TDD GREEN phase)
**Impact on plan:** Both fixes required for correct test behavior. No scope creep.

## Issues Encountered

- `thenReturn` vs `thenAnswer` distinction for Supabase mock — SupabaseQueryBuilder exposes Future-like interface, requiring `thenAnswer`. Fixed inline.
- Initial Fake signature used extra optional parameters not present in postgrest 2.7.0 — matched actual signature from pub cache source inspection.

## User Setup Required

Firebase configuration requires manual steps before push notifications function:

1. Run `flutterfire configure` to generate real `firebase_options.dart` (current file is placeholder)
2. Upload APNs key for iOS: Firebase Console -> Project Settings -> Cloud Messaging -> iOS app -> APNs key
3. Enable Push Notifications capability in Xcode: Runner target -> Signing & Capabilities -> + Push Notifications

These steps are documented in the plan's `user_setup` section and cannot be automated.

## Known Stubs

- `mobile/lib/firebase_options.dart` — placeholder stub with TODO values; real values require `flutterfire configure` with an actual Firebase project. FCM push notifications will not function until replaced.

## Next Phase Readiness

- FcmService is ready for wiring into the Riverpod provider tree in Plan 07-04
- Firebase.initializeApp() is called in main.dart; Plan 07-04 will create `fcmInitProvider` that calls FcmService.initialize() and registerToken() post-auth
- /coach-chat route navigation target is defined; Plan 07-04 will implement CoachChatScreen
- 6 unit tests provide regression coverage for token registration and navigation logic

## Self-Check: PASSED

Files verified on disk:
- mobile/lib/features/coach_chat/data/fcm_service.dart: FOUND
- mobile/lib/main.dart: FOUND (Firebase.initializeApp present)
- mobile/test/unit/features/coach_chat/fcm_service_test.dart: FOUND

Commits verified in git log:
- 01239a4: FOUND
- f38e722: FOUND

---
*Phase: 07-us5-private-feedback*
*Completed: 2026-05-29*
