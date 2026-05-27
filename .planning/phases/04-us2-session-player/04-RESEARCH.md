# Phase 4: US2 Session Player - Research

**Researched:** 2026-05-26
**Domain:** Flutter video playback (chewie/video_player), 3D model rendering (model_viewer_plus), Drift session-state persistence, CQRS progress recording, streak logic
**Confidence:** HIGH (all packages verified against pub.dev + existing codebase scouted)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Video is the primary content, full-screen during playback. The 3D model is a secondary on-demand reference — not shown by default.
- **D-02:** A small icon button (3D/body-form icon) overlaid on the video player lets the student toggle the 3D model open as a bottom sheet or slide-up panel over the video. Tapping again closes it.
- **D-03:** The 3D model viewer uses `model_viewer_plus` (already in pubspec) with the GLB asset URL from `exercises.model_asset_url`.
- **D-04:** Navigation through exercises is always manual — the student taps "Next Exercise" when ready, for both rep-based and timer-based exercises.
- **D-05:** For timer-based exercises, the countdown reaching zero enables/highlights the Next button but does NOT auto-advance.
- **D-06:** Rep-based exercises: large tap-target counter overlay. Each tap increments the count (e.g., "8 / 12 reps"). When target is reached, Next button activates/highlights.
- **D-07:** Timer-based exercises: visible countdown timer overlay, counts down to zero, then Next button activates.
- **D-08:** Exercise cue text (`exercises.cue_text`) is displayed as a persistent strip or card below the video/overlay area.
- **D-09:** Replace the existing placeholder in `ProgramDetailScreen` with rich session rows: day number, title, exercise count, estimated duration, and state indicator (complete/current/locked).
- **D-10:** "Today's session" row highlighted via `enrollment.current_day`. Past = checkmark; future = lock + non-tappable.
- **D-11:** Tapping current or past (completed) session navigates to `/programs/:programId/session/:sessionId`.
- **D-12:** Full-screen motivational completion screen: session title, total duration, exercise count, streak badge (FR-014), and "Send Feedback to Coach" CTA routing to `/feedback/:sessionId` (Phase 7 placeholder).
- **D-13:** Completion records a `progress_record` (command), increments `enrollment.current_day` (command), updates streak counter.
- **D-14:** Secondary "Back to Program" button dismisses completion screen and returns to `ProgramDetailScreen`.
- **D-15:** Per FR-013 and US2-SC4: re-opening app mid-session resumes from last incomplete exercise. Current exercise index persisted locally in Drift as session progress state and cleared on completion.

### Claude's Discretion
- Exact split ratios / sizing of the video area and bottom cue strip within the player screen
- Specific animation or visual polish on the rep counter (e.g., pulse on tap)
- Icon choice for the 3D model toggle button
- Whether cue text scrolls or truncates with a "more" expand
- Confetti or animation style on the completion screen (keep it calm and appropriate for a Pilates app)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FR-004 | System MUST present each program as a sequential day-by-day session list where future sessions are locked until previous ones are complete. | SessionsDao.watchSessionsByProgram + enrollment.current_day comparison covers lock state derivation |
| FR-005 | Each session MUST display exercises in order, each with: video player, 3D animation companion panel, rep/time overlay, and written cues. | chewie+video_player for video; model_viewer_plus for 3D; Stack+overlay widget for rep/timer; cue_text column on LocalExercises |
| FR-012 | System MUST display a completion screen with session summary after all exercises are finished. | Triggered when exercise index reaches exercises.length; writes progress_record + increments current_day |
| FR-013 | System MUST resume a partially completed session from the last incomplete exercise. | New `session_resume_state` Drift table (or column on local_sessions) to persist current exercise index |
| FR-014 | System MUST maintain a streak counter based on consecutive days with completed sessions. | Computed from progress_records ordered by completed_at; stored as local projection in Drift or computed on read |
</phase_requirements>

---

## Summary

Phase 4 builds the core daily workout loop: session list with lock/unlock state, a session player screen combining full-screen video (chewie + video_player) with an on-demand 3D model companion (model_viewer_plus), exercise-level rep/timer overlays, and a completion + streak screen.

All required packages are already declared in `pubspec.yaml` and resolved in `pubspec.lock` at exact target versions. All Drift tables and DAOs needed for data access (sessions, exercises, progress records, enrollments) exist and have the correct columns. The two gaps are: (1) no Drift table for mid-session resume state — a new `session_resume_state` table must be added with a Drift migration; (2) no streak computation utility — it must be derived from `local_progress_records` joined with `local_sessions` ordered by `completed_at`.

Both platform prerequisites for `model_viewer_plus` are already configured: `minSdk = 24` in `android/app/build.gradle.kts` and `io.flutter.embedded_views_preview = YES` in `ios/Runner/Info.plist`.

**Primary recommendation:** Build the session player as a `ConsumerStatefulWidget` (needs `State` for VideoPlayerController lifecycle), wire the existing DAOs directly, add one new Drift table for resume state with a `schemaVersion` bump to 2, and compute streak inline from `ProgressDao.getProgressByStudent`.

---

## Standard Stack

### Core (all versions verified against pubspec.lock 2026-05-26)

| Library | Version (locked) | Purpose | Status |
|---------|-----------------|---------|--------|
| `chewie` | 1.14.1 | Video player UI with Material/Cupertino controls | In pubspec.yaml, resolved |
| `video_player` | 2.11.1 | Low-level video controller (HLS via `networkUrl`) | In pubspec.yaml, resolved |
| `model_viewer_plus` | 1.10.0 | WebView-based GLB/glTF 3D renderer | In pubspec.yaml, resolved |
| `drift` | 2.33.0 | SQLite ORM for session resume state + queries | In pubspec.yaml, resolved |
| `flutter_riverpod` / `riverpod_annotation` | 3.3.1 / 4.0.2 | State management, providers | In pubspec.yaml, resolved |
| `go_router` | 17.2.3 | Routing — existing `session-player` route to replace | In pubspec.yaml, resolved |
| `freezed_annotation` | 3.1.0 | Domain model immutability | In pubspec.yaml, resolved |

No new packages need to be added. All packages are already present.

**Version verification:** All versions read directly from `/mobile/pubspec.lock` — no training-data assumptions.

---

## Architecture Patterns

### Recommended Project Structure for Phase 4

```
mobile/lib/features/session/
├── data/
│   ├── session_datasource.dart         # Queries sessions+exercises from Drift DAOs
│   └── session_datasource.g.dart
├── domain/
│   ├── session_model.dart              # Freezed: SessionModel, ExerciseModel
│   └── session_model.freezed.dart
└── presentation/
    ├── session_player_screen.dart      # ConsumerStatefulWidget (video lifecycle)
    ├── exercise_video_player.dart      # Chewie widget wrapper
    ├── rep_counter_overlay.dart        # Tap-to-count overlay widget
    ├── timer_countdown_overlay.dart    # Countdown timer overlay widget
    ├── model_viewer_sheet.dart         # Bottom sheet wrapping ModelViewer
    ├── cue_text_strip.dart             # Persistent cue text below video
    └── session_completion_screen.dart  # Full-screen completion with streak

mobile/lib/core/database/
├── tables/session_resume_state_table.dart   # NEW: persists exercise index
└── daos/session_resume_dao.dart             # NEW: read/write resume state
```

The session list enhancement goes into the existing `features/programs/presentation/program_detail_screen.dart` (D-09 through D-11), not a new file.

---

### Pattern 1: chewie + video_player for HLS Playback

**What:** `VideoPlayerController.networkUrl(Uri.parse(hlsUrl))` wraps the HLS stream; `ChewieController` wraps it for UI controls. Must be inside a `State` class (not a pure `ConsumerWidget`) because `VideoPlayerController` must be initialized async and disposed with `widget.dispose()`.

**Mux HLS URL format:**
```
https://stream.mux.com/{mux_playback_id}.m3u8
```
The `mux_playback_id` column exists on `local_exercises` (`muxPlaybackId`). When the device is offline and a local file was downloaded, resolve via `DownloadManifestDao.getByExerciseId()` and use `path_provider`'s `applicationDocumentsDirectory` + the stored relative path.

**Lifecycle pattern (verified from pub.dev docs + chewie GitHub example):**
```dart
// In ConsumerStatefulWidget State
late VideoPlayerController _vpc;
ChewieController? _chewieController;

@override
void initState() {
  super.initState();
  _initPlayer(exercise.muxPlaybackId);
}

Future<void> _initPlayer(String? playbackId) async {
  // Prefer local file if downloaded; fall back to HLS stream
  final manifest = await ref.read(appDatabaseProvider).downloadManifestDao
      .getByExerciseId(exercise.id);
  final Uri uri;
  if (manifest?.videoLocalPath != null &&
      manifest!.downloadStatus == 'complete') {
    final dir = await getApplicationDocumentsDirectory();
    uri = Uri.file('${dir.path}/${manifest.videoLocalPath}');
  } else {
    uri = Uri.parse('https://stream.mux.com/${playbackId}.m3u8');
  }

  _vpc = VideoPlayerController.networkUrl(uri);
  await _vpc.initialize();
  _chewieController = ChewieController(
    videoPlayerController: _vpc,
    autoPlay: true,
    looping: true,                        // exercises loop until student taps Next
    allowFullScreen: false,               // we manage our own fullscreen layout
    showControls: true,
    overlay: _buildOverlay(),             // rep counter or timer sits here
    placeholder: const CircularProgressIndicator(),
  );
  setState(() {});
}

@override
void dispose() {
  _chewieController?.dispose();
  _vpc.dispose();
  super.dispose();
}
```

**Key:** Pass `overlay:` to ChewieController (sits between video and controls layer) for the rep/timer widget. Alternatively, wrap `Chewie(...)` in a `Stack` and position the overlay above it — either approach works. Using `overlay:` parameter is cleaner.

**When to use:** Anytime an exercise screen is loaded. Reinitialize controller when exercise index advances (dispose old, create new).

---

### Pattern 2: model_viewer_plus in a Bottom Sheet

**What:** `ModelViewer` is a WebView-based widget. It's loaded on-demand when the user taps the 3D toggle icon (D-02). Opening as a `DraggableScrollableSheet` or `showModalBottomSheet` avoids permanently consuming screen space.

**Source:** `exercises.model_asset_url` contains a Supabase Storage path or full URL to the `.glb` file. If the file was downloaded locally (`download_manifest.model_local_path`), use the local path as a `file://` URL — `ModelViewer` accepts `file://` URIs on mobile.

```dart
// Trigger from icon button overlaid on video player
void _toggleModelViewer(BuildContext context, String modelUrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // drag handle
            const SizedBox(height: 8),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            Expanded(
              child: ModelViewer(
                src: modelUrl,         // 'file:///...' or 'https://...'
                cameraControls: true,
                autoRotate: true,
                autoRotateDelay: 1000,
                ar: false,             // AR is out of scope
                loading: Loading.eager,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Performance considerations:**
- ModelViewer is a WebView — it takes ~500ms–1500ms to initialize on first load. Use `loading: Loading.eager` (pre-fetches model immediately when widget appears) and a `poster:` image (exercise thumbnail or placeholder) to mask the load time.
- Do NOT keep a persistent ModelViewer widget in the widget tree when the sheet is closed — the WebView consumes ~40–80MB RAM while alive. `showModalBottomSheet` disposes it automatically on close.
- Supabase Storage URLs require CORS headers set to `*`. The model_viewer_plus docs require this for any remote GLB. Confirm with Supabase Storage bucket CORS policy before testing.
- iOS: `io.flutter.embedded_views_preview = YES` already in `Info.plist`. Android: `minSdk = 24` already set. No additional platform changes needed.

**Anti-pattern to avoid:** Do NOT embed ModelViewer directly in the exercise screen scaffold — it will initialize a WebView for every exercise even when never toggled. Lazy-load via bottom sheet only.

---

### Pattern 3: Rep Counter and Timer Overlays

**Rep counter (D-06):**

```dart
// Stateful widget — local state only, no provider needed
class RepCounterOverlay extends StatefulWidget {
  const RepCounterOverlay({
    super.key,
    required this.target,
    required this.onTargetReached,
  });
  final int target;
  final VoidCallback onTargetReached;

  @override
  State<RepCounterOverlay> createState() => _RepCounterOverlayState();
}

class _RepCounterOverlayState extends State<RepCounterOverlay> {
  int _count = 0;

  void _increment() {
    if (_count >= widget.target) return;
    setState(() => _count++);
    if (_count == widget.target) widget.onTargetReached();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _increment,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_count / ${widget.target} reps',
        style: const TextStyle(fontSize: 32, color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    ),
  );
}
```

**Timer countdown (D-07):**
Use `dart:async` `Timer.periodic` inside a `State`. No third-party package needed.

```dart
class TimerCountdownOverlay extends StatefulWidget {
  const TimerCountdownOverlay({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
  });
  final int durationSeconds;
  final VoidCallback onComplete;

  @override
  State<TimerCountdownOverlay> createState() => _TimerCountdownState();
}

class _TimerCountdownState extends State<TimerCountdownOverlay> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        setState(() => _remaining = 0);
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 48, color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

**Key:** Both overlays are purely local-state `StatefulWidget`s. They need no Riverpod provider. They call back to the parent (session player) which owns the "Next button active" state. The session player screen holds a `bool _nextEnabled` in local state toggled by the overlay's callback.

---

### Pattern 4: Session Resume State — New Drift Table

**What:** FR-013 requires persisting current exercise index so app restart resumes mid-session. The existing Drift schema has no such table. A new table `session_resume_state` must be added, and `AppDatabase.schemaVersion` bumped to 2 with a migration.

**New table:**
```dart
// mobile/lib/core/database/tables/session_resume_state_table.dart
class SessionResumeState extends Table {
  @override
  String get tableName => 'session_resume_state';

  TextColumn get sessionId => text()();      // PK
  TextColumn get studentId => text()();
  IntColumn get exerciseIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sessionId};
}
```

**Migration in AppDatabase:**
```dart
@DriftDatabase(tables: [..., SessionResumeState], ...)
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(sessionResumeState);
      }
    },
  );
}
```

**New DAO:**
```dart
@DriftAccessor(tables: [SessionResumeState])
class SessionResumeDao extends DatabaseAccessor<AppDatabase>
    with _$SessionResumeDaoMixin {
  SessionResumeDao(super.attachedDatabase);

  Future<SessionResumeStateData?> getResumeState(
          String sessionId) =>
      (select(sessionResumeState)
            ..where((t) => t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  Future<void> saveResumeState(String sessionId, String studentId,
          int exerciseIndex) =>
      into(sessionResumeState).insertOnConflictUpdate(
        SessionResumeStateCompanion(
          sessionId: Value(sessionId),
          studentId: Value(studentId),
          exerciseIndex: Value(exerciseIndex),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> clearResumeState(String sessionId) =>
      (delete(sessionResumeState)
            ..where((t) => t.sessionId.equals(sessionId)))
          .go();
}
```

**Usage in SessionPlayerScreen:**
- `initState`: read `SessionResumeDao.getResumeState(sessionId)` → set `_currentExerciseIndex`.
- On exercise advance (Next tap): call `SessionResumeDao.saveResumeState(...)`.
- On session completion: call `SessionResumeDao.clearResumeState(sessionId)`.

---

### Pattern 5: Session Completion Command (CQRS Write)

**Existing infrastructure:** `CommandBus.dispatch(CommandType.completeSession, payload)` already routes to `progress_records` table. Enrollment `current_day` increment uses the existing `EnrollmentsDao.updateCurrentDay()`.

**What to do on completion (D-13):**

```dart
Future<void> _completeSession({
  required String studentId,
  required String sessionId,
  required String enrollmentId,
  required int currentDay,
  required int durationSeconds,
}) async {
  final now = DateTime.now();
  final progressId = const Uuid().v4();

  // 1. Write progress_record to Drift (source of truth locally)
  await db.progressDao.upsertProgress(LocalProgressRecordsCompanion(
    id: Value(progressId),
    studentId: Value(studentId),
    sessionId: Value(sessionId),
    completedAt: Value(now),
    durationSeconds: Value(durationSeconds),
    createdAt: Value(now),
  ));

  // 2. Enqueue to CommandBus for Supabase sync
  await commandBus.dispatch(CommandType.completeSession, {
    'id': progressId,
    'student_id': studentId,
    'session_id': sessionId,
    'completed_at': now.toIso8601String(),
    'duration_seconds': durationSeconds,
  });

  // 3. Increment enrollment current_day locally
  await db.enrollmentsDao.updateCurrentDay(enrollmentId, currentDay + 1);

  // 4. Clear resume state
  await db.sessionResumeDao.clearResumeState(sessionId);
}
```

Note: There is no separate CommandType for enrollment `current_day` increment — it is a local-only update. The enrollment row was already synced to Supabase when the student enrolled. The `current_day` field is updated locally; a future sync or dedicated `updateEnrollment` command would propagate it. For Phase 4 (offline-first sync is Phase 5), local-only is sufficient.

---

### Pattern 6: Session List Lock State Derivation

**What:** The session list rows display complete/current/locked state derived from `enrollment.current_day` and the session's `day_number`.

```
session.dayNumber < enrollment.currentDay  → COMPLETE (checkmark, tappable)
session.dayNumber == enrollment.currentDay → CURRENT  (highlighted, tappable)
session.dayNumber > enrollment.currentDay  → LOCKED   (lock icon, non-tappable)
```

**Data query — no new DAO needed:**

```dart
// In SessionDatasource or directly in the provider
Future<List<SessionRowModel>> getSessionsWithState({
  required String programId,
  required int currentDay,
}) async {
  final sessions = await db.sessionsDao.getSessionsByProgram(programId);
  return sessions.map((s) {
    final exercisesFuture = db.exercisesDao.getExercisesBySession(s.id);
    // For exercise count: we need a count query or load and take .length
    return SessionRowModel(
      session: s,
      state: s.dayNumber < currentDay
          ? SessionState.complete
          : s.dayNumber == currentDay
              ? SessionState.current
              : SessionState.locked,
    );
  }).toList();
}
```

For exercise count per session, a dedicated `ExercisesDao` method `getExerciseCountBySession(String sessionId)` should be added — it avoids loading full exercise rows just for a count.

**No exercise count column exists on `local_sessions`** — count must come from joining/querying `local_exercises`. The planner must add this DAO method.

---

### Pattern 7: Streak Counter Logic

**What (FR-014):** Consecutive days with at least one completed session. Streaks are calendar-day based, not session-order based.

**Where to compute:** Computed on read from `local_progress_records` joined with `local_sessions`. No separate streak table needed for Phase 4 (streak display on completion screen). The `student_progress_dashboard_view` is deferred to Phase 6; Phase 4 only needs the current streak value for the completion screen badge.

**Algorithm (Dart):**
```dart
int computeCurrentStreak(List<LocalProgressRecord> records) {
  if (records.isEmpty) return 0;
  // Get unique calendar dates with at least one completion
  final completedDates = records
      .map((r) => DateOnly(r.completedAt))  // normalize to date without time
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));       // descending

  // Today's date
  final today = DateOnly(DateTime.now());
  // If most recent is not today or yesterday, streak is broken
  if (completedDates.first != today &&
      completedDates.first != today.subtract(const Duration(days: 1))) {
    return 0;
  }

  int streak = 1;
  for (int i = 0; i < completedDates.length - 1; i++) {
    final diff = completedDates[i].difference(completedDates[i + 1]);
    if (diff.inDays == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
```

`DateOnly` is a helper that zeroes out the time component — use `DateTime(dt.year, dt.month, dt.day)` for this. No third-party package needed.

**Where to call:** In a Riverpod `FutureProvider` that reads from `ProgressDao.getProgressByStudent(studentId)` after session completion, before navigating to the completion screen.

**Timezone edge case (from spec):** The spec notes potential timezone issues. For Phase 4, use the device's local timezone (default `DateTime.now()`) and note this as a known limitation. Phase 6 (metrics) can add IANA timezone-aware streak computation.

---

### Pattern 8: Session Player Screen Layout

```
Scaffold
├── body: Column
│   ├── Expanded (video + overlay area)
│   │   └── Stack
│   │       ├── Chewie(controller: _chewieController)     // full-width video
│   │       ├── Positioned (3D toggle icon, top-right)
│   │       │   └── IconButton → _toggleModelViewer()
│   │       └── Center
│   │           └── RepCounterOverlay | TimerCountdownOverlay (conditional)
│   └── Container (cue text strip, ~120px)
│       └── CueTextStrip(text: exercise.cueText)
└── bottomNavigationBar: SafeArea
    └── Padding
        └── FilledButton('Next Exercise' | 'Finish Session')
                → enabled only when _nextEnabled == true
```

Navigation: When `_currentExerciseIndex < exercises.length - 1`, tapping Next increments index, re-inits video player, saves resume state. When on last exercise and Next tapped, calls `_completeSession` and routes to `SessionCompletionScreen`.

---

### Anti-Patterns to Avoid

- **Reinitializing ChewieController without disposing first:** Always `_chewieController?.dispose(); _vpc.dispose()` before creating new instances for the next exercise. Failure causes memory leak + black screen.
- **Keeping ModelViewer in the widget tree when hidden:** ModelViewer holds a live WebView. Close it via `Navigator.pop` (modal bottom sheet auto-disposes). Never hide it with `Visibility(visible: false, ...)` — the WebView stays in memory.
- **Using `autoPlay: true` on ChewieController without `autoInitialize`:** `autoInitialize` is false by default. Set it true OR call `_vpc.initialize()` manually before creating ChewieController. Otherwise the video won't start even with `autoPlay: true`.
- **Deriving lock state from remote fetch per row:** Compute lock state purely from local Drift data (enrollment.currentDay + session.dayNumber). No network call needed for the session list.
- **Forgetting to bump schemaVersion:** Adding `session_resume_state` table REQUIRES `schemaVersion => 2` and a `MigrationStrategy.onUpgrade` that calls `m.createTable(sessionResumeState)`. Skipping this crashes existing installs.
- **Timer not disposed on widget unmount:** `Timer.periodic` in `TimerCountdownOverlay` must be cancelled in `dispose()`. Not cancelling causes setState-after-dispose errors when navigating away mid-timer.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| HLS streaming + seek controls | Custom HLS player | `chewie` ^1.14.1 + `video_player` ^2.11.1 | HLS adaptive bitrate, buffering indicators, seek bar, full-screen toggle — hundreds of edge cases |
| GLB 3D rendering | Custom OpenGL renderer | `model_viewer_plus` ^1.10.0 | Google's model-viewer.js handles GLTF parsing, PBR lighting, mobile gesture controls |
| Background downloads with resume | Custom HTTP chunked download | `background_downloader` ^9.5.4 (already in use) | iOS Background Fetch, Android DownloadManager bridging, pause/resume — already wired in `DownloadService` |
| SQLite migrations | Manual `ALTER TABLE` | Drift `MigrationStrategy.onUpgrade` | Drift generates the schema diff; manual SQL errors are silent on SQLite |
| Offline write queue | Custom retry mechanism | `SyncQueue` + `CommandBus` (already in use) | Already built in Phase 2, already has `completeSession` command type |

**Key insight:** All the hard infrastructure is already built. Phase 4 is almost entirely UI composition on top of existing plumbing.

---

## Common Pitfalls

### Pitfall 1: VideoPlayerController Double-Init

**What goes wrong:** `_vpc.initialize()` is called, then `ChewieController` is created, then exercise advances and a new `_vpc.initialize()` is called on a new controller — but the old one was never disposed. Flutter throws "A VideoPlayerController was used after being disposed."

**Why it happens:** `State._initPlayer()` is called again on exercise index change without guarding against an in-flight init.

**How to avoid:** Use an `_isInitializing` flag. Dispose old controllers synchronously before creating new ones. Pattern:
```dart
Future<void> _goToExercise(int index) async {
  _chewieController?.dispose();
  await _vpc.dispose();
  setState(() { _currentIndex = index; _nextEnabled = false; });
  await _initPlayer(exercises[index]);
}
```

**Warning signs:** Black video screen, "disposed controller" exception in debug console.

---

### Pitfall 2: model_viewer_plus CORS Failure

**What goes wrong:** `ModelViewer(src: 'https://storage.supabase.co/...')` shows a blank WebView with a console CORS error. The 3D model silently fails to load.

**Why it happens:** The model_viewer_plus WebView runs in a browser context. Supabase Storage buckets have restricted CORS by default; they must explicitly allow `*` or the app's scheme.

**How to avoid:** Set the Supabase Storage bucket CORS policy for the models bucket to allow all origins (`*`) before testing. For local files (`file://` path from download_manifest), CORS is not an issue.

**Warning signs:** Blank ModelViewer widget, JS console (Flutter `--verbose`) shows "Access-Control-Allow-Origin" error.

---

### Pitfall 3: Drift Migration Not Run on Existing Installs

**What goes wrong:** Developer adds `session_resume_state` table, bumps `schemaVersion` to 2, but forgets `MigrationStrategy.onUpgrade`. On a device that had schema v1, the table doesn't exist → Drift throws `SqliteException: no such table: session_resume_state`.

**Why it happens:** Drift won't auto-create new tables on upgrade without explicit migration.

**How to avoid:** Always add both: `int get schemaVersion => 2;` AND the migration body `if (from < 2) await m.createTable(sessionResumeState);`.

**Warning signs:** Works on fresh installs (no existing DB), crashes on update.

---

### Pitfall 4: go_router `pathParameters` Must Match Route Template

**What goes wrong:** Navigating via `context.goNamed('session-player', pathParameters: {'programId': ..., 'sessionId': ...})` throws "Required parameter not found" or silently navigates to wrong route.

**Why it happens:** The session-player route is nested under `:programId` — so `programId` must be passed in `pathParameters`. Missing either parameter crashes the router.

**How to avoid:** The existing route template is `/programs/:programId/session/:sessionId`. Always pass both: `pathParameters: {'programId': programId, 'sessionId': session.id}`.

**Warning signs:** Router assertion errors in debug; blank screen in release.

---

### Pitfall 5: Streak Computed from Future Completions

**What goes wrong:** After `_completeSession` writes the progress record to Drift, the streak provider is computed before Drift has committed the new record. Streak shows previous value on the completion screen.

**Why it happens:** Riverpod `ref.invalidate(streakProvider)` doesn't wait for the next Drift read; the completion screen builds immediately.

**How to avoid:** Compute streak synchronously inside `_completeSession` after the Drift write returns, and pass it directly to the completion screen as a constructor parameter. Don't rely on reactive invalidation for the immediate post-completion display.

---

## Code Examples

### Full chewie + HLS Initialization with Local Fallback

```dart
// Source: video_player pub.dev docs + chewie GitHub example (verified 2026-05-26)
Future<void> _initPlayer(LocalExercise exercise) async {
  final manifest = await _db.downloadManifestDao
      .getByExerciseId(exercise.id);
  final Uri videoUri;
  if (manifest?.videoLocalPath != null &&
      manifest!.downloadStatus == 'complete') {
    final dir = await getApplicationDocumentsDirectory();
    videoUri = Uri.file('${dir.path}/${manifest.videoLocalPath}');
  } else if (exercise.muxPlaybackId != null) {
    videoUri = Uri.parse(
        'https://stream.mux.com/${exercise.muxPlaybackId}.m3u8');
  } else {
    // No video available — show placeholder
    setState(() => _videoAvailable = false);
    return;
  }
  _vpc = VideoPlayerController.networkUrl(videoUri);
  await _vpc.initialize();
  setState(() {
    _chewieController = ChewieController(
      videoPlayerController: _vpc,
      autoPlay: true,
      looping: true,
      allowFullScreen: false,
      showControls: true,
    );
  });
}
```

### Session Row Widget (lock/complete/current state)

```dart
// Derived entirely from local Drift data, no network call
class SessionListTile extends StatelessWidget {
  const SessionListTile({
    super.key,
    required this.session,
    required this.state,    // SessionState enum
    required this.exerciseCount,
    this.onTap,
  });

  final LocalSession session;
  final SessionState state;
  final int exerciseCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (state) {
      SessionState.complete => (Icons.check_circle, Colors.green),
      SessionState.current  => (Icons.play_circle_filled,
                                Theme.of(context).colorScheme.primary),
      SessionState.locked   => (Icons.lock, Colors.grey),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('Day ${session.dayNumber}: ${session.title}'),
      subtitle: Text('$exerciseCount exercises · ~20 min'),
      trailing: state == SessionState.locked
          ? null
          : const Icon(Icons.chevron_right),
      onTap: state == SessionState.locked ? null : onTap,
      tileColor: state == SessionState.current
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
    );
  }
}

enum SessionState { complete, current, locked }
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `VideoPlayerController.network(url)` | `VideoPlayerController.networkUrl(Uri.parse(url))` | video_player 2.x | Old constructor deprecated; must use `networkUrl` with `Uri` object |
| Global `ChewieController` singleton | Per-exercise controller in `State` | Always best practice | Different videos per exercise require fresh controllers |
| model_viewer_plus `<model-viewer>` web script in index.html | Not needed for mobile | Package bundles the JS asset | Only needed for Flutter Web target |

---

## Open Questions

1. **Supabase Storage CORS for GLB models**
   - What we know: model_viewer_plus requires `Access-Control-Allow-Origin: *` on the serving domain.
   - What's unclear: Whether the project's Supabase Storage bucket CORS policy has been configured.
   - Recommendation: Add a Wave 0 task to verify/set bucket CORS policy before the first model_viewer integration test. If CORS not set, ModelViewer will silently show blank.

2. **Enrollment `current_day` sync strategy**
   - What we know: `EnrollmentsDao.updateCurrentDay()` updates local Drift only. The sync queue has no `updateEnrollment` command type.
   - What's unclear: Whether Phase 4 should add an `updateEnrollment` sync command or defer to Phase 5 (offline sync).
   - Recommendation: Defer full sync to Phase 5 per the phase boundary. Phase 4 writes `current_day` locally only. The planner should document this as a known Phase 5 handoff item.

3. **Exercise count for session list rows**
   - What we know: `local_sessions` has no `exercise_count` column; it must be queried from `local_exercises`.
   - What's unclear: Whether a `COUNT` query or loading all exercises and counting is more appropriate.
   - Recommendation: Add `getExerciseCountBySession(String sessionId) → Future<int>` to `ExercisesDao` using Drift's `countAll()` expression for efficiency.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `chewie` / `video_player` | Video playback | Yes (pubspec.lock) | 1.14.1 / 2.11.1 | — |
| `model_viewer_plus` | 3D model viewer | Yes (pubspec.lock) | 1.10.0 | — |
| Android `minSdk = 24` | model_viewer_plus | Yes (build.gradle.kts) | 24 | — |
| iOS `embedded_views_preview` plist key | model_viewer_plus | Yes (Info.plist) | YES | — |
| `path_provider` | Local video file resolution | Yes (pubspec.lock) | 2.1.5 | — |
| `background_downloader` | Pre-downloaded media | Yes (pubspec.lock) | 9.5.4 | HLS stream fallback |
| Drift `schemaVersion` migration | session_resume_state table | Requires code change | v1 → v2 | — (blocker if not done) |
| Supabase Storage CORS for GLB | ModelViewer remote loading | Unknown — needs verification | — | Use only local downloaded files |

**Missing dependencies with no fallback:**
- Drift migration (schemaVersion 1 → 2) is a code change, not a missing tool; it blocks resume persistence if not done.

**Missing dependencies with fallback:**
- Supabase CORS for GLB: if not set, fallback to local downloaded `.glb` files only. ModelViewer will still work with `file://` paths.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) + mocktail ^1.0.5 |
| Config file | none — standard `flutter test` |
| Quick run command | `cd mobile && flutter test test/unit/features/session/ -x` |
| Full suite command | `cd mobile && flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FR-004 | Lock state: session.dayNumber vs enrollment.currentDay | unit | `flutter test test/unit/features/session/session_lock_state_test.dart -x` | No — Wave 0 |
| FR-013 | Resume: index persisted to Drift, loaded on init | unit | `flutter test test/unit/features/session/session_resume_test.dart -x` | No — Wave 0 |
| FR-014 | Streak: consecutive days computed correctly | unit | `flutter test test/unit/features/session/streak_test.dart -x` | No — Wave 0 |
| FR-005 | Exercise display order (video + overlay selection) | widget | `flutter test test/widget/session_player_screen_test.dart -x` | No — Wave 0 |
| FR-012 | Completion: progress_record written + currentDay incremented | unit | `flutter test test/unit/features/session/session_completion_test.dart -x` | No — Wave 0 |
| SC-002 | Video starts within 2s (pre-downloaded, file:// URI) | manual / integration | Manual on device: tap session → time to first frame | — |
| SC-003 | 3D model loads within 1s | manual | Manual on device: tap 3D icon → time to first render | — |

SC-002 and SC-003 are timing SCs that require real device measurement, not automated unit tests. They are tracked in Phase 9 benchmarks.

### Sampling Rate
- **Per task commit:** `cd mobile && flutter test test/unit/features/session/ -x`
- **Per wave merge:** `cd mobile && flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/unit/features/session/session_lock_state_test.dart` — covers FR-004
- [ ] `test/unit/features/session/session_resume_test.dart` — covers FR-013
- [ ] `test/unit/features/session/streak_test.dart` — covers FR-014
- [ ] `test/unit/features/session/session_completion_test.dart` — covers FR-012
- [ ] `test/widget/session_player_screen_test.dart` — covers FR-005 (widget smoke test)

---

## Project Constraints (from CLAUDE.md)

| Directive | Impact on Phase 4 |
|-----------|------------------|
| Never push directly to `main` | All Phase 4 work goes on a feature branch. The GSD planning agents should be spawned after `git checkout -b feat/phase-4-session-player` |
| Always create a PR | Phase 4 work is merged via `gh pr create`, not direct push |

---

## Sources

### Primary (HIGH confidence)
- `mobile/pubspec.lock` — verified all package versions (chewie 1.14.1, video_player 2.11.1, model_viewer_plus 1.10.0, drift 2.33.0)
- `mobile/lib/core/database/` — all Drift table definitions and DAOs scouted directly
- `mobile/lib/features/programs/` — established CQRS/Riverpod/Freezed patterns read from source
- `mobile/lib/shared/router/app_router.dart` — confirmed route structure
- `mobile/android/app/build.gradle.kts` — confirmed minSdk = 24
- `mobile/ios/Runner/Info.plist` — confirmed embedded_views_preview = YES
- pub.dev/packages/chewie documentation (2026-05-26) — ChewieController parameter list
- pub.dev/packages/video_player documentation (2026-05-26) — networkUrl constructor, initialize pattern
- www.mux.com/docs/guides/play-your-videos — HLS URL format `https://stream.mux.com/{PLAYBACK_ID}.m3u8`
- pub.dev/packages/model_viewer_plus (2026-05-26) — constructor params, CORS requirements, platform setup

### Secondary (MEDIUM confidence)
- model_viewer_plus README for iOS/Android platform setup (confirmed against actual project files)
- chewie GitHub README for StatefulWidget lifecycle pattern

### Tertiary (LOW confidence)
- None

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all versions verified against pubspec.lock on disk
- Architecture patterns: HIGH — derived from actual codebase patterns (ProgramsRepository, CommandBus, existing DAOs)
- Video playback (chewie/video_player): HIGH — pub.dev docs + GitHub source confirmed
- model_viewer_plus: MEDIUM-HIGH — pub.dev docs confirmed; CORS behavior for Supabase Storage untested
- Streak logic: HIGH — pure Dart algorithm, no external dependency
- Drift migration: HIGH — standard Drift migration pattern, schemaVersion bump required
- Pitfalls: HIGH — based on source code review + official docs

**Research date:** 2026-05-26
**Valid until:** 2026-06-26 (stable ecosystem; model_viewer_plus and chewie are mature; drift APIs stable)
