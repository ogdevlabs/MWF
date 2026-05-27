---
phase: 04-us2-session-player
plan: 05
subsystem: mobile/features/session/presentation
tags: [flutter, overlay, timer, rep-counter, 3d-model, model-viewer, bottom-sheet]
dependency_graph:
  requires: [04-02, 04-04]
  provides: [rep-counter-overlay, timer-countdown-overlay, model-viewer-sheet, session-player-overlays]
  affects: [session_player_screen]
tech_stack:
  added: []
  patterns: [stateful-overlay, draggable-bottom-sheet, modal-bottom-sheet, model-viewer-plus]
key_files:
  created:
    - mobile/lib/features/session/presentation/rep_counter_overlay.dart
    - mobile/lib/features/session/presentation/timer_countdown_overlay.dart
    - mobile/lib/features/session/presentation/model_viewer_sheet.dart
  modified:
    - mobile/lib/features/session/presentation/session_player_screen.dart
decisions:
  - RepCounterOverlay uses _targetHit bool guard to prevent double-firing onTargetReached callback
  - TimerCountdownOverlay cancels Timer in dispose to prevent setState-after-dispose
  - ModelViewerSheet resolves localModelPath via getApplicationDocumentsDirectory for file:// URI
  - Overlays use Positioned.fill in the Stack so they sit above the video player layer
  - Close and 3D buttons moved after overlay declarations (same Stack, no z-order change needed)
metrics:
  duration: 122s
  completed_date: "2026-05-26"
  tasks: 2
  files_created: 3
  files_modified: 1
---

# Phase 4 Plan 5: Rep/Timer Overlays and 3D Model Sheet Summary

**One-liner:** Rep-count and countdown-timer overlays wired into SessionPlayerScreen Stack, with on-demand DraggableScrollableSheet 3D model viewer using model_viewer_plus.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create RepCounterOverlay and TimerCountdownOverlay widgets | 901e382 | rep_counter_overlay.dart, timer_countdown_overlay.dart |
| 2 | Create ModelViewerSheet and wire overlays into SessionPlayerScreen | 1601df1 | model_viewer_sheet.dart, session_player_screen.dart |

## What Was Built

### RepCounterOverlay (`rep_counter_overlay.dart`)
Tap-to-count `StatefulWidget` overlay for rep-based exercises (D-06). Displays `"N / M reps"` with a full-area `GestureDetector`. Increments on each tap; fires `onTargetReached` callback when count reaches target. Uses a `_targetHit` guard to prevent double-firing. Text turns `colorScheme.primary` when complete. Includes `Semantics` label for accessibility.

### TimerCountdownOverlay (`timer_countdown_overlay.dart`)
Countdown timer `StatefulWidget` for duration-based exercises (D-07). Uses `dart:async` `Timer.periodic` to count down from `durationSeconds` to zero. Fires `onComplete` at zero; text turns `colorScheme.primary`. Timer is cancelled in `dispose()` to prevent setState-after-dispose. Includes `Semantics` label for accessibility.

### ModelViewerSheet (`model_viewer_sheet.dart`)
Top-level `Future<void> showModelViewerSheet()` function opening a `showModalBottomSheet` with `DraggableScrollableSheet` (initialChildSize: 0.55, minChildSize: 0.3, maxChildSize: 0.9, per D-02). Contains `ModelViewer` with `cameraControls: true`, `autoRotate: true`, `autoRotateDelay: 1000`, `ar: false`, `Loading.eager` (D-03). Resolves `localModelPath` via `path_provider` `getApplicationDocumentsDirectory` for `file://` URI. No-ops if both `modelAssetUrl` and `localModelPath` are null.

### SessionPlayerScreen updates
- Added imports for all three new files
- Added `_onOverlayTargetReached()` method: `setState(() => _nextEnabled = true)`
- Added `Positioned.fill` overlay in Stack: `RepCounterOverlay` if `exercise.repCount != null`, else `TimerCountdownOverlay` if `exercise.durationSeconds != null`
- Each overlay uses `ValueKey('rep-${exercise.id}')` / `ValueKey('timer-${exercise.id}')` to force widget rebuild on exercise advance
- Replaced `_build3DToggleButton` SnackBar placeholder with real `showModelViewerSheet()` call

## Verification

All plan verification checks pass:
- `flutter analyze lib/features/session/presentation/` — No issues found
- `grep "RepCounterOverlay" session_player_screen.dart` — match found
- `grep "TimerCountdownOverlay" session_player_screen.dart` — match found
- `grep "showModelViewerSheet" session_player_screen.dart` — match found
- `grep "DraggableScrollableSheet" model_viewer_sheet.dart` — match found

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. All overlays are fully functional. The `showModelViewerSheet` gracefully no-ops if both model URL fields are null (exercises without 3D models).

## Self-Check: PASSED

Files exist:
- FOUND: mobile/lib/features/session/presentation/rep_counter_overlay.dart
- FOUND: mobile/lib/features/session/presentation/timer_countdown_overlay.dart
- FOUND: mobile/lib/features/session/presentation/model_viewer_sheet.dart

Commits exist:
- FOUND: 901e382 (Task 1)
- FOUND: 1601df1 (Task 2)
