# Phase 2: Foundation - Research

**Researched:** 2026-05-25
**Domain:** Flutter offline-first infrastructure — Drift 2.33, Riverpod 3.x, Supabase Flutter 2.x, background_downloader 9.x, CQRS projections
**Confidence:** HIGH

---

## Project Constraints (from CLAUDE.md)

- Never push directly to `main`. Always create a feature branch and open a PR.
- Branch → commit → push → `gh pr create` workflow is mandatory.

---

## Summary

Phase 2 builds all cross-cutting infrastructure that every feature phase depends on: the Drift SQLite local database (9 tables, 8 DAOs), Supabase client singleton, auth repository with email/password + Apple + Google, offline sync queue, sync service, download service, CQRS command bus and query gateway, and the router completion.

The critical insight is that **connectivity_plus, sign_in_with_apple, google_sign_in, and crypto are not in pubspec.yaml** and must be added before T033–T039 can be implemented. The plan must include a `flutter pub add` step as Wave 0 or the first task.

The CQRS projection side (T131–T136) spans both Supabase SQL (regular views with `security_invoker=true` are the correct choice — materialized views cannot have RLS in Supabase) and a Deno edge function triggered by database webhooks. The admin-side query client (T135) uses `@supabase/supabase-js` from the already-installed dependency.

**Primary recommendation:** Structure the phase in four sequential waves: (0) add missing packages + test scaffolding, (1) all Drift tables + DAOs in parallel, (2) core services (Supabase client, auth, sync, downloads) sequentially, (3) CQRS layer + router.

---

## Standard Stack

### Core (all already in pubspec.yaml unless noted)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| drift | 2.33.0 | SQLite ORM, reactive streams | Type-safe local DB with code gen |
| drift_flutter | 0.3.0 | `driftDatabase()` opener for Flutter | Flutter-specific storage path helper |
| drift_dev | 2.33.0 (dev) | Code generation for Drift | Generates `_$AppDatabaseMixin`, companion classes |
| flutter_riverpod | 3.3.1 | State management | Compile-time safe DI + `AsyncNotifier` |
| riverpod_annotation | 4.0.2 | `@riverpod` annotation | Code gen decorators |
| riverpod_generator | 4.0.4-dev.1 (dev) | Builds `*.g.dart` from `@riverpod` | Generates provider boilerplate |
| supabase_flutter | 2.12.4 | Auth + REST + Realtime | Single SDK for all Supabase features |
| go_router | 17.2.3 | Declarative routing | Auth guard via `redirect` callback |
| background_downloader | 9.5.4 | Background file downloads | Cross-platform with `BaseDirectory` |
| build_runner | 2.15.0 (dev) | Runs code generators | Required for Drift + Riverpod + Freezed |
| mocktail | 1.0.5 (dev) | Mocking in tests | `when()`/`verify()` without code gen |

### Missing — Must Add to pubspec.yaml

| Library | Version | Purpose | Required By |
|---------|---------|---------|-------------|
| connectivity_plus | ^7.1.1 | Network status stream | T038 ConnectivityProvider |
| sign_in_with_apple | ^7.2.0 | Native Apple Sign-In on iOS | T034 auth_repository |
| google_sign_in | ^8.0.0 | Native Google Sign-In | T034 auth_repository |
| crypto | ^3.0.0 | SHA-256 nonce for Apple Sign-In | T034 auth_repository |

**Installation:**
```bash
cd mobile
flutter pub add connectivity_plus sign_in_with_apple google_sign_in crypto
# dev
flutter pub add --dev fake_async
```

**Version verification (confirmed 2026-05-25):**
- connectivity_plus: 7.1.1
- sign_in_with_apple: 7.2.0
- google_sign_in: 8.0.0
- crypto: 3.0.3
- fake_async: 3.0.7

---

## Architecture Patterns

### Recommended Project Structure (Phase 2 creates)

```
mobile/lib/core/
├── database/
│   ├── app_database.dart         # @DriftDatabase — references all tables + DAOs
│   ├── tables/
│   │   ├── programs_table.dart
│   │   ├── sessions_table.dart
│   │   ├── exercises_table.dart
│   │   ├── enrollments_table.dart
│   │   ├── progress_records_table.dart
│   │   ├── metric_logs_table.dart
│   │   ├── feedback_threads_table.dart
│   │   ├── sync_queue_table.dart
│   │   └── download_manifest_table.dart
│   └── daos/
│       ├── programs_dao.dart
│       ├── sessions_dao.dart
│       ├── exercises_dao.dart
│       ├── progress_dao.dart
│       ├── metric_logs_dao.dart
│       ├── feedback_dao.dart
│       ├── sync_queue_dao.dart
│       └── download_manifest_dao.dart
├── network/
│   └── supabase_client.dart
├── auth/
│   ├── auth_repository.dart
│   └── auth_provider.dart
├── sync/
│   ├── sync_queue.dart
│   ├── sync_service.dart
│   └── connectivity_provider.dart
├── downloads/
│   └── download_service.dart
└── cqrs/
    ├── command_bus.dart
    └── query_gateway.dart

supabase/
├── migrations/
│   └── 003_cqrs_read_models.sql
└── functions/
    └── projection-refresh/
        └── index.ts

admin/lib/cqrs/
└── query-client.ts

mobile/test/unit/core/
├── auth/
├── sync/
└── downloads/
mobile/test/integration/
└── cqrs_projection_lag_test.dart
```

---

### Pattern 1: Drift @DriftDatabase Class

**What:** Central database class referencing all table and DAO classes. Code generator produces `_$AppDatabase` mixin.
**When to use:** One per app. Constructor accepts optional `QueryExecutor` for test injection.

```dart
// Source: https://drift.simonbinder.eu/setup
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/programs_table.dart';
// ... other table imports
import 'daos/programs_dao.dart';
// ... other DAO imports

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalPrograms,
    LocalSessions,
    LocalExercises,
    LocalEnrollments,
    LocalProgressRecords,
    LocalMetricLogs,
    LocalFeedbackThreads,
    SyncQueue,
    DownloadManifest,
  ],
  daos: [
    ProgramsDao,
    SessionsDao,
    ExercisesDao,
    ProgressDao,
    MetricLogsDao,
    FeedbackDao,
    SyncQueueDao,
    DownloadManifestDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mwf_local');
  }
}
```

---

### Pattern 2: Drift Table Definition

**What:** Dart class extending `Table`. Column builders return typed column descriptors.
**Key rules:**
- Text UUIDs: use `text()` — override `primaryKey` getter for text PKs
- `autoIncrement()` only on `integer()` columns
- `customConstraint()` replaces all Drift-generated constraints on that column (must re-add `NOT NULL` if needed)
- Override `tableName` to match Supabase snake_case names

```dart
// Source: https://drift.simonbinder.eu/dart_api/tables
class LocalPrograms extends Table {
  @override
  String get tableName => 'local_programs';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get difficulty => text()();
  IntColumn get durationWeeks => integer()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get published => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**sync_queue uses autoincrement integer PK:**
```dart
class SyncQueue extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();      // insert | update | delete
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get payload => text()();        // JSON-encoded row
  IntColumn get createdAt => integer()();    // unix timestamp
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}
```

**download_manifest uses text PK:**
```dart
class DownloadManifest extends Table {
  @override
  String get tableName => 'download_manifest';

  TextColumn get exerciseId => text()();
  IntColumn get videoVersion => integer()();
  TextColumn get videoLocalPath => text().nullable()();
  TextColumn get modelLocalPath => text().nullable()();
  TextColumn get downloadStatus => text().withDefault(const Constant('pending'))();
  IntColumn get downloadedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
```

---

### Pattern 3: Drift DAO with @DriftAccessor

**What:** Scoped query/mutation class per entity. Generated mixin provides access to table helpers.
**Key:** Must declare DAO in `@DriftDatabase(daos: [...])` — generates a getter on `AppDatabase`.

```dart
// Source: https://drift.simonbinder.eu/dart_api/daos
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/programs_table.dart';

part 'programs_dao.g.dart';

@DriftAccessor(tables: [LocalPrograms])
class ProgramsDao extends DatabaseAccessor<AppDatabase>
    with _$ProgramsDaoMixin {
  ProgramsDao(super.attachedDatabase);

  // Watch all published programs — emits on every change
  Stream<List<LocalProgram>> watchAllPrograms() =>
      select(localPrograms).watch();

  // Single fetch
  Future<List<LocalProgram>> getAllPrograms() =>
      select(localPrograms).get();

  // Upsert (insertOnConflictUpdate for sync)
  Future<void> upsertProgram(LocalProgramsCompanion entry) =>
      into(localPrograms).insertOnConflictUpdate(entry);

  // Delete by id
  Future<int> deleteProgramById(String id) =>
      (delete(localPrograms)..where((t) => t.id.equals(id))).go();
}
```

---

### Pattern 4: Drift In-Memory DB for Tests

**What:** Inject `NativeDatabase.memory()` via constructor parameter.
**Critical:** `closeStreamsSynchronously: true` prevents hanging timers in widget tests.

```dart
// Source: https://drift.simonbinder.eu/docs/testing/
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('sync_queue enqueue and dequeue', () async {
    await database.syncQueueDao.enqueue(
      SyncQueueCompanion(
        operation: const Value('insert'),
        tableName_: const Value('progress_records'),
        payload: const Value('{"id":"abc"}'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final items = await database.syncQueueDao.getPendingItems();
    expect(items.length, 1);
  });
}
```

---

### Pattern 5: Riverpod 3.x Code Generation

**What:** `@riverpod` annotation on functions or classes generates typed providers.
**Key rules:**
- `@riverpod` (lowercase) = `autoDispose` by default
- `@Riverpod(keepAlive: true)` = persists when no listeners (use for singletons like AppDatabase, SupabaseClient)
- Class-based `AsyncNotifier` for stateful async providers with mutation methods
- `StreamProvider` for reactive Drift watch streams

```dart
// Source: https://riverpod.dev/docs/concepts/about_code_generation

// Singleton provider (keepAlive) — for AppDatabase
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// Singleton Supabase client
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

// AsyncNotifier for auth — class-based, mutable state
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Stream<AuthState> build() {
    return ref
        .watch(supabaseClientProvider)
        .auth
        .onAuthStateChange
        .map((data) => data);
  }
}

// StreamProvider for Drift reactive query
@riverpod
Stream<List<LocalProgram>> watchPrograms(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.programsDao.watchAllPrograms();
}
```

---

### Pattern 6: Supabase Flutter Initialization

**What:** Call `Supabase.initialize()` in `main()` before `runApp()`.
**Critical:** `onAuthStateChange` stream requires an `onError` handler — omitting it will crash the app on token refresh network errors.

```dart
// Source: https://supabase.com/docs/reference/dart/initializing
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);

// Access client anywhere after init:
final supabase = Supabase.instance.client;

// Auth state stream — MUST have onError handler:
supabase.auth.onAuthStateChange.listen(
  (data) {
    final event = data.event;   // AuthChangeEvent enum
    final session = data.session;
    // handle signedIn, signedOut, tokenRefreshed, etc.
  },
  onError: (error, stackTrace) {
    // Network errors during refresh — must not crash
  },
);
```

---

### Pattern 7: Apple Sign-In via supabase_flutter

**What:** Uses `sign_in_with_apple` package + nonce flow on iOS. Non-iOS platforms use OAuth redirect.
**Required:** `sign_in_with_apple` package, `crypto` package, Sign In with Apple capability in Xcode.

```dart
// Source: https://supabase.com/docs/guides/auth/social-login/auth-apple?platform=flutter
Future<void> signInWithApple() async {
  final rawNonce = supabase.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) throw const AuthException('No ID Token from Apple');

  await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
}
```

---

### Pattern 8: Google Sign-In via supabase_flutter

**What:** Uses `google_sign_in` package with `serverClientId` (Web OAuth Client ID) and `clientId` (iOS OAuth Client ID). Android uses the Web Client ID as `serverClientId`.

```dart
// Source: https://supabase.com/docs/guides/auth/social-login/auth-google?platform=flutter
Future<void> signInWithGoogle() async {
  const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(
    serverClientId: webClientId,
    clientId: iosClientId,
  );

  final googleUser = await googleSignIn.attemptLightweightAuthentication();
  final scopes = ['email', 'profile'];
  final authorization = await googleUser.authorizationClient
          .authorizationForScopes(scopes) ??
      await googleUser.authorizationClient.authorizeScopes(scopes);

  final idToken = googleUser.authentication.idToken;

  await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: authorization.accessToken,
  );
}
```

---

### Pattern 9: ConnectivityProvider (connectivity_plus 7.x)

**What:** In version 7.x, `onConnectivityChanged` emits `List<ConnectivityResult>` (not a single value). Detect reconnection by checking if the previous state was `[ConnectivityResult.none]` and new state does not contain `none`.

```dart
// Source: https://pub.dev/packages/connectivity_plus
import 'package:connectivity_plus/connectivity_plus.dart';

// In a Riverpod StreamProvider:
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

// Detect reconnect in ConnectivityProvider notifier:
void _onConnectivityChanged(List<ConnectivityResult> results) {
  final isNowOnline = !results.contains(ConnectivityResult.none);
  final wasOffline = _previousResults.contains(ConnectivityResult.none);

  if (isNowOnline && wasOffline) {
    // Trigger sync + resume downloads
    ref.read(syncServiceProvider).sync();
    ref.read(downloadServiceProvider).resumeQueue();
  }
  _previousResults = results;
}
```

---

### Pattern 10: background_downloader 9.x

**What:** `FileDownloader` singleton. Files stored via `BaseDirectory` enum — never use absolute paths (iOS paths change across app launches).
**iOS setup:** Enable Background Fetch capability in Xcode Signing & Capabilities.
**Android setup:** Kotlin 2.1.0+ in `android/settings.gradle`.

```dart
// Source: https://pub.dev/packages/background_downloader

// Enqueue a download (non-blocking):
final task = DownloadTask(
  taskId: 'exercise_${exerciseId}_video',
  url: muxDownloadUrl,
  filename: '${exerciseId}_video.mp4',
  directory: 'exercises/$exerciseId',
  baseDirectory: BaseDirectory.applicationDocuments,
  updates: Updates.statusAndProgress,
  requiresWiFi: false,
  retries: 3,
  allowPause: true,
  metaData: exerciseId,   // use to identify in callbacks
);

await FileDownloader().enqueue(task);

// Listen for progress updates:
FileDownloader().updates.listen((update) {
  if (update is TaskProgressUpdate) {
    // update.progress (0.0 to 1.0), update.task.metaData = exerciseId
  }
  if (update is TaskStatusUpdate) {
    if (update.status == TaskStatus.complete) {
      // update download_manifest in Drift
    }
    if (update.status == TaskStatus.failed) {
      // mark manifest as 'failed'
    }
  }
});

// Resume paused/queued downloads:
await FileDownloader().resumeAll();
```

---

### Pattern 11: SyncQueue — Append-Only with Retry

**What:** Write all mutations to `sync_queue` first, then replay when online. Each row has `retry_count`; stop at 5.
**Idempotency:** Upstream Supabase upserts must use `onConflict: 'do update'` or have UNIQUE constraints to be safe to replay.

```dart
// Enqueue a write:
Future<void> enqueue({
  required String operation,
  required String targetTable,
  required Map<String, dynamic> payload,
}) async {
  await db.syncQueueDao.enqueue(
    SyncQueueCompanion(
      operation: Value(operation),
      tableName_: Value(targetTable),
      payload: Value(jsonEncode(payload)),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
}

// Process queue:
Future<void> processQueue() async {
  final items = await db.syncQueueDao.getPendingItems();
  for (final item in items) {
    if (item.retryCount >= 5) continue;
    try {
      await _replayItem(item);
      await db.syncQueueDao.deleteById(item.id);
    } catch (e) {
      await db.syncQueueDao.incrementRetry(item.id, e.toString());
    }
  }
}
```

---

### Pattern 12: CQRS — Supabase Views with security_invoker

**What:** Regular views (not materialized) for CQRS projections. Materialized views cannot have RLS enforced in Supabase — always use regular views with `security_invoker = true`.

```sql
-- Source: https://supabase.com/docs/guides/database/tables
-- program_catalog_view: denormalized read model
CREATE VIEW program_catalog_view WITH (security_invoker = true) AS
SELECT
  p.id,
  p.title,
  p.description,
  p.difficulty,
  p.duration_weeks,
  p.thumbnail_url,
  p.published_at,
  e.id AS enrollment_id,
  e.current_day,
  s.status AS subscription_status
FROM programs p
LEFT JOIN enrollments e ON e.program_id = p.id AND e.student_id = auth.uid()
LEFT JOIN subscriptions s ON s.student_id = auth.uid() AND s.status = 'active'
WHERE p.published = true;

GRANT SELECT ON program_catalog_view TO authenticated;
```

**Why not materialized:** Materialized views in Supabase are refreshed globally and cannot invoke `auth.uid()` at query time, which breaks per-student RLS. Regular views re-run the query each time and respect `security_invoker`.

---

### Pattern 13: Supabase Edge Function for Projection Refresh

**What:** Deno edge function triggered by DB webhook after command-side writes. Uses `Deno.serve()`. Project already uses this pattern (see existing webhook stubs).

```typescript
// Source: Confirmed from existing supabase/functions/revenuecat-webhook/index.ts
import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = await req.json();
  // payload.type: 'INSERT' | 'UPDATE' | 'DELETE'
  // payload.table, payload.record, payload.old_record

  // For projection refresh — views are live so just validate idempotency key
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // If using materialized views (NOT recommended — see pitfalls):
  // await supabase.rpc('refresh_projections');

  // For regular views: projections are always fresh; record the refresh event
  console.log("Projection refresh triggered for:", payload.table);
  return Response.json({ refreshed: true });
});
```

---

### Pattern 14: Riverpod + GoRouter Auth Guard

**What:** GoRouter provider wraps auth state and redirects. `refreshListenable` pattern re-evaluates redirect when auth state changes.

```dart
// Source: GoRouter + Riverpod documented pattern
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/programs',
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.event == AuthChangeEvent.signedIn
          || authState.valueOrNull?.session != null;
      final isAuthRoute = state.matchedLocation == '/login'
          || state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/programs';
      return null;
    },
    routes: [ /* all routes */ ],
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}
```

---

### Pattern 15: CQRS CommandBus

**What:** Thin wrapper that translates command intents into `sync_queue` entries. No direct Supabase calls — all writes go through the queue for offline safety.

```dart
// Command types known at Phase 2
enum CommandType { completeSession, logMetric, submitFeedback, enrollProgram }

class CommandBus {
  CommandBus(this._syncQueue);
  final SyncQueue _syncQueue;

  Future<void> dispatch(CommandType type, Map<String, dynamic> payload) async {
    final tableName = switch (type) {
      CommandType.completeSession => 'progress_records',
      CommandType.logMetric => 'metric_logs',
      CommandType.submitFeedback => 'feedback_threads',
      CommandType.enrollProgram => 'enrollments',
    };
    await _syncQueue.enqueue(
      operation: 'insert',
      targetTable: tableName,
      payload: payload,
    );
  }
}
```

---

### Pattern 16: admin/lib/cqrs/query-client.ts (Next.js 16 / T135)

**What:** Admin reads from projection views, not raw tables. Uses existing `@supabase/supabase-js` dep. Next.js 16 route handlers use `export async function GET(request: Request)` pattern.

```typescript
// admin/lib/cqrs/query-client.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
);

export async function getProgramCatalog() {
  const { data, error } = await supabase
    .from('program_catalog_view')
    .select('*');
  if (error) throw error;
  return data;
}
```

---

### Anti-Patterns to Avoid

- **Absolute file paths in background_downloader:** Use `BaseDirectory.applicationDocuments` + relative `directory` — iOS paths change across installs
- **Materialized views with RLS:** Cannot call `auth.uid()` at query time — use regular views with `security_invoker = true`
- **Skipping onError in onAuthStateChange:** Network errors during token refresh crash the app
- **Direct Supabase writes instead of sync_queue:** Bypasses offline support — all mutations must go through sync_queue first
- **Calling Supabase.initialize() inside a provider:** Must be called before `runApp()` — initialize in `main()`, access via `Supabase.instance.client` in providers
- **Missing `part 'filename.g.dart'` directive:** Drift and Riverpod code gen requires the `part` directive in each file that uses code generation
- **DAO tableName clash:** The `SyncQueue` table has a column named `tableName` which conflicts with Drift's own `tableName` getter — name the column getter `tableName_` and use `.named('table_name')` modifier

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Local SQLite with reactive streams | Custom DB wrapper | Drift 2.33 | Type-safe codegen, `.watch()` streams, migrations, test injection |
| Background file downloads | Custom isolate + HTTP | background_downloader 9.x | Handles iOS background fetch, Android WorkManager, path stability |
| Social auth nonce flow | Custom SHA-256 + Apple credential | sign_in_with_apple + crypto | Apple's nonce requirement has precise spec; wrong impl = rejected by App Store |
| Network status detection | Polling or timer | connectivity_plus | Platform stream API, handles VPN/WiFi/cellular/none state machine |
| JWT token refresh | Manual retry interceptor | supabase_flutter built-in | Supabase client auto-refreshes sessions; manual refresh risks race conditions |

**Key insight:** Every item in this list has subtle platform-specific edge cases (iOS background session lifetimes, Android Doze mode, Apple reviewer rejection conditions) that the libraries already handle correctly.

---

## Common Pitfalls

### Pitfall 1: Missing `flutter pub get` After Adding Packages
**What goes wrong:** T033–T039 import connectivity_plus, sign_in_with_apple, google_sign_in — none of which are in pubspec.yaml. Build fails immediately.
**Why it happens:** pubspec.yaml was written during Phase 0 with only the packages known at that time.
**How to avoid:** Wave 0 task must be `flutter pub add connectivity_plus sign_in_with_apple google_sign_in crypto` before any other implementation task.
**Warning signs:** `Target of URI doesn't exist` analyzer errors on import statements.

### Pitfall 2: Drift `part` Directive Missing
**What goes wrong:** `build_runner` generates `app_database.g.dart` but the database class doesn't pick it up.
**Why it happens:** Dart's part/part-of system is explicit — code gen is not automatic.
**How to avoid:** Every file using `@DriftDatabase`, `@DriftAccessor`, `@riverpod`, or `@freezed` must have `part 'filename.g.dart';` at the top.
**Warning signs:** `Undefined name '_$AppDatabase'` at compile time.

### Pitfall 3: SyncQueue Column Name Conflicts
**What goes wrong:** `SyncQueue` table defines a `tableName` column — but `Table` already has a `get tableName` getter.
**Why it happens:** Naming a Drift column getter the same as a reserved `Table` member causes a compile error.
**How to avoid:** Name the getter `tableName_` and use `.named('table_name')` to set the SQL column name.
**Warning signs:** `getter 'tableName' is already defined` compile error.

### Pitfall 4: onAuthStateChange Without onError
**What goes wrong:** Any network interruption during Supabase token refresh throws an error into the stream, crashing the app if there is no `onError` handler.
**Why it happens:** Dart stream errors propagate to listeners as unhandled exceptions by default.
**How to avoid:** Always pass `onError: (error, stackTrace) { /* log */ }` to every `onAuthStateChange.listen()` call.
**Warning signs:** App crashes with `SocketException` or `AuthException` on poor connectivity.

### Pitfall 5: Materialized Views Break RLS
**What goes wrong:** Query projections using `CREATE MATERIALIZED VIEW` cannot call `auth.uid()` — they are refreshed globally and stored results reflect one user's access.
**Why it happens:** Materialized views snapshot the data at refresh time, before a user session exists.
**How to avoid:** Use `CREATE VIEW ... WITH (security_invoker = true)` — views re-run the query per request and can call `auth.uid()`.
**Warning signs:** All students see each other's data in the program catalog, OR RLS entirely blocks the view.

### Pitfall 6: background_downloader Absolute Path Storage
**What goes wrong:** Storing the absolute file path (e.g., `/var/mobile/Containers/...`) in `download_manifest` — on next app launch the path is different, causing 404s on playback.
**Why it happens:** iOS app containers have version-specific path segments that change on update.
**How to avoid:** Store `directory` + `filename` relative to `BaseDirectory.applicationDocuments`, not the absolute path. Resolve at playback time using `FileDownloader().pathForDownload(task)`.
**Warning signs:** Video plays after download but fails after app restart.

### Pitfall 7: Riverpod keepAlive Missing on Database/Client Providers
**What goes wrong:** `AppDatabase` gets garbage-collected when no widget is watching it, closing the DB connection mid-operation.
**Why it happens:** Default `@riverpod` (lowercase) uses `autoDispose`.
**How to avoid:** Use `@Riverpod(keepAlive: true)` for `AppDatabase`, `SupabaseClient`, `SyncService`, `DownloadService`, and `CommandBus`.
**Warning signs:** `DatabaseException: database is closed` during background sync.

### Pitfall 8: Google Sign-In `serverClientId` vs `clientId`
**What goes wrong:** Google Sign-In returns a null `idToken` because the wrong client ID type is passed.
**Why it happens:** Android requires the Web OAuth Client ID as `serverClientId`; iOS needs the iOS OAuth Client ID as `clientId`.
**How to avoid:** Create separate Web and iOS credentials in Google Cloud Console. Pass `serverClientId` (web) + `clientId` (iOS) to `GoogleSignIn.instance.initialize()`.
**Warning signs:** `googleUser.authentication.idToken` is null; sign-in appears to succeed but Supabase auth fails.

---

## Code Examples

### Complete SyncQueueDao
```dart
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.attachedDatabase);

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<List<SyncQueueData>> getPendingItems() =>
      (select(syncQueue)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..where((t) => t.retryCount.isSmallerThan(const Constant(5))))
          .get();

  Future<void> deleteById(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> incrementRetry(int id, String error) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(SyncQueueCompanion(
            retryCount: Value(syncQueue.retryCount + const Constant(1)),
            lastError: Value(error),
          ));
}
```

### DownloadManifestDao
```dart
@DriftAccessor(tables: [DownloadManifest])
class DownloadManifestDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadManifestDaoMixin {
  DownloadManifestDao(super.attachedDatabase);

  Future<void> upsertEntry(DownloadManifestCompanion entry) =>
      into(downloadManifest).insertOnConflictUpdate(entry);

  Future<DownloadManifestData?> getByExerciseId(String exerciseId) =>
      (select(downloadManifest)
            ..where((t) => t.exerciseId.equals(exerciseId)))
          .getSingleOrNull();

  Future<List<DownloadManifestData>> getPendingDownloads() =>
      (select(downloadManifest)
            ..where((t) => t.downloadStatus.equals('pending')))
          .get();

  Stream<List<DownloadManifestData>> watchAllEntries() =>
      select(downloadManifest).watch();
}
```

### Supabase Client Provider
```dart
// mobile/lib/core/network/supabase_client.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
```

### Auth Provider (StreamProvider)
```dart
// mobile/lib/core/auth/auth_provider.dart
@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  return ref
      .watch(supabaseClientProvider)
      .auth
      .onAuthStateChange
      .map((data) => data)
      .handleError((error) {
        // Swallow network errors — don't crash
      });
}
```

### 003_cqrs_read_models.sql (structure)
```sql
-- student_today_session_view
CREATE VIEW student_today_session_view WITH (security_invoker = true) AS
SELECT
  e.student_id,
  e.program_id,
  e.current_day,
  s.id AS session_id,
  s.title AS session_title,
  s.day_number,
  CASE WHEN sub.status = 'active' THEN true ELSE false END AS is_unlocked
FROM enrollments e
JOIN sessions s ON s.program_id = e.program_id AND s.day_number = e.current_day
LEFT JOIN subscriptions sub ON sub.student_id = e.student_id AND sub.status = 'active'
WHERE e.student_id = auth.uid();

GRANT SELECT ON student_today_session_view TO authenticated;

-- (Repeat pattern for program_catalog_view, session_playback_view,
--  student_progress_dashboard_view, student_notifications_view)
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `riverpod_generator` `family()` modifier | Direct parameters on `@riverpod` functions | Riverpod 2.x → 3.x | Simpler parameterized providers |
| `Provider<T>` manual | `@Riverpod(keepAlive: true)` class | Riverpod 3.x | No manual `override` needed for test injection |
| `connectivity_plus` returns single `ConnectivityResult` | Returns `List<ConnectivityResult>` | v6 → v7 | Check list, not single value |
| Supabase `anonKey` param | `publishableKey` param (with backward compat) | supabase_flutter 2.x | `anonKey` still works; `publishableKey` preferred |
| `NativeDatabase` from `drift/native.dart` directly | `driftDatabase()` from `drift_flutter` | drift_flutter 0.x | Simplifies Flutter path resolution |

**Deprecated/outdated:**
- `connectivity_plus`: Returning single `ConnectivityResult` — now always returns `List<ConnectivityResult>`. Treat as list.
- `Supabase.initialize(anonKey:)`: Deprecated in favor of `publishableKey`. Both work but use `anonKey` for now since existing TODO comment in main.dart uses it.

---

## Open Questions

1. **Google Sign-In client ID injection strategy**
   - What we know: `String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')` is the pattern
   - What's unclear: How these values get set in CI and local dev (`.env` file vs `--dart-define-from-file`)
   - Recommendation: Plan should include a `--dart-define-from-file=.env.json` setup or document the `flutter run --dart-define=` convention. Leave Google Sign-In as stub if client IDs aren't configured yet.

2. **background_downloader iOS background fetch capability**
   - What we know: Requires enabling "Background Fetch" capability in Xcode
   - What's unclear: Whether this was done during Phase 1 Xcode config
   - Recommendation: Include a verification step in the plan — if not configured, downloads won't resume in background.

3. **Supabase DB webhook pointing to projection-refresh function**
   - What we know: Webhooks are configured in the Supabase Dashboard or via SQL trigger
   - What's unclear: Whether local dev uses `host.docker.internal` or another URL
   - Recommendation: Plan should note that T132 edge function deployment and T131 migration are separate from the webhook configuration in the Dashboard — document the manual step.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|---------|
| Flutter SDK | All mobile tasks | Yes | 3.44.0 | — |
| Dart SDK | All mobile tasks | Yes | 3.12.0 | — |
| Node.js | T135 admin tasks | Yes | 22.22.3 | — |
| Supabase CLI | T131, T132 | Not detected | — | Use Supabase Dashboard for migration; deploy function via CLI when installed |
| build_runner (Flutter) | All codegen | Yes (in pubspec) | 2.15.0 | — |
| connectivity_plus | T038 | Not in pubspec.yaml | — | Add via `flutter pub add` (Wave 0) |
| sign_in_with_apple | T034 | Not in pubspec.yaml | — | Add via `flutter pub add` (Wave 0) |
| google_sign_in | T034 | Not in pubspec.yaml | — | Add via `flutter pub add` (Wave 0) |
| crypto | T034 | Not in pubspec.yaml | — | Add via `flutter pub add` (Wave 0) |

**Missing dependencies with no fallback:**
- Supabase CLI: needed for `supabase db push` (T131) and `supabase functions deploy` (T132). Plan should note Dashboard as manual fallback.

**Missing dependencies with fallback (add to pubspec.yaml in Wave 0):**
- connectivity_plus, sign_in_with_apple, google_sign_in, crypto — all available on pub.dev, add before any implementation tasks.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) + mocktail 1.0.5 |
| Config file | none — Flutter uses `flutter test` |
| Quick run command | `flutter test test/unit/core/ --no-pub` |
| Full suite command | `flutter test --no-pub` |

### Phase Requirements → Test Map

| Task | Behavior | Test Type | Automated Command | File Exists? |
|------|----------|-----------|-------------------|-------------|
| T015–T024 (Drift tables) | AppDatabase opens in-memory with all tables | unit | `flutter test test/unit/core/database/app_database_test.dart` | Wave 0 |
| T025–T032 (DAOs) | DAO CRUD + watch stream operations | unit | `flutter test test/unit/core/database/` | Wave 0 |
| T033 (Supabase client) | Provider returns initialized client | unit (mocktail) | `flutter test test/unit/core/network/` | Wave 0 |
| T034–T035 (Auth) | signUpWithEmail, signOut, currentUser stream | unit (mocktail) | `flutter test test/unit/core/auth/` | Wave 0 |
| T036–T037 (Sync) | Enqueue, dequeue, replay, retry_count=5 skip | unit | `flutter test test/unit/core/sync/` | Wave 0 |
| T039 (Download) | enqueue download, update manifest on complete | unit (mocktail) | `flutter test test/unit/core/downloads/` | Wave 0 |
| T133–T134 (CQRS) | CommandBus dispatches to sync_queue; QueryGateway reads view data | unit | `flutter test test/unit/core/cqrs/` | Wave 0 |
| T136 (CQRS consistency) | Projection lag integration test | integration | `flutter test test/integration/cqrs_projection_lag_test.dart` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/unit/core/ --no-pub`
- **Per wave merge:** `flutter test --no-pub`
- **Phase gate:** Full suite green before marking Phase 2 complete

### Wave 0 Gaps
- [ ] `test/unit/core/database/app_database_test.dart` — in-memory DB open + schema verify
- [ ] `test/unit/core/database/daos/sync_queue_dao_test.dart` — enqueue/dequeue/retry
- [ ] `test/unit/core/database/daos/download_manifest_dao_test.dart` — upsert/status transitions
- [ ] `test/unit/core/auth/auth_repository_test.dart` — mocktail Supabase auth
- [ ] `test/unit/core/sync/sync_queue_test.dart` — queue logic
- [ ] `test/unit/core/sync/sync_service_test.dart` — pull-sync + processQueue
- [ ] `test/unit/core/downloads/download_service_test.dart` — mock FileDownloader
- [ ] `test/unit/core/cqrs/command_bus_test.dart` — dispatch to sync_queue
- [ ] `test/integration/cqrs_projection_lag_test.dart` — T136

---

## Sources

### Primary (HIGH confidence)
- drift.simonbinder.eu/setup — @DriftDatabase, column types, constructor pattern
- drift.simonbinder.eu/dart_api/tables — all column builders, nullable, withDefault, primaryKey override, tableName override
- drift.simonbinder.eu/docs/testing/ — NativeDatabase.memory(), closeStreamsSynchronously, setUp/tearDown
- drift.simonbinder.eu/dart_api/daos — @DriftAccessor, DatabaseAccessor, watch streams, upsert
- supabase.com/docs/reference/dart/initializing — Supabase.initialize(), onAuthStateChange, AuthChangeEvent
- supabase.com/docs/guides/auth/social-login/auth-apple?platform=flutter — signInWithIdToken, nonce flow
- supabase.com/docs/guides/auth/social-login/auth-google?platform=flutter — GoogleSignIn.instance, serverClientId
- supabase.com/docs/guides/database/tables — CREATE VIEW with security_invoker, materialized view refresh
- supabase.com/docs/guides/database/webhooks — DB webhook trigger, payload structure
- pub.dev/packages/background_downloader — DownloadTask, BaseDirectory, Updates.statusAndProgress, updates stream
- pub.dev/packages/connectivity_plus — List<ConnectivityResult>, onConnectivityChanged stream
- Confirmed from /mobile/pubspec.yaml: exact locked versions for all dependencies
- Confirmed from existing /supabase/functions/revenuecat-webhook/index.ts: `Deno.serve()` + `import "@supabase/functions-js/edge-runtime.d.ts"` is the project's edge function convention

### Secondary (MEDIUM confidence)
- riverpod.dev/docs/concepts/about_code_generation — @riverpod, @Riverpod(keepAlive:true), class-based AsyncNotifier
- GoRouter + Riverpod auth pattern — Refreshable ChangeNotifier for refreshListenable
- Next.js 16 local docs (admin/node_modules/next/dist/docs/) — route.ts export async function GET pattern

### Tertiary (LOW confidence — verify at implementation time)
- `supabase.com/docs/guides/functions/connect-to-postgres` — `SUPABASE_SERVICE_ROLE_KEY` env var name; confirmed `Deno.serve()` pattern but exact env var names should be verified against Supabase dashboard

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all versions verified from live pubspec.yaml + pub.dev registry
- Architecture: HIGH — patterns confirmed from official docs + existing project structure
- Pitfalls: HIGH — column name conflict and view/materialized view limitation verified from docs; others from direct code analysis
- Missing packages: HIGH — verified by grepping pubspec.yaml

**Research date:** 2026-05-25
**Valid until:** 2026-07-25 (stable libraries; connectivity_plus 7.x API may shift on major bump)
