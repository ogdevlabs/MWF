---
phase: 2
plan: "02-05"
subsystem: sync-and-downloads
tags: [sync-queue, download-service, offline-first, background-downloader, riverpod]
dependency_graph:
  requires: ["02-03"]
  provides: ["02-06"]
  affects: ["offline mutations", "exercise media downloads", "manifest tracking"]
tech_stack:
  added: []
  patterns: ["offline-first write queue", "FIFO retry with dead-letter", "relative-path download storage", "keepAlive Riverpod providers"]
key_files:
  created:
    - mobile/lib/core/sync/sync_queue.dart
    - mobile/lib/core/downloads/download_service.dart
  modified: []
decisions:
  - "Insert operations use upsert (not insert) for idempotent replay — safe to retry without duplicates"
  - "resumeQueue() is a hook stub intentionally — actual URL resolution lives in SyncService.sync() (Plan 02-06)"
  - "DownloadService stores relative paths only (exercises/{id}/{filename}); absolute path resolved at playback via BaseDirectory.applicationDocuments"
  - "DownloadService provider is keepAlive — must persist across navigation for background download callbacks"
metrics:
  duration: "82s"
  completed: "2026-05-26"
  tasks_completed: 2
  files_created: 2
  files_modified: 0
---

# Phase 2 Plan 05: SyncQueue wrapper + DownloadService Summary

**One-liner:** Offline write queue with idempotent upsert replay + background download manager with relative-path manifest tracking.

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Create SyncQueue wrapper (T036) | a7f5687 | mobile/lib/core/sync/sync_queue.dart |
| 2 | Create DownloadService (T039) | 2e86ed8 | mobile/lib/core/downloads/download_service.dart |

## What Was Built

### SyncQueue (`mobile/lib/core/sync/sync_queue.dart`)

High-level wrapper over `SyncQueueDao` providing the write-path for all offline-capable mutations.

- `enqueue(operation, targetTable, payload)` — JSON-encodes payload and persists to `sync_queue` table
- `processQueue()` — FIFO replay of pending items against Supabase; deletes on success, increments `retryCount` on failure
- `_replayItem()` — routes insert (upsert for idempotency), update (by id), delete (by id) to Supabase
- Items with `retryCount >= 5` are never returned by `getPendingItems()` — effectively dead-lettered
- `pendingCount` getter exposes queue depth
- `@Riverpod(keepAlive: true)` provider wires `appDatabaseProvider` + `supabaseClientProvider`

### DownloadService (`mobile/lib/core/downloads/download_service.dart`)

Background download manager for exercise video (MP4) and 3D model (GLB) assets.

- `downloadExerciseMedia(exerciseId, videoUrl, modelUrl, videoVersion)` — sets manifest to `in_progress`, enqueues `DownloadTask` items with `background_downloader`
- `cancelDownload(exerciseId)` — cancels both video and model tasks, resets manifest to `pending`
- `resumeQueue()` — hook called by `ConnectivityProvider` on reconnect; actual URL resolution deferred to `SyncService.sync()` (Plan 02-06)
- `initialize()` — sets up `FileDownloader().updates` listener for status/progress events
- `_handleStatusUpdate()` — updates manifest with relative path on `complete`, sets `failed` / `pending` on failure / cancel
- Progress stream (`StreamController.broadcast()`) for UI consumption
- Stores **relative paths only**: `exercises/{exerciseId}/{filename}` — never absolute (iOS paths change across installs)
- `metaData` field on each `DownloadTask` carries `exerciseId` for identification in callbacks
- `taskId` pattern: `exercise_{exerciseId}_video` / `exercise_{exerciseId}_model`
- `@Riverpod(keepAlive: true)` provider calls `initialize()` and registers `dispose()` with `ref.onDispose`

## Deviations from Plan

None — plan executed exactly as written. Both files match the provided code blueprints verbatim.

## Known Stubs

**1. `resumeQueue()` placeholder DownloadTask** — `download_service.dart` line ~118

- **File:** `mobile/lib/core/downloads/download_service.dart`
- **Pattern:** `DownloadTask(taskId: 'resume_trigger', url: 'https://placeholder')`
- **Reason:** Intentional per plan design. `resumeQueue()` is a connectivity-hook stub. The `resumeFromPause` call requires a `DownloadTask` argument but the actual URL resolution (and re-enqueue logic) lives in `SyncService.sync()` which is implemented in Plan 02-06. This stub does not block the plan goal — the manifest tracking and download initiation paths are fully wired.
- **Resolution:** Plan 02-06 (`SyncService`) will call `downloadService.resumeQueue()` and implement full URL-based re-enqueue.

## Self-Check

- [x] `mobile/lib/core/sync/sync_queue.dart` — FOUND
- [x] `mobile/lib/core/downloads/download_service.dart` — FOUND
- [x] Commit `a7f5687` — SyncQueue
- [x] Commit `2e86ed8` — DownloadService
- [x] `upsert` for idempotent insert replay — CONFIRMED
- [x] `BaseDirectory.applicationDocuments` + relative paths only — CONFIRMED
- [x] Both `@Riverpod(keepAlive: true)` providers — CONFIRMED
- [x] Both `part '*.g.dart'` directives — CONFIRMED

## Self-Check: PASSED
