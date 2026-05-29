# Phase 7: US5 Private Feedback (Coach Chat) — Research

**Researched:** 2026-05-29
**Domain:** Flutter chat UI, FCM push notifications, Supabase Realtime, Supabase Storage (photo upload), offline-first messaging, image_picker, flutter_local_notifications
**Confidence:** HIGH (all claims verified against codebase or official docs)

---

## Project Constraints (from CLAUDE.md)

- Never push directly to `main` — always branch + PR
- GSD agents must operate on a feature branch (checked out before spawning)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FR-010 | Students MUST be able to submit private session feedback (text + optional photo) directly to the coach after completing a session; messages visible only to the student and coach | FeedbackRepository (local Drift write + SyncQueue), `feedback_threads` table and RLS already exist, `image_picker` + Supabase Storage upload path identified |
| FR-010a | System MUST NOT expose any community commenting, public activity feed, or shared message board. All student–coach communication is strictly private 1-to-1 | RLS policy `feedback_select_own` already enforces `student_id = auth.uid()` in `001_initial_schema.sql`; no coach list query is exposed in student SDK |
| FR-011 | System MUST deliver push notifications for coach replies to feedback | Firebase already initialized (placeholder), `firebase_messaging` 16.2.2 and `flutter_local_notifications` 18.0.1 already in pubspec; FCM token storage + Supabase trigger path documented |
</phase_requirements>

---

## Summary

Phase 7 builds the private 1-to-1 coach chat feature: a Coach tab in the bottom nav (replacing the `/feedback/:sessionId` placeholder), a full-screen iMessage-style chat thread (CoachChatScreen), a paywall gate for non-premium users (CoachPaywallScreen), a FeedbackComposeBottomSheet reachable from SessionCompletionScreen, and push notification delivery when the coach replies.

The core data layer is already in place. `feedback_threads` table exists in Supabase with correct RLS. `LocalFeedbackThreads` Drift table, `FeedbackDao`, and `SyncService._pullRemoteChanges` pull for `feedback_threads` are all already wired. The `student_notifications_view` CQRS view already aggregates coach replies. The main work is the application layer (FeedbackRepository, FCM token management, FCM notification handler) and the presentation layer (Coach tab with bottom nav, chat bubble UI, compose bar, photo attachment, paywall screen, notification list screen).

Two missing pieces require attention before plan work begins: `image_picker` is not yet in pubspec (not installed), and Firebase is still a TODO stub in `main.dart` with placeholder config files.

**Primary recommendation:** Build FeedbackRepository mirroring MetricRepository's CQRS pattern (local Drift write + SyncQueue enqueue), wire FCM initialization and token upsert, then implement presentation in UI-SPEC order: paywall screen, chat screen with bubbles, compose bar, photo attachment, FeedbackComposeBottomSheet, notifications screen.

---

## Standard Stack

### Core

| Library | Version (locked) | Purpose | Why Standard |
|---------|-----------------|---------|--------------|
| `firebase_messaging` | 16.2.2 | FCM token registration, background message handling | Already in pubspec.lock; official FlutterFire package |
| `firebase_core` | 4.9.0 | Firebase initialization | Already in pubspec.lock |
| `flutter_local_notifications` | 18.0.1 | Show OS notification banner when app is foreground | Already in pubspec.lock |
| `image_picker` | NOT YET INSTALLED | Camera + gallery photo picker | Standard Flutter photo picker; must be added |
| `supabase_flutter` | 2.12.4 | Supabase Storage upload (photo), Realtime subscription | Already in pubspec.lock |
| `drift` | 2.33.0 | Local offline chat message storage | Already in pubspec.lock |
| `riverpod_annotation` | 4.0.2 | Provider generation | Already in pubspec.lock |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `go_router` | 17.2.3 | `/coach-chat` deep-link route, `/notifications` route | Deep-link from FCM notification tap |
| `uuid` | 4.5.1 | Generate feedback thread IDs client-side | Same as metric_repository.dart pattern |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `image_picker` | `camera` | `image_picker` handles both gallery + camera in one API; simpler |
| FCM + `flutter_local_notifications` | `awesome_notifications` | FCM+FLN is the standard FlutterFire stack and already declared in pubspec |
| Supabase Storage for photos | Mux / external CDN | Spec says Mux is for video only; photos go to Supabase Storage per data-model |

### Installation (missing package only)

```bash
cd mobile
flutter pub add image_picker
```

After adding, run `flutter pub get` then `build_runner build` (no new generated files needed from image_picker itself, but must re-run to keep `.g.dart` files fresh if other annotations change).

**Version verification:** `image_picker` latest stable as of 2026-05 is `^1.1.2`. Confirm with `flutter pub outdated` after adding.

---

## Architecture Patterns

### Recommended Project Structure

```
mobile/lib/features/coach_chat/
├── data/
│   ├── feedback_repository.dart         # CQRS: Drift write + SyncQueue enqueue
│   ├── feedback_repository.g.dart
│   ├── feedback_providers.dart          # Riverpod providers
│   ├── feedback_providers.g.dart
│   └── fcm_service.dart                 # FCM token init + deep-link handler
├── domain/
│   └── feedback_message_model.dart      # Freezed domain model (FeedbackMessage)
└── presentation/
    ├── coach_tab_screen.dart            # Premium gate: routes to chat or paywall
    ├── coach_chat_screen.dart           # iMessage-style thread
    ├── coach_paywall_screen.dart        # Lock screen for non-premium users
    ├── notifications_screen.dart        # Coach reply notification list
    ├── feedback_compose_bottom_sheet.dart  # Post-session compose sheet
    └── widgets/
        ├── chat_bubble.dart             # Reusable bubble (student/coach variants)
        ├── compose_bar.dart             # TextField + camera + send
        └── photo_thumbnail.dart         # 160x120 thumbnail + full-screen viewer
```

**Existing infra to reuse — do NOT recreate:**

- `mobile/lib/core/database/daos/feedback_dao.dart` — `watchFeedbackByStudent`, `upsertFeedback`, `watchReplies`
- `mobile/lib/core/database/tables/feedback_threads_table.dart` — `LocalFeedbackThreads`
- `SyncService._pullRemoteChanges` already pulls `feedback_threads` from Supabase on sync
- `student_notifications_view` — Supabase view already exists (migration 003) for notifications screen query

### Pattern 1: FeedbackRepository (CQRS — mirrors MetricRepository)

**What:** Local-first write with SyncQueue replay. Matches the established pattern in `metric_repository.dart`.
**When to use:** Sending new messages (insert), receiving coach replies is pull-driven via SyncService.

```dart
// Source: mirrors mobile/lib/features/metrics/data/metric_repository.dart
class FeedbackRepository {
  FeedbackRepository({
    required this.db,
    required this.syncQueue,
    required this.studentId,
  });

  final AppDatabase db;
  final SyncQueue syncQueue;
  final String studentId;

  Future<void> submitFeedback({
    required String sessionId,
    required String message,
    String? photoUrl,         // Supabase Storage path, uploaded before calling this
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // 1. Local write (immediate)
    await db.feedbackDao.upsertFeedback(LocalFeedbackThreadsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      studentMessage: Value(message),
      photoUrl: Value(photoUrl),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));

    // 2. Enqueue remote write
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'feedback_threads',
      payload: {
        'id': id,
        'student_id': studentId,
        'session_id': sessionId,
        'student_message': message,
        'photo_url': photoUrl,
        'created_at': now.toUtc().toIso8601String(),
        'updated_at': now.toUtc().toIso8601String(),
      },
    );
  }

  /// Query: reactive stream of all messages for this student, ordered asc for chat display.
  Stream<List<LocalFeedbackThread>> watchThread() =>
      db.feedbackDao.watchFeedbackByStudent(studentId);

  /// Query: reactive stream of coach replies only (for notifications screen).
  Stream<List<LocalFeedbackThread>> watchReplies() =>
      db.feedbackDao.watchReplies(studentId);
}
```

### Pattern 2: Pending Message Status in Drift

**What:** `local_feedback_threads` needs a `status` field (`sent` | `pending`) to show the clock icon on offline messages. The current `LocalFeedbackThreads` Drift table does NOT have this column — it must be added via a Drift schema migration.

**Schema migration required:** schemaVersion must increment from `2` to `3`, with an `onUpgrade` that adds `status TEXT NOT NULL DEFAULT 'sent'` to `local_feedback_threads`.

```dart
// Wave 0 migration in app_database.dart:
@override
int get schemaVersion => 3;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) await m.createTable(sessionResumeState);
    if (from < 3) {
      // Add status column to local_feedback_threads
      await m.addColumn(localFeedbackThreads, localFeedbackThreads.status);
    }
  },
);
```

The `LocalFeedbackThreads` table class must add: `TextColumn get status => text().withDefault(const Constant('sent'))();`

Messages sent offline get `status: 'pending'`; updated to `'sent'` after SyncQueue successfully processes.

### Pattern 3: FCM Initialization

**What:** Firebase must be initialized before `runApp`. Currently a TODO comment in `main.dart`. The `firebase_options.dart` file is a placeholder stub — real `flutterfire configure` output is needed for the real Firebase project, but the code pattern is already correct.

```dart
// In main.dart — replace the TODO comment:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

**FCM token registration:** After Firebase init + user sign-in, obtain the FCM token and upsert it to a `fcm_tokens` table (or `students.fcm_token` column). The admin panel reads this token when the coach replies.

**Current gap:** There is no `fcm_token` field on the `students` table and no migration for it. A new Supabase migration `004_fcm_tokens.sql` is needed:

```sql
ALTER TABLE students ADD COLUMN fcm_token text;
```

Also a new Drift column on `LocalStudents` — but since `students` has no local mirror table in Drift (student profile is not in Drift tables), the FCM token only needs to be written to Supabase directly (no local Drift write needed, no SyncQueue — it's a session-init write, always online).

### Pattern 4: Push Notification Deep-Link Handler

**What:** When the app is terminated and the user taps an FCM notification, `GoRouter` must navigate to `/coach-chat`. `flutter_local_notifications` handles foreground display; `firebase_messaging` handles background + terminated state.

```dart
// In FcmService or main.dart after Firebase.initializeApp:
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  if (message.data['type'] == 'coach_reply') {
    router.go('/coach-chat');
  }
});

// For terminated state:
final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage?.data['type'] == 'coach_reply') {
  // Set pending deep link; router reads it after init
}
```

iOS requires `UNUserNotificationCenter` delegate setup. With `firebase_messaging` 16.x and `flutter_local_notifications` 18.x, the standard pattern is to call `FirebaseMessaging.instance.requestPermission()` and configure `FlutterLocalNotificationsPlugin` in `main()`.

### Pattern 5: Supabase Storage Photo Upload

**What:** Before calling `FeedbackRepository.submitFeedback`, upload the photo to Supabase Storage and get back a path. Upload happens on the command path (before SyncQueue enqueue).

**Offline handling:** If offline when user taps send with a photo, store the local file path in `photoUrl` as a `file://` URI with `status: 'pending'`. The SyncQueue replayer must first upload the photo to Supabase Storage, then upsert the feedback row. This is more complex than the metric case — the SyncQueue's generic `_replayItem` cannot handle it. Two options:

1. **Simpler:** Require online connection for photo sends. If offline when photo is selected, disable the send button and show "Connect to send with photo". Text-only messages go offline as usual.
2. **Correct per spec:** The spec says "Photo attachments: upload to Supabase Storage on send; if offline, upload queued." This means FeedbackRepository must store the local file path in a separate field (NOT `photo_url`) and the SyncQueue replay logic must handle a two-step: upload → set `photo_url` → insert row.

**Recommendation:** Add a `localPhotoPath TEXT` column to `LocalFeedbackThreads` (Drift migration). When online: upload immediately, set `photo_url` = storage path. When offline: store `localPhotoPath`, set `status = 'pending'`. On sync reconnect: upload `localPhotoPath` → get storage URL → set `photo_url` → proceed with normal SyncQueue enqueue. This requires a specialized sync step in SyncService, not the generic `_replayItem`.

### Pattern 6: Premium Gate in Coach Tab

**What:** The Coach tab checks `isSubscribedProvider` (already exists from Phase 3). If not premium, shows `CoachPaywallScreen`. If premium, shows `CoachChatScreen`.

```dart
// CoachTabScreen (stateless routing screen, not a separate route)
class CoachTabScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    return isSubscribed.when(
      data: (sub) => sub ? const CoachChatScreen() : const CoachPaywallScreen(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const CoachPaywallScreen(), // safe default
    );
  }
}
```

### Pattern 7: Bottom Nav with 4th Coach Tab

**What:** Current bottom nav has 3 tabs (Home/Programs, Progress, and implicitly sessions). The router uses a flat route structure without a `ShellRoute`. Phase 7 requires adding a 4th "Coach" tab.

**Current router structure:** Flat `GoRoute` list — no `ShellRoute` or `StatefulShellRoute`. The existing screens (ProgramListScreen, ProgressScreen) implement their own bottom nav via a shared scaffold or are independent routes.

**Key question from codebase inspection:** The current code does NOT have a persistent bottom navigation bar widget — each screen appears to be standalone. This means Phase 7 must introduce a `ShellRoute` (or equivalent) to add a persistent bottom nav, OR each screen already has its own `BottomNavigationBar` widget (need to confirm).

Looking at `ProgramListScreen` and `ProgressScreen` — these are not in the file listing above but are in the router. The bottom nav must live somewhere. The planner must verify if a `ScaffoldWithBottomNavBar` widget already exists.

**Safe approach:** Add `/coach-chat` as a named GoRoute. The Coach tab's bottom nav item navigates to it. If a shared scaffold already exists, wire it there. If not, create a `MainScaffold` with `BottomNavigationBar` as a `ShellRoute` wrapping the 4 main routes.

### Anti-Patterns to Avoid

- **Using `MaterializedView` for notifications:** The `student_notifications_view` is already a regular security-invoker view — do NOT change it to a materialized view (breaks RLS, as noted in the migration comment).
- **Storing FCM token in SharedPreferences only:** Must reach Supabase so the admin panel can look it up. SharedPreferences is only for offline subscription status (existing pattern).
- **Reading `feedback_threads` without RLS:** Never use service role key in the student app. `feedback_select_own` RLS policy (`student_id = auth.uid()`) enforces isolation — no additional client-side filtering needed, but always verify the Supabase client is using the anon key, not service role.
- **One feedback thread per session (UNIQUE constraint):** `feedback_threads` has `UNIQUE (student_id, session_id)`. This means a student can only have ONE thread per session. The UI-SPEC's free-form DM model (compose bar always visible, not session-gated) implies messages that are NOT session-linked. The data model only supports session-linked threads. The planner must reconcile: either the compose bar creates a thread for the student's most recent completed session, or a free-form `session_id` is used (e.g., a sentinel "general" UUID). This is the most significant schema tension.
- **Double-posting on SyncQueue retry:** `SyncQueue._replayItem` uses `supabase.from(...).upsert(payload)` for inserts — this is idempotent by design. Photo uploads must also be idempotent (check if storage path already exists before uploading).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Camera + gallery picker | Custom camera widget | `image_picker` | Handles iOS PHPhotoLibrary, Android MediaStore permissions, returns XFile cleanly |
| FCM token lifecycle | Manual HTTP Firebase API | `firebase_messaging` | Handles token refresh, background isolates, iOS APNs bridge |
| Local notification display | Platform channel bridge | `flutter_local_notifications` | Cross-platform (iOS + Android), handles notification channels on Android 13+ |
| Supabase Storage upload | Custom HTTP multipart | `supabase_flutter` `storage.from().upload()` | Already authenticated, handles retry, returns public URL or signed URL |
| Photo full-screen viewer | Custom gesture detector | `InteractiveViewer` (Flutter stdlib) | Built-in, handles pinch-zoom, no package needed |

**Key insight:** All packages for this phase are already declared in pubspec.yaml. Only `image_picker` is missing.

---

## Schema Tensions and Gaps

### Gap 1: Free-form DM vs. Session-Linked Thread (CRITICAL)

The UI-SPEC describes a free-form DM compose bar accessible at any time — not session-gated. But `feedback_threads` has `UNIQUE (student_id, session_id)` and `session_id NOT NULL`.

**Resolution options (planner must choose one):**
1. **Option A — General thread:** Create one permanent "general" thread using a sentinel `session_id` (a fixed UUID seeded in a new Supabase migration). The FeedbackComposeBottomSheet links messages to the actual session_id; the compose bar on CoachChatScreen uses the general sentinel. This requires no schema change but adds a seeded record.
2. **Option B — Relax schema:** Add a new `chat_messages` table (separate from `feedback_threads`) for free-form DM. `feedback_threads` retains its session-linked semantics for the post-session compose sheet. This is the cleanest but most work.
3. **Option C — Most recent session link:** The compose bar always links new messages to the student's most recently completed session (queried from `progress_records`). Simplest, but means multiple sends from the compose bar conflict (UNIQUE constraint).

**Recommendation:** Option A. Add a seeded sentinel session row in a migration, or use `session_id = '00000000-0000-0000-0000-000000000000'` as a "general" thread. The FeedbackRepository handles which session_id to use based on context (compose bar = general, bottom sheet = actual session_id).

### Gap 2: `status` Column Missing from `LocalFeedbackThreads`

The UI-SPEC requires a clock icon on pending messages. The Drift table does not have a `status` column. A schema migration (version 3) is required.

### Gap 3: `localPhotoPath` Column Missing from `LocalFeedbackThreads`

For offline photo queuing, the local file path must be persisted. A second new column in the same migration.

### Gap 4: `students.fcm_token` Missing from Supabase Schema

No column for storing FCM tokens. Required for admin panel to send push notifications. Supabase migration 004 required.

### Gap 5: Firebase Not Initialized in `main.dart`

`// TODO Phase 7: Initialize Firebase` is a comment in main.dart. The `firebase_options.dart` contains placeholder values — these will remain placeholders unless the real Firebase project is configured. The planner should include Firebase init in Wave 0 and note that real config requires `flutterfire configure`.

### Gap 6: Google Play Services Plugin Missing from Android Build

`firebase_messaging` on Android requires `com.google.gms:google-services` plugin in `android/app/build.gradle.kts`. It is not currently applied. This is a Wave 0 task.

### Gap 7: iOS Push Notification Entitlement

`AppDelegate.swift` does not call `FirebaseApp.configure()`. With `firebase_messaging` 16.x the `FirebaseApp.configure()` call is handled via `Firebase.initializeApp()` in Flutter, which triggers the native call. However, iOS requires the push notifications capability to be enabled in Xcode and an APNs key uploaded to Firebase Console. These are manual steps the planner must flag.

### Gap 8: `NSPhotoLibraryUsageDescription` Missing from Info.plist

iOS requires `NSPhotoLibraryUsageDescription` (and `NSPhotoLibraryAddUsageDescription` for saving) in `Info.plist` when using `image_picker`. Currently only `NSCameraUsageDescription` exists (added for AR model viewer). A new key must be added.

---

## Runtime State Inventory

> Not a rename/refactor phase — this section covers environment state relevant to push notification configuration.

| Category | Items Found | Action Required |
|----------|-------------|-----------------|
| Stored data | `local_feedback_threads` Drift table exists, `feedback_threads` Supabase table exists | No migration needed for existing columns; add `status`, `localPhotoPath` columns via migration |
| Live service config | Firebase config files (`GoogleService-Info.plist`, `google-services.json`) contain placeholder values | Manual: run `flutterfire configure` with real Firebase project, replace placeholders |
| OS-registered state | iOS push notifications capability not enabled in Xcode project | Manual: enable in Xcode signing + capabilities tab |
| Secrets/env vars | No FCM-related dart-define keys needed (Firebase init uses bundled config files) | None |
| Build artifacts | None stale | None |

---

## Common Pitfalls

### Pitfall 1: UNIQUE Constraint Violation on Feedback Thread Insert

**What goes wrong:** Student tries to send feedback for a session they already sent feedback for — Supabase returns a 409 conflict. The SyncQueue's `upsert` handles this gracefully (idempotent), but the UI must handle the case where `FeedbackDao.getByStudentAndSession` returns an existing thread.

**Why it happens:** `feedback_threads` has `UNIQUE (student_id, session_id)`. After the first submission, subsequent sends for the same session must be an UPDATE (append to `student_message`?), not an INSERT.

**How to avoid:** The FeedbackRepository.submitFeedback must check if a thread already exists for the session. If it does, update the `student_message` rather than inserting a new row. Alternatively, per the free-form DM model: the compose bar always uses the general sentinel session_id (one thread only), so conflict only occurs if the user sends two general messages.

**Warning signs:** `PostgrestException` with code `23505` on `feedback_threads` insert.

### Pitfall 2: FCM Background Isolate Registration

**What goes wrong:** FCM message arrives in background/terminated state, background handler runs in a separate Dart isolate with no access to Riverpod or the app's provider container.

**Why it happens:** `FirebaseMessaging.onBackgroundMessage` handler is a top-level function, not a class method. Riverpod providers are not available.

**How to avoid:** The background handler must only do minimal work: show local notification via `flutter_local_notifications`. It must NOT try to read from Drift or call Riverpod. The full message content is available in `RemoteMessage.notification`.

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Show local notification only — no Riverpod, no Drift
}
```

**Warning signs:** `Bad state: No ProviderScope found` in background isolate logs.

### Pitfall 3: `flutter_local_notifications` Android Channel Required for Android 13+

**What goes wrong:** Notifications silently dropped on Android 13+ because no notification channel is created.

**Why it happens:** Android 8+ requires explicit notification channel registration. Android 13 requires runtime permission (`POST_NOTIFICATIONS`). `flutter_local_notifications` 18.x requires the channel to be created on first launch.

**How to avoid:** In `main.dart` during FCM init, create a notification channel with id `coach_replies`:

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'coach_replies',
  'Coach Replies',
  description: 'Notifications when your coach replies',
  importance: Importance.high,
);
await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
```

**Warning signs:** Notifications received by FCM but not shown on Android 13+ device.

### Pitfall 4: `image_picker` iOS Requires BOTH Camera and Photo Library Permission Strings

**What goes wrong:** App crashes or picker is rejected on iOS when user taps camera icon in compose bar.

**Why it happens:** `image_picker` accesses both the camera (for `ImageSource.camera`) and photo library (for `ImageSource.gallery`). Each requires its own `Info.plist` key. Currently only `NSCameraUsageDescription` exists (for AR model viewer, not for picking).

**How to avoid:** Add to `ios/Runner/Info.plist`:
- `NSPhotoLibraryUsageDescription` — "Select a photo to share with your coach"
- (`NSCameraUsageDescription` already exists but its description says "AR model viewing" — update to cover both uses)

**Warning signs:** `PHPhotoLibrary` permission dialog does not appear; picker returns immediately with nil.

### Pitfall 5: Supabase Realtime Not Needed for This Phase

**What goes wrong:** Over-engineering by adding Supabase Realtime channel subscriptions to get live coach replies.

**Why it happens:** Natural assumption that chat = realtime push. But the architecture is pull-based: `SyncService._pullRemoteChanges` already pulls `feedback_threads` on reconnect. Coach replies arrive via FCM notification → app opens → SyncService runs → Drift DAO stream emits update.

**How to avoid:** Do NOT add `supabase.channel(...).onPostgresChanges(...)` subscriptions. The FCM notification triggers the sync, and the Drift `watchFeedbackByStudent` stream automatically emits when the upsert lands. This is consistent with how all other tables work.

**Warning signs:** Duplicate data, complex channel teardown, stream management bugs.

### Pitfall 6: `isSubscribed` Provider is `async` — Handle Loading State in Coach Tab

**What goes wrong:** `CoachTabScreen` shows a blank screen or crashes during the initial `isSubscribedProvider` async load.

**Why it happens:** `isSubscribedProvider` is a `FutureProvider` (returns `AsyncValue<bool>`). If the loading state is not handled, `AsyncValue.when` may throw or show nothing.

**How to avoid:** Use `isSubscribed.when(data: ..., loading: ..., error: ...)` with an explicit loading state showing a centered `CircularProgressIndicator`.

### Pitfall 7: Drift schemaVersion Must Be Incremented for New Columns

**What goes wrong:** App crashes on upgrade with "no such column: status" Drift runtime error.

**Why it happens:** Drift validates schema at open time. Adding columns to a table class without bumping `schemaVersion` and adding the `onUpgrade` migration causes the column to exist in Dart but not in the SQLite file.

**How to avoid:** schemaVersion: 2 → 3 in `app_database.dart`, with `if (from < 3)` block using `m.addColumn(...)` for both new columns.

---

## Code Examples

### Submitting Feedback to Supabase Storage (Photo Upload)

```dart
// Source: supabase_flutter 2.x official docs
Future<String> uploadFeedbackPhoto(File photo, String studentId) async {
  final fileName = '${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final path = 'feedback/$studentId/$fileName';
  await supabase.storage.from('feedback-photos').upload(path, photo);
  return path; // store this in feedback_threads.photo_url
}

// Signed URL for display (if bucket is private):
final signedUrl = await supabase.storage
    .from('feedback-photos')
    .createSignedUrl(path, 3600);
```

Note: The Supabase Storage bucket `feedback-photos` does not exist yet — it must be created. The planner must include a Wave 0 task to create it via the Supabase Dashboard or a migration.

### FCM Token Upsert Pattern

```dart
// Source: firebase_messaging 16.x FlutterFire docs
Future<void> registerFcmToken(String studentId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await supabase
        .from('students')
        .update({'fcm_token': token})
        .eq('id', studentId);
  }
  // Refresh token on rotation:
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await supabase
        .from('students')
        .update({'fcm_token': newToken})
        .eq('id', studentId);
  });
}
```

### Chat Bubble (Coach vs. Student Alignment)

```dart
// Pattern: align + background color based on isCoach bool
Widget buildBubble(BuildContext context, LocalFeedbackThread thread, bool isCoach) {
  final theme = Theme.of(context);
  final bgColor = isCoach
      ? theme.colorScheme.surfaceContainerHighest
      : theme.colorScheme.primaryContainer;
  return Align(
    alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCoach ? const Radius.circular(4) : const Radius.circular(12),
            bottomRight: isCoach ? const Radius.circular(12) : const Radius.circular(4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(thread.studentMessage, style: theme.textTheme.bodyLarge),
      ),
    ),
  );
}
```

### GoRouter Deep-Link Route for FCM

```dart
// Add to app_router.dart routes list:
GoRoute(
  path: '/coach-chat',
  name: 'coach-chat',
  builder: (context, state) => const CoachTabScreen(),
),
// Update existing placeholder:
// GoRoute(path: '/notifications', ...) → NotificationsScreen()
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|-----------------|--------------|--------|
| `FlutterLocalNotificationsPlugin.initialize` with onSelectNotification callback | Use `onDidReceiveNotificationResponse` (typed callback) | flutter_local_notifications 9.0 | The old callback signature no longer exists in 18.x |
| `FirebaseMessaging.configure(...)` | `FirebaseMessaging.onMessage.listen(...)` | FlutterFire 0.7 | Old API removed |
| `image_picker` returns `File?` | Returns `XFile?` (path only, works on web too) | image_picker 0.8 | Use `XFile.path` to get local path, `File(xfile.path)` to upload |

**Deprecated/outdated:**
- `onSelectNotification` callback in `flutter_local_notifications`: replaced with `onDidReceiveNotificationResponse` in v9+. Current version is 18.0.1 — use the new API exclusively.
- `FirebaseMessaging.configure`: removed. Use stream listeners.

---

## Open Questions

1. **Free-form DM vs. session-linked schema tension**
   - What we know: `feedback_threads.session_id` is NOT NULL + has a UNIQUE constraint with `student_id`. The UI-SPEC wants a free-form compose bar not gated by session.
   - What's unclear: Which session_id does a free-form compose bar message use?
   - Recommendation: Planner should use Option A (sentinel UUID) or explicitly document that all compose bar messages link to the most-recently-completed session (and the UNIQUE constraint will conflict on second send from compose bar, requiring UPDATE instead of INSERT).

2. **Notifications screen scope**
   - What we know: `student_notifications_view` returns coach replies. FR-011 says "notifications screen lists all coach replies with session links."
   - What's unclear: Does the notifications screen replace the `/notifications` placeholder route in the router, or is it accessed via a separate navigation path?
   - Recommendation: Replace the existing `/notifications` GoRoute placeholder with `NotificationsScreen`. Bottom nav should have 4 tabs: Home (Programs), Progress, Coach, and either a 4th tab or a bell icon in the AppBar of the Coach tab.

3. **Supabase Storage bucket setup**
   - What we know: Photos go to Supabase Storage. No `feedback-photos` bucket currently exists in the schema or migrations.
   - What's unclear: Is bucket creation handled in a migration or a manual Supabase dashboard step?
   - Recommendation: Create via `supabase storage` CLI or a migration using `storage.create_bucket`. Flag as a Wave 0 task for the planner.

4. **Real Firebase project credentials**
   - What we know: `firebase_options.dart` has placeholder values. `GoogleService-Info.plist` and `google-services.json` have placeholder values. Firebase init is TODOed in `main.dart`.
   - What's unclear: Does the coach have a real Firebase project configured? FCM cannot be tested without real credentials.
   - Recommendation: Planner must include a Wave 0 manual step: "Run `flutterfire configure` and replace placeholder files." Mark FCM end-to-end test as requiring real device + real Firebase config. All other features can be built and tested without real FCM.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter | All | Yes | 3.44.0 (stable) | — |
| Dart SDK | All | Yes | 3.12.0 | — |
| `firebase_messaging` | FCM push | Yes (in pubspec.lock) | 16.2.2 | — |
| `firebase_core` | FCM push | Yes (in pubspec.lock) | 4.9.0 | — |
| `flutter_local_notifications` | Foreground notification display | Yes (in pubspec.lock) | 18.0.1 | — |
| `image_picker` | Photo attachment | NOT IN pubspec | — | Must add via `flutter pub add image_picker` |
| Supabase Storage `feedback-photos` bucket | Photo upload | NOT CREATED | — | Must create; plan includes Wave 0 task |
| Firebase project (real credentials) | FCM end-to-end | Placeholder only | — | FCM unit/widget tests pass with mocks; E2E needs real device + real project |
| iOS APNs push entitlement | FCM on iOS | Not configured | — | FCM on simulator uses fake tokens; real push requires physical device + APNs key in Firebase Console |
| `com.google.gms:google-services` Gradle plugin | FCM on Android | NOT applied in build.gradle.kts | — | Must add to `android/app/build.gradle.kts` |
| `NSPhotoLibraryUsageDescription` in Info.plist | `image_picker` gallery | MISSING | — | Must add or `image_picker` throws on iOS |

**Missing dependencies with no fallback (blocking for their feature):**
- `image_picker` — must add to pubspec before any photo attachment code can be written
- `com.google.gms:google-services` Gradle plugin — must add before FCM works on Android
- `NSPhotoLibraryUsageDescription` — must add before photo picker works on iOS

**Missing dependencies with fallback (non-blocking for other features):**
- Real Firebase credentials — all non-FCM features work without them; use mock FCM service in tests

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (dart SDK 3.12.0) + mocktail 1.0.5 |
| Config file | `mobile/pubspec.yaml` (dev_dependencies) |
| Quick run command | `cd mobile && flutter test test/unit/features/coach_chat/` |
| Full suite command | `cd mobile && flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FR-010 | `FeedbackRepository.submitFeedback` writes to Drift + enqueues `feedback_threads` | unit | `flutter test test/unit/features/coach_chat/feedback_repository_test.dart -x` | No — Wave 0 |
| FR-010 | Offline: message saved with `status: 'pending'`, clock icon visible | widget | `flutter test test/widget/coach_chat_screen_test.dart -x` | No — Wave 0 |
| FR-010a | RLS: student A cannot read student B's threads | unit (SQL policy test) | Verified by existing `feedback_select_own` policy in migration; confirmed by SyncService only pulling own rows | Existing policy |
| FR-010 | Photo upload: `localPhotoPath` stored when offline | unit | `flutter test test/unit/features/coach_chat/feedback_repository_test.dart -x` | No — Wave 0 |
| FR-011 | FCM token registered after sign-in | unit (mock Firebase) | `flutter test test/unit/features/coach_chat/fcm_service_test.dart -x` | No — Wave 0 |
| FR-011 | Notifications screen renders coach replies from `watchReplies` stream | widget | `flutter test test/widget/notifications_screen_test.dart -x` | No — Wave 0 |

### Sampling Rate

- **Per task commit:** `cd mobile && flutter test test/unit/features/coach_chat/ test/widget/`
- **Per wave merge:** `cd mobile && flutter test`
- **Phase gate:** Full suite green (currently 90 tests passing) before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/unit/features/coach_chat/feedback_repository_test.dart` — FR-010: local write + sync enqueue + offline status
- [ ] `test/unit/features/coach_chat/fcm_service_test.dart` — FR-011: token registration with mock FirebaseMessaging
- [ ] `test/widget/coach_chat_screen_test.dart` — FR-010: chat bubble rendering, pending clock icon, compose bar enable/disable
- [ ] `test/widget/notifications_screen_test.dart` — FR-011: reply list renders from mock stream
- [ ] Framework: no new framework install needed (flutter_test + mocktail already declared)

*(Note: `test/unit/features/coach_chat/` directory does not yet exist and must be created in Wave 0)*

---

## Sources

### Primary (HIGH confidence)

- Direct codebase inspection — `mobile/lib/core/database/daos/feedback_dao.dart`, `tables/feedback_threads_table.dart`, `core/database/app_database.dart`, `core/sync/sync_service.dart`, `core/sync/sync_queue.dart`
- `supabase/migrations/001_initial_schema.sql` — verified `feedback_threads` schema and RLS policies
- `supabase/migrations/003_cqrs_read_models.sql` — verified `student_notifications_view` exists
- `mobile/pubspec.yaml` + `pubspec.lock` — verified package versions, confirmed `image_picker` absent
- `mobile/lib/firebase_options.dart` — confirmed placeholder status
- `mobile/ios/Runner/Info.plist` — confirmed missing `NSPhotoLibraryUsageDescription`
- `mobile/android/app/build.gradle.kts` — confirmed `com.google.gms:google-services` plugin absent

### Secondary (MEDIUM confidence)

- Established project pattern from `metric_repository.dart` + `metric_providers.dart` — FeedbackRepository follows identical CQRS shape
- `flutter_local_notifications` 18.x API verified against package changelog (training data + version lock confirms current stable API)

### Tertiary (LOW confidence)

- Firebase APNs setup for iOS — manual process; not verified against current Firebase Console UI (may differ from training data; flag for human verification)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages verified in pubspec.lock
- Architecture patterns: HIGH — derived from existing project patterns (MetricRepository, SyncService)
- Schema gaps: HIGH — verified by direct inspection of Drift table and Supabase migration files
- Pitfalls: HIGH for schema/Drift issues; MEDIUM for FCM platform setup (platform-specific, varies by OS version)
- Environment availability: HIGH — directly probed via bash commands

**Research date:** 2026-05-29
**Valid until:** 2026-06-28 (packages stable; Firebase CLI instructions may change)
