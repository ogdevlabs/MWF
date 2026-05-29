---
phase: 05-us3-offline-first
plan: "04"
subsystem: session-download-ui
tags: [offline-first, download-state, riverpod, flutter, widget]
dependency_graph:
  requires: ["05-02", "05-03"]
  provides: ["session-download-badge-ui", "offline-guard-tile", "program-detail-download-wiring"]
  affects: ["session-list-tile", "program-detail-screen"]
tech_stack:
  added: []
  patterns:
    - "SessionDownloadState.derive() — pure static function in domain layer for testability"
    - "Fake stub over Mock for PostgrestFilterBuilder (Future-implementing class)"
    - "connectivityProvider (Riverpod 4.x drops Notifier suffix from generated name)"
    - "dlStateAsync.value (not .valueOrNull — Riverpod 3.x removed .valueOrNull)"
key_files:
  created:
    - mobile/lib/features/session/domain/session_download_state.dart
    - mobile/lib/features/session/data/download_state_provider.dart
    - mobile/lib/features/session/data/download_state_provider.g.dart
    - mobile/test/unit/features/session/session_download_state_test.dart
    - mobile/test/widget/session_list_tile_download_test.dart
    - mobile/test/unit/features/session/offline_sync_integration_test.dart
  modified:
    - mobile/lib/features/session/presentation/session_list_tile.dart
    - mobile/lib/features/programs/presentation/program_detail_screen.dart
decisions:
  - "SessionDownloadState placed in domain/ not data/ — pure derivation logic, no Riverpod dependency; tests import from domain"
  - "SessionDownloadState.derive() static method mirrors watchAllEntries() filtering: vacuous guard when relevant.isEmpty"
  - "connectivityProvider (not connectivityNotifierProvider) — Riverpod 4.x drops Notifier suffix from generated name"
  - "dlStateAsync.value (not .valueOrNull) — Riverpod 3.x removed .valueOrNull"
  - "Fake stub (_FakeQueryBuilder) for PostgrestFilterBuilder — mocktail thenReturn fails for Future-implementing classes"
  - "session_download_state_test uses watchAllEntries().first for inProgress scenario — matches provider's actual query pattern"
metrics:
  duration: "469s (~8min)"
  completed_date: "2026-05-28"
  tasks: 2
  files: 8
---

# Phase 05 Plan 04: Session Download Badge UI and Offline Guard Summary

SessionDownloadState enum with reactive Riverpod stream provider, SessionListTile download badge + offline guard, and ProgramDetailScreen wiring with connectivity.

## Tasks Completed

| # | Name | Commit | Files |
|---|------|--------|-------|
| 1 | SessionDownloadState + provider + SessionListTile badge | 5aa4d9c | session_download_state.dart, download_state_provider.dart, session_list_tile.dart, 2 test files |
| 2 | Wire download state + connectivity into ProgramDetailScreen | 91d5322 | program_detail_screen.dart, offline_sync_integration_test.dart |

## Decisions Made

1. **SessionDownloadState in domain layer** — placed in `features/session/domain/` (not `data/`) so the pure derivation logic has no Riverpod dependency. The `data/download_state_provider.dart` imports from the domain and re-exports for convenience.

2. **connectivityProvider vs connectivityNotifierProvider** — plan spec used `connectivityNotifierProvider` but Riverpod 4.x drops the `Notifier` suffix from generated provider names. Used `connectivityProvider` (matches STATE.md decision from Phase 02).

3. **AsyncValue.value vs .valueOrNull** — Riverpod 3.x removed `.valueOrNull`. Used `.value` instead (returns null for loading/error, which is the desired behavior for nullable `SessionDownloadState?`).

4. **Fake stub for PostgrestFilterBuilder** — `PostgrestFilterBuilder<T>` implements `Future<T>`, causing mocktail's `thenReturn` to throw. Used `Fake` class (`_FakeQueryBuilder`) with manual `upsert()` override and a `_CompletedFilterBuilder` that implements `Future.then()` directly. Also used `thenAnswer((_) => fakeQueryBuilder)` instead of `thenReturn`.

5. **session_download_state_test inProgress scenario** — original Wave 0 stub combined `getCompletedDownloads() + getPendingDownloads()` which would miss `in_progress` status entries. Updated to use `watchAllEntries().first` — matching how the Riverpod provider actually queries the DAO.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing functionality] connectivityProvider name correction**
- **Found during:** Task 2
- **Issue:** Plan spec used `connectivityNotifierProvider` but generated name is `connectivityProvider`
- **Fix:** Used `connectivityProvider` per existing codebase conventions (STATE.md)
- **Files modified:** `program_detail_screen.dart`
- **Commit:** 91d5322

**2. [Rule 1 - Bug] valueOrNull not available in Riverpod 3.x**
- **Found during:** Task 2
- **Issue:** `AsyncValue.valueOrNull` doesn't exist in Riverpod 3.x
- **Fix:** Used `.value` instead which returns null for loading/error states
- **Files modified:** `program_detail_screen.dart`
- **Commit:** 91d5322

**3. [Rule 1 - Bug] session_download_state_test inProgress scenario wrong DAO method**
- **Found during:** Task 1 test implementation
- **Issue:** Wave 0 stub combined `getCompletedDownloads() + getPendingDownloads()` — `getPendingDownloads()` fetches `pending` status (not `in_progress`), so the seeded `in_progress` entry was invisible in `combined`
- **Fix:** Updated test to use `watchAllEntries().first` which mirrors the provider's actual query
- **Files modified:** `session_download_state_test.dart`
- **Commit:** 5aa4d9c

**4. [Rule 1 - Bug] Fake stub required for PostgrestFilterBuilder mock**
- **Found during:** Task 2
- **Issue:** `thenReturn` fails when mock returns Future-implementing class; `PostgrestFilterBuilder` implements `Future<T>`
- **Fix:** Created `_FakeQueryBuilder` and `_CompletedFilterBuilder` using `Fake` + manual method overrides; used `thenAnswer` instead of `thenReturn`
- **Files modified:** `offline_sync_integration_test.dart`
- **Commit:** 91d5322

## Test Results

| Suite | Tests | Status |
|-------|-------|--------|
| session_download_state_test.dart | 4 | PASS |
| session_list_tile_download_test.dart | 6 | PASS |
| offline_sync_integration_test.dart | 2 | PASS |
| All session unit + widget tests | 37 | PASS |
| flutter analyze lib/features/ | — | No issues |

## Known Stubs

None — all production code and tests are wired with real data sources.

## Self-Check: PASSED

Files created:
- mobile/lib/features/session/domain/session_download_state.dart — FOUND
- mobile/lib/features/session/data/download_state_provider.dart — FOUND
- mobile/test/unit/features/session/session_download_state_test.dart — FOUND
- mobile/test/widget/session_list_tile_download_test.dart — FOUND
- mobile/test/unit/features/session/offline_sync_integration_test.dart — FOUND

Commits:
- 5aa4d9c — FOUND (Task 1)
- 91d5322 — FOUND (Task 2)
