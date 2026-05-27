---
phase: 04-us2-session-player
plan: "03"
subsystem: session-ui
tags: [flutter, riverpod, session-list, navigation, go_router]
dependency_graph:
  requires: [04-01, 04-02]
  provides: [session-list-ui, session-player-navigation]
  affects: [program_detail_screen, app_router]
tech_stack:
  added: []
  patterns: [Consumer widget for nested AsyncValue, SessionListTile reusable row, goNamed with pathParameters]
key_files:
  created:
    - mobile/lib/features/session/presentation/session_list_tile.dart
  modified:
    - mobile/lib/features/programs/presentation/program_detail_screen.dart
decisions:
  - "error lambda uses (_, _) all-underscore wildcards to satisfy unnecessary_underscores lint (consistent with Phase 03 pattern)"
  - "Continue Program CTA reads sessionsWithStateProvider to resolve current session ID for navigation"
  - "Non-enrolled programs show 'Enroll to see sessions' card instead of real session list"
metrics:
  duration: "~8 minutes"
  completed: "2026-05-27"
  tasks_completed: 2
  files_changed: 2
---

# Phase 4 Plan 3: Session List UI + CTA Navigation Summary

SessionListTile widget with 3 visual states (complete/current/locked) and ProgramDetailScreen wired to real session data via sessionsWithStateProvider, with Continue Program CTA navigating to the current session player route.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create SessionListTile widget | 240815f | mobile/lib/features/session/presentation/session_list_tile.dart |
| 2 | Replace session placeholder + wire CTA | f95dbbc | mobile/lib/features/programs/presentation/program_detail_screen.dart |

## What Was Built

### SessionListTile (`session_list_tile.dart`)

Reusable StatelessWidget rendering a session row with three visual states per D-09/D-10:

- **Complete**: `Icons.check_circle` (green), transparent background, tappable, chevron trailing
- **Current**: `Icons.play_circle_filled` (primary/sage green), `primaryContainer.withValues(alpha: 0.3)` background highlight, tappable, chevron trailing
- **Locked**: `Icons.lock` (grey), transparent background, `onTap: null` (non-tappable), `Opacity(0.6)`, no trailing

Row format: `Day N — [Title]` / `N exercises · ~20 min`

### ProgramDetailScreen Updates

- Replaced static placeholder Card with `Consumer` widget reading `sessionsWithStateProvider(programId, currentDay)`
- Non-enrolled programs show "Enroll to see sessions." card
- `_buildCTA` now reads session provider to find current session and passes its `id` as `sessionId` path parameter
- CTA label: "Start Program" (day 1) vs "Continue Program" (day > 1)
- CTA disabled while loading or if no current session found

### Navigation Wiring

Both session list row taps and the Continue/Start CTA navigate via:
```dart
context.goNamed('session-player', pathParameters: {'programId': ..., 'sessionId': ...})
```
Router already had `session-player` route at `/programs/:programId/session/:sessionId` (placeholder screen retained — replaced in plan 04-04).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed unnecessary_underscores lint warning in error lambda**
- **Found during:** Task 2 verification
- **Issue:** `error: (_, __) =>` triggered `unnecessary_underscores` lint
- **Fix:** Changed to `error: (_, _) =>` using all-underscore wildcards (consistent with Phase 03 pattern documented in STATE.md)
- **Files modified:** `mobile/lib/features/programs/presentation/program_detail_screen.dart`
- **Commit:** f95dbbc

None others — plan executed as written after lint fix.

## Known Stubs

- `SessionListTile` shows `~20 min` as a hardcoded duration placeholder (real session duration data not yet in schema — documented in UI-SPEC as "duration fixed at ~20 min placeholder until real duration data exists")
- Session player route still shows `_PlaceholderScreen` — will be replaced in Plan 04-04

## Self-Check: PASSED

- `mobile/lib/features/session/presentation/session_list_tile.dart` — FOUND
- `mobile/lib/features/programs/presentation/program_detail_screen.dart` — FOUND (modified)
- Commit 240815f — FOUND
- Commit f95dbbc — FOUND
- `flutter analyze lib/features/programs/presentation/ lib/features/session/presentation/` — No issues found
