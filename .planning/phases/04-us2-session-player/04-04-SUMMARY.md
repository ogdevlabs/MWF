---
phase: 04-us2-session-player
plan: "04"
subsystem: ui
tags: [flutter, chewie, video_player, riverpod, go_router, drift, session-player]

# Dependency graph
requires:
  - phase: 04-01
    provides: SessionResumeDao, session_resume_state Drift table, schema migration v2
  - phase: 04-02
    provides: ExerciseModel, SessionDatasource, sessionDatasourceProvider, session_providers

provides:
  - ExerciseVideoPlayer widget: Chewie wrapper with HLS/local video fallback and looping
  - CueTextStrip widget: scrollable cue text strip below video, hidden when null/empty
  - SessionPlayerScreen: ConsumerStatefulWidget for full session playback with resume
  - Router wiring: session-player route replaced with real screen; session-complete placeholder added

affects:
  - 04-05 (rep/timer overlays will call back into SessionPlayerScreen._nextEnabled)
  - 04-06 (SessionCompletionScreen will replace session-complete placeholder)
  - 05-xx (offline first: ExerciseVideoPlayer already checks localVideoPath + downloadManifest)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ConsumerStatefulWidget pattern for video lifecycle management (Chewie requires State)
    - ExerciseVideoPlayer keyed by ValueKey(exercise.id) to force re-init on exercise advance
    - Local file fallback priority: localVideoPath > muxPlaybackId HLS > downloadManifest

key-files:
  created:
    - mobile/lib/features/session/presentation/exercise_video_player.dart
    - mobile/lib/features/session/presentation/cue_text_strip.dart
    - mobile/lib/features/session/presentation/session_player_screen.dart
  modified:
    - mobile/lib/shared/router/app_router.dart

key-decisions:
  - "_onOverlayTargetReached removed from SessionPlayerScreen (unused until Plan 05 adds rep/timer overlays)"
  - "session-complete route added as placeholder (Plan 06 will build SessionCompletionScreen)"
  - "Resume index clamped with .clamp(0, exercises.length - 1) to handle edge case where exercises shrink"
  - "clearResumeState called before navigation to completion screen (not after)"

patterns-established:
  - "ExerciseVideoPlayer: always key with ValueKey(exercise.id) — StatefulWidget re-creates on key change"
  - "Video URL priority: exercise.localVideoPath > exercise.muxPlaybackId HLS > downloadManifest"
  - "Router session-player route nested under :programId — both programId and sessionId must be in pathParameters"

requirements-completed: [FR-005, FR-013]

# Metrics
duration: 3min
completed: 2026-05-27
---

# Phase 4 Plan 04: Session Player Screen Summary

**Chewie-based SessionPlayerScreen with HLS/local video playback, exercise navigation, resume-state persistence via Drift, and cue text display**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-27T02:46:32Z
- **Completed:** 2026-05-27T02:49:43Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- ExerciseVideoPlayer widget: Chewie wrapper with looping video, graceful fallback to "Video not available" when neither HLS nor local file available
- CueTextStrip widget: scrollable cue text panel below video, zero-height when cueText is null/empty
- SessionPlayerScreen: loads exercises from Drift via SessionDatasource, restores exercise index from SessionResumeDao on init, saves index on each Next tap, navigates to session-complete on final exercise
- Router updated: session-player now serves real SessionPlayerScreen; session-complete placeholder added for Plan 06

## Task Commits

1. **Task 1: Create ExerciseVideoPlayer and CueTextStrip widgets** - `c38abb1` (feat)
2. **Task 2: Create SessionPlayerScreen and wire router** - `5912cc4` (feat)

## Files Created/Modified

- `mobile/lib/features/session/presentation/exercise_video_player.dart` - Chewie wrapper with HLS/local fallback, looping=true, allowFullScreen=false, proper controller lifecycle
- `mobile/lib/features/session/presentation/cue_text_strip.dart` - Scrollable cue text strip, hidden when null/empty
- `mobile/lib/features/session/presentation/session_player_screen.dart` - Main player: ConsumerStatefulWidget, loads exercises, resumes, shows Next/Finish button
- `mobile/lib/shared/router/app_router.dart` - Replace placeholder with SessionPlayerScreen, add session-complete route

## Decisions Made

- Removed `_onOverlayTargetReached` from SessionPlayerScreen to keep flutter analyze clean; Plan 05 will re-add it when wiring rep/timer overlay callbacks.
- Added `session-complete` placeholder route alongside `session-player` inside `:programId` route tree, so navigation from SessionPlayerScreen works immediately.
- Resume index clamped to valid range in case exercises list shrinks between sessions.
- `clearResumeState` called before navigating to completion screen to avoid stale state on back-navigation.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed nullable Uri declaration causing unnecessary_non_null_assertion warning**
- **Found during:** Task 1 (ExerciseVideoPlayer)
- **Issue:** `final Uri? videoUri` declared nullable but analyzer warned `!` operator unnecessary at `VideoPlayerController.networkUrl(videoUri!)` since control flow guarantees non-null
- **Fix:** Changed declaration to `final Uri videoUri` (non-nullable); Dart flow analysis confirms all paths either assign or return early
- **Files modified:** mobile/lib/features/session/presentation/exercise_video_player.dart
- **Verification:** flutter analyze reports no issues
- **Committed in:** c38abb1 (Task 1 commit)

**2. [Rule 1 - Bug] Removed unused _onOverlayTargetReached method**
- **Found during:** Task 2 (SessionPlayerScreen)
- **Issue:** `_onOverlayTargetReached` declared but never called, triggering `unused_element` warning
- **Fix:** Removed method — it will be re-added in Plan 05 when rep/timer overlays are wired
- **Files modified:** mobile/lib/features/session/presentation/session_player_screen.dart
- **Verification:** flutter analyze reports no issues
- **Committed in:** 5912cc4 (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Both fixes necessary for clean analyzer output. No behavior change. No scope creep.

## Issues Encountered

None — all packages and interfaces already in place from Plans 01 and 02.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- ExerciseVideoPlayer and CueTextStrip ready for use in Plan 05 (rep/timer overlay integration)
- SessionPlayerScreen ready to receive overlay callback wiring in Plan 05
- session-complete route ready for Plan 06 (SessionCompletionScreen)
- All flutter analyze checks pass on all 4 files

---
*Phase: 04-us2-session-player*
*Completed: 2026-05-27*
