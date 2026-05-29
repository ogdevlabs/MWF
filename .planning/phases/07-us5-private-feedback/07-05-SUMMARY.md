---
phase: 07-us5-private-feedback
plan: 05
subsystem: ui
tags: [flutter, riverpod, go_router, coach-chat, material3, drift, widget-tests, fcm, navigation]

# Dependency graph
requires:
  - phase: 07-us5-private-feedback/07-02
    provides: FeedbackRepository, feedbackRepositoryProvider, coachRepliesProvider, getBySession()
  - phase: 07-us5-private-feedback/07-03
    provides: FcmService, push notification deep-link handling
  - phase: 07-us5-private-feedback/07-04
    provides: CoachTabScreen, CoachChatScreen, CoachPaywallScreen, ComposeBar

provides:
  - FeedbackComposeBottomSheet: session-linked compose sheet from SessionCompletionScreen with UNIQUE constraint guard and photo attachment
  - NotificationsScreen: coach replies list from coachRepliesProvider with sessionId query param tap navigation
  - ScaffoldWithNavBar: persistent 4-tab NavigationBar (Home, Progress, Coach, Notifications)
  - StatefulShellRoute.indexedStack: proper bottom nav shell for authenticated tabs
  - /coach-chat route with sessionId query parameter for FCM deep-link scroll-to support
  - SessionCompletionScreen rewired to open FeedbackComposeBottomSheet instead of /feedback placeholder route
  - 3 NotificationsScreen widget tests passing

affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - StatefulShellRoute.indexedStack pattern for persistent bottom NavigationBar in GoRouter
    - sessionId query param in GoRouter for deep-link scroll: state.uri.queryParameters['sessionId']
    - FeedbackComposeBottomSheet UNIQUE constraint guard via repo.getBySession() before submit
    - Manual date formatting (no intl) for notification timestamps — matches ChatBubble pattern from 07-04
    - GoRouter-driven navigation in widget tests via MaterialApp.router + GoRouter config for testing routes

key-files:
  created:
    - mobile/lib/features/coach_chat/presentation/feedback_compose_bottom_sheet.dart
    - mobile/lib/features/coach_chat/presentation/notifications_screen.dart
    - mobile/lib/shared/router/scaffold_with_nav_bar.dart
  modified:
    - mobile/lib/shared/router/app_router.dart
    - mobile/lib/features/session/presentation/session_completion_screen.dart
    - mobile/test/widget/notifications_screen_test.dart

key-decisions:
  - "StatefulShellRoute.indexedStack wraps 4 branches (programs, progress, coach-chat, notifications) with ScaffoldWithNavBar — auth/paywall/settings remain outside shell"
  - "Manual date formatting in NotificationsScreen — intl not in pubspec.yaml, consistent with ChatBubble approach from 07-04"
  - "/coach-chat route uses sessionId query param: direct to CoachChatScreen for deep-links, CoachTabScreen (premium gate) for tab nav"
  - "GoRouter-based widget test for NotificationsScreen — tap navigation test verifies route param by rendering destination content"

patterns-established:
  - "GoRouter navigation test pattern: MaterialApp.router + GoRouter with test routes to verify navigation targets"
  - "StatefulShellRoute branch isolation: auth-only screens outside shell, app screens inside branches"

requirements-completed: [FR-010, FR-011]

# Metrics
duration: 5min
completed: 2026-05-29
---

# Phase 7 Plan 05: Wire-up (FeedbackComposeBottomSheet + NotificationsScreen + Router) Summary

**Session-to-coach feedback flow complete: FeedbackComposeBottomSheet (session-linked, UNIQUE guard, photo attach), NotificationsScreen (coachRepliesProvider, tap-to-chat with sessionId), StatefulShellRoute 4-tab NavigationBar, and FCM deep-link /coach-chat route**

## Performance

- **Duration:** 5 min
- **Started:** 2026-05-29T16:52:06Z
- **Completed:** 2026-05-29T16:57:10Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments

- FeedbackComposeBottomSheet: session-linked compose sheet with UNIQUE constraint guard (blocks duplicate feedback per session), photo attachment via ImagePicker, online/offline path selection, success/error SnackBar feedback
- NotificationsScreen: renders coach replies from `coachRepliesProvider` stream, empty state, tap navigates to `/coach-chat?sessionId=...` for highlighted message scroll
- StatefulShellRoute.indexedStack with ScaffoldWithNavBar: 4-tab persistent NavigationBar (Home, Progress, Coach, Notifications) — auth/paywall/settings routes excluded from shell
- /coach-chat route accepts optional `sessionId` query parameter for FCM notification deep-link support
- SessionCompletionScreen rewired: `goNamed('feedback', ...)` replaced with `showModalBottomSheet → FeedbackComposeBottomSheet`
- 111 tests passing, no regressions

## Task Commits

Each task was committed atomically:

1. **Task 1: FeedbackComposeBottomSheet + NotificationsScreen** - `6f877f3` (feat)
2. **Task 2: StatefulShellRoute + ScaffoldWithNavBar (router restructure)** - `c0bb543` (feat)
3. **Task 3: SessionCompletionScreen rewiring to FeedbackComposeBottomSheet** - `f00d3b6` (feat)

## Files Created/Modified

- `mobile/lib/features/coach_chat/presentation/feedback_compose_bottom_sheet.dart` - Session-linked compose sheet, UNIQUE guard, photo attach, online/offline submit
- `mobile/lib/features/coach_chat/presentation/notifications_screen.dart` - Coach replies list, empty state, sessionId query param tap navigation
- `mobile/lib/shared/router/scaffold_with_nav_bar.dart` - Persistent 4-tab NavigationBar wrapper for StatefulShellRoute
- `mobile/lib/shared/router/app_router.dart` - Restructured with StatefulShellRoute.indexedStack, /coach-chat with sessionId query param, /notifications pointing to real NotificationsScreen
- `mobile/lib/features/session/presentation/session_completion_screen.dart` - Rewired "Send Feedback to Coach" button to FeedbackComposeBottomSheet
- `mobile/test/widget/notifications_screen_test.dart` - 3 tests: replies list, empty state, tap navigation with sessionId

## Decisions Made

- `intl` package not added — notification date formatting implemented manually to stay consistent with ChatBubble (07-04 decision, no new dependency).
- `/coach-chat` route: when `sessionId` query param is present, renders `CoachChatScreen(sessionId: sessionId)` directly for deep-link scroll; without sessionId renders `CoachTabScreen` (premium gate). This gives clean FCM tap handling while preserving the premium gate for tab navigation.
- Widget test for `NotificationsScreen` uses `MaterialApp.router + GoRouter` with a test route for `/coach-chat` — tap test verifies the `sessionId` reaches the destination by checking rendered text.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `unnecessary_underscores` lint in NotificationsScreen separator builder**
- **Found during:** Task 1 (flutter analyze)
- **Issue:** `separatorBuilder: (_, __) => const Divider(height: 1)` triggered `unnecessary_underscores` lint; fix attempt `(_, _a)` triggered `no_leading_underscores_for_local_identifiers`
- **Fix:** Changed to named params `(context, index)` — both unused but avoids lint violations
- **Files modified:** notifications_screen.dart
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** 6f877f3 (Task 1 commit)

**2. [Rule 3 - Blocking] Fixed wrong import path for connectivity provider**
- **Found during:** Task 1 (creating feedback_compose_bottom_sheet.dart)
- **Issue:** Initial import used `core/network/connectivity_provider.dart` which doesn't exist; the provider lives at `core/sync/connectivity_provider.dart`
- **Fix:** Corrected import path to `'../../../core/sync/connectivity_provider.dart'`
- **Files modified:** feedback_compose_bottom_sheet.dart
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** 6f877f3 (Task 1 commit, pre-first-commit correction)

---

**Total deviations:** 2 auto-fixed (1 Rule 1 - lint bug, 1 Rule 3 - blocking import)
**Impact on plan:** Both fixes trivial. No scope creep.

## Issues Encountered

None — all tasks executed smoothly. The lint guard from established project patterns (no `__` vars, no `_x` local identifiers) caught during analyze before commit.

## Known Stubs

None — all wired:
- `FeedbackComposeBottomSheet` uses real `feedbackRepositoryProvider` and `connectivityProvider`
- `NotificationsScreen` uses real `coachRepliesProvider` which streams from `FeedbackDao.watchReplies()`
- `ScaffoldWithNavBar` routes to `CoachTabScreen` → `CoachChatScreen` (real premium gate)

## User Setup Required

None — no new external service configuration required. Firebase and FCM configuration from Plan 07-03 still applies.

## Next Phase Readiness

- Phase 7 US5 (private coach chat) is feature-complete from the student side
- End-to-end flow ready: session complete → FeedbackComposeBottomSheet → submit → coach replies in admin panel → NotificationsScreen → tap → CoachChatScreen (scrolled to session)
- FCM deep links work via `/coach-chat?sessionId=...` route
- Admin panel (Phase 8) needs to be built for coach to see and reply to student messages

## Self-Check: PASSED

Files verified on disk:
- mobile/lib/features/coach_chat/presentation/feedback_compose_bottom_sheet.dart: FOUND
- mobile/lib/features/coach_chat/presentation/notifications_screen.dart: FOUND
- mobile/lib/shared/router/scaffold_with_nav_bar.dart: FOUND
- mobile/lib/shared/router/app_router.dart: FOUND (StatefulShellRoute present)
- mobile/lib/features/session/presentation/session_completion_screen.dart: FOUND (FeedbackComposeBottomSheet wired)
- mobile/test/widget/notifications_screen_test.dart: FOUND (3 tests pass)

Commits verified: 6f877f3, c0bb543, f00d3b6 confirmed in git log.

---
*Phase: 07-us5-private-feedback*
*Completed: 2026-05-29*
