---
phase: "06"
plan: "01"
name: "Metrics domain model + repository + progress dashboard"
subsystem: "mobile/features/metrics"
tags: [metrics, progress, charts, offline-first, fl_chart]
dependency_graph:
  requires: [core/database/daos/metric_logs_dao, core/cqrs/command_bus, features/session/data/streak_calculator]
  provides: [features/metrics/domain/MetricLog, features/metrics/data/MetricsRepository, features/metrics/presentation/ProgressScreen, features/metrics/presentation/LogMetricSheet]
  affects: [features/session/presentation/SessionCompletionScreen, shared/router/app_router]
tech_stack:
  added: [fl_chart 0.69.2]
  patterns: [offline-first write (Drift + CommandBus), Freezed domain model, reactive Riverpod stream provider, fl_chart LineChart]
key_files:
  created:
    - mobile/lib/features/metrics/domain/metric_log_model.dart
    - mobile/lib/features/metrics/domain/metric_log_model.freezed.dart
    - mobile/lib/features/metrics/domain/metric_log_model.g.dart
    - mobile/lib/features/metrics/data/metrics_repository.dart
    - mobile/lib/features/metrics/data/metrics_repository.g.dart
    - mobile/lib/features/metrics/presentation/log_metric_sheet.dart
    - mobile/lib/features/metrics/presentation/progress_screen.dart
    - mobile/test/unit/features/metrics/metrics_repository_test.dart
    - .planning/phases/06-us4-metrics-progress/06-01-PLAN.md
  modified:
    - mobile/lib/features/session/data/streak_calculator.dart (added computeLongestStreak)
    - mobile/lib/features/session/presentation/session_completion_screen.dart (Log Metrics prompt)
    - mobile/lib/shared/router/app_router.dart (/progress -> ProgressScreen)
    - mobile/pubspec.yaml (fl_chart 0.69.0)
decisions:
  - "fl_chart 0.69.2 used (resolved to latest compatible version during pub get)"
  - "studentId is optional on SessionCompletionScreen to preserve backward compatibility with existing router usage"
  - "computeLongestStreak added to streak_calculator.dart alongside existing computeCurrentStreak for co-location"
  - "ProgressScreen reads studentId from currentUserProvider — no prop drilling needed"
  - "LogMetricSheet uses Drift + CommandBus directly via metricsRepositoryProvider (offline-safe)"
metrics:
  duration: "435s"
  completed_date: "2026-05-29"
  tasks: 7
  files: 13
---

# Phase 6 Plan 1: Metrics domain model + repository + progress dashboard Summary

**One-liner**: Offline-first body metric logging with Drift + CommandBus dispatch, fl_chart line trends, and progress dashboard showing current/longest streaks.

## What Was Built

### MetricLog Freezed domain model
`mobile/lib/features/metrics/domain/metric_log_model.dart`

Freezed + JSON serializable model with `fromDrift(LocalMetricLog)` factory. Covers weight / measurement / flexibility metric types with optional subtype (waist, hip, shoulder).

### MetricsRepository + Riverpod providers
`mobile/lib/features/metrics/data/metrics_repository.dart`

Offline-first write: writes to local Drift immediately, then enqueues `CommandType.logMetric` to CommandBus for eventual Supabase sync. Exposes:
- `logMetric(...)` — write entry
- `watchMetrics(studentId, metricType)` — reactive stream for UI
- `getMetrics(studentId, metricType)` — one-shot future

Riverpod providers: `metricsRepositoryProvider`, `metricLogsStreamProvider(studentId, metricType)`.

### LogMetricSheet
`mobile/lib/features/metrics/presentation/log_metric_sheet.dart`

Modal bottom sheet with:
- SegmentedButton: Weight / Measurement / Flexibility
- FilterChip subtype selector (waist / hip / shoulder) for measurements
- Numeric value input with decimal validation
- Unit label auto-set by type (kg / cm / degrees)
- DatePicker row defaulting to today
- Save FilledButton — offline-safe, no network error UI

### ProgressScreen
`mobile/lib/features/metrics/presentation/progress_screen.dart`

Progress dashboard replacing the placeholder route at `/progress`:
- Streak card: current streak + longest streak (via `computeCurrentStreak` + `computeLongestStreak`)
- Metric type SegmentedButton selector
- fl_chart `LineChart` of selected metric over time (X = day offset, Y = value)
- Delta badge: "+X.X kg since start" / "-X.X kg since start"
- FAB to open LogMetricSheet

### computeLongestStreak
`mobile/lib/features/session/data/streak_calculator.dart`

Added `computeLongestStreak(List<DateTime>)` alongside existing `computeCurrentStreak` — finds the longest consecutive calendar day run in completion history.

### Session Completion "Log Today's Metrics" prompt
`mobile/lib/features/session/presentation/session_completion_screen.dart`

Added optional `studentId` parameter to `SessionCompletionScreen`. When provided, shows a non-blocking "Log Today's Metrics" `OutlinedButton.icon` that opens `LogMetricSheet` as a modal sheet. "Back to Program" unchanged.

### Router
`mobile/lib/shared/router/app_router.dart`

`/progress` route now builds `ProgressScreen` instead of `_PlaceholderScreen`.

## Test Coverage

`mobile/test/unit/features/metrics/metrics_repository_test.dart` — 5 tests:
1. `logMetric writes entry to local Drift`
2. `logMetric dispatches logMetric command to CommandBus`
3. `getMetrics returns only entries matching requested metric_type`
4. `watchMetrics emits updated list when new entry inserted`
5. `logMetric stores metricSubtype when provided`

Full test suite: **67 tests pass**, 1 skipped (live Supabase integration).

## Commits

| Hash | Message |
|------|---------|
| a0ffb83 | chore(06-01): add fl_chart 0.69.2 dependency for metric trend charts |
| 5908e3c | feat(06-01): MetricLog Freezed domain model with fromDrift factory |
| 7273430 | feat(06-01): MetricsRepository with offline-first log + reactive stream provider |
| 6909159 | feat(06-01): LogMetricSheet modal with type selector, value input, date picker |
| 86e3349 | feat(06-01): ProgressScreen with streak card + fl_chart metric trend; wire /progress route |
| 806b8c8 | feat(06-01): add non-blocking Log Metrics prompt to SessionCompletionScreen |
| 4fb1307 | test(06-01): add 5 MetricsRepository unit tests covering CRUD + reactive stream |

## Deviations from Plan

### Auto-fixed Issues

None — plan executed exactly as written, with one minor fix:

**1. [Rule 1 - Lint] Fixed unnecessary_underscores in progress_screen.dart error handler**
- **Found during:** Task 5 analyze pass
- **Issue:** `(_, __)` triggers `unnecessary_underscores` lint
- **Fix:** Changed to `(err, st)` parameter names
- **Files modified:** `mobile/lib/features/metrics/presentation/progress_screen.dart`
- **Commit:** 86e3349

## Known Stubs

None — all metric data flows from real Drift queries. ProgressScreen reads live data via `metricLogsStreamProvider` and `progressDao.getProgressByStudent`. Empty states show appropriate "no data" UI.

## Self-Check: PASSED

Files exist:
- mobile/lib/features/metrics/domain/metric_log_model.dart ✓
- mobile/lib/features/metrics/domain/metric_log_model.freezed.dart ✓
- mobile/lib/features/metrics/data/metrics_repository.dart ✓
- mobile/lib/features/metrics/presentation/log_metric_sheet.dart ✓
- mobile/lib/features/metrics/presentation/progress_screen.dart ✓
- mobile/test/unit/features/metrics/metrics_repository_test.dart ✓

Commits verified: a0ffb83, 5908e3c, 7273430, 6909159, 86e3349, 806b8c8, 4fb1307 all present in git log.
