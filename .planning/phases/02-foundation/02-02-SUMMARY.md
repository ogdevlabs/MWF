---
plan: 02-02
phase: 2
subsystem: mobile/core
tags: [drift, sqlite, riverpod, supabase, offline-first]
dependency_graph:
  requires: [02-01]
  provides: [mobile/lib/core/database/tables/*.dart, mobile/lib/core/network/supabase_client.dart]
  affects: [02-03-app-database, 02-04-daos, 02-05-auth, 02-06-sync]
tech_stack:
  added: []
  patterns: [Drift Table extends, Drift primaryKey override, Riverpod keepAlive, Supabase.instance.client]
key_files:
  created:
    - mobile/lib/core/database/tables/programs_table.dart
    - mobile/lib/core/database/tables/sessions_table.dart
    - mobile/lib/core/database/tables/exercises_table.dart
    - mobile/lib/core/database/tables/enrollments_table.dart
    - mobile/lib/core/database/tables/progress_records_table.dart
    - mobile/lib/core/database/tables/metric_logs_table.dart
    - mobile/lib/core/database/tables/feedback_threads_table.dart
    - mobile/lib/core/database/tables/sync_queue_table.dart
    - mobile/lib/core/database/tables/download_manifest_table.dart
    - mobile/lib/core/network/supabase_client.dart
  modified:
    - mobile/lib/main.dart
decisions:
  - "SyncQueue column getter named targetTable (not tableName_) with .named('table_name') — avoids Drift Table.tableName getter conflict"
  - "DownloadManifest uses text PK on exerciseId — exerciseId uniquely identifies each manifest entry"
  - "LocalExercises includes localVideoPath and localModelPath as nullable text columns — mirrors offline download strategy"
  - "Supabase provider uses @Riverpod(keepAlive: true) — client must survive full app lifecycle"
metrics:
  duration: "2m"
  completed_date: "2026-05-26"
  tasks_completed: 2
  files_created: 10
  files_modified: 1
---

# Phase 2 Plan 2: Drift Table Definitions + Supabase Client Provider Summary

**One-liner:** 9 Drift SQLite table classes + Supabase keepAlive Riverpod provider, with SyncQueue tableName conflict resolved via `.named('table_name')`.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create all 9 Drift table definitions (T016-T024) | bd7d6df | 9 table files under mobile/lib/core/database/tables/ |
| 2 | Create Supabase client Riverpod provider (T033) | 6ea4f0a | mobile/lib/core/network/supabase_client.dart, mobile/lib/main.dart |

## What Was Built

### Drift Table Definitions (T016-T024)

Nine table classes were created under `mobile/lib/core/database/tables/`, each extending Drift's `Table` base class and mirroring the corresponding Supabase PostgreSQL schema for offline-first operation:

- **LocalPrograms** (`local_programs`) — mirrors `programs` table; all UUIDs as TEXT
- **LocalSessions** (`local_sessions`) — mirrors `sessions` table
- **LocalExercises** (`local_exercises`) — mirrors `exercises` + adds `localVideoPath` and `localModelPath` nullable text columns for offline media
- **LocalEnrollments** (`local_enrollments`) — mirrors `enrollments` table
- **LocalProgressRecords** (`local_progress_records`) — mirrors `progress_records` table
- **LocalMetricLogs** (`local_metric_logs`) — mirrors `metric_logs` with `RealColumn` for numeric value
- **LocalFeedbackThreads** (`local_feedback_threads`) — mirrors `feedback_threads` (private DM, no cross-student access)
- **SyncQueue** (`sync_queue`) — autoincrement integer PK; `targetTable` getter uses `.named('table_name')` to avoid Drift getter name conflict
- **DownloadManifest** (`download_manifest`) — text PK on `exerciseId`; integer columns for timestamps and `downloadedAt`

### Supabase Client Provider (T033)

`mobile/lib/core/network/supabase_client.dart` created with:
- `@Riverpod(keepAlive: true)` annotation — provider persists for app lifetime
- Returns `Supabase.instance.client` — accesses the singleton initialized in `main()`
- `part 'supabase_client.g.dart'` directive for code generation in Wave 3

### main.dart Update

- Added `import 'package:supabase_flutter/supabase_flutter.dart'`
- Uncommented `Supabase.initialize()` with `String.fromEnvironment('SUPABASE_URL')` and `String.fromEnvironment('SUPABASE_ANON_KEY')`

## Decisions Made

1. **SyncQueue column naming:** The plan specified `targetTable` getter with `.named('table_name')` (not `tableName_` as shown in the RESEARCH.md pattern). The PLAN.md version was used — avoids any visual confusion between the SQL name and the Dart getter name.

2. **DownloadManifest integer timestamps:** `downloadedAt` is `integer().nullable()()` (Unix timestamp) matching the data-model.md spec. Same for `SyncQueue.createdAt`. This differs from other tables that use `dateTime()` — intentional for sync queue and download tracking where Unix timestamps are more practical.

3. **No `onDispose` in Supabase provider:** The Supabase client is a long-lived external singleton; calling `.close()` on it would break the app. The provider simply reads the already-initialized instance.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

- `mobile/lib/core/network/supabase_client.g.dart` — does not exist yet; generated by `build_runner` in Wave 3 (Plan 02-03+). This is intentional and expected at this stage.

## Self-Check: PASSED

- [x] 9 dart files exist in `mobile/lib/core/database/tables/`
- [x] `sync_queue_table.dart` contains `.named('table_name')` on `targetTable`
- [x] `download_manifest_table.dart` has `primaryKey => {exerciseId}`
- [x] `exercises_table.dart` has `localVideoPath` and `localModelPath`
- [x] `supabase_client.dart` has `@Riverpod(keepAlive: true)` and `part` directive
- [x] `main.dart` has `Supabase.initialize(...)` uncommented with `String.fromEnvironment`
- [x] Commit bd7d6df exists (Task 1)
- [x] Commit 6ea4f0a exists (Task 2)
