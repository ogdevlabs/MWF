---
phase: 05-us3-offline-first
plan: "03"
subsystem: sync
tags: [stale-video-detection, sync-queue, tdd, offline-first]
dependency_graph:
  requires:
    - 05-01  # Download service + manifest DAO foundation
  provides:
    - stale-video-detection  # remoteVersion > manifest.videoVersion resets manifest to pending
    - dead-letter-validation  # retry_count >= 5 items skipped
    - fifo-validation  # processQueue FIFO order confirmed
  affects:
    - mobile/lib/core/sync/sync_service.dart
    - mobile/test/unit/core/sync/sync_service_stale_video_test.dart
    - mobile/test/unit/core/sync/sync_queue_test.dart
tech_stack:
  added: []
  patterns:
    - TDD Red-Green cycle for stale detection
    - Per-table MockQueryBuilder/MockFilterBuilder pairs to avoid mocktail stub collision
    - dynamic Function cast via (future as dynamic).then(onValue) for typed Future mocking
key_files:
  created:
    - mobile/test/unit/core/sync/sync_service_stale_video_test.dart
  modified:
    - mobile/lib/core/sync/sync_service.dart
    - mobile/test/unit/core/sync/sync_queue_test.dart
decisions:
  - "Per-table mock pairs: each _stubTable() call creates its own _MockQueryBuilder + _MockFilterBuilder to prevent then() stub collision when multiple tables share a mock"
  - "dynamic future cast: (Future<List<...>>.value(rows) as dynamic).then(onValue) avoids typed Function parameter mismatch in mocktail thenAnswer for PostgrestFilterBuilder"
  - "Value(null) for videoLocalPath/modelLocalPath: uses present-null (clears column) vs Value.absent() which is a no-op on upsert (Drift pitfall)"
metrics:
  duration: "806s (~14 min)"
  completed: "2026-05-28"
  tasks_completed: 2
  files_changed: 3
---

# Phase 05 Plan 03: Stale Video Detection + SyncQueue Tests Summary

**One-liner:** Stale video detection via `remoteVersion > manifest.videoVersion` in SyncService exercises pull, validated with per-table mocktail chain stubs; dead-letter and FIFO ordering tests green.

## Tasks Completed

| Task | Type | Description | Commit |
|------|------|-------------|--------|
| 1 | TDD (Red/Green) | Add stale video detection to SyncService._pullRemoteChanges | ba0907d |
| 2 | TDD (Green) | Add dead-letter and FIFO ordering tests to sync_queue_test | 71a4d3c |

## What Was Built

### Task 1: Stale Video Detection

Modified `mobile/lib/core/sync/sync_service.dart` exercises pull block:

- After upserting each exercise, calls `db.downloadManifestDao.getByExerciseId(exerciseId)`
- If manifest exists and `remoteVersion > manifest.videoVersion`: resets to `pending`
- Uses `const Value(null)` for `videoLocalPath` and `modelLocalPath` to explicitly clear stale paths (not `Value.absent()` which would preserve the stale path)
- Satisfies D-15/D-16 from RESEARCH.md

Test file `sync_service_stale_video_test.dart` completely rewritten from the Wave 0 skip stub:
- 4 tests: pending reset, null path clear, version update, no-op same version
- Mock strategy: per-table `_MockQueryBuilder` + `_MockFilterBuilder` pairs (prevents `then()` stub collision)
- `(future as dynamic).then(onValue)` pattern to bypass typed Function cast issue in mocktail

### Task 2: Dead-Letter and FIFO Tests

Extended `sync_queue_test.dart` with 2 new tests (5 total):
- **Dead-letter (D-18):** item with `retryCount=5` not returned by `getPendingItems()`; `processQueue()` returns 0
- **FIFO (D-17):** items inserted out-of-order by createdAt; `getPendingItems()` returns in createdAt ASC order

Both tests pass GREEN immediately — the production code in `SyncQueueDao.getPendingItems()` already implements these behaviors (Phase 2 foundation). The tests confirm the existing behavior.

## Test Results

```
flutter test test/unit/core/sync/
  sync_service_stale_video_test.dart: 4/4 passed
  sync_queue_test.dart: 5/5 passed
  Total: 9 tests, 0 failures

flutter analyze lib/core/sync/sync_service.dart: No issues found
```

## Decisions Made

1. **Per-table mock pairs:** Each call to `_stubTable()` creates its own `_MockQueryBuilder` + `_MockFilterBuilder` instance. Sharing a single `mockFb` across tables caused the `then()` stub to be overridden by the last `_stubTable` call, making all tables return the last table's rows.

2. **Dynamic future cast for mocktail:** `PostgrestFilterBuilder<PostgrestList>` implements `Future<List<Map<String, dynamic>>>`. Stubbing `then()` via `thenAnswer` caused a type mismatch: the actual continuation has type `(List<Map<String, dynamic>>) => dynamic` but the cast expected `(dynamic) => dynamic`. Solution: `(Future<List<Map<String, dynamic>>>.value(rows) as dynamic).then(onValue)` — the dynamic dispatch bypasses static type checking.

3. **Value(null) not Value.absent():** As documented in RESEARCH.md Pitfall 4, `Value.absent()` is a no-op in Drift upserts (preserves existing column value). `const Value(null)` is a present-but-null value that clears the column. Critical for stale path cleanup.

## Deviations from Plan

None — plan executed exactly as written. The TDD Red→Green cycle worked as specified. The `_FakeQuery` approach from plan notes was superseded by the per-table mocktail approach which handles the `SupabaseQueryBuilder` return type constraint.

## Known Stubs

None — no stub values or placeholder data flow to UI rendering from this plan.

## Self-Check: PASSED

| Item | Status |
|------|--------|
| mobile/lib/core/sync/sync_service.dart | FOUND |
| mobile/test/unit/core/sync/sync_service_stale_video_test.dart | FOUND |
| mobile/test/unit/core/sync/sync_queue_test.dart | FOUND |
| Commit b0aa685 (RED test) | FOUND |
| Commit ba0907d (GREEN production) | FOUND |
| Commit 71a4d3c (dead-letter/FIFO tests) | FOUND |
