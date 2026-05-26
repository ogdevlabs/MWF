---
phase: 03-us1-enroll-access
plan: "06"
subsystem: programs-ui
tags: [flutter, riverpod, go_router, presentation, programs]
dependency_graph:
  requires: [03-04, 03-05]
  provides: [program-list-screen, program-detail-screen, program-card-widget, router-wired]
  affects: [app_router, programs-feature]
tech_stack:
  added: []
  patterns: [ConsumerWidget, GridView.builder, SliverAppBar, CustomScrollView, goNamed]
key_files:
  created:
    - mobile/lib/features/programs/presentation/program_card_widget.dart
    - mobile/lib/features/programs/presentation/program_list_screen.dart
    - mobile/lib/features/programs/presentation/program_detail_screen.dart
  modified:
    - mobile/lib/shared/router/app_router.dart
decisions:
  - "AsyncValue.value ?? true (not .valueOrNull) for onboardingSeenProvider — Riverpod 3.x dropped .valueOrNull"
  - "errorBuilder uses (_, _, _) all-underscore wildcards to satisfy unnecessary_underscores lint"
metrics:
  duration: 183s
  completed_date: "2026-05-26"
  tasks_completed: 2
  files_changed: 4
---

# Phase 03 Plan 06: Program UI Screens Summary

**One-liner:** Three program presentation screens (card widget, grid list, detail) wired into GoRouter, replacing all placeholder routes for /programs, /programs/:id, and /paywall.

## What Was Built

### Task 1: ProgramCard + ProgramListScreen + ProgramDetailScreen

**ProgramCard** (`program_card_widget.dart`):
- 16:9 thumbnail with `Image.network` + fallback icon container
- Lock overlay (`Colors.black54` + `Icons.lock`) when `program.isLocked`
- Color-coded `_DifficultyBadge` (green/orange/red/grey) via switch expression
- Duration label, enrollment progress bar + "Day N" for enrolled+accessible programs

**ProgramListScreen** (`program_list_screen.dart`):
- `ConsumerWidget` watching `programsListProvider`
- `AsyncValue.when` with loading spinner, error state (retry button via `ref.invalidate`), empty state
- `LayoutBuilder`-driven responsive `GridView.builder`: 2 cols <600px, 3 cols >=600px
- `RefreshIndicator` for pull-to-refresh
- `_onProgramTap`: `context.goNamed('paywall')` if locked, `context.pushNamed('program-detail', pathParameters: ...)` if accessible

**ProgramDetailScreen** (`program_detail_screen.dart`):
- `ConsumerWidget` loading program from `programsListProvider` by `programId`
- `SliverAppBar(expandedHeight: 200, pinned: true)` collapsing header with thumbnail
- Difficulty `Chip` (color-coded), duration row, description text
- Progress card (enrolled programs): `LinearProgressIndicator` + "Day N of M" text
- Session list placeholder (Phase 4 will add real sessions)
- Bottom `SafeArea` CTA: "Subscribe to Access" (locked), "Continue Program" (enrolled), "Enroll in Program" (subscribed, not enrolled)
- `_enroll()` calls `programsRepositoryProvider.enrollStudent()`, invalidates cache, shows snackbar

### Task 2: Wire router

Updated `app_router.dart`:
- Added imports: `PaywallScreen`, `ProgramListScreen`, `ProgramDetailScreen`
- `/programs` → `ProgramListScreen()`
- `/programs/:programId` → `ProgramDetailScreen(programId: state.pathParameters['programId']!)`
- `/paywall` → `PaywallScreen()`
- Kept `_PlaceholderScreen` for: session-player, progress, notifications, feedback, settings

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Reverted `.valueOrNull` → `.value` for `AsyncValue<bool>`**
- **Found during:** Task 2 (flutter analyze)
- **Issue:** Plan specified `.valueOrNull ?? true` but Riverpod 3.x removed `.valueOrNull`; `.value` is the correct accessor for `AsyncValue<bool>`
- **Fix:** Used `.value ?? true` matching the existing router pattern and the decision recorded in STATE.md
- **Files modified:** `mobile/lib/shared/router/app_router.dart`
- **Commit:** c49ea1c

**2. [Rule 1 - Bug] Fixed `unnecessary_underscores` lint in errorBuilder callbacks**
- **Found during:** Task 2 (flutter analyze)
- **Issue:** `errorBuilder: (_, __, ___)` triggered `unnecessary_underscores` info; Dart allows `(_, _, _)` for all-wildcard params
- **Fix:** Changed all three params to `_` in both `program_card_widget.dart` and `program_detail_screen.dart`
- **Files modified:** `program_card_widget.dart`, `program_detail_screen.dart`
- **Commit:** c49ea1c

## Known Stubs

- `program_detail_screen.dart`: Session list is a placeholder card with text "Session list will be available in the next update." — intentional per plan (Phase 4 will add real sessions). The plan's objective is program overview + enroll CTA, not session playback.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | 86b5b3f | feat(03-06): create ProgramCard, ProgramListScreen, ProgramDetailScreen |
| Task 2 | c49ea1c | feat(03-06): wire real program screens into app_router, fix analyze warnings |

## Verification

All plan verification checks pass:
- `grep -q "ProgramListScreen" app_router.dart` — PASS
- `grep -q "ProgramDetailScreen" app_router.dart` — PASS
- `grep -q "PaywallScreen" app_router.dart` — PASS
- `grep -q "goNamed('paywall')" program_list_screen.dart` — PASS
- `flutter analyze lib/ --fatal-warnings --no-fatal-infos` — **No issues found**

## Self-Check: PASSED

Files exist:
- mobile/lib/features/programs/presentation/program_card_widget.dart — FOUND
- mobile/lib/features/programs/presentation/program_list_screen.dart — FOUND
- mobile/lib/features/programs/presentation/program_detail_screen.dart — FOUND
- mobile/lib/shared/router/app_router.dart — FOUND (modified)

Commits exist:
- 86b5b3f — FOUND
- c49ea1c — FOUND
