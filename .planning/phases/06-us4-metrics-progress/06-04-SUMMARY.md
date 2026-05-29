---
phase: "06-us4-metrics-progress"
plan: "04"
subsystem: "metrics-ui"
tags: ["flutter", "riverpod", "bottom-sheet", "offline-first", "metrics"]
dependency_graph:
  requires:
    - "06-02 (MetricRepository + metricRepositoryProvider)"
    - "06-03 (ProgressScreen with Log Metrics button)"
  provides:
    - "MetricLogBottomSheet widget (canonical, offline-first)"
    - "Session completion metric prompt (non-blocking)"
    - "Progress screen Log Metrics button wired to MetricLogBottomSheet"
  affects:
    - "session_completion_screen.dart"
    - "progress_screen.dart"
    - "metric_log_bottom_sheet_test.dart"
tech_stack:
  added: []
  patterns:
    - "ConsumerStatefulWidget with inline 'Log another' form reset (Pitfall 6 avoided)"
    - "metricRepositoryProvider.overrideWithValue in widget tests"
key_files:
  created:
    - "mobile/lib/features/metrics/presentation/metric_log_bottom_sheet.dart"
  modified:
    - "mobile/lib/features/metrics/presentation/progress_screen.dart"
    - "mobile/lib/features/session/presentation/session_completion_screen.dart"
    - "mobile/test/widget/metric_log_bottom_sheet_test.dart"
decisions:
  - "MetricLogBottomSheet created as new canonical file; log_metric_sheet.dart retained for backward compat with existing usages"
  - "widget test migrated from LogMetricSheet+appDatabaseProvider to MetricLogBottomSheet+metricRepositoryProvider.overrideWithValue"
  - "progress_screen: removed studentId param from _openLogSheet since MetricRepository injects studentId from Supabase auth"
  - "session_completion_screen: switched from LogMetricSheet(studentId:) to MetricLogBottomSheet() const"
metrics:
  duration: "165s"
  completed_date: "2026-05-29"
  tasks_completed: 2
  files_changed: 4
---

# Phase 6 Plan 4: MetricLogBottomSheet Wire-Up Summary

MetricLogBottomSheet ConsumerStatefulWidget with offline-first logMetric, inline "Log another" reset, and two screen entry points wired.

## Tasks Completed

| # | Task | Commit | Key Files |
|---|------|--------|-----------|
| 1 | Create MetricLogBottomSheet | 48c99bc | metric_log_bottom_sheet.dart (created) |
| 2 | Wire into SessionCompletion + ProgressScreen | 4a40b3f | session_completion_screen.dart, progress_screen.dart, metric_log_bottom_sheet_test.dart |

## What Was Built

**MetricLogBottomSheet** (`metric_log_bottom_sheet.dart`):
- `ConsumerStatefulWidget` using `metricRepositoryProvider` (canonical Plan-02 repository)
- Metric type `DropdownButtonFormField` with `weight`, `measurement`, `flexibility`
- Optional subtype `DropdownButtonFormField` for measurement (waist/hip/chest/thigh/arm) and flexibility (forward_bend/shoulder/hip_flexor)
- `TextFormField` for value with validator (must parse to double > 0)
- Date row with `showDatePicker` (defaults today, editable backwards up to 365 days)
- Inline "Log another" flow via `_formKey.currentState!.reset()` + `setState` — does NOT pop/re-show sheet (Pitfall 6 avoided per D-03)
- Success state shows "Metric logged!" with "Log another" TextButton + "Done" FilledButton
- Keyboard avoidance via `MediaQuery.of(context).viewInsets.bottom`

**SessionCompletionScreen** — switched import from `log_metric_sheet.dart` to `metric_log_bottom_sheet.dart`, updated `showModalBottomSheet` builder to use `const MetricLogBottomSheet()` (no studentId required).

**ProgressScreen** — removed stale `log_metric_sheet.dart` import, added `metric_log_bottom_sheet.dart` import, updated `_openLogSheet` to open `MetricLogBottomSheet` (removed unused `studentId` param).

**Widget test** — migrated from `LogMetricSheet(studentId: 'test-student')` + `appDatabaseProvider` override to `MetricLogBottomSheet()` + `metricRepositoryProvider.overrideWithValue(MetricRepository(...))` pattern for proper isolation.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] log_metric_sheet.dart used stale metricsRepositoryProvider**
- **Found during:** Task 1 (reading existing code before creating MetricLogBottomSheet)
- **Issue:** The Plan 06-01 `log_metric_sheet.dart` imported `metrics_repository.dart` (old Plan 01 dual-repository) and called `metricsRepositoryProvider` with an explicit `studentId` param. This bypassed the canonical Plan 02 `MetricRepository`.
- **Fix:** Created `metric_log_bottom_sheet.dart` with canonical `metricRepositoryProvider` (SyncQueue-based offline-first). Left `log_metric_sheet.dart` intact for backward compat (tests and usages still compile).
- **Files modified:** `metric_log_bottom_sheet.dart` (new), `progress_screen.dart`, `session_completion_screen.dart`
- **Commits:** 48c99bc, 4a40b3f

**2. [Rule 1 - Bug] widget test used wrong provider override pattern**
- **Found during:** Task 2
- **Issue:** `metric_log_bottom_sheet_test.dart` tested `LogMetricSheet(studentId:)` with only `appDatabaseProvider` override. After switching screens to use `MetricLogBottomSheet`, the test would fail because `metricRepositoryProvider` needs `syncQueueProvider` + `supabaseClientProvider` too.
- **Fix:** Updated test to mock `SyncQueue`, construct `MetricRepository` directly, and override `metricRepositoryProvider.overrideWithValue(...)`. Pattern matches `metric_repository_test.dart`.
- **Files modified:** `test/widget/metric_log_bottom_sheet_test.dart`
- **Commit:** 4a40b3f

## Test Results

```
flutter test test/unit/features/metrics/ test/widget/ --no-pub
All tests passed! (90 tests, 1 integration test skipped — requires live Supabase)
```

## Known Stubs

None — all data paths are wired. `MetricLogBottomSheet` calls `metricRepositoryProvider` → `MetricRepository.logMetric()` → Drift insert + SyncQueue enqueue.

## Self-Check: PASSED
