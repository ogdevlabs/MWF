---
phase: 07-us5-private-feedback
verified: 2026-05-29T18:30:00Z
status: human_needed
score: 11/12 must-haves verified
human_verification:
  - test: "SC1 — Submit private feedback, have admin panel post a coach reply, observe push notification arrives on student device within 60s"
    expected: "Push notification appears within 60s of coach reply; tapping notification opens /coach-chat and scrolls to the session message"
    why_human: "Push delivery requires: (a) real Firebase project configured (firebase_options.dart is still a placeholder), (b) admin panel built (Phase 8 scope), (c) a Supabase Edge Function to trigger FCM on coach reply — none of these exist yet. All client-side FCM wiring is verified; the server-side trigger and real Firebase config are manual/future steps."
  - test: "Real device FCM token registration: sign in, navigate to Coach tab, confirm fcm_token is written to Supabase students table"
    expected: "students row for the test user shows fcm_token column populated with a valid FCM token"
    why_human: "Cannot verify Firebase token flow without a real Firebase project; firebase_options.dart contains TODO placeholder values."
---

# Phase 7: US5 Private Feedback Verification Report

**Phase Goal:** Student submits a private post-session note and optional photo directly to the coach; receives a push notification when the coach replies; the full exchange is visible only to the student and coach (no community/public visibility).
**Verified:** 2026-05-29T18:30:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|---------|
| 1 | Student can submit a private post-session note | ✓ VERIFIED | `FeedbackComposeBottomSheet` opens from `SessionCompletionScreen`, calls `feedbackRepositoryProvider.submitFeedback` with `sessionId` |
| 2 | Optional photo can be attached to the note | ✓ VERIFIED | `ComposeBar` and `FeedbackComposeBottomSheet` both use `ImagePicker().pickImage(source: ImageSource.gallery)` with online upload or offline `localPhotoPath` |
| 3 | Offline feedback notes save locally and submit on reconnect | ✓ VERIFIED | `FeedbackRepository.submitFeedback(isOnline: false)` writes `status='pending'` to Drift and enqueues `SyncQueue`; `FeedbackComposeBottomSheet` checks `connectivityProvider` |
| 4 | Full exchange visible only to student and coach — no public visibility | ✓ VERIFIED | Supabase RLS: `feedback_select_own` (`student_id = auth.uid()`) + `feedback_insert_own`; Drift queries in `FeedbackDao` filter by `studentId` on all reads; no community feed or shared feed exists anywhere in the codebase |
| 5 | No cross-student data access | ✓ VERIFIED | `FeedbackDao.watchFeedbackByStudent(studentId)` and `watchReplies(studentId)` both apply `WHERE student_id = ?`; Supabase RLS enforces same at DB level; `FeedbackRepository` constructor accepts `studentId` from `supabase.auth.currentUser?.id` |
| 6 | Student receives push notification when coach replies | ? PARTIAL | Client-side FCM pipeline is fully wired (`FcmService`, `fcmInitProvider`, `Firebase.initializeApp`, notification channel, deep-link nav). Server-side trigger (Edge Function) not yet built — Phase 8 scope. `firebase_options.dart` is a placeholder stub requiring `flutterfire configure`. |
| 7 | Notifications screen lists all coach replies with session links | ✓ VERIFIED | `NotificationsScreen` watches `coachRepliesProvider` (via `FeedbackDao.watchReplies` filtering `coachReply IS NOT NULL`); each `ListTile` calls `goNamed('coach-chat', queryParameters: {'sessionId': reply.sessionId})` |
| 8 | CoachChatScreen shows full private thread (student + coach messages) | ✓ VERIFIED | `CoachChatScreen` watches `feedbackThreadProvider`; `ChatBubble` renders student (right, `primaryContainer`) and coach (left, `surfaceContainerHighest`) variants; pending messages show `Icons.schedule` |
| 9 | Premium gate enforces coach access | ✓ VERIFIED | `CoachTabScreen` watches `isSubscribedProvider`; premium → `CoachChatScreen`; non-premium → `CoachPaywallScreen` with `Upgrade to Premium` CTA |
| 10 | FCM token registered on auth for push delivery | ✓ VERIFIED (wiring) | `fcmInitProvider` calls `FcmService.initialize()` and `registerToken(user.id)` post-auth; `FcmService.registerTokenDirect` upserts `fcm_token` to Supabase `students` table. Pending real Firebase config. |
| 11 | Router supports /coach-chat with sessionId deep-link | ✓ VERIFIED | `app_router.dart`: `GoRoute(path: '/coach-chat', name: 'coach-chat')` with `state.uri.queryParameters['sessionId']`; passes `sessionId` to `CoachChatScreen` for scroll-and-highlight |
| 12 | 4-tab NavigationBar with Coach and Notifications tabs | ✓ VERIFIED | `StatefulShellRoute.indexedStack` with `ScaffoldWithNavBar`; 4 branches: Home, Progress, Coach (`/coach-chat`), Notifications (`/notifications`) |

**Score:** 11/12 truths verified (1 partial — push notification delivery requires manual Firebase setup + Phase 8 admin panel + server-side Edge Function)

---

## Required Artifacts

### Plan 07-01 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/core/database/tables/feedback_threads_table.dart` | status and localPhotoPath columns | ✓ VERIFIED | Lines 18-19: `TextColumn get status` with default 'sent', `TextColumn get localPhotoPath` nullable |
| `mobile/lib/core/database/app_database.dart` | Schema version 3 with migration | ✓ VERIFIED | `schemaVersion => 3`; `onUpgrade` adds both columns when `from < 3` |
| `mobile/test/unit/features/coach_chat/feedback_repository_test.dart` | Unit test stubs for FeedbackRepository | ✓ VERIFIED | 168 lines; real tests with `mocktail`, `verify`, `expect` — not stubs |
| `mobile/test/unit/features/coach_chat/fcm_service_test.dart` | Unit test stubs for FCM service | ✓ VERIFIED | 176 lines; real tests with mocked Supabase, GoRouter |
| `mobile/test/widget/coach_chat_screen_test.dart` | Widget test stubs for CoachChatScreen | ✓ VERIFIED | 140 lines; 5 real widget tests using `Stream.value(fakeThreads)` pattern |
| `mobile/test/widget/notifications_screen_test.dart` | Widget test stubs for NotificationsScreen | ✓ VERIFIED | 107 lines; 3 real widget tests |
| `supabase/migrations/004_fcm_token.sql` | FCM token column on students table | ✓ VERIFIED | `ALTER TABLE students ADD COLUMN fcm_token text` |
| `supabase/migrations/20260529000003_feedback_photos_bucket.sql` | Storage bucket and RLS policies | ✓ VERIFIED | `INSERT INTO storage.buckets` + 3 RLS policies |

### Plan 07-02 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/coach_chat/data/feedback_repository.dart` | CQRS FeedbackRepository | ✓ VERIFIED | 94 lines; `submitFeedback`, `uploadPhoto`, `watchThread`, `watchReplies`, `getBySession` all implemented |
| `mobile/lib/features/coach_chat/domain/feedback_message_model.dart` | kGeneralSessionId + FeedbackStatus | ✓ VERIFIED | `const String kGeneralSessionId = '00000000-0000-0000-0000-000000000000'`; `enum FeedbackStatus { sent, pending }` |
| `mobile/lib/features/coach_chat/data/feedback_providers.dart` | Riverpod providers | ✓ VERIFIED | `feedbackRepositoryProvider` (keepAlive), `feedbackThreadProvider`, `coachRepliesProvider` |
| `mobile/lib/features/coach_chat/data/feedback_providers.g.dart` | Generated provider | ✓ VERIFIED | `feedbackRepositoryProvider` in generated file; regenerated by `build_runner` successfully |

### Plan 07-03 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/coach_chat/data/fcm_service.dart` | FcmService with full FCM pipeline | ✓ VERIFIED | 157 lines; `initialize()`, `registerToken()`, `registerTokenDirect()` (@visibleForTesting), `firebaseMessagingBackgroundHandler` (top-level), `coachRepliesChannel`, `handleMessageNavigation()`, `onNotificationTap()` |
| `mobile/lib/main.dart` | Firebase.initializeApp call | ✓ VERIFIED | `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` present; no TODO comment |
| `mobile/lib/firebase_options.dart` | Firebase config | ⚠️ STUB | Contains TODO placeholder values; requires `flutterfire configure` with real Firebase project — documented user setup step |

### Plan 07-04 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/coach_chat/presentation/coach_tab_screen.dart` | Premium gate routing | ✓ VERIFIED | Watches `isSubscribedProvider` and `fcmInitProvider`; routes to `CoachChatScreen` or `CoachPaywallScreen` |
| `mobile/lib/features/coach_chat/presentation/coach_paywall_screen.dart` | Paywall CTA | ✓ VERIFIED | `Icons.lock_outline`, "Coach Chat", "Available on Premium", "Upgrade to Premium" FilledButton → `/paywall` |
| `mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart` | iMessage-style chat thread | ✓ VERIFIED | 210 lines; watches `feedbackThreadProvider`; empty state welcome message; `ChatBubble` list; `ComposeBar`; sessionId deep-link scroll + highlight |
| `mobile/lib/features/coach_chat/presentation/widgets/chat_bubble.dart` | Coach/student bubble variants | ✓ VERIFIED | `bool isCoach`, `MediaQuery.sizeOf(context).width * 0.72`, `Icons.schedule` for pending, `highlighted` border |
| `mobile/lib/features/coach_chat/presentation/widgets/compose_bar.dart` | TextField + camera + send | ✓ VERIFIED | `ImagePicker`, `Icons.photo_camera_outlined`, `Icons.send`, disabled when no content, `_canSend` guard |
| `mobile/lib/features/coach_chat/presentation/widgets/photo_thumbnail.dart` | 160x120 with tap-to-expand | ✓ VERIFIED | 121 lines; `width: 160, height: 120`; `InteractiveViewer` in `showDialog` on tap |
| `mobile/lib/features/coach_chat/data/fcm_providers.dart` | fcmInitProvider | ✓ VERIFIED | `@Riverpod(keepAlive: true)` `fcmInit`; calls `FcmService.initialize()` + `registerToken(user.id)` when user != null |
| `mobile/lib/features/coach_chat/data/fcm_providers.g.dart` | Generated fcmInitProvider | ✓ VERIFIED | `fcmInitProvider` in generated file |

### Plan 07-05 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/coach_chat/presentation/feedback_compose_bottom_sheet.dart` | Session-linked compose sheet | ✓ VERIFIED | "Send Feedback to Coach", "Send Note", "Write a note to your coach...", "Note sent to coach", UNIQUE guard via `repo.getBySession()`, `feedbackRepositoryProvider`, `ImagePicker` |
| `mobile/lib/features/coach_chat/presentation/notifications_screen.dart` | Coach replies list | ✓ VERIFIED | Watches `coachRepliesProvider`; "No notifications yet" empty state; "Coach replied" titles; `queryParameters: {'sessionId': reply.sessionId}` on tap |
| `mobile/lib/shared/router/scaffold_with_nav_bar.dart` | 4-tab NavigationBar | ✓ VERIFIED | `StatefulNavigationShell`; `NavigationBar` with Home, Progress, Coach, Notifications |
| `mobile/lib/shared/router/app_router.dart` | Router with /coach-chat + StatefulShellRoute | ✓ VERIFIED | `StatefulShellRoute.indexedStack` with 4 branches; `/coach-chat` with `queryParameters['sessionId']`; `/notifications` → `NotificationsScreen` |
| `mobile/lib/features/session/presentation/session_completion_screen.dart` | FeedbackComposeBottomSheet wired | ✓ VERIFIED | `showModalBottomSheet` → `FeedbackComposeBottomSheet(sessionId:, sessionTitle:)` replacing old `goNamed('feedback',...)` |

---

## Key Link Verification

### Plan 07-01 Links

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `app_database.dart` | `feedback_threads_table.dart` | `onUpgrade` adds columns | ✓ WIRED | `m.addColumn(localFeedbackThreads, localFeedbackThreads.status)` + `localFeedbackThreads.localPhotoPath` at `from < 3` |

### Plan 07-02 Links

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `feedback_repository.dart` | `feedback_dao.dart` | `db.feedbackDao.upsertFeedback` | ✓ WIRED | Line 55: `db.feedbackDao.upsertFeedback(LocalFeedbackThreadsCompanion(...))` |
| `feedback_repository.dart` | `sync_queue.dart` | `syncQueue.enqueue` | ✓ WIRED | Lines 68-80: `syncQueue.enqueue(operation: 'insert', targetTable: 'feedback_threads', payload: {...})` |
| `feedback_providers.dart` | `feedback_repository.dart` | `FeedbackRepository(...)` | ✓ WIRED | `return FeedbackRepository(db: db, syncQueue: syncQueue, supabase: supabase, studentId: studentId)` |

### Plan 07-03 Links

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `fcm_service.dart` | `students.fcm_token` | `supabase.from('students').update({'fcm_token': token})` | ✓ WIRED | `registerTokenDirect()` line 111-112 calls `.update({'fcm_token': token}).eq('id', studentId)` |
| `fcm_service.dart` | `app_router.dart` | `router.go('/coach-chat')` | ✓ WIRED | `handleMessageNavigation()` line 154: `router.go('/coach-chat')` when `data['type'] == 'coach_reply'` |

### Plan 07-04 Links

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `coach_chat_screen.dart` | `feedback_providers.dart` | `ref.watch(feedbackThreadProvider)` | ✓ WIRED | Line 94: `final threadsAsync = ref.watch(feedbackThreadProvider)` |
| `coach_chat_screen.dart` | `feedback_repository.dart` | `ref.read(feedbackRepositoryProvider).submitFeedback` | ✓ WIRED | Lines 69, 75: `ref.read(feedbackRepositoryProvider)` then `.uploadPhoto` and `.submitFeedback` |
| `coach_tab_screen.dart` | `subscription_provider.dart` | `ref.watch(isSubscribedProvider)` | ✓ WIRED | Line 22: `ref.watch(isSubscribedProvider).when(...)` |
| `fcm_providers.dart` | `fcm_service.dart` | `FcmService.initialize()` + `registerToken()` | ✓ WIRED | Lines 23-25: `FcmService(supabase: supabase, router: router)`, `.initialize()`, `.registerToken(user.id)` |

### Plan 07-05 Links

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `session_completion_screen.dart` | `feedback_compose_bottom_sheet.dart` | `showModalBottomSheet` | ✓ WIRED | `showModalBottomSheet(..., builder: (sheetContext) => FeedbackComposeBottomSheet(sessionId:, sessionTitle:))` |
| `notifications_screen.dart` | `feedback_providers.dart` | `ref.watch(coachRepliesProvider)` | ✓ WIRED | Line 18: `final repliesAsync = ref.watch(coachRepliesProvider)` |
| `notifications_screen.dart` | `app_router.dart` | `goNamed('coach-chat', queryParameters: {'sessionId': ...})` | ✓ WIRED | Line 121-124: `context.goNamed('coach-chat', queryParameters: {'sessionId': reply.sessionId})` |
| `app_router.dart` | `coach_tab_screen.dart` | `GoRoute path: '/coach-chat'` | ✓ WIRED | `/coach-chat` route: no `sessionId` → `CoachTabScreen()`; with `sessionId` → `CoachChatScreen(sessionId: sessionId)` |

---

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|-------------------|--------|
| `CoachChatScreen` | `threadsAsync` | `feedbackThreadProvider` → `FeedbackRepository.watchThread()` → `FeedbackDao.watchFeedbackByStudent(studentId)` → Drift stream | Yes — `SELECT` query on `local_feedback_threads WHERE student_id = ?` | ✓ FLOWING |
| `NotificationsScreen` | `repliesAsync` | `coachRepliesProvider` → `FeedbackRepository.watchReplies()` → `FeedbackDao.watchReplies(studentId)` → Drift stream | Yes — `SELECT` with `WHERE student_id = ? AND coach_reply IS NOT NULL` | ✓ FLOWING |
| `FeedbackComposeBottomSheet` | Submit path | `feedbackRepositoryProvider` → `FeedbackRepository.submitFeedback()` → `FeedbackDao.upsertFeedback()` + `SyncQueue.enqueue()` | Yes — writes to real Drift DB and SyncQueue | ✓ FLOWING |
| `CoachTabScreen` | `isSubscribed` | `isSubscribedProvider` → RevenueCat entitlement check | Yes — live RevenueCat check (established in Phase 3) | ✓ FLOWING |

---

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `feedbackRepositoryProvider` generates correctly | `ls mobile/lib/features/coach_chat/data/feedback_providers.g.dart` | File exists, contains `feedbackRepositoryProvider` | ✓ PASS |
| `fcmInitProvider` generates correctly | `ls mobile/lib/features/coach_chat/data/fcm_providers.g.dart` | File exists, contains `fcmInitProvider` | ✓ PASS |
| Drift schema v3 | `grep "schemaVersion => 3" mobile/lib/core/database/app_database.dart` | Found | ✓ PASS |
| `build_runner` produces output cleanly | `dart run build_runner build --delete-conflicting-outputs` | "wrote 40 outputs" — clean | ✓ PASS |
| FeedbackRepository unit tests are real | Line count + `verify`/`expect` patterns | 168 lines; mocktail-based assertions | ✓ PASS |
| FCM service unit tests are real | Line count + mock pattern | 176 lines; `MockGoRouter`, Fake Supabase chain | ✓ PASS |
| Real FCM push delivery end-to-end | Requires device + real Firebase + admin panel | Cannot test without full setup | ? SKIP |

---

## Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
|-------------|-------------|-------------|--------|---------|
| FR-010 | 07-01, 07-02, 07-04, 07-05 | Students MUST be able to submit private session feedback (text + optional photo) directly to the coach after completing a session | ✓ SATISFIED | `FeedbackComposeBottomSheet` from `SessionCompletionScreen`; `FeedbackRepository.submitFeedback`; `FeedbackDao.upsertFeedback`; Supabase `feedback_insert_own` RLS policy |
| FR-010a | 07-02, 07-04 | System MUST NOT expose community commenting or public activity feed. All student–coach communication is strictly private 1-to-1. | ✓ SATISFIED | No public feed, community routes, or shared message boards exist anywhere in the codebase. Supabase `feedback_select_own` RLS (`student_id = auth.uid()`). `FeedbackDao` filters all reads by `studentId`. Premium gate prevents non-subscribed access to coach UI. |
| FR-011 | 07-03, 07-04 | System MUST deliver push notifications for coach replies to feedback | ✓ WIRED / ? DELIVERY | Client-side FCM pipeline fully implemented: `FcmService`, `fcmInitProvider`, `Firebase.initializeApp`, `coachRepliesChannel`, deep-link nav to `/coach-chat`. Server-side delivery requires: (1) real Firebase config (`firebase_options.dart` is placeholder), (2) Supabase Edge Function to send FCM on `feedback_threads.coach_reply` write (not yet built — Phase 8 scope). |

---

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `mobile/lib/firebase_options.dart` | 36, 39-40 | `'TODO-replace-with-real-api-key'`, `'move-with-fergie-placeholder'` | ⚠️ Warning | FCM push notifications will not function until replaced with real Firebase project values via `flutterfire configure`. FcmService wiring is complete; only configuration is missing. Documented in Plan 07-03 as required user setup step. |

No blockers found. The firebase_options.dart stub is a documented, intentional placeholder — not an implementation gap.

---

## Human Verification Required

### 1. End-to-End Push Notification Flow

**Test:** Configure real Firebase project via `flutterfire configure`, deploy Supabase Edge Function that sends FCM on `coach_reply` write (Phase 8), sign in on a real device, submit feedback from SessionCompletionScreen, have the coach post a reply via admin panel (Phase 8), wait up to 60s.
**Expected:** Push notification appears on student device within 60s. Tapping notification opens the app, navigates to `/coach-chat`, scrolls to and highlights the message matching the `sessionId`.
**Why human:** Requires real Firebase project (not placeholder), real physical device (simulator does not receive real FCM), admin panel (Phase 8 not yet built), and a Supabase Edge Function for the server-side push trigger — none of which are automated-testable.

### 2. FCM Token Registration Verification

**Test:** On a real device with real Firebase config, sign in, navigate to the Coach tab, query Supabase: `SELECT fcm_token FROM students WHERE id = '<test-user-id>'`.
**Expected:** `fcm_token` column is populated with a valid FCM registration token string.
**Why human:** `firebase_options.dart` placeholder prevents `FirebaseMessaging.instance.getToken()` from returning a real token in any automated context.

---

## Gaps Summary

No blocking gaps found. All Phase 7 code is fully wired, substantive, and data-flowing.

The single outstanding item (push notification server-side delivery) is intentionally deferred:
- The client-side FCM pipeline is complete and verified (FcmService, fcmInitProvider, Firebase init, channel creation, deep-link navigation)
- The server-side trigger (Supabase Edge Function to send FCM when coach writes a reply) requires the admin panel from Phase 8 to be meaningful — correctly deferred
- The `firebase_options.dart` placeholder is documented as a required manual user step (run `flutterfire configure`) in Plan 07-03's SUMMARY

Phase 7 achieves its goal with one pending manual configuration (Firebase) and one dependency on Phase 8 (server-side push trigger).

---

_Verified: 2026-05-29T18:30:00Z_
_Verifier: Claude (gsd-verifier)_
