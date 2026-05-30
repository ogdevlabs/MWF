---
phase: 09-polish-qa
plan: "02"
subsystem: mobile-ui
tags: [flutter, dart, accessibility, error-handling, widget-tests, riverpod]

# Dependency graph
requires:
  - phase: 09-01
    provides: flutter analyze --fatal-infos exits 0
provides:
  - error+retry UI on all AsyncValue.when() error branches in 5 screens
  - Semantics wrapper on ExerciseVideoPlayer for VoiceOver/TalkBack
  - 3 new widget tests verifying error+retry and accessibility label
affects: [09-03-integration-tests, 09-04-accessibility]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "OutlinedButton + ref.invalidate pattern for AsyncValue error+retry (ProgramListScreen already established)"
    - "Semantics widget wraps entire build output of ExerciseVideoPlayer (not just one branch)"
    - "tester.ensureSemantics() + find.bySemanticsLabel(RegExp) for accessibility widget testing"
    - "Wave 0 TDD: write test stubs first (Red), then implement (Green) in same plan"

key-files:
  created:
    - mobile/test/widget/program_detail_screen_error_retry_test.dart
    - mobile/test/widget/coach_chat_screen_error_retry_test.dart
  modified:
    - mobile/lib/features/programs/presentation/program_detail_screen.dart
    - mobile/lib/features/metrics/presentation/progress_screen.dart
    - mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart
    - mobile/lib/features/coach_chat/presentation/notifications_screen.dart
    - mobile/lib/features/session/presentation/exercise_video_player.dart
    - mobile/test/widget/session_player_screen_test.dart

key-decisions:
  - "Semantics wrapper placed in build() to wrap all three states (loading, unavailable, playing) — not just the Chewie branch — so tests in no-video environments find the label"
  - "ExerciseVideoPlayer refactored to _buildContent() helper to keep build() clean with single Semantics wrapper at root"
  - "Wave 0 test stubs committed before implementation — both tests initially fail (Red) then pass after Task 2 (Green)"

patterns-established:
  - "Pattern: Semantics on StatefulWidget wraps entire build() return, not just one code path"
  - "Pattern: tester.ensureSemantics() + semanticsHandle.dispose() for scoped accessibility tests"

requirements-completed: []

# Metrics
duration: 4min
completed: "2026-05-30"
---

# Phase 09 Plan 02: Error+Retry UI and Video Accessibility Summary

**Error+retry OutlinedButton added to all 5 AsyncValue error branches (3 screens + 2 sub-widgets) using ref.invalidate pattern; ExerciseVideoPlayer wrapped in Semantics for VoiceOver/TalkBack with bySemanticsLabel widget test proof**

## Performance

- **Duration:** ~4 min
- **Started:** 2026-05-30T00:47:59Z
- **Completed:** 2026-05-30T00:52:00Z
- **Tasks:** 3
- **Files created:** 2 (test stubs)
- **Files modified:** 6

## Accomplishments

- Created `program_detail_screen_error_retry_test.dart` — Wave 0 stub verifying OutlinedButton retry on `programsListProvider` error
- Created `coach_chat_screen_error_retry_test.dart` — Wave 0 stub verifying OutlinedButton retry on `feedbackThreadProvider` stream error
- `ProgramDetailScreen`: 3 error branches upgraded — outer `programsListProvider.when(error:)`, inner `sessionsWithStateProvider.when(error:)` in session list, CTA `sessionsWithStateProvider.when(error:)` in `_buildCTA`
- `ProgressScreen._MetricTabContent`: error branch now shows `OutlinedButton(ref.invalidate(metricLogsByTypeProvider(widget.metricType)))`
- `CoachChatScreen`: error branch now shows `OutlinedButton(ref.invalidate(feedbackThreadProvider))`
- `NotificationsScreen`: error branch now shows `OutlinedButton(ref.invalidate(coachRepliesProvider))`
- `ExerciseVideoPlayer`: `build()` now wraps all output in `Semantics(label: 'Exercise video: ${widget.exercise.title}')` — covers loading, unavailable, and playing states
- `session_player_screen_test.dart`: new `bySemanticsLabel(RegExp('Exercise video'))` test using `tester.ensureSemantics()` — SC-P9-3 verified
- `flutter test test/` passes: **114 tests pass**, 1 pre-existing skip (was 111 + 3 new)
- `flutter analyze --fatal-infos` exits 0 — zero issues

## Task Commits

Each task was committed atomically:

1. **Task 1: Wave 0 widget test stubs** - `ae752c5` (test)
2. **Task 2: Error+retry on 5 screens** - `1cc57c7` (feat)
3. **Task 3: Semantics wrapper + accessibility test** - `13dbf7a` (feat)

## Files Created/Modified

- `mobile/test/widget/program_detail_screen_error_retry_test.dart` — new: overrides `programsListProvider` to throw, asserts `OutlinedButton` + `Retry` text
- `mobile/test/widget/coach_chat_screen_error_retry_test.dart` — new: overrides `feedbackThreadProvider` stream to error, asserts `OutlinedButton` + `Retry` text
- `mobile/lib/features/programs/presentation/program_detail_screen.dart` — 3 error branches replaced; `ref.invalidate(programsListProvider)` and `ref.invalidate(sessionsWithStateProvider(...))` added
- `mobile/lib/features/metrics/presentation/progress_screen.dart` — `_MetricTabContent` error branch: `ref.invalidate(metricLogsByTypeProvider(widget.metricType))`
- `mobile/lib/features/coach_chat/presentation/coach_chat_screen.dart` — error branch: `ref.invalidate(feedbackThreadProvider)`
- `mobile/lib/features/coach_chat/presentation/notifications_screen.dart` — error branch: `ref.invalidate(coachRepliesProvider)`
- `mobile/lib/features/session/presentation/exercise_video_player.dart` — `build()` refactored: `Semantics(label:...)` wraps `_buildContent()` for all three video states
- `mobile/test/widget/session_player_screen_test.dart` — new test: `bySemanticsLabel(RegExp('Exercise video'))` with `tester.ensureSemantics()`

## Decisions Made

- Semantics wrapper placed on the entire `build()` output (not just the Chewie branch) so that `find.bySemanticsLabel` works in test environments where no video URL is available and `_videoAvailable == false`
- `ExerciseVideoPlayer.build()` refactored into `build()` + `_buildContent()` to keep the Semantics at the outermost level without repetition
- Wave 0 TDD cycle: test stubs committed (Red) before implementation (Green) in a single plan, reflecting the natural development order

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Semantics wrapper scope extended to cover all ExerciseVideoPlayer build paths**
- **Found during:** Task 3
- **Issue:** The plan specified wrapping only `Chewie(controller: _chewieController!)` in a Semantics widget. In tests (and production when video is unavailable), `_videoAvailable == false` so the Chewie branch is never reached — `bySemanticsLabel` would find nothing
- **Fix:** Refactored `build()` to call `_buildContent()` helper, placing the `Semantics` wrapper at the root so all three states (loading, unavailable, playing) carry the accessibility label
- **Files modified:** `mobile/lib/features/session/presentation/exercise_video_player.dart`
- **Commit:** 13dbf7a

## Issues Encountered

None beyond the Semantics scope issue auto-fixed above.

## User Setup Required

None.

## Known Stubs

None.

## Next Phase Readiness

- 114 tests passing — clean base for Plan 09-03 (integration tests)
- All AsyncValue error branches now have retry — SC-P9-4 satisfied for this wave
- `bySemanticsLabel` test proof for SC-P9-3 committed
- `flutter analyze --fatal-infos` exits 0 — prerequisite for all Phase 9 plans maintained

## Self-Check: PASSED

- program_detail_screen_error_retry_test.dart: FOUND
- coach_chat_screen_error_retry_test.dart: FOUND
- program_detail_screen.dart ref.invalidate(programsListProvider): PASS
- program_detail_screen.dart ref.invalidate(sessionsWithStateProvider: PASS
- progress_screen.dart ref.invalidate(metricLogsByTypeProvider: PASS
- coach_chat_screen.dart ref.invalidate(feedbackThreadProvider): PASS
- notifications_screen.dart ref.invalidate(coachRepliesProvider): PASS
- exercise_video_player.dart Semantics: PASS
- session_player_screen_test.dart bySemanticsLabel: PASS
- Commit ae752c5: FOUND
- Commit 1cc57c7: FOUND
- Commit 13dbf7a: FOUND
- flutter analyze --fatal-infos exits 0: PASS
- flutter test exits 0 (114 tests): PASS

---
*Phase: 09-polish-qa*
*Completed: 2026-05-30*
