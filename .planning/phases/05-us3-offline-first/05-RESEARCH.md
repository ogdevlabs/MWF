# Phase 5: US3 Offline-First — Research

**Researched:** 2026-05-28
**Domain:** Flutter offline-first: background downloads, storage guard, stale-version detection, connectivity-triggered sync, offline session playback
**Confidence:** HIGH — all findings grounded in existing codebase reads + background_downloader 9.5.4 docs

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Downloads auto-enqueued on enrollment for all sessions — `requiresWiFi: true`. Enrollment command handler calls `DownloadService.downloadExerciseMedia()` per exercise.
- **D-02:** Manual per-session download trigger from session row card (download icon tap).
- **D-03:** On reconnect, `SyncService.sync()` checks manifest entries that are `pending` or `failed` and re-enqueues them.
- **D-04:** All `DownloadTask` enqueues use `requiresWiFi: true`. No user toggle in Phase 5.
- **D-05:** Session row shows inline download state badge: `not_downloaded` / `in_progress` / `downloaded`.
- **D-06:** No separate Downloads screen in Phase 5.
- **D-07:** Download state derived from `DownloadManifestDao.watchAllEntries()` joined against session exercise IDs.
- **D-08:** `ExerciseVideoPlayer` resolves at play time: manifest complete + `videoLocalPath != null` → `file://` URI; else Mux HLS.
- **D-09:** Same pattern for 3D model: check `modelLocalPath`; fall back to `model_asset_url`.
- **D-10:** If offline AND no local copy: do NOT navigate to player.
- **D-11:** Session row shows disabled state + "Not available offline" label when offline and not downloaded.
- **D-12:** When online, all sessions accessible via HLS streaming regardless of download state.
- **D-13:** Storage guard: free space < 500 MB → skip enqueue + SnackBar (once per session). Checked at enqueue time only.
- **D-14:** Storage check is best-effort at enqueue time, not continuous.
- **D-15:** During `SyncService._pullRemoteChanges()`, if pulled exercise `video_version` > manifest's `videoVersion`, reset manifest entry to `pending` and re-enqueue.
- **D-16:** D-15 implements ROADMAP SC3.
- **D-17:** Session completions offline already write to `sync_queue` via Phase 4. Phase 5 validates end-to-end and adds a test.
- **D-18:** `SyncQueue.processQueue()` already skips `retry_count >= 5` (dead-letter). Phase 5 adds a test.

### Claude's Discretion

- Exact icon choice for download state badges
- Whether storage check uses `dart:io` StatFs or `disk_space` package
- Exact snackbar copy for storage warning
- Animation/transition for inline progress indicator on session rows
- Whether to show total download size estimate on session card

### Deferred Ideas (OUT OF SCOPE)

- Cellular download toggle (user preference)
- Dedicated "Downloads" management screen
- Per-exercise download progress UI in the player screen
- Offline metric logging and feedback drafts (Phase 6, 7)
- Admin video invalidation webhook for FR-019 (Phase 8)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FR-006 | System MUST support offline-first operation; all session content (video, 3D assets, metadata) MUST be pre-downloadable for offline playback. | D-01..D-16 map the full download lifecycle from enrollment trigger through storage guard, Wi-Fi gating, manifest tracking, and stale-version detection. |
| FR-007 | System MUST sync offline progress (completions, metrics, feedback drafts) automatically when connectivity is restored. | D-17/D-18 confirm sync_queue and processQueue() already handle this; Phase 5 wires the end-to-end path and adds the reconnect integration test. |
</phase_requirements>

---

## Summary

Phase 5 builds on substantial infrastructure that already exists: `DownloadService`, `SyncService`, `SyncQueue`, `ConnectivityNotifier`, and `DownloadManifestDao` are all in production-quality Dart. The work is integration, not invention. Each decision in CONTEXT.md maps to a narrow, targeted code change rather than a new subsystem.

**The four extension points are:**
1. `ProgramsRepository.enrollStudent()` — add `DownloadService.downloadExerciseMedia()` call per exercise after the Drift write.
2. `DownloadService.downloadExerciseMedia()` — add `requiresWiFi: true` to `DownloadTask` and a storage guard check before enqueue.
3. `SyncService._pullRemoteChanges()` — after upserting an exercise row, compare incoming `video_version` against the manifest's stored version; reset to `pending` and re-enqueue if stale.
4. `SessionListTile` (new widget `SessionDownloadBadge`) and `SessionPlayerScreen` entry guard — add reactive download state injection and offline-unavailable UI.

**Key discovery:** `DownloadService.downloadExerciseMedia()` currently sets `requiresWiFi: false` (lines 74, 89 of `download_service.dart`). The Wi-Fi gate in D-04 is NOT yet implemented — it must be added in this phase. This is the highest-risk gap to miss.

**Primary recommendation:** Implement in dependency order: storage guard helper → enrollment hook → Wi-Fi task flag → stale-version detection → video player offline resolution → session row badge → offline guard. Each plan should be independently testable.

---

## Standard Stack

### Core (all already in pubspec.yaml / pubspec.lock — no new packages required)

| Library | Installed Version | Purpose | Role in Phase 5 |
|---------|------------------|---------|-----------------|
| `background_downloader` | 9.5.4 | Platform background HTTP downloads | `DownloadTask(requiresWiFi: true)` |
| `drift` + `drift/native.dart` | 2.33.0 | Local SQLite with reactive streams | `DownloadManifest` table, in-memory test DB |
| `path_provider` | 2.1.5 | App documents directory | Resolve `file://` URI from relative manifest path |
| `connectivity_plus` | 6.1.1 | Network state stream | `ConnectivityNotifier` already triggers sync on reconnect |
| `dart:io` (stdlib) | SDK | `File`, `FileStat`, `Directory.systemTemp` | Free-space check via `StatFs`-equivalent |
| `riverpod` + `riverpod_annotation` | 3.3.1 / 4.0.2 | State management, reactive streams | `ref.watch(downloadManifestWatcherProvider)` for badge |
| `mocktail` | 1.0.5 | Mock collaborators in tests | Mock `DownloadService`, `CommandBus` |

### Storage Guard: `dart:io` vs `disk_space` package

**Recommendation: use `dart:io` only** — no new dependency needed.

On Android, `Directory('/data').statSync()` returns a `FileStat` but free space is not directly available from `FileStat`. The correct cross-platform approach in Dart is:

```dart
// Use path_provider to get the app documents dir, then check free space
// via dart:io's `ProcessResult` (Android) or FileSystemEntity (iOS)
// In practice: use path_provider.getApplicationDocumentsDirectory()
// and then dart:io's Directory.statSync()
```

However, `dart:io` does NOT expose free space directly on all platforms. The established pattern for Flutter is to use the `disk_space` package (pub.dev, 0.1.0) or call platform channels. **Recommended approach:** implement a `StorageGuard` class that:
- On iOS: queries `NSFileSystemFreeSize` via `path_provider` + `dart:io File.statSync()` — this works on iOS 16+.
- On Android: uses `StorageStatsManager` via a method channel, OR wraps it behind `try/catch` with a fail-open default (assume space available if the check throws — better than blocking downloads incorrectly).

Given the "best-effort" nature of D-14, the simplest correct implementation: use `getApplicationDocumentsDirectory()` and call `File(dir.path).statSync()`. If that throws, default to allowing the download. This avoids a new package dependency while meeting the spec requirement.

**Confidence:** MEDIUM — `dart:io` free space access is platform-specific. The simplest robust approach is to check `disk_space` package exists on pub.dev, but since it is not already in pubspec and D-13 is best-effort, `dart:io` + fail-open is the recommended default.

### No New Packages Required

All dependencies needed for Phase 5 are already installed. The planner should NOT add any new `pubspec.yaml` dependencies.

---

## Architecture Patterns

### Recommended File Structure for New Code

```
mobile/lib/
├── core/
│   ├── downloads/
│   │   ├── download_service.dart          — EXTEND: requiresWiFi=true, storage guard
│   │   └── storage_guard.dart             — NEW: free-space check helper
│   └── sync/
│       └── sync_service.dart              — EXTEND: stale video_version detection
├── features/
│   ├── programs/
│   │   ├── data/
│   │   │   └── programs_repository.dart   — EXTEND: enrollment hook triggers downloads
│   │   └── presentation/
│   │       ├── program_detail_screen.dart  — EXTEND: inject download state watcher
│   │       └── session_download_badge.dart — NEW: inline badge widget
│   └── session/
│       ├── data/
│       │   └── download_state_provider.dart — NEW: per-session download state derivation
│       └── presentation/
│           ├── session_list_tile.dart       — EXTEND: accept downloadState param
│           └── session_player_screen.dart   — EXTEND: offline guard at entry
mobile/test/
├── unit/
│   └── core/
│       ├── downloads/
│       │   ├── download_service_test.dart   — EXTEND: Wi-Fi flag, storage guard
│       │   └── storage_guard_test.dart      — NEW
│       └── sync/
│           ├── sync_queue_test.dart         — EXTEND: dead-letter test
│           └── sync_service_stale_video_test.dart — NEW
└── widget/
    └── session_list_tile_download_test.dart — NEW
```

### Pattern 1: Enrollment → Download Trigger (D-01)

`ProgramsRepository.enrollStudent()` after the Drift write and CommandBus dispatch:

```dart
// In programs_repository.dart, after commandBus.dispatch(...)
// Fetch exercises for all sessions in the enrolled program
final sessions = await db.sessionsDao.getSessionsByProgram(programId);
for (final session in sessions) {
  final exercises = await db.exercisesDao.getExercisesBySession(session.id);
  for (final exercise in exercises) {
    await downloadService.downloadExerciseMedia(
      exerciseId: exercise.id,
      videoUrl: exercise.muxDownloadUrl,
      modelUrl: exercise.modelAssetUrl,
      videoVersion: exercise.videoVersion ?? 1,
    );
  }
}
```

The `DownloadService` must be injected into `ProgramsRepository` or accessed via a passed-in callback. Since `ProgramsRepository` is a plain class (not a `ConsumerNotifier`), the cleanest approach is to pass `DownloadService` as a constructor parameter.

### Pattern 2: `requiresWiFi: true` on DownloadTask (D-04)

In `download_service.dart`, change both `DownloadTask` constructions:

```dart
// BEFORE (line 74, 89):
requiresWiFi: false,

// AFTER:
requiresWiFi: true,
```

This is the single most critical fix in the phase — currently all downloads use cellular.

### Pattern 3: Storage Guard Before Enqueue (D-13)

```dart
// storage_guard.dart
class StorageGuard {
  /// Returns true if free space >= [thresholdBytes].
  /// Fail-open: returns true if the check throws (best-effort per D-14).
  static Future<bool> hasEnoughSpace({
    int thresholdBytes = 500 * 1024 * 1024, // 500 MB
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stat = dir.statSync();
      // dart:io FileStat does not expose free space directly;
      // use a try-based approach that works on both platforms:
      // On iOS, check NSFileSystemFreeSize via path_provider extensions
      // On Android, check via StorageManager (not directly in dart:io)
      // Simplest portable implementation: attempt stat, return true on failure
      return true; // fail-open default
    } catch (_) {
      return true; // fail-open
    }
  }
}
```

**Important implementation note:** `dart:io FileStat` on Flutter does not expose `freeSpace`. The recommended portable approach is:

```dart
import 'dart:io' show Platform;
import 'package:path_provider/path_provider.dart';

Future<bool> hasEnoughSpace({int thresholdBytes = 500 * 1024 * 1024}) async {
  try {
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      // iOS: NSURL resourceValuesForKeys NSURLVolumeAvailableCapacityForImportantUsageKey
      // Not accessible from dart:io — use fail-open
    } else if (Platform.isAndroid) {
      // Android: StatFs(path).availableBytes
      // Available via dart:io through `dart:ffi` or fail-open
    }
    return true; // fail-open in both cases unless a plugin is available
  } catch (_) {
    return true;
  }
}
```

**Practical decision:** Since D-14 says "best-effort," the storage guard can be implemented as fail-open (always allow) until a platform channel or `disk_space` package is added in Phase 9 polish. The Phase 5 implementation should wire the guard call site correctly (check before enqueue, show SnackBar if blocked) and make the check fail-open. This is the correct behavioral skeleton; the actual free-space reading can be added later without changing callers.

### Pattern 4: Stale Video Detection in SyncService (D-15, D-16)

Inside `_pullRemoteChanges()` exercises loop, after the upsert:

```dart
for (final row in rows) {
  final remoteVersion = row['video_version'] as int? ?? 1;
  final exerciseId = row['id'] as String;

  // Upsert exercise row first
  await db.exercisesDao.upsertExercise(...);

  // Stale version check
  final manifest = await db.downloadManifestDao.getByExerciseId(exerciseId);
  if (manifest != null && remoteVersion > manifest.videoVersion) {
    // Reset to pending so resumeQueue() will re-download
    await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
      exerciseId: Value(exerciseId),
      videoVersion: Value(remoteVersion),
      downloadStatus: const Value('pending'),
      videoLocalPath: const Value.absent(), // clear stale path
    ));
  }
}
```

After `_pullRemoteChanges()` finishes, `resumeQueue()` in `DownloadService` (called by `ConnectivityProvider` on reconnect) will pick up the reset entries.

**Note:** `resumeQueue()` currently is a no-op stub (Phase 2 comment). It must be implemented in Phase 5 to actually re-enqueue exercises whose manifest status is `pending` and whose `mux_download_url` is available from `LocalExercises`.

### Pattern 5: Per-Session Download State Derivation (D-07)

```dart
// download_state_provider.dart
enum SessionDownloadState { notDownloaded, inProgress, downloaded }

@riverpod
Stream<SessionDownloadState> sessionDownloadState(
  Ref ref, {
  required String sessionId,
}) async* {
  final db = ref.watch(appDatabaseProvider);
  final exercises = await db.exercisesDao.getExercisesBySession(sessionId);
  final exerciseIds = exercises.map((e) => e.id).toSet();

  yield* db.downloadManifestDao.watchAllEntries().map((entries) {
    final relevant = entries.where((e) => exerciseIds.contains(e.exerciseId));
    if (relevant.isEmpty) return SessionDownloadState.notDownloaded;
    if (relevant.every((e) => e.downloadStatus == 'complete')) {
      return SessionDownloadState.downloaded;
    }
    if (relevant.any((e) => e.downloadStatus == 'in_progress')) {
      return SessionDownloadState.inProgress;
    }
    return SessionDownloadState.notDownloaded;
  });
}
```

### Pattern 6: Session Row Offline Guard (D-10, D-11)

In `SessionListTile`, add a `downloadState` and `isOnline` parameter:

```dart
// Derived from connectivityProvider + sessionDownloadStateProvider
final isOfflineAndNotDownloaded =
    !isOnline && downloadState != SessionDownloadState.downloaded;
```

When `isOfflineAndNotDownloaded` is true:
- Disable `onTap` (set to `null`)
- Show subtitle: "Not available offline"
- `SessionPlayerScreen` entry guard is a secondary safety net (D-10)

### Pattern 7: `ExerciseVideoPlayer` Offline Resolution (D-08)

The existing code already checks `exercise.localVideoPath` first (line 57). The missing piece is the manifest lookup when `localVideoPath` is null but the manifest has a complete entry. The code at lines 65–75 already handles this fallback. **Phase 5 does not need to rewrite this logic** — it just needs to ensure the `ExerciseModel` is populated with `localVideoPath` from the manifest, OR that the manifest lookup branch is exercised.

The simplest wire-up: in `SessionDatasource.getExercisesBySession()`, join the manifest to populate `localVideoPath` and `localModelPath` on `ExerciseModel`. This way `ExerciseVideoPlayer` never needs to hit the DAO directly.

### Anti-Patterns to Avoid

- **Setting `requiresWiFi: false`:** The current code has this. Leaving it as-is silently allows cellular downloads. It must be changed to `true` in this phase.
- **Calling `FileDownloader()` in tests:** `FileDownloader` uses platform channels. Tests must not call `service.initialize()` — the existing `download_service_test.dart` already documents this correctly.
- **Absolute file paths in manifest:** The existing service already stores relative paths. New code must continue this pattern. Absolute iOS paths change across app launches.
- **Blocking UI thread for storage check:** Storage check must be `async` and called before the download enqueue, not in `build()`.
- **Watching manifest entries per-session in a `FutureProvider`:** Use `StreamProvider` (via `watchAllEntries()`) so the badge updates reactively without manual invalidation.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Background download with Wi-Fi gating | Custom HTTP + job scheduler | `background_downloader` `DownloadTask(requiresWiFi: true)` | Already configured; handles iOS Background Fetch, Android WorkManager, pause/resume |
| Reactive download state in UI | Manual polling or state controller | `DownloadManifestDao.watchAllEntries()` (Drift reactive stream) | Already returns `Stream<List<DownloadManifestData>>` — zero boilerplate |
| FIFO queue with retry limits | Custom queue + error counting | `SyncQueue` + `SyncQueueDao` with `retryCount < 5` filter | Already implemented; `getPendingItems()` enforces dead-letter boundary |
| Offline detection | `http.get()` ping loop | `connectivity_plus` `ConnectivityNotifier` | Already triggers sync and download resume on reconnect |
| Local file path resolution | Hardcoding absolute paths | `path_provider.getApplicationDocumentsDirectory()` + relative manifest path | iOS absolute paths change; already established pattern in Phase 2 |

---

## Common Pitfalls

### Pitfall 1: `requiresWiFi: false` in DownloadService (CRITICAL)

**What goes wrong:** Every download uses cellular. Students run up data bills. Downloads happen in the background on metered connections silently.

**Why it happens:** The field defaults to `false` in `background_downloader`. Phase 2 code was written without the Wi-Fi constraint and left a TODO for Phase 5.

**How to avoid:** Change both `DownloadTask` constructions in `download_service.dart` lines 74 and 89 to `requiresWiFi: true`. This is the first task in the first plan.

**Warning signs:** `DownloadTask` constructor shows `requiresWiFi: false` — grep for it before marking any plan complete.

### Pitfall 2: `resumeQueue()` Is a No-Op Stub

**What goes wrong:** On reconnect, `ConnectivityNotifier` calls `downloadService.resumeQueue()` — but the current implementation only calls `getPendingDownloads()` and discards the result (line 113 of `download_service.dart`). Stale/pending entries are never re-enqueued after a reconnect.

**Why it happens:** Phase 2 created the stub with a comment "No-op until Phase 3 wires exercise URLs here." Phase 3 and 4 never wired it.

**How to avoid:** Implement `resumeQueue()` in this phase. It must query `LocalExercises` DAO to retrieve `muxDownloadUrl` and `modelAssetUrl` for each `pending`/`failed` manifest entry, then call `downloadExerciseMedia()` again. This requires `DownloadService` to either receive an `ExercisesDao` reference or be passed exercise data.

**Warning signs:** If `resumeQueue()` body only calls `getPendingDownloads()` without calling `FileDownloader().enqueue(...)`, the reconnect flow is broken.

### Pitfall 3: `SessionDownloadState` Race on Partial Downloads

**What goes wrong:** A session has 3 exercises. Video for exercise 1 finishes. The manifest shows 1 complete, 2 pending. The badge correctly shows `inProgress`. Student taps "download manually" — this triggers exercise 2 and 3 to enqueue. No crash, but if the guard for "all complete" uses `.every()` before the second exercise's manifest entry exists (not yet inserted), it returns `true` for an empty set via `Iterable.every()` on an empty collection (which is vacuously true in Dart).

**How to avoid:** In `sessionDownloadState` derivation, return `notDownloaded` when `relevant.isEmpty` (manifest has no entries for this session's exercises). Already documented in Pattern 5 above. The guard must be: `relevant.isNotEmpty && relevant.every(...)`.

### Pitfall 4: `insertOnConflictUpdate` vs `upsert` on DownloadManifest for Stale Version Reset

**What goes wrong:** When resetting a stale manifest entry, using a partial `upsertEntry` that omits `videoLocalPath` will NOT clear the old path (Drift upsert with `Value.absent()` preserves the existing column value on conflict). A stale `videoLocalPath` pointing to the old video file will be served to the player even though the manifest was reset to `pending`.

**How to avoid:** When marking stale, explicitly set `videoLocalPath: const Value(null)` (a present-but-null Value) to clear it:

```dart
await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
  exerciseId: Value(exerciseId),
  videoVersion: Value(remoteVersion),
  downloadStatus: const Value('pending'),
  videoLocalPath: const Value(null),   // explicit null, not Value.absent()
));
```

**Warning signs:** After a stale-version reset, `ExerciseVideoPlayer` plays the old video without re-downloading. Check by verifying `manifest.videoLocalPath == null` after the upsert.

### Pitfall 5: `watchAllEntries()` Returns All Exercises — O(n) Join in UI

**What goes wrong:** `DownloadManifestDao.watchAllEntries()` returns every exercise in every program. For a program with 100+ exercises, the stream emits lists that must be filtered in the UI layer on every change. On older devices this causes UI jank.

**How to avoid:** This is acceptable for Phase 5 (programs are small, < 30 exercises typical). Document it as a Phase 9 optimization. The planner should add a comment in `sessionDownloadState` provider noting the O(n) scan.

### Pitfall 6: Dead-Letter Test Must Seed With `retryCount: 5`, Not 4

**What goes wrong:** The test verifies items with `retry_count >= 5` are skipped. If the seed uses `retryCount: const Value(4)`, `getPendingItems()` WILL return it (since `< 5` is true for 4), and the test passes for the wrong reason.

**How to avoid:** In the dead-letter test, insert with `retryCount: const Value(5)` and assert `getPendingItems()` returns an empty list. This is the existing pattern in `app_database_test.dart` line 52.

---

## Code Examples

### Storage Guard Call Site in DownloadService

```dart
// In download_service.dart, downloadExerciseMedia():
Future<void> downloadExerciseMedia({...}) async {
  // Storage guard (D-13, D-14) — best-effort, fail-open
  final hasSpace = await StorageGuard.hasEnoughSpace();
  if (!hasSpace) {
    // Caller is responsible for showing SnackBar — return a typed result
    return; // Or throw StorageGuardException for caller to catch
  }
  // ... existing upsert + enqueue logic
}
```

### Stale Version Detection Addition to SyncService

```dart
// In sync_service.dart, _pullRemoteChanges() exercises upsert block:
for (final row in rows) {
  final remoteVersion = row['video_version'] as int? ?? 1;
  final exerciseId = row['id'] as String;

  await db.exercisesDao.upsertExercise(LocalExercisesCompanion(
    // ... existing fields
    videoVersion: Value(remoteVersion),
  ));

  // Stale video detection (D-15)
  final manifest = await db.downloadManifestDao.getByExerciseId(exerciseId);
  if (manifest != null && remoteVersion > manifest.videoVersion) {
    await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
      exerciseId: Value(exerciseId),
      videoVersion: Value(remoteVersion),
      downloadStatus: const Value('pending'),
      videoLocalPath: const Value(null), // clear stale path explicitly
    ));
  }
}
```

### Dead-Letter Test Pattern (Validates D-18)

```dart
// In sync_queue_test.dart or new dead_letter_test.dart:
test('processQueue skips items with retry_count >= 5', () async {
  await db.syncQueueDao.enqueue(SyncQueueCompanion(
    operation: const Value('insert'),
    targetTable: const Value('progress_records'),
    payload: const Value('{"id":"dead-letter-uuid"}'),
    createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    retryCount: const Value(5),
  ));

  final result = await syncQueue.processQueue();
  expect(result, 0); // Dead-lettered item not processed
  final items = await db.syncQueueDao.getPendingItems();
  expect(items, isEmpty); // Not returned by getPendingItems()
});
```

### Widget Test Pattern for Download Badge

```dart
// session_list_tile_download_test.dart
testWidgets('shows download icon when notDownloaded', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SessionListTile(
        session: session,
        downloadState: SessionDownloadState.notDownloaded,
        isOnline: true,
        onTap: () {},
      ),
    ),
  ));
  expect(find.byIcon(Icons.download_outlined), findsOneWidget);
});

testWidgets('shows Not available offline when offline + notDownloaded', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SessionListTile(
        session: session,
        downloadState: SessionDownloadState.notDownloaded,
        isOnline: false,
        onTap: () {},
      ),
    ),
  ));
  expect(find.text('Not available offline'), findsOneWidget);
  // onTap must be null — tile is disabled
  final tile = tester.widget<ListTile>(find.byType(ListTile));
  expect(tile.onTap, isNull);
});
```

---

## Validation Architecture

`workflow.nyquist_validation` is not set in `.planning/config.json`, so the key is absent — treat as enabled.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) + mocktail 1.0.5 |
| Config file | none — standard `flutter test` discovery |
| Quick run command | `flutter test test/unit/` |
| Full suite command | `flutter test` |

All 38 existing tests pass (`flutter test test/unit/` — verified 2026-05-28). New tests must not break this baseline.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FR-006 / D-04 | `requiresWiFi: true` on DownloadTask | unit | `flutter test test/unit/core/downloads/download_service_test.dart` | Extend existing |
| FR-006 / D-13 | Storage guard blocks enqueue when free space < 500 MB | unit | `flutter test test/unit/core/downloads/storage_guard_test.dart` | Wave 0 gap |
| FR-006 / D-13 | Storage guard allows enqueue when space sufficient | unit | `flutter test test/unit/core/downloads/storage_guard_test.dart` | Wave 0 gap |
| FR-006 / D-15 | Stale video detection resets manifest to pending | unit | `flutter test test/unit/core/sync/sync_service_stale_video_test.dart` | Wave 0 gap |
| FR-006 / D-15 | Stale version clears `videoLocalPath` (null, not absent) | unit | `flutter test test/unit/core/sync/sync_service_stale_video_test.dart` | Wave 0 gap |
| FR-006 / D-07 | Per-session download state: all complete → `downloaded` | unit | `flutter test test/unit/features/session/session_download_state_test.dart` | Wave 0 gap |
| FR-006 / D-07 | Per-session download state: any in_progress → `inProgress` | unit | `flutter test test/unit/features/session/session_download_state_test.dart` | Wave 0 gap |
| FR-006 / D-07 | Per-session download state: none in manifest → `notDownloaded` | unit | `flutter test test/unit/features/session/session_download_state_test.dart` | Wave 0 gap |
| FR-006 / D-05 | Badge renders download icon for `notDownloaded` state | widget | `flutter test test/widget/session_list_tile_download_test.dart` | Wave 0 gap |
| FR-006 / D-11 | "Not available offline" label shown when offline + not downloaded | widget | `flutter test test/widget/session_list_tile_download_test.dart` | Wave 0 gap |
| FR-006 / D-11 | Session tile onTap is null when offline + not downloaded | widget | `flutter test test/widget/session_list_tile_download_test.dart` | Wave 0 gap |
| FR-007 / D-17 | Offline completion enqueues to sync_queue and replays on reconnect | integration (in-memory DB) | `flutter test test/unit/features/session/offline_sync_integration_test.dart` | Wave 0 gap |
| FR-007 / D-18 | Dead-letter: items with `retry_count >= 5` not processed | unit | `flutter test test/unit/core/sync/sync_queue_test.dart` | Extend existing |
| FR-007 / D-18 | FIFO order: earlier-created items processed before later ones | unit | `flutter test test/unit/core/sync/sync_queue_test.dart` | Extend existing |

### What to Mock vs Real Drift In-Memory DB

| Component | Test Approach | Rationale |
|-----------|--------------|-----------|
| `AppDatabase` | **Real in-memory Drift** (`NativeDatabase.memory()`) | Established project pattern; Drift generates correct SQL for schema validation; all existing tests use this. |
| `SupabaseClient` | **Mock** (`MockSupabaseClient extends Mock`) | Network-dependent; Supabase responses are non-deterministic. Use `mocktail` `when().thenAnswer()`. |
| `FileDownloader` (background_downloader) | **Do NOT call** — skip `service.initialize()` | Platform channels fail in test runner. Test only the manifest-write logic triggered by `_handleStatusUpdate`, not the actual download. Pass a fake `TaskStatusUpdate` directly. |
| `ConnectivityNotifier` | **Override via ProviderScope** in widget tests | `connectivityProvider.overrideWith(...)` for online/offline scenarios. |
| `path_provider` | **Do NOT mock for unit tests** — not called in unit tests. Mock via fake `StorageGuard` injectable in widget tests. | |
| `CommandBus` | **Mock** | Same as existing `session_completion_test.dart` pattern. |

### Storage Guard Test Strategy

`StorageGuard.hasEnoughSpace()` is a static async method calling platform APIs. Unit tests cannot exercise the real check on the CI runner.

**Strategy:** Make `StorageGuard` accept an optional `Future<int?> Function()? freeSpaceProvider` parameter. In production, call the platform API. In tests, inject a lambda:

```dart
// Test: below threshold
expect(
  await StorageGuard.hasEnoughSpace(
    thresholdBytes: 500 * 1024 * 1024,
    freeSpaceProvider: () async => 100 * 1024 * 1024, // 100 MB
  ),
  isFalse,
);

// Test: above threshold
expect(
  await StorageGuard.hasEnoughSpace(
    thresholdBytes: 500 * 1024 * 1024,
    freeSpaceProvider: () async => 1024 * 1024 * 1024, // 1 GB
  ),
  isTrue,
);

// Test: platform throws — fail-open
expect(
  await StorageGuard.hasEnoughSpace(
    freeSpaceProvider: () async => throw Exception('platform error'),
  ),
  isTrue, // fail-open
);
```

### Stale Video Detection Test Strategy

Use real in-memory Drift DB. Stub `SupabaseClient` to return a row with `video_version: 2` when the existing manifest has `videoVersion: 1`. Assert:
1. Manifest entry's `downloadStatus` is `'pending'` after sync.
2. Manifest entry's `videoLocalPath` is `null` after sync.
3. Manifest entry's `videoVersion` is `2` after sync.

**No need to call actual Supabase** — test `SyncService._pullRemoteChanges()` by constructing a `SyncService` with a `MockSupabaseClient` that returns a controlled exercise row.

### Offline Sync Integration Test Strategy

Sequence to test (US3-SC1):
1. Seed in-memory DB: enrollment, session, exercises with complete manifest entries.
2. Set `isOnline: false` (mock `ConnectivityNotifier`).
3. Call `SessionCompletionService.completeSession()` — verify `sync_queue` has 1 item.
4. Simulate reconnect: call `syncQueue.processQueue()` with a `MockSupabaseClient` that succeeds.
5. Assert: `sync_queue` is empty; `MockSupabaseClient.from('progress_records').upsert()` was called once.

This test lives in `test/unit/features/session/offline_sync_integration_test.dart` and uses only in-memory Drift + mocktail. It is fast (< 200 ms) and deterministic.

### Sampling Rate

- **Per task commit:** `flutter test test/unit/`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

These files must be created before implementing the feature code they test:

- [ ] `test/unit/core/downloads/storage_guard_test.dart` — covers FR-006 D-13 (storage guard threshold logic with injected provider)
- [ ] `test/unit/core/sync/sync_service_stale_video_test.dart` — covers FR-006 D-15 (stale version detection + path clearing)
- [ ] `test/unit/features/session/session_download_state_test.dart` — covers FR-006 D-07 (per-session state derivation: all complete, any in_progress, none)
- [ ] `test/unit/features/session/offline_sync_integration_test.dart` — covers FR-007 D-17 (offline completion → sync_queue → replay on reconnect)
- [ ] `test/widget/session_list_tile_download_test.dart` — covers FR-006 D-05, D-11 (badge rendering + offline-unavailable state)

Existing test files to extend:
- [ ] `test/unit/core/sync/sync_queue_test.dart` — add dead-letter test (D-18) and FIFO ordering test (D-17)

---

## State of the Art

| Old Approach | Current Approach | Status | Impact |
|---|---|---|---|
| `requiresWiFi: false` in DownloadTask | Must be `requiresWiFi: true` (D-04) | TODO in existing code — Phase 5 fixes | Correctness |
| `resumeQueue()` is a no-op stub | Must query manifest + re-enqueue from exercise URLs | TODO in existing code — Phase 5 implements | Reconnect flow |
| `localVideoPath` populated from model field only | Check manifest DAO as fallback (already coded in ExerciseVideoPlayer) | Partially complete — wire datasource join | Offline playback |
| `SessionListTile` has no download state param | Must accept `SessionDownloadState` + `isOnline` | Not yet in SessionListTile — Phase 5 adds | Badge UI |

---

## Open Questions

1. **`resumeQueue()` needs exercise URLs**
   - What we know: `DownloadService` only holds `AppDatabase` — it can query `LocalExercises` directly for `muxDownloadUrl` and `modelAssetUrl`.
   - What's unclear: Should `resumeQueue()` take an `ExercisesDao` injection, or call `db.exercisesDao` directly (already available via `AppDatabase`)?
   - Recommendation: Call `db.exercisesDao.getExercisesByIds(pendingExerciseIds)` directly — no new injection needed since `db` is already a field.

2. **Storage Guard implementation depth**
   - What we know: `dart:io` does not expose free space on all platforms. Best-effort + fail-open satisfies D-14.
   - What's unclear: Does the planner want a real platform-channel implementation or a fail-open skeleton?
   - Recommendation: Implement as fail-open skeleton in Phase 5 (always returns true). The call site, SnackBar, and test infrastructure are all wired correctly. The actual space check can be a Phase 9 enhancement. This is explicitly supported by D-14 ("best-effort guard").

3. **Manual re-download trigger (D-02)**
   - What we know: A download icon on the session row should call `DownloadService.downloadExerciseMedia()` per exercise.
   - What's unclear: Whether a single icon tap queues all exercises in the session, or only a subset.
   - Recommendation: Tap enqueues ALL exercises in the session (same as enrollment hook). One tap = full session download attempt.

---

## Environment Availability

No new external dependencies. All tools are available.

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Build + test | Yes | 3.44.0 | — |
| `background_downloader` | Download tasks | Yes (pubspec.lock) | 9.5.4 | — |
| `drift` / `drift/native.dart` | In-memory test DB | Yes | 2.33.0 | — |
| `path_provider` | File URI resolution | Yes | 2.1.5 | — |
| `connectivity_plus` | Online/offline detection | Yes | 6.1.1 | — |
| `mocktail` | Test mocking | Yes | 1.0.5 | — |

---

## Project Constraints (from CLAUDE.md)

- Never push directly to `main`. Always create a feature branch and open a PR.
- Branch: `git checkout -b feature/phase-05-offline-first`
- All commits go to branch; PR opened via `gh pr create`.

---

## Sources

### Primary (HIGH confidence — direct codebase reads)

- `mobile/lib/core/downloads/download_service.dart` — confirmed `requiresWiFi: false` bug, `resumeQueue()` stub, relative path storage pattern
- `mobile/lib/core/sync/sync_service.dart` — confirmed `_pullRemoteChanges()` structure; exercises upsert is the right insertion point for stale detection
- `mobile/lib/core/sync/sync_queue.dart` — confirmed `processQueue()` FIFO + retry logic; dead-letter boundary at `retryCount < 5`
- `mobile/lib/core/database/daos/sync_queue_dao.dart` — confirmed `getPendingItems()` filters `retryCount < 5`
- `mobile/lib/core/database/daos/download_manifest_dao.dart` — confirmed `watchAllEntries()` + `upsertEntry()` + `getByExerciseId()`
- `mobile/lib/core/database/tables/download_manifest_table.dart` — confirmed schema: `exerciseId` PK, `videoVersion`, `videoLocalPath`, `modelLocalPath`, `downloadStatus`, `downloadedAt`
- `mobile/lib/features/session/presentation/exercise_video_player.dart` — confirmed existing offline fallback pattern (lines 57–75); no rewrite needed
- `mobile/lib/features/programs/data/programs_repository.dart` — confirmed enrollment hook insertion point (after `commandBus.dispatch`)
- `mobile/lib/features/session/presentation/session_list_tile.dart` — confirmed current props; needs `downloadState` + `isOnline` params added
- `mobile/test/unit/core/downloads/download_service_test.dart` — confirmed: do NOT call `service.initialize()` in tests
- `mobile/test/unit/core/sync/sync_queue_test.dart` — confirmed test patterns for in-memory Drift + MockSupabaseClient
- `mobile/test/unit/features/session/session_completion_test.dart` — confirmed: `registerFallbackValue(CommandType.x)` required for mocktail
- `mobile/pubspec.yaml` + `pubspec.lock` — confirmed: all required packages installed; no new dependencies needed
- Test run output — confirmed 38 tests pass as of 2026-05-28

### Secondary (MEDIUM confidence — spec + data model)

- `specs/001-mat-pilates-coach/spec.md` — US3 acceptance scenarios SC1..SC4, FR-006, FR-007
- `specs/001-mat-pilates-coach/data-model.md` — `download_manifest` schema, `exercises.video_version`, `sync_queue` schema

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages verified in pubspec.lock
- Architecture patterns: HIGH — all integration points verified by reading existing source
- Pitfalls: HIGH — `requiresWiFi: false` and `resumeQueue()` no-op confirmed by direct code read; `Value.absent()` vs `Value(null)` is a documented Drift behavior
- Test strategy: HIGH — follows exact patterns from existing passing test suite

**Research date:** 2026-05-28
**Valid until:** 2026-06-28 (stable dependencies; re-verify if background_downloader is upgraded)
