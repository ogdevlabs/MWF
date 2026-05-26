---
phase: 2
plan: "02-06"
subsystem: sync/cqrs
tags: [sync, cqrs, offline-first, riverpod, supabase, drift]
dependency_graph:
  requires: ["02-04", "02-05"]
  provides: ["SyncService", "CommandBus", "QueryGateway"]
  affects: ["all feature phases"]
tech_stack:
  added: []
  patterns:
    - "CQRS command/query segregation"
    - "Offline-first via SyncQueue write path"
    - "Incremental sync via updated_at timestamp filtering"
    - "Connectivity-triggered background sync"
key_files:
  created:
    - mobile/lib/core/sync/sync_service.dart
    - mobile/lib/core/cqrs/command_bus.dart
    - mobile/lib/core/cqrs/query_gateway.dart
  modified: []
decisions:
  - "ConnectivityNotifier state is bool (true=online); transition detection uses previous==false && next==true"
  - "QueryGateway is auto-dispose (not keepAlive) so it recomputes when connectivity changes"
  - "_pullTable uses dynamic query type to avoid complex PostgrestFilterBuilder generics"
metrics:
  duration: "~15 minutes"
  completed: "2026-05-25"
  tasks_completed: 3
  tasks_total: 3
  files_created: 3
  files_modified: 0
---

# Phase 2 Plan 06: SyncService + CommandBus + QueryGateway Summary

## One-liner

Offline-first CQRS architecture complete: SyncService pull/push orchestration, CommandBus routing typed commands to sync_queue, QueryGateway reading Supabase projection views with Drift fallback.

## What Was Built

### Task 1 — SyncService (T037) [commit: db44e7d]

`mobile/lib/core/sync/sync_service.dart`

- `SyncService` class with `sync()` returning `SyncResult(pulled, pushed, skipped)`
- `_isSyncing` boolean guard prevents concurrent sync cycles
- `_pullRemoteChanges()` fetches from 6 Supabase tables (programs, sessions, exercises, enrollments, progress_records, feedback_threads) using `updated_at >= lastSync` incremental filter
- Each table pull wrapped in try/catch — one table failure does not abort the full cycle
- `syncQueue.processQueue()` call handles the push phase
- Last sync timestamp persisted in `SharedPreferences` under key `last_sync_timestamp`
- `@Riverpod(keepAlive: true)` provider wires `ref.listen(connectivityNotifierProvider)` to call both `service.sync()` and `ref.read(downloadServiceProvider).resumeQueue()` on offline->online transition

### Task 2 — CommandBus (T133) [commit: 39a89fd]

`mobile/lib/core/cqrs/command_bus.dart`

- `CommandType` enum: `completeSession`, `logMetric`, `submitFeedback`, `enrollProgram`
- `CommandBus.dispatch(CommandType, Map<String, dynamic>)` enqueues to `SyncQueue`, never imports or calls `SupabaseClient`
- `_resolveTable` and `_resolveOperation` kept separate for extensibility when update/delete commands are added in feature phases
- Table mapping: completeSession→progress_records, logMetric→metric_logs, submitFeedback→feedback_threads, enrollProgram→enrollments
- `@Riverpod(keepAlive: true)` provider

### Task 3 — QueryGateway (T134) [commit: e7154da]

`mobile/lib/core/cqrs/query_gateway.dart`

- `QueryGateway` with 5 read methods matching projection views from `003_cqrs_read_models.sql`:
  - `getProgramCatalog()` → `program_catalog_view` / local Drift fallback
  - `getTodaySession()` → `student_today_session_view`
  - `getSessionPlayback(sessionId)` → `session_playback_view`
  - `getProgressDashboard()` → `student_progress_dashboard_view`
  - `getNotifications()` → `student_notifications_view`
- Online methods try Supabase first, fall back to local Drift DAOs on exception or when offline
- `@riverpod` (auto-dispose) provider — recreated when `connectivityNotifierProvider` changes

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] ConnectivityNotifier bool state transition**

- **Found during:** Task 1
- **Issue:** Plan code used `previous.isOffline` and `!next.isOffline` but `ConnectivityNotifier` state is a plain `bool` (true=online), not an object with `.isOffline`
- **Fix:** Replaced with `previous == false` (was offline) and `next` (is now online)
- **Files modified:** mobile/lib/core/sync/sync_service.dart
- **Commit:** db44e7d

**2. [Rule 1 - Bug] _pullTable generic type simplification**

- **Found during:** Task 1
- **Issue:** Plan used `PostgrestFilterBuilder Function(PostgrestFilterBuilder query)? filter` but the Supabase Flutter SDK's `select()` returns a chained builder type not easily typed as `PostgrestFilterBuilder` in that position. Using `dynamic` avoids incorrect type annotations that would fail at compile time.
- **Fix:** Typed `_pullTable` filter parameter as `dynamic Function(dynamic query)?` and `query` as `dynamic`
- **Files modified:** mobile/lib/core/sync/sync_service.dart
- **Commit:** db44e7d

## Known Stubs

None — all three classes are fully wired. The `resumeQueue()` method in `DownloadService` has a placeholder body (from Plan 02-05), but that is pre-existing and outside this plan's scope.

## Commits

| Hash | Message |
|------|---------|
| db44e7d | feat(02-06): add SyncService orchestrator (T037) |
| 39a89fd | feat(02-06): add CommandBus CQRS write dispatcher (T133) |
| e7154da | feat(02-06): add QueryGateway CQRS read path (T134) |

## Self-Check: PASSED

- mobile/lib/core/sync/sync_service.dart — FOUND
- mobile/lib/core/cqrs/command_bus.dart — FOUND
- mobile/lib/core/cqrs/query_gateway.dart — FOUND
- Commit db44e7d — FOUND
- Commit 39a89fd — FOUND
- Commit e7154da — FOUND
