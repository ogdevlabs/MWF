---
phase: 06-us4-metrics-progress
plan: "02"
subsystem: metrics-data-layer
tags: [metrics, drift, riverpod, sync, streak, fl_chart]
dependency_graph:
  requires: ["04-06", "05-04"]
  provides:
    - "computeLongestStreak"
    - "computeMetricDelta"
    - "MetricRepository"
    - "metricRepositoryProvider"
    - "metricLogsByTypeProvider"
    - "SyncService.metric_logs-pull"
  affects:
    - "mobile/lib/core/sync/sync_service.dart"
    - "mobile/lib/features/session/data/streak_calculator.dart"
tech_stack:
  added:
    - "fl_chart: ^1.2.0 (trend chart dependency for Plan 03)"
  patterns:
    - "computeLongestStreak — historical max consecutive-day run, not anchored to today"
    - "computeMetricDelta — first-to-last delta from ordered log list; null for <2 entries"
    - "MetricRepository CQRS: local Drift write + SyncQueue enqueue in single operation"
    - "logged_at serialized as YYYY-MM-DD (not ISO-8601) for Supabase date column"
    - "metric_logs sync uses created_at filter (table has no updated_at column)"
    - "metricLogsByTypeProvider uses manual StreamProvider.family (riverpod_generator cannot resolve Drift-generated LocalMetricLog type)"
key_files:
  created:
    - mobile/lib/features/metrics/domain/metric_delta.dart
    - mobile/lib/features/metrics/data/metric_repository.dart
    - mobile/lib/features/metrics/data/metric_providers.dart
    - mobile/lib/features/metrics/data/metric_providers.g.dart
    - mobile/test/unit/features/metrics/metric_delta_test.dart
    - mobile/test/unit/features/metrics/metric_repository_test.dart
    - mobile/test/unit/features/metrics/offline_metric_sync_test.dart
    - mobile/test/widget/metric_log_bottom_sheet_test.dart
    - mobile/test/widget/progress_screen_test.dart
    - .planning/phases/06-us4-metrics-progress/06-01-PLAN.md
    - .planning/phases/06-us4-metrics-progress/06-02-PLAN.md
    - .planning/phases/06-us4-metrics-progress/06-CONTEXT.md
    - .planning/phases/06-us4-metrics-progress/06-RESEARCH.md
  modified:
    - mobile/pubspec.yaml (added fl_chart: ^1.2.0)
    - mobile/pubspec.lock
    - mobile/lib/features/session/data/streak_calculator.dart (added computeLongestStreak)
    - mobile/lib/core/sync/sync_service.dart (added metric_logs pull block)
    - mobile/test/unit/features/session/streak_test.dart (added computeLongestStreak group)
decisions:
  - "computeLongestStreak in streak_calculator.dart alongside computeCurrentStreak — same file, same concern"
  - "MetricRepository uses relative imports for internal packages (not package: prefix)"
  - "metricLogsByTypeProvider uses manual StreamProvider.family — riverpod_generator 4.0.4-dev.1 throws InvalidTypeException when provider return type is Stream<List<LocalMetricLog>> (Drift-generated type not resolvable by generator)"
  - "metric_logs sync uses since: null + filter: query.gte('created_at', lastSync) — table has no updated_at column (Pitfall 2 in RESEARCH.md)"
  - "Plan 06-01 (Wave 0 test stubs) executed as prerequisite within 06-02 — stubs created before implementation per TDD pattern"
metrics:
  duration: "583s (~10min)"
  completed_date: "2026-05-29"
  tasks: 2
  files: 19
---

# Phase 06 Plan 02: Metrics Data Layer Summary

MetricRepository CQRS pattern (local write + sync enqueue), computeLongestStreak, computeMetricDelta pure functions, fl_chart dependency, and SyncService metric_logs pull block using created_at filter.

## Tasks Completed

| # | Name | Commit | Files |
|---|------|--------|-------|
| 1 | Add fl_chart, computeLongestStreak, computeMetricDelta + Wave 0 test stubs | d268580 | streak_calculator.dart, metric_delta.dart, pubspec.yaml, 7 test files, 4 plan files |
| 2 | MetricRepository + providers + SyncService metric_logs pull | ba8ccdf | metric_repository.dart, metric_providers.dart, metric_providers.g.dart, sync_service.dart |

## Decisions Made

1. **computeLongestStreak location** — Added to `features/session/data/streak_calculator.dart` alongside `computeCurrentStreak` since both operate on the same `List<DateTime>` type and same concept (streak = consecutive calendar days).

2. **metricLogsByTypeProvider uses manual StreamProvider.family** — `riverpod_generator 4.0.4-dev.1` throws `InvalidTypeException: The type is invalid and cannot be converted to code` when a provider function returns `Stream<List<LocalMetricLog>>`. This is because `LocalMetricLog` is defined in `app_database.g.dart` (a `part of` file), and the generator cannot resolve the import path for code generation. Solution: use `StreamProvider.family<List<LocalMetricLog>, String>` directly instead of the `@riverpod` annotation.

3. **metric_logs sync uses created_at filter** — The Supabase `metric_logs` table has no `updated_at` column (it's an insert-only log table). Passing `since: null` to `_pullTable` skips the generic `updated_at >= since` filter; the `filter:` parameter applies `gte('created_at', lastSync)` instead.

4. **logged_at as YYYY-MM-DD** — Supabase `metric_logs.logged_at` is a `date` column (not `timestamptz`). Sending a full ISO-8601 datetime string causes a Postgres type cast error. The payload serializes `loggedAt` as `'YYYY-MM-DD'` using `padLeft` string formatting.

5. **Wave 0 test stubs as prerequisite** — Plan 06-01 was not executed before 06-02. Applied Deviation Rule 3: created Wave 0 test stubs (metric_delta_test, metric_repository_test, offline_metric_sync_test, metric_log_bottom_sheet_test, progress_screen_test) as part of this plan before implementing production code.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Plan 06-01 Wave 0 test stubs not executed**
- **Found during:** Task 1 start — test files referenced in 06-02 plan didn't exist
- **Issue:** Plan 06-02 depended on Wave 0 test stubs from 06-01 that had not been run
- **Fix:** Created all 6 Wave 0 test files (5 new + 1 extended) before implementing production code
- **Files modified:** streak_test.dart, metric_delta_test.dart, metric_repository_test.dart, offline_metric_sync_test.dart, metric_log_bottom_sheet_test.dart, progress_screen_test.dart
- **Commit:** d268580

**2. [Rule 1 - Bug] metricLogsByType provider cannot use @riverpod annotation**
- **Found during:** Task 2 code generation
- **Issue:** `riverpod_generator` throws `InvalidTypeException` when provider return type is `Stream<List<LocalMetricLog>>` (Drift-generated type not resolvable by code generator)
- **Fix:** Used manual `StreamProvider.family<List<LocalMetricLog>, String>` instead of `@riverpod` annotation for the stream provider
- **Files modified:** metric_providers.dart
- **Commit:** ba8ccdf

**3. [Rule 3 - Blocking] Plan files not in worktree**
- **Found during:** Plan start — .planning/phases/06-us4-metrics-progress/ directory didn't exist in worktree
- **Issue:** Worktree is based on main (2e97237), but plan files were on feat/phase-6-metrics-progress branch
- **Fix:** Copied plan files from feat/phase-6-metrics-progress branch using `git show`
- **Files modified:** .planning/phases/06-us4-metrics-progress/06-01-PLAN.md, 06-02-PLAN.md, 06-CONTEXT.md, 06-RESEARCH.md
- **Commit:** d268580

## Test Results

| Suite | Tests | Status |
|-------|-------|--------|
| streak_test.dart (both groups) | 14 | PASS |
| metric_delta_test.dart | 5 | PASS |
| metric_repository_test.dart | 3 | PASS |
| offline_metric_sync_test.dart | 1 | PASS |
| All unit tests (test/unit/) | 68 | PASS |
| flutter analyze lib/features/metrics/ + sync_service + streak_calculator | — | No issues |

## Known Stubs

The widget test files (`metric_log_bottom_sheet_test.dart`, `progress_screen_test.dart`) import classes that do not yet exist (`MetricLogBottomSheet`, `ProgressScreen`). These will fail to compile until Plan 03 creates those widgets. This is intentional Wave 0 behavior.

## Self-Check: PASSED

Files created:
- mobile/lib/features/metrics/domain/metric_delta.dart — FOUND
- mobile/lib/features/metrics/data/metric_repository.dart — FOUND
- mobile/lib/features/metrics/data/metric_providers.dart — FOUND
- mobile/lib/features/metrics/data/metric_providers.g.dart — FOUND
- mobile/test/unit/features/metrics/metric_delta_test.dart — FOUND
- mobile/test/unit/features/metrics/metric_repository_test.dart — FOUND
- mobile/test/unit/features/metrics/offline_metric_sync_test.dart — FOUND
- mobile/test/widget/metric_log_bottom_sheet_test.dart — FOUND
- mobile/test/widget/progress_screen_test.dart — FOUND

Files modified:
- mobile/pubspec.yaml contains fl_chart: ^1.2.0 — FOUND
- streak_calculator.dart contains computeLongestStreak — FOUND
- sync_service.dart contains metric_logs pull block — FOUND
- streak_test.dart contains computeLongestStreak group — FOUND

Commits:
- d268580 — FOUND (Task 1)
- ba8ccdf — FOUND (Task 2)
