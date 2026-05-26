---
plan: 02-03
phase: 2
subsystem: mobile/database
tags: [drift, dao, riverpod, sqlite, offline-first]
dependency_graph:
  requires: [02-02]
  provides: [app_database, programs_dao, sessions_dao, exercises_dao, progress_dao, metric_logs_dao, feedback_dao, sync_queue_dao, download_manifest_dao]
  affects: [02-04, 02-05, 02-06, 02-07]
tech_stack:
  added: []
  patterns:
    - Drift @DriftAccessor DAO per entity with CRUD + reactive stream methods
    - AppDatabase accepts optional QueryExecutor for in-memory test injection
    - @Riverpod(keepAlive: true) provider with onDispose cleanup for DB singleton
key_files:
  created:
    - mobile/lib/core/database/app_database.dart
    - mobile/lib/core/database/daos/programs_dao.dart
    - mobile/lib/core/database/daos/sessions_dao.dart
    - mobile/lib/core/database/daos/exercises_dao.dart
    - mobile/lib/core/database/daos/progress_dao.dart
    - mobile/lib/core/database/daos/metric_logs_dao.dart
    - mobile/lib/core/database/daos/feedback_dao.dart
    - mobile/lib/core/database/daos/sync_queue_dao.dart
    - mobile/lib/core/database/daos/download_manifest_dao.dart
  modified: []
decisions:
  - SyncQueueDao.incrementRetry uses getSingle + write pattern matching plan spec exactly
  - SyncQueueDao.pendingCount uses selectOnly + countAll for efficient aggregate query
  - AppDatabase uses driftDatabase(name: 'mwf_local') from drift_flutter for production path resolution
metrics:
  duration: 8m
  completed: 2026-05-26
  tasks_completed: 2
  files_created: 9
---

# Phase 2 Plan 03: Drift DAOs + AppDatabase Summary

**One-liner:** 8 typed Drift DAOs with CRUD + reactive streams plus central AppDatabase wiring all 9 tables, test-injectable constructor, and keepAlive Riverpod provider.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create all 8 Drift DAOs (T025-T032) | 64b9f5c | mobile/lib/core/database/daos/*.dart (8 files) |
| 2 | Create AppDatabase class (T015) | 86d3a49 | mobile/lib/core/database/app_database.dart |

## What Was Built

**8 DAO files** in `mobile/lib/core/database/daos/`:

- `programs_dao.dart` — watchAllPrograms, getAllPrograms, getProgramById, upsertProgram, deleteProgramById
- `sessions_dao.dart` — watchSessionsByProgram (ordered by dayNumber), getSessionsByProgram, getSessionById, upsertSession, deleteSessionById
- `exercises_dao.dart` — watchExercisesBySession (ordered by displayOrder), getExercisesBySession, getExerciseById, upsertExercise, deleteExerciseById
- `progress_dao.dart` — watchProgressByStudent (ordered desc by completedAt), getProgressByStudent, getByStudentAndSession, upsertProgress
- `metric_logs_dao.dart` — watchMetricsByType (ordered asc by loggedAt), getMetricsByStudent, insertMetricLog, upsertMetricLog
- `feedback_dao.dart` — watchFeedbackByStudent, getByStudentAndSession, upsertFeedback, watchReplies (filters coachReply.isNotNull)
- `sync_queue_dao.dart` — enqueue, getPendingItems (retryCount < 5, ordered by createdAt), deleteById, incrementRetry, pendingCount
- `download_manifest_dao.dart` — upsertEntry, getByExerciseId, getPendingDownloads, getCompletedDownloads, watchAllEntries, updateStatus

**AppDatabase** at `mobile/lib/core/database/app_database.dart`:

- `@DriftDatabase(tables: [...], daos: [...])` with all 9 tables and 8 DAOs
- Constructor: `AppDatabase([QueryExecutor? executor])` — production uses `driftDatabase(name: 'mwf_local')`, tests inject `NativeDatabase.memory()`
- `schemaVersion => 1`
- `@Riverpod(keepAlive: true) AppDatabase appDatabase(Ref ref)` provider with `ref.onDispose(db.close)`

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — all DAOs are fully wired to their table classes. No placeholder data or hardcoded empty values. Code generation (`.g.dart` files) is intentionally deferred to Plan 02-07 per the wave structure.

## Self-Check: PASSED

Files created:
- mobile/lib/core/database/daos/programs_dao.dart: FOUND
- mobile/lib/core/database/daos/sessions_dao.dart: FOUND
- mobile/lib/core/database/daos/exercises_dao.dart: FOUND
- mobile/lib/core/database/daos/progress_dao.dart: FOUND
- mobile/lib/core/database/daos/metric_logs_dao.dart: FOUND
- mobile/lib/core/database/daos/feedback_dao.dart: FOUND
- mobile/lib/core/database/daos/sync_queue_dao.dart: FOUND
- mobile/lib/core/database/daos/download_manifest_dao.dart: FOUND
- mobile/lib/core/database/app_database.dart: FOUND

Commits:
- 64b9f5c: feat(02-03): add 8 Drift DAOs (T025-T032) — FOUND
- 86d3a49: feat(02-03): add AppDatabase class with all 9 tables and 8 DAOs (T015) — FOUND
