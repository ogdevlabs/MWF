---
phase: 07-us5-private-feedback
plan: 04
subsystem: ui
tags: [flutter, riverpod, coach-chat, fcm, material3, drift, widget-tests]

# Dependency graph
requires:
  - phase: 07-us5-private-feedback/07-02
    provides: FeedbackRepository, feedbackRepositoryProvider, feedbackThreadProvider, kGeneralSessionId
  - phase: 07-us5-private-feedback/07-03
    provides: FcmService with initialize() and registerToken()

provides:
  - CoachTabScreen premium gate routing via isSubscribedProvider
  - CoachPaywallScreen with exact UI-SPEC copy (lock icon, Coach Chat, Available on Premium, CTA)
  - CoachChatScreen iMessage-style chat thread with sessionId deep-link scroll + highlight
  - ChatBubble widget with coach (left/surfaceContainerHighest) and student (right/primaryContainer) variants
  - ComposeBar with TextField, camera picker, and send button (enabled only when content present)
  - PhotoThumbnail 160x120 with tap-to-expand InteractiveViewer dialog
  - fcmInitProvider (keepAlive) that initializes FcmService and registers FCM token post-auth
  - 5 widget tests passing

affects: [07-05]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - CoachTabScreen premium gate pattern: ref.watch(isSubscribedProvider).when(data: sub => sub ? ChatScreen : Paywall, ...)
    - fcmInitProvider fire-and-forget watch in CoachTabScreen — FCM init triggered on first tab load
    - LocalFeedbackThread constructed directly in widget tests (not via DB) to avoid Drift reactive stream hang
    - Stream.value(fakeThreads) pattern for feedbackThreadProvider override in widget tests

key-files:
  created:
    - mobile/lib/features/coach_chat/presentation/coach_paywall_screen.dart
    - mobile/lib/features/coach_chat/presentation/coach_tab_screen.dart
    - mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart
    - mobile/lib/features/coach_chat/presentation/widgets/chat_bubble.dart
    - mobile/lib/features/coach_chat/presentation/widgets/compose_bar.dart
    - mobile/lib/features/coach_chat/presentation/widgets/photo_thumbnail.dart
    - mobile/lib/features/coach_chat/data/fcm_providers.dart
    - mobile/lib/features/coach_chat/data/fcm_providers.g.dart
  modified:
    - mobile/test/widget/coach_chat_screen_test.dart

key-decisions:
  - "LocalFeedbackThread constructed directly in widget tests rather than via in-memory DB — Drift reactive streams caused test hang when watchThread() stream stayed open during pump()"
  - "ChatBubble uses manual time formatter (no intl package) — intl not in pubspec.yaml; avoids new dependency"
  - "ComposeBar previews selected photo via Image.file (not Image.asset) — local file path from ImagePicker"

patterns-established:
  - "LocalFeedbackThread fake constructor pattern for widget tests: construct DataClass directly instead of writing to in-memory DB"
  - "fcmInitProvider fire-and-forget: ref.watch(fcmInitProvider) in CoachTabScreen.build() triggers FCM once per auth session"

requirements-completed: [FR-010, FR-010a, FR-011]

# Metrics
duration: 29min
completed: 2026-05-29
---

# Phase 7 Plan 04: Coach Chat UI Summary

**iMessage-style CoachChatScreen with premium gate, paywall, ChatBubble/ComposeBar/PhotoThumbnail widgets, and fcmInitProvider wiring FCM post-auth — 5 widget tests passing**

## Performance

- **Duration:** 29 min
- **Started:** 2026-05-29T16:59:04Z
- **Completed:** 2026-05-29T17:27:44Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- CoachTabScreen gates premium access via `isSubscribedProvider`, watching `fcmInitProvider` to activate FCM on coach tab load
- CoachPaywallScreen matches UI-SPEC exactly: lock icon (grey[400], 48px), "Coach Chat" headlineMedium, "Available on Premium" bodyLarge, description bodyMedium, full-width FilledButton CTA
- CoachChatScreen renders chat thread from `feedbackThreadProvider` with welcome message for empty state, sessionId query param scroll-to and highlight support
- ChatBubble correctly differentiates coach (left-aligned, surfaceContainerHighest, top-left radius 4px) vs student (right-aligned, primaryContainer, top-right radius 4px) and shows `Icons.schedule` for pending messages
- ComposeBar with `textInputAction: TextInputAction.newline`, `ImagePicker` gallery picker, send `FilledButton` disabled when no content
- PhotoThumbnail at 160×120 with `Image.file` / `Image.network`, `InteractiveViewer` full-size dialog on tap
- fcmInitProvider (`keepAlive: true`) initializes `FcmService.initialize()` and `registerToken(user.id)` after auth

## Task Commits

Each task was committed atomically:

1. **Task 1: CoachPaywallScreen + CoachTabScreen + ChatBubble + PhotoThumbnail + fcmInitProvider** - `dbe243b` (feat)
2. **Task 2: CoachChatScreen + ComposeBar + widget tests** - `50a2ba7` (feat)

## Files Created/Modified

- `mobile/lib/features/coach_chat/presentation/coach_paywall_screen.dart` - Lock icon, Coach Chat heading, Upgrade CTA
- `mobile/lib/features/coach_chat/presentation/coach_tab_screen.dart` - isSubscribedProvider gate + fcmInitProvider watch
- `mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart` - Chat thread, welcome state, sessionId deep-link
- `mobile/lib/features/coach_chat/presentation/widgets/chat_bubble.dart` - Coach/student bubble variants, pending clock icon, highlighted border
- `mobile/lib/features/coach_chat/presentation/widgets/compose_bar.dart` - TextField, camera picker, FilledButton send
- `mobile/lib/features/coach_chat/presentation/widgets/photo_thumbnail.dart` - 160×120 with InteractiveViewer tap-to-expand
- `mobile/lib/features/coach_chat/data/fcm_providers.dart` - fcmInitProvider that initializes FcmService post-auth
- `mobile/lib/features/coach_chat/data/fcm_providers.g.dart` - Generated by build_runner
- `mobile/test/widget/coach_chat_screen_test.dart` - 5 widget tests (welcome, bubbles, pending icon, send enabled/disabled)

## Decisions Made

- `intl` package not added — time formatting implemented manually (h:mm AM/PM) to avoid a new dependency; `intl` is not in `pubspec.yaml` and the project only needs simple 12-hour formatting.
- `LocalFeedbackThread` constructed directly in widget tests instead of via in-memory DB writes — Drift reactive `watchFeedbackByStudent()` streams stay open and caused `tester.pumpWidget` + `pump(duration)` to hang indefinitely. Constructing the DataClass directly with named params is cleaner and avoids stream lifecycle issues.
- `ComposeBar` photo preview uses `Image.file(File(path))` for the local pick preview — consistent with `PhotoThumbnail` approach.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed LocalFeedbackThread import in ChatBubble and CoachChatScreen**
- **Found during:** Task 1 (first flutter analyze run)
- **Issue:** `LocalFeedbackThread` type was not accessible via `feedback_providers.dart` — it's a Drift-generated type in `app_database.g.dart` exported via `app_database.dart`
- **Fix:** Changed import to `../../../../core/database/app_database.dart` in both files
- **Files modified:** chat_bubble.dart, coach_chat_screen.dart
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** dbe243b (Task 1 commit)

**2. [Rule 1 - Bug] Fixed unnecessary_import lint in fcm_providers.dart**
- **Found during:** Task 1 (analyze)
- **Issue:** `flutter_riverpod/flutter_riverpod.dart` was imported alongside `riverpod_annotation/riverpod_annotation.dart` — the former is redundant since all used elements are in the latter
- **Fix:** Removed the redundant import
- **Files modified:** fcm_providers.dart
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** dbe243b (Task 1 commit)

**3. [Rule 1 - Bug] Fixed `unnecessary_underscores` and `no_leading_underscores_for_local_identifiers` lint violations**
- **Found during:** Task 1 (analyze)
- **Issue:** `error: (_, __)` closures triggered `unnecessary_underscores` and attempts to fix with `_e`, `_err` triggered `no_leading_underscores_for_local_identifiers`
- **Fix:** Changed to named variables `(err, stack)` where values are unused
- **Files modified:** coach_tab_screen.dart, coach_chat_screen.dart, compose_bar.dart
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** 50a2ba7 (Task 2 commit, in test file and compose bar)

**4. [Rule 1 - Bug] Fixed widget test hang — used fake LocalFeedbackThread constructor instead of real DB writes**
- **Found during:** Task 2 (flutter test run)
- **Issue:** Tests using real in-memory Drift DB with `submitFeedback()` then `watchThread().first` caused subsequent `tester.pump()` to hang — Drift reactive streams remain open; widget test pump infrastructure couldn't settle
- **Fix:** Constructed `LocalFeedbackThread` directly with named params, used `Stream.value(fakeThreads)` for the provider override — no DB writes needed
- **Files modified:** mobile/test/widget/coach_chat_screen_test.dart
- **Verification:** All 5 tests pass (00:00 +5: All tests passed!)
- **Committed in:** 50a2ba7 (Task 2 commit)

---

**Total deviations:** 4 auto-fixed (4 Rule 1 - Bug fixes)
**Impact on plan:** All fixes required for correct compilation and test operation. No scope creep.

## Issues Encountered

- Widget test framework hangs when combining Drift reactive streams with `tester.pump()` — fixed by using direct DataClass construction instead of DB-backed streams in tests. Established pattern for future coach chat widget tests.

## Known Stubs

None — all widgets are fully wired. `feedbackThreadProvider` feeds real Drift data in production; `fcmInitProvider` calls real FcmService. The Firebase placeholder (`firebase_options.dart`) stub is tracked in Plan 07-03's SUMMARY.md (pre-existing).

## User Setup Required

None — no new external service configuration required at this stage. Firebase configuration from Plan 07-03 still applies.

## Next Phase Readiness

- CoachTabScreen, CoachChatScreen, and ComposeBar are complete — Plan 07-05 (FeedbackComposeBottomSheet from SessionCompletionScreen) can begin
- FCM initialization is active via `fcmInitProvider` — push notifications will work once `firebase_options.dart` is replaced
- The `/coach-chat` route still needs to be added to `app_router.dart` (Plan 07-05 scope) to enable the FCM deep-link and CoachTabScreen navigation

## Self-Check: PASSED

Files verified on disk:
- mobile/lib/features/coach_chat/presentation/coach_paywall_screen.dart: FOUND
- mobile/lib/features/coach_chat/presentation/coach_tab_screen.dart: FOUND
- mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart: FOUND
- mobile/lib/features/coach_chat/presentation/widgets/chat_bubble.dart: FOUND
- mobile/lib/features/coach_chat/presentation/widgets/compose_bar.dart: FOUND
- mobile/lib/features/coach_chat/presentation/widgets/photo_thumbnail.dart: FOUND
- mobile/lib/features/coach_chat/data/fcm_providers.dart: FOUND
- mobile/lib/features/coach_chat/data/fcm_providers.g.dart: FOUND
- mobile/test/widget/coach_chat_screen_test.dart: FOUND (5 tests pass)

Commits verified: dbe243b and 50a2ba7 confirmed in git log.

---
*Phase: 07-us5-private-feedback*
*Completed: 2026-05-29*
