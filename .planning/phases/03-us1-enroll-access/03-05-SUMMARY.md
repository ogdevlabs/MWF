---
phase: 03-us1-enroll-access
plan: "05"
subsystem: programs-feature-layer
tags: [programs, freezed, cqrs, offline-first, enrollment, riverpod]
dependency_graph:
  requires: [03-01, 03-04]
  provides: [ProgramModel, ProgramsRepository, programsListProvider, programsRemoteDatasourceProvider, programsLocalDatasourceProvider]
  affects: [UI programs screens (Wave 6)]
tech_stack:
  added: [uuid ^4.5.1]
  patterns: [freezed domain model, CQRS QueryGateway read, CommandBus write, remote-first with local fallback]
key_files:
  created:
    - mobile/lib/features/programs/domain/program_model.dart
    - mobile/lib/features/programs/domain/program_model.freezed.dart
    - mobile/lib/features/programs/domain/program_model.g.dart
    - mobile/lib/features/programs/data/programs_remote_datasource.dart
    - mobile/lib/features/programs/data/programs_remote_datasource.g.dart
    - mobile/lib/features/programs/data/programs_local_datasource.dart
    - mobile/lib/features/programs/data/programs_local_datasource.g.dart
    - mobile/lib/features/programs/data/programs_repository.dart
    - mobile/lib/features/programs/data/programs_repository.g.dart
  modified:
    - mobile/pubspec.yaml (added uuid ^4.5.1)
    - mobile/pubspec.lock
decisions:
  - "uuid package added to pubspec (was missing, needed for enrollment ID generation)"
  - "LocalProgramsCompanion.cacheProgram supplies createdAt/updatedAt = DateTime.now() to satisfy non-nullable table columns"
  - "ProgramModel.fromCatalogRow maps program_catalog_view keys (published_at not published) matching QueryGateway output"
metrics:
  duration: "~205 seconds"
  completed_date: "2026-05-26"
  tasks_completed: 2
  files_created: 9
  files_modified: 2
---

# Phase 03 Plan 05: Programs Feature Layer Summary

Freezed ProgramModel + CQRS-wired datasources + enrollment repository with remote-first offline fallback via QueryGateway and CommandBus.

## What Was Built

### Task 1: ProgramModel + Datasources

**ProgramModel** (`domain/program_model.dart`):
- Freezed abstract class with all `program_catalog_view` fields: id, title, description, difficulty, durationWeeks, thumbnailUrl, publishedAt, enrollmentId, currentDay, isSubscribed
- `fromCatalogRow()` factory maps raw QueryGateway map rows with null-safe defaults
- `ProgramAccessState` extension adds `isEnrolled`, `isLocked`, `canAccess` computed getters

**ProgramsRemoteDatasource** (`data/programs_remote_datasource.dart`):
- Wraps `QueryGateway.getProgramCatalog()` — no direct Supabase calls
- Maps rows via `ProgramModel.fromCatalogRow()`
- `programsRemoteDatasourceProvider` via `@riverpod`

**ProgramsLocalDatasource** (`data/programs_local_datasource.dart`):
- Reads/caches via `ProgramsDao.getAllPrograms()` / `upsertProgram()`
- `getCachedPrograms()`, `cacheProgram()`, `cachePrograms()`, `watchCachedPrograms()`
- Supplies `createdAt`/`updatedAt` = `DateTime.now()` on cache writes (table requires these)
- `programsLocalDatasourceProvider` via `@riverpod`

### Task 2: ProgramsRepository + programsListProvider

**ProgramsRepository** (`data/programs_repository.dart`):
- Remote-first: fetches from QueryGateway, caches locally on success
- Offline fallback: serves cached programs + overlays `subscription_is_active` from SharedPreferences
- `enrollStudent()`: writes `LocalEnrollmentsCompanion` to Drift immediately, then dispatches `CommandType.enrollProgram` via CommandBus
- `getProgramById()`, `isEnrolled()` helpers
- `programsRepositoryProvider` + `programsListProvider` (FutureProvider)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added uuid package to pubspec.yaml**
- **Found during:** Task 2 preparation (before creating repository file)
- **Issue:** `programs_repository.dart` uses `const Uuid().v4()` for enrollment ID generation but `uuid` was not listed in pubspec.yaml
- **Fix:** Added `uuid: ^4.5.1` to dependencies, ran `flutter pub get`
- **Files modified:** `mobile/pubspec.yaml`, `mobile/pubspec.lock`
- **Commit:** 54e0dfa

**2. [Rule 1 - Bug] Supply createdAt/updatedAt in cacheProgram**
- **Found during:** Task 1 code review
- **Issue:** `LocalPrograms` table has non-nullable `createdAt` and `updatedAt` columns with no SQL defaults; inserting without these values would fail at runtime
- **Fix:** `cacheProgram()` sets both to `DateTime.now()` on upsert
- **Files modified:** `mobile/lib/features/programs/data/programs_local_datasource.dart`
- **Commit:** 54e0dfa

## Verification Results

All plan verification checks pass:
- `grep -q "CommandType.enrollProgram"` — PASS
- `grep -q "enrollmentsDao.upsertEnrollment"` — PASS
- `grep -q "queryGatewayProvider"` — PASS
- `grep -q "fromCatalogRow"` — PASS
- `flutter analyze lib/features/programs/` — No issues found

## Known Stubs

None. All data flows are wired: QueryGateway for remote reads, ProgramsDao for local cache, EnrollmentsDao + CommandBus for enrollment writes.

## Self-Check: PASSED

Files verified:
- FOUND: mobile/lib/features/programs/domain/program_model.dart
- FOUND: mobile/lib/features/programs/domain/program_model.freezed.dart
- FOUND: mobile/lib/features/programs/data/programs_remote_datasource.dart
- FOUND: mobile/lib/features/programs/data/programs_local_datasource.dart
- FOUND: mobile/lib/features/programs/data/programs_repository.dart

Commits verified:
- FOUND: 54e0dfa (Task 1 — model + datasources)
- FOUND: bb43aba (Task 2 — repository + generated code)
