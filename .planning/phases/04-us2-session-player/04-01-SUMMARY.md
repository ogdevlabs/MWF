---
phase: 04-us2-session-player
plan: 01
subsystem: database
tags: [drift, sqlite, session-resume, migration, test-stubs]

# Dependency graph
requires:
  - phase: 03-us1-enroll-access
    provides: AppDatabase v1 with 9 tables + 9 DAOs, EnrollmentsDao, LocalExercises table

provides:
  - Drift schema v2 with session_resume_state table and migration from v1
  - SessionResumeDao with getResumeState, saveResumeState, clearResumeState
  - ExercisesDao.getExerciseCountBySession() returning int count
  - Test stubs for FR-004 (lock state), FR-005 (widget), FR-012 (completion), FR-013 (resume), FR-014 (streak)

affects:
  - 04-02 (session list needs getExerciseCountBySession)
  - 04-04 (resume player needs SessionResumeDao)
  - 04-06 (test stubs replaced with real implementations)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Drift MigrationStrategy: onCreate=createAll(), onUpgrade guards with `if (from < 2)`"
    - "SessionResumeDao.saveResumeState uses insertOnConflictUpdate for idempotent upsert"
    - "ExercisesDao.getExerciseCountBySession uses selectOnly + countAll() + map().getSingle()"

key-files:
  created:
    - mobile/lib/core/database/tables/session_resume_state_table.dart
    - mobile/lib/core/database/daos/session_resume_dao.dart
    - mobile/lib/core/database/daos/session_resume_dao.g.dart
    - mobile/test/unit/features/session/session_lock_state_test.dart
    - mobile/test/unit/features/session/session_resume_test.dart
    - mobile/test/unit/features/session/streak_test.dart
    - mobile/test/unit/features/session/session_completion_test.dart
    - mobile/test/widget/session_player_screen_test.dart
  modified:
    - mobile/lib/core/database/daos/exercises_dao.dart
    - mobile/lib/core/database/app_database.dart
    - mobile/lib/core/database/app_database.g.dart

key-decisions:
  - "AppDatabase schemaVersion bumped to 2 with explicit MigrationStrategy guarded by `if (from < 2)`"
  - "SessionResumeStateCompanion.saveResumeState sets updatedAt=DateTime.now() at DAO layer (not caller)"
  - "getExerciseCountBySession uses selectOnly+countAll rather than fetching all rows — avoids N-row fetch for a count query"
  - "Test stubs use `expect(true, isTrue, reason: 'Stub — replaced in Plan 06')` to compile cleanly and signal intent"

patterns-established:
  - "Drift count queries: selectOnly + addColumns([countAll()]) + map(row => row.read(countAll())).getSingle()"
  - "Drift migration guard: `if (from < 2) { await m.createTable(tableRef); }` pattern for additive migrations"

requirements-completed: [FR-004, FR-005, FR-012, FR-013, FR-014]

# Metrics
duration: 3min
completed: 2026-05-27
---

# Phase 04 Plan 01: Session Player — DB Schema v2 + Test Stubs Summary

**Drift schema bumped to v2 with session_resume_state table, SessionResumeDao (save/get/clear), ExercisesDao.getExerciseCountBySession(), and 19 placeholder tests anchoring all Phase 4 requirements**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-27T02:38:54Z
- **Completed:** 2026-05-27T02:41:55Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments

- Created `session_resume_state` Drift table (sessionId PK, studentId, exerciseIndex, updatedAt) and bumped schemaVersion to 2 with a safe `if (from < 2)` migration guard
- Created `SessionResumeDao` with `getResumeState`, `saveResumeState` (upsert), and `clearResumeState` methods; registered in AppDatabase
- Added `getExerciseCountBySession` to `ExercisesDao` using `selectOnly + countAll()` — no row fetch for a count query
- Created 5 test stub files (19 tests total) covering FR-004 lock state, FR-005 widget, FR-012 completion, FR-013 resume, FR-014 streak — all passing

## Task Commits

1. **Task 1: DB schema v2 + SessionResumeDao + ExercisesDao.getExerciseCountBySession** - `4bcd90b` (feat)
2. **Task 2: Test stubs for FR-004, FR-005, FR-012, FR-013, FR-014** - `cef7deb` (test)

## Files Created/Modified

- `mobile/lib/core/database/tables/session_resume_state_table.dart` - Drift table: sessionId PK, studentId, exerciseIndex, updatedAt
- `mobile/lib/core/database/daos/session_resume_dao.dart` - DAO with save/get/clear resume state methods
- `mobile/lib/core/database/daos/session_resume_dao.g.dart` - Generated mixin for SessionResumeDao
- `mobile/lib/core/database/daos/exercises_dao.dart` - Added getExerciseCountBySession using countAll()
- `mobile/lib/core/database/app_database.dart` - Added SessionResumeState table, SessionResumeDao, schemaVersion=2, MigrationStrategy
- `mobile/lib/core/database/app_database.g.dart` - Regenerated with new table + DAO wiring
- `mobile/test/unit/features/session/session_lock_state_test.dart` - 3 stubs: SessionState derivation (FR-004)
- `mobile/test/unit/features/session/session_resume_test.dart` - 4 stubs: SessionResumeDao operations (FR-013)
- `mobile/test/unit/features/session/streak_test.dart` - 5 stubs: computeCurrentStreak (FR-014)
- `mobile/test/unit/features/session/session_completion_test.dart` - 4 stubs: completion flow (FR-012)
- `mobile/test/widget/session_player_screen_test.dart` - 3 stubs: SessionPlayerScreen smoke tests (FR-005)

## Decisions Made

- Bumped schemaVersion to 2 with `MigrationStrategy.onUpgrade` guarded by `if (from < 2)` — additive pattern for future migrations
- `saveResumeState` sets `updatedAt = DateTime.now()` at the DAO layer to keep callers simple
- Used `selectOnly + countAll()` for `getExerciseCountBySession` to avoid loading full exercise rows for a count query
- Test stubs use `expect(true, isTrue, reason: 'Stub — replaced in Plan 06')` — compiles cleanly and communicates intent

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

All stubs are intentional placeholders per the plan design. Each file documents which plan replaces it (Plan 06):

| File | Stub Count | Replaced In |
|------|-----------|-------------|
| session_lock_state_test.dart | 3 | Plan 06 |
| session_resume_test.dart | 4 | Plan 06 |
| streak_test.dart | 5 | Plan 06 |
| session_completion_test.dart | 4 | Plan 06 |
| session_player_screen_test.dart | 3 | Plan 06 |

These stubs do not prevent the plan's goal (unblock downstream plans) — they provide the Nyquist validation anchor required by the phase validation strategy.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Plan 02 (session list screen) can proceed — `getExerciseCountBySession` is available
- Plan 03 (video player) can proceed — database foundation is complete
- Plan 04 (resume player) can proceed — `SessionResumeDao` is available
- Plan 06 (final wiring) will replace all 5 test stubs with real implementations

---
*Phase: 04-us2-session-player*
*Completed: 2026-05-27*
