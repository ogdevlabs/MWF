---
phase: 5
slug: us3-offline-first
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-28
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) + mocktail 1.0.5 |
| **Config file** | none — standard `flutter test` discovery |
| **Quick run command** | `flutter test test/unit/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~45 seconds (38 existing tests + ~15 new) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/unit/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** ~45 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 5-01-01 | 01 | 0 | FR-006 D-04 | unit | `flutter test test/unit/core/downloads/storage_guard_test.dart` | ❌ W0 | ⬜ pending |
| 5-01-02 | 01 | 0 | FR-006 D-13 | unit | `flutter test test/unit/core/downloads/storage_guard_test.dart` | ❌ W0 | ⬜ pending |
| 5-01-03 | 01 | 0 | FR-006 D-15 | unit | `flutter test test/unit/core/sync/sync_service_stale_video_test.dart` | ❌ W0 | ⬜ pending |
| 5-01-04 | 01 | 0 | FR-006 D-07 | unit | `flutter test test/unit/features/session/session_download_state_test.dart` | ❌ W0 | ⬜ pending |
| 5-01-05 | 01 | 0 | FR-007 D-17 | unit | `flutter test test/unit/features/session/offline_sync_integration_test.dart` | ❌ W0 | ⬜ pending |
| 5-01-06 | 01 | 0 | FR-006 D-05 | widget | `flutter test test/widget/session_list_tile_download_test.dart` | ❌ W0 | ⬜ pending |
| 5-02-01 | 02 | 1 | FR-006 D-04 | unit | `flutter test test/unit/core/downloads/download_service_test.dart` | ✅ extend | ⬜ pending |
| 5-02-02 | 02 | 1 | FR-006 D-13 | unit | `flutter test test/unit/core/downloads/storage_guard_test.dart` | ❌ W0 | ⬜ pending |
| 5-03-01 | 03 | 1 | FR-007 D-03 | unit | `flutter test test/unit/core/sync/sync_service_stale_video_test.dart` | ❌ W0 | ⬜ pending |
| 5-03-02 | 03 | 1 | FR-007 D-18 | unit | `flutter test test/unit/core/sync/sync_queue_test.dart` | ✅ extend | ⬜ pending |
| 5-04-01 | 04 | 2 | FR-006 D-08 | unit | `flutter test test/unit/features/session/session_download_state_test.dart` | ❌ W0 | ⬜ pending |
| 5-04-02 | 04 | 2 | FR-007 D-17 | unit | `flutter test test/unit/features/session/offline_sync_integration_test.dart` | ❌ W0 | ⬜ pending |
| 5-05-01 | 05 | 2 | FR-006 D-05 | widget | `flutter test test/widget/session_list_tile_download_test.dart` | ❌ W0 | ⬜ pending |
| 5-05-02 | 05 | 2 | FR-006 D-11 | widget | `flutter test test/widget/session_list_tile_download_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/unit/core/downloads/storage_guard_test.dart` — stubs for FR-006 D-13 (threshold logic with injected freeSpaceProvider)
- [ ] `test/unit/core/sync/sync_service_stale_video_test.dart` — stubs for FR-006 D-15 (stale version detection + videoLocalPath clearing)
- [ ] `test/unit/features/session/session_download_state_test.dart` — stubs for FR-006 D-07 (all complete → downloaded, any in_progress → inProgress, none → notDownloaded)
- [ ] `test/unit/features/session/offline_sync_integration_test.dart` — stubs for FR-007 D-17 (offline completion → sync_queue → reconnect replay)
- [ ] `test/widget/session_list_tile_download_test.dart` — stubs for FR-006 D-05, D-11 (badge rendering + offline-unavailable state)

Existing files to extend (not Wave 0 gaps):
- `test/unit/core/downloads/download_service_test.dart` — add Wi-Fi flag assertion (D-04)
- `test/unit/core/sync/sync_queue_test.dart` — add dead-letter test (D-18) and FIFO ordering test

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Background download actually executes on device | FR-006 | `FileDownloader` uses platform channels; can't run in flutter_test | Run on iOS sim: enroll program on Wi-Fi, force-kill app, reopen — verify manifest shows 'complete' |
| Airplane mode offline playback | FR-006 US3-SC2 | Requires real device network toggle | Enable airplane mode after sync, open session, verify video plays from file:// URI |
| Reconnect sync visible in program calendar | FR-007 US3-SC1 | Requires real connectivity transition | Complete session offline, toggle airplane off, verify progress_records synced in Supabase |
| Storage guard SnackBar shown on low storage | FR-006 D-13 | dart:io free-space check is fail-open stub in Phase 5 | Manual test deferred to Phase 9 when real platform-channel check is added |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 45s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
