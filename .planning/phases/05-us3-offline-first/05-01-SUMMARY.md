---
phase: 05-us3-offline-first
plan: "01"
subsystem: testing
tags: [flutter, drift, mocktail, wave0-stubs, tdd, offline-first]

requires:
  - phase: 04-us2-session-player
    provides: SessionListTile, SessionModel, SessionState, AppDatabase with DownloadManifestDao

provides:
  - Wave 0 test stubs for Phase 5 offline-first features (5 files)
  - StorageGuard.hasEnoughSpace() stub method (injectable freeSpaceProvider)
  - SessionDownloadState enum stub with derive() placeholder
  - SessionListTile.downloadState and isOnline stub parameters for compilation
affects:
  - 05-us3-offline-first plans 02 through 04 (turn stubs green)

tech-stack:
  added: []
  patterns:
    - "Wave 0 skip stub: group(..., skip: 'Wave 0 stub — ...', () {...}) so flutter test exits 0 before production code exists"
    - "Injectable freeSpaceProvider: Future<int?> Function()? for platform-agnostic unit testing"
    - "FakeQuery pattern: implements Future<List<Map<String,dynamic>>> with fluent chain stubs for Supabase _pullTable"

key-files:
  created:
    - mobile/test/unit/core/downloads/storage_guard_test.dart
    - mobile/test/unit/core/sync/sync_service_stale_video_test.dart
    - mobile/test/unit/features/session/session_download_state_test.dart
    - mobile/test/unit/features/session/offline_sync_integration_test.dart
    - mobile/test/widget/session_list_tile_download_test.dart
    - mobile/lib/features/session/domain/session_download_state.dart
  modified:
    - mobile/lib/features/session/presentation/session_list_tile.dart

key-decisions:
  - "Wave 0 stubs use skip on the group() call so flutter test exits 0 — compilation requires production stubs to exist"
  - "SessionDownloadState stub enum created with unimplemented derive() — full implementation in Plan 05-03"
  - "SessionListTile.downloadState + isOnline added as optional stub params to enable widget test compilation"
  - "FakeSupabaseClient extends Fake pattern needed for Supabase chain stubs (dynamic return type incompatible with SupabaseClient.from())"
  - "storage_guard_test.dart linter rewrote to actual passing tests — StorageGuard stub was already created by Plan 05-02 parallel agent"

patterns-established:
  - "Wave 0 TDD stub: test file + skip + minimal production stub = red-green cycle ready"
  - "Injectable freeSpaceProvider for StorageGuard enables pure unit testing without platform channels"

requirements-completed: [FR-006, FR-007]

duration: 6min
completed: 2026-05-28
---

# Phase 5 Plan 01: Wave 0 TDD Test Stubs Summary

**5 Wave 0 test stub files for offline-first features — StorageGuard, stale video detection, SessionDownloadState derivation, offline sync replay, and download badge widget**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-05-28T23:27:26Z
- **Completed:** 2026-05-28T23:33:01Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Created 4 unit test stubs covering: StorageGuard thresholds, stale video manifest reset, SessionDownloadState derivation, and offline completion FIFO replay
- Created 1 widget test stub for SessionListTile download badge rendering and offline-unavailable state
- Added `SessionDownloadState` stub enum with unimplemented `derive()` so test files compile
- Added optional `downloadState` and `isOnline` params to `SessionListTile` for widget test compilation

## Task Commits

1. **Task 1: Unit test stubs (StorageGuard, stale video, download state, offline sync)** - `2f6462d` (test)
2. **Task 2: Widget test stub for SessionListTile download badge** - `c5f5a24` (test)

## Files Created/Modified

- `mobile/test/unit/core/downloads/storage_guard_test.dart` - StorageGuard.hasEnoughSpace tests with injectable freeSpaceProvider (3 passing tests — Plan 05-02 already shipped StorageGuard)
- `mobile/test/unit/core/sync/sync_service_stale_video_test.dart` - Stale video detection tests (skip group, Plan 05-02 target)
- `mobile/test/unit/features/session/session_download_state_test.dart` - SessionDownloadState derivation tests (skip group, Plan 05-03 target)
- `mobile/test/unit/features/session/offline_sync_integration_test.dart` - Offline sync FIFO queue replay tests (skip group)
- `mobile/test/widget/session_list_tile_download_test.dart` - Download badge icons and offline-unavailable tile tests (skip group, Plan 05-03 target)
- `mobile/lib/features/session/domain/session_download_state.dart` - Stub enum: downloaded/inProgress/notDownloaded with unimplemented derive()
- `mobile/lib/features/session/presentation/session_list_tile.dart` - Added downloadState? and isOnline stub params

## Decisions Made

- Wave 0 skip stubs: `group('...', skip: 'Wave 0 stub — ...', () {...})` pattern ensures `flutter test` exits 0 before production code exists, enabling TDD red-green cycle in Plans 02-04
- `StorageGuard` and `storage_guard_test.dart` were already created by the parallel Plan 05-02 agent — the linter rewrote storage_guard_test.dart to use actual tests (not skip), all 3 pass
- `FakeSupabaseClient extends Fake` approach needed for stale video tests — `dynamic` return type incompatible with `SupabaseClient.from()` return type `SupabaseQueryBuilder`, so skip is correct for Wave 0
- `SessionDownloadState` stub enum created in `session/domain/` so both the session_download_state_test.dart and session_list_tile_download_test.dart compile

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Created SessionDownloadState stub enum**
- **Found during:** Task 1 (session_download_state_test.dart compilation)
- **Issue:** Test imports `package:mwf_mobile/features/session/domain/session_download_state.dart` which didn't exist, causing compile error
- **Fix:** Created `session_download_state.dart` with stub `enum SessionDownloadState { downloaded, inProgress, notDownloaded }` and unimplemented `derive()` method
- **Files modified:** `mobile/lib/features/session/domain/session_download_state.dart` (created)
- **Verification:** All 4 unit test files compile and pass (skipped) after creation
- **Committed in:** `2f6462d` (Task 1 commit)

**2. [Rule 2 - Missing Critical] Added stub params to SessionListTile for widget test compilation**
- **Found during:** Task 2 (widget test compilation)
- **Issue:** `session_list_tile_download_test.dart` references `downloadState:` and `isOnline:` params that don't exist on `SessionListTile`
- **Fix:** Added optional `downloadState` and `isOnline` params to `SessionListTile` constructor (stub only — full implementation in Plan 05-03)
- **Files modified:** `mobile/lib/features/session/presentation/session_list_tile.dart`
- **Verification:** Widget test compiles and all 6 tests skip cleanly
- **Committed in:** `c5f5a24` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 missing critical)
**Impact on plan:** Both fixes required for Wave 0 compilation requirement. No scope creep — stubs are minimal and explicitly marked for implementation in Plans 02-04.

## Issues Encountered

- `FakeSupabaseClient` approach for sync_service_stale_video_test: `SupabaseClient.from()` returns `SupabaseQueryBuilder` (a concrete class with no public constructor), making it impossible to override with a custom type. Linter tried `dynamic` return — fails Dart type system. Skip annotation is the correct Wave 0 approach; real Supabase mocking will be done in Plan 05-02 using the existing `_pullTable` pattern.
- `StorageGuard` stub was already created by the Plan 05-02 parallel agent; linter removed skip from `storage_guard_test.dart` and the tests actually run and pass with the real implementation.

## Next Phase Readiness

- All 5 Wave 0 test files exist, compile, and `flutter test` exits 0
- Plans 05-02, 05-03, 05-04 can implement features and turn these stubs green
- `SessionDownloadState.derive()` stub ready to implement in Plan 05-03
- `SessionListTile` stub params ready for full download badge implementation in Plan 05-03

---
*Phase: 05-us3-offline-first*
*Completed: 2026-05-28*

## Self-Check: PASSED

- FOUND: mobile/test/unit/core/downloads/storage_guard_test.dart
- FOUND: mobile/test/unit/core/sync/sync_service_stale_video_test.dart
- FOUND: mobile/test/unit/features/session/session_download_state_test.dart
- FOUND: mobile/test/unit/features/session/offline_sync_integration_test.dart
- FOUND: mobile/test/widget/session_list_tile_download_test.dart
- FOUND: mobile/lib/features/session/domain/session_download_state.dart
- Commit 2f6462d: test(05-01): add Wave 0 unit test stubs for offline-first features
- Commit c5f5a24: test(05-01): add Wave 0 widget test stub for SessionListTile download badge
- Commit 58091f1: fix(05-01): lock stale video test to skip group
