# Phase 5: US3 Offline-First - Context

**Gathered:** 2026-05-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Student pre-downloads upcoming session content (video + 3D assets) on Wi-Fi in the
background; the session player transparently uses local files when offline; offline
progress (completions) is enqueued in sync_queue and replayed on reconnect.

This phase does NOT include: body metric offline sync (Phase 6), offline feedback
drafts (Phase 7), admin video invalidation webhook (Phase 8).

</domain>

<decisions>
## Implementation Decisions

### Download Trigger Strategy
- **D-01:** Downloads are **auto-enqueued on enrollment** for all sessions in the
  enrolled program — using `requiresWiFi: true` so they only execute on Wi-Fi.
  Enrollment event already writes to Drift; the enrollment command handler will
  also call `DownloadService.downloadExerciseMedia()` for each session's exercises.
- **D-02:** Individual sessions can also be manually triggered from the session row
  card (a download icon tapped by the student), in case auto-enqueue was skipped
  (e.g., enrolled while offline, then came online later).
- **D-03:** On reconnect, `SyncService.sync()` checks for any exercises whose
  manifest entry is `pending` or `failed` and re-enqueues them.

### Wi-Fi Gating
- **D-04:** All DownloadTask enqueues use `requiresWiFi: true`. No user toggle
  in Phase 5 — simple and predictable. Cellular downloads are out of scope for v1.

### Download UI (Session Row Indicators)
- **D-05:** Each session row in `ProgramDetailScreen` shows an inline download
  state badge/icon next to the session state indicator:
  - `not_downloaded` — download icon (outlined)
  - `in_progress` — circular progress indicator (compact)
  - `downloaded` — checkmark or filled icon
- **D-06:** No separate "Downloads" screen in Phase 5. Progress is visible inline
  per session card.
- **D-07:** Download state is derived by watching `DownloadManifestDao.watchAllEntries()`
  and joining against the session's exercise IDs — all exercises complete = session
  downloaded.

### Offline Playback Switching
- **D-08:** `ExerciseVideoPlayer` resolves video source at play time:
  1. Check `download_manifest` for `downloadStatus == 'complete'` and
     `videoLocalPath != null`
  2. If complete: use `file://` URI (resolve absolute path via
     `getApplicationDocumentsDirectory()` + relative path)
  3. If not complete (or no entry): use Mux HLS `mux_playback_id` URL (requires
     online)
- **D-09:** Same pattern for 3D model: check `modelLocalPath` in manifest; fall
  back to `model_asset_url` from exercise row.
- **D-10:** If offline AND no local copy: do NOT navigate to player — show
  "Not available offline" state (see D-11).

### Offline-Unavailable State
- **D-11:** When a student taps a session row while offline and the session is not
  downloaded:
  - Session row shows a disabled state (not tappable)
  - An inline "Not available offline" label appears below the session title
  - Optionally a small "will download when Wi-Fi available" note
  - Does NOT navigate to player
- **D-12:** When online, all sessions are accessible via HLS streaming regardless
  of download state.

### Storage Guard
- **D-13:** Before enqueuing each exercise download, check available free space via
  `path_provider` + `dart:io` `FileStat` / `getStorageStatistics`. If free space
  < 500 MB: skip the enqueue and show a dismissible SnackBar once per session.
- **D-14:** Storage check is a best-effort guard — it is checked at enqueue time,
  not continuously during download.

### Stale Video Detection
- **D-15:** During `SyncService._pullRemoteChanges()`, if a pulled exercise row has
  a `video_version` greater than the manifest's stored `videoVersion`, the manifest
  entry is reset to `pending` and re-enqueued for download.
- **D-16:** This implements the ROADMAP success criterion: "Stale video versions are
  detected and re-queued for download on sync."

### Sync Queue — Offline Completions
- **D-17:** Session completions recorded offline (via `SessionCompletionService`)
  already write to `sync_queue` via `SyncQueue.enqueue()` — this is the existing
  Phase 4 behavior. Phase 5 just validates this path works end-to-end and adds
  a test.
- **D-18:** `SyncQueue.processQueue()` already skips items with `retry_count >= 5`
  (dead-letter behavior per ROADMAP SC4). Phase 5 adds a test for this.

### Claude's Discretion
- Exact icon choice for download state badges
- Whether storage check uses `dart:io` StatFs or `disk_space` package
- Exact snackbar copy for storage warning
- Animation/transition for inline progress indicator on session rows
- Whether to show total download size estimate on session card

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Specification & Requirements
- `specs/001-mat-pilates-coach/spec.md` — User Story 3 (FR-006, FR-007), acceptance scenarios US3-SC1..SC4
- `specs/001-mat-pilates-coach/data-model.md` — `download_manifest` table, `exercises.mux_download_url`, `exercises.video_version`, `sync_queue` table

### Existing Core Services (must extend, not replace)
- `mobile/lib/core/downloads/download_service.dart` — DownloadService with `downloadExerciseMedia()`, manifest status tracking, `resumeQueue()`
- `mobile/lib/core/sync/sync_service.dart` — SyncService with `sync()`, `_pullRemoteChanges()` (extend to check video_version staleness)
- `mobile/lib/core/sync/sync_queue.dart` — SyncQueue with `processQueue()`, retry logic (retry_count >= 5 dead-letter)
- `mobile/lib/core/sync/connectivity_provider.dart` — ConnectivityNotifier (already triggers sync + resumeQueue on reconnect)
- `mobile/lib/core/database/daos/download_manifest_dao.dart` — DownloadManifestDao with upsert, watch, status update methods
- `mobile/lib/core/database/tables/download_manifest_table.dart` — schema: exerciseId PK, videoVersion, videoLocalPath, modelLocalPath, downloadStatus, downloadedAt

### Existing UI (integration points)
- `mobile/lib/features/session/presentation/exercise_video_player.dart` — needs offline path resolution logic (D-08)
- `mobile/lib/features/programs/presentation/program_detail_screen.dart` — session rows need download state badge (D-05)
- `mobile/lib/features/session/presentation/session_player_screen.dart` — entry guard when offline + not downloaded (D-10)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DownloadService.downloadExerciseMedia()`: already takes `videoUrl`, `modelUrl`, `exerciseId`, `videoVersion` — ready to call from enrollment handler
- `DownloadManifestDao.watchAllEntries()`: reactive stream for UI — derive per-session download state by joining exercise IDs
- `SyncService._pullTable()`: generic pull helper already in place — extend `_pullRemoteChanges()` to compare `video_version`
- `ConnectivityProvider`: already wired to trigger `resumeQueue()` on reconnect — no new wiring needed
- `background_downloader` (`FileDownloader`): fully configured with `Updates.statusAndProgress`, 3 retries, pausable — `requiresWiFi` is a per-task flag on `DownloadTask`

### Established Patterns
- Riverpod + Freezed domain models for all features
- CQRS: command side writes to normalized tables, query side reads from `*_view` projections
- `ConsumerWidget` + `ref.watch()` for reactive UI
- `getApplicationDocumentsDirectory()` + relative path for cross-platform file resolution (established in Phase 2 DownloadService)
- Drift upsert pattern: `insertOnConflictUpdate` for idempotent writes

### Integration Points
- `programs_repository.dart` enrollment command → add `DownloadService.downloadExerciseMedia()` call per exercise after enrollment
- `exercise_video_player.dart` → add local path resolution before HLS fallback
- `program_detail_screen.dart` session rows → inject download state from manifest watcher
- `session_player_screen.dart` → add offline guard at entry if session not downloaded

</code_context>

<specifics>
## Specific Ideas

- Downloads should be completely silent and automatic after enrollment — no modal or
  confirmation dialog. The only visible indication is the per-session row badge.
- The offline-unavailable state should be non-alarming — it's informational, not an
  error. Students in studios regularly toggle airplane mode.

</specifics>

<deferred>
## Deferred Ideas

- Cellular download toggle (user preference) — deferred to a future UX pass
- Dedicated "Downloads" management screen (see/delete downloads) — Phase 9 polish
- Per-exercise download progress UI in the player screen — Phase 9 polish
- Offline metric logging and feedback drafts — Phase 6 and Phase 7 respectively
- Admin video invalidation webhook for FR-019 — Phase 8

</deferred>

---

*Phase: 05-us3-offline-first*
*Context gathered: 2026-05-28*
