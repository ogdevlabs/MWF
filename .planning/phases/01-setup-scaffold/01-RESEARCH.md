# Phase 1: Setup & Scaffold — Research

**Researched:** 2026-05-25
**Domain:** Flutter 3.44 / Next.js 16 / Supabase CLI / Firebase / RevenueCat
**Confidence:** HIGH

---

## Summary

Phase 1 initializes three distinct project trees (`mobile/`, `admin/`, `supabase/`)
and provisions four external services. The vast majority of tasks (T002–T014) are
fully parallelizable; only T001 (Flutter scaffold) has a sequential dependency with
T004/T005 (adding pubspec dependencies) and T007 (configuring main.dart).

The most important discovery for the planner: **Next.js has moved to version 16**
(released October 2025; current stable: 16.2.6). The spec and tasks reference "Next.js 15"
but `create-next-app@latest` installs v16. This changes one flag (`middleware.ts` →
`proxy.ts`) and makes async `params`/`cookies()` mandatory. The App Router file
structure is unchanged; all T002/T006/T009 tasks work as-spec'd with minor version
notes.

Flutter is at 3.44.0 on this machine (spec targets 3.22; 3.44 is a superset — no
action needed). All required pub.dev packages are compatible with Flutter 3.44 /
Dart 3.12.

**Two critical native setup items are not in the task list** and must be done as
part of T004's aftermath: (1) `model_viewer_plus` requires `minSdkVersion 24` in
`android/app/build.gradle` and an Info.plist key; (2) `background_downloader`
requires Kotlin 2.1.0+ in `android/settings.gradle` and Background Fetch capability
in Xcode.

**Primary recommendation:** Proceed with all tasks as spec'd. Annotate T004 with the
native platform tweaks. Note the Next.js version reality (v16, not v15) in T002 so
the planner's instructions use the right flag set.

---

## Project Constraints (from CLAUDE.md)

- **Never push directly to `main`.** All work must go through a feature branch + PR.
- Branch naming: `git checkout -b <branch-name>`
- PR creation: `gh pr create` after pushing branch with `-u` flag
- Main is protected; direct pushes will be rejected

---

## Standard Stack

### Core Flutter Dependencies (pubspec.yaml `dependencies`)

| Package | Verified Version | Purpose | Notes |
|---------|-----------------|---------|-------|
| `flutter_riverpod` | 3.3.1 | State management | Requires `riverpod_annotation` for codegen |
| `riverpod_annotation` | 4.0.2 | Codegen annotations | Paired with riverpod_generator |
| `drift` | 2.33.0 | SQLite ORM | Core (Dart-only); needs `drift_flutter` for platform setup |
| `drift_flutter` | 0.3.0 | Flutter SQLite bridge | Replaces `sqlite3_flutter_libs` boilerplate |
| `go_router` | 17.2.3 | Declarative routing | Requires `flutter >=3.35.0`; on this machine: satisfied |
| `supabase_flutter` | 2.12.4 | Auth + Realtime + API | Latest v2 stable |
| `video_player` | 2.11.1 | HLS/local video | Official Flutter team |
| `chewie` | 1.14.1 | Video player UI | Wraps video_player with controls |
| `model_viewer_plus` | 1.10.0 | 3D GLB rendering | Requires Flutter >=3.38.0; **needs Android minSdkVersion 24** |
| `background_downloader` | 9.5.4 | Background file download | **Requires Kotlin 2.1.0+** on Android |
| `purchases_flutter` | 10.1.1 | RevenueCat IAP | v10.x major |
| `firebase_messaging` | 16.2.2 | FCM push notifications | Requires `firebase_core` 4.9.0 |
| `flutter_local_notifications` | 21.0.0 | Foreground notification display | Requires Flutter >=3.38.1; satisfied on 3.44 |
| `dio` | 5.9.2 | HTTP client | For Mux and custom endpoints |
| `freezed_annotation` | 3.1.0 | Freeze annotations | Must match freezed version |
| `json_annotation` | 4.12.0 | JSON codegen annotations | |
| `path_provider` | 2.1.5 | App document directory | Required by drift_flutter |

### Flutter Dev Dependencies (pubspec.yaml `dev_dependencies`)

| Package | Verified Version | Purpose |
|---------|-----------------|---------|
| `build_runner` | 2.15.0 | Code generation runner |
| `riverpod_generator` | 4.0.3 | Generates Riverpod providers |
| `drift_dev` | 2.33.0 | Generates Drift table/DAO code |
| `freezed` | 3.2.5 | Generates immutable value classes |
| `json_serializable` | 6.14.0 | Generates JSON serialization |
| `mocktail` | 1.0.5 | Mocking for flutter_test |
| `flutter_lints` | 6.0.0 | Lint rules (included by flutter create) |

### Next.js Admin Panel Dependencies (package.json)

| Package | Verified Version | Purpose | Notes |
|---------|-----------------|---------|-------|
| `next` | 16.2.6 | Framework | Spec says "15" but latest stable is 16 |
| `@supabase/supabase-js` | 2.106.2 | Supabase JS client | |
| `@supabase/ssr` | 0.10.3 | SSR-safe Supabase client helpers | |
| `@mux/mux-node` | 8.3.1 | Mux server SDK (video upload API) | Note: npm shows 8.3.1 in registry |
| `@mux/mux-uploader-react` | 1.5.0 | Mux direct upload UI component | |
| `recharts` | 2.106.2 | Chart library (progress charts) | |
| `react-hook-form` | 7.56.1 | Form state management | Note: latest is 7.56.1, not 7.5.0 shown in task |
| `zod` | 3.24.4 | Schema validation | Note: 3.24.4 is latest |

> Note on `shadcn-ui` in task T006: the package is now published as `shadcn` (not
> `shadcn-ui`). Install via `npx shadcn@latest init` after `create-next-app`;
> do NOT `npm install shadcn-ui` — it is the old package at 4.8.0 and unmaintained.
> The correct workflow is CLI-based initialization.

**Installation (Flutter):**
```bash
# After flutter create, inside mobile/
flutter pub add flutter_riverpod riverpod_annotation drift drift_flutter go_router supabase_flutter video_player chewie model_viewer_plus background_downloader purchases_flutter firebase_messaging flutter_local_notifications dio freezed_annotation json_annotation path_provider
flutter pub add --dev build_runner riverpod_generator drift_dev freezed json_serializable mocktail
```

**Installation (Next.js admin):**
```bash
npx create-next-app@latest admin --typescript --tailwind --app --eslint
cd admin
npm install @supabase/supabase-js @supabase/ssr @mux/mux-node @mux/mux-uploader-react recharts react-hook-form zod
npx shadcn@latest init
```

**Version verification:** All versions above confirmed against pub.dev and npm registries on 2026-05-25.

---

## Architecture Patterns

### Recommended Project Structure

The spec defines this structure; research confirms it is correct for the tool versions in use.

```
mwf/                              # Repo root
├── mobile/                       # Flutter app (flutter create output)
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   ├── shared/
│   │   │   ├── theme/
│   │   │   └── router/
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   ├── test/
│   └── pubspec.yaml
├── admin/                        # Next.js 16 app (create-next-app output)
│   ├── app/                      # App Router
│   ├── components/
│   ├── lib/
│   └── package.json
└── supabase/                     # Supabase project (supabase init output)
    ├── config.toml
    ├── migrations/
    └── functions/
```

### Pattern 1: Flutter Project Initialization

**What:** `flutter create` with org and project-name flags generates the project skeleton.

**Command:**
```bash
# From repo root
flutter create --org com.fererelabs --project-name mwf_mobile mobile
```

**The `--empty` flag** can optionally be added to omit the counter demo; without it
the default counter example is generated (which T007 overwrites anyway).

**What gets generated:**
- `mobile/pubspec.yaml` with SDK constraint `sdk: ^3.12.0`
- `mobile/lib/main.dart` with counter demo (replaced in T007)
- `mobile/android/`, `mobile/ios/` platform folders
- `mobile/test/widget_test.dart`
- `analysis_options.yaml` referencing `package:flutter_lints/flutter.yaml`

### Pattern 2: Next.js 16 App Router Initialization

**What:** `create-next-app@latest` scaffolds a Next.js 16 project with App Router.

**Command:**
```bash
npx create-next-app@latest admin --typescript --tailwind --app --eslint --yes
```

**Key flags for v16:**
- `--app` — App Router (default in v16, but explicit is clearer)
- `--typescript` — TypeScript (default in v16)
- `--tailwind` — Tailwind CSS
- `--eslint` — ESLint config
- `--yes` — Accept defaults (avoids interactive prompts in scripts)

**What gets generated:**
- `admin/app/` with `layout.tsx`, `page.tsx`, `globals.css`
- `admin/next.config.ts` (TypeScript config — v16 default)
- `admin/tailwind.config.ts`
- `admin/tsconfig.json`

**Next.js 16 vs. 15 differences relevant to T002/T006/T009:**
1. `middleware.ts` is deprecated; use `proxy.ts` instead (but `middleware.ts` still works for now)
2. `params` and `searchParams` in page components are now `Promise<...>` — must be `await`-ed
3. `cookies()` and `headers()` from `next/headers` must be `await`-ed
4. `revalidateTag()` requires second `cacheLife` argument
5. Default bundler is Turbopack (no action needed; it just works)
6. Node.js 20.9+ required — this machine has 22.22.3, satisfied

### Pattern 3: Supabase Project Initialization

**What:** `supabase init` creates the local project structure and `config.toml`.

**Command sequence:**
```bash
# From repo root — creates supabase/ directory
npx supabase init
# Then create migrations directory (init does NOT create it automatically)
mkdir -p supabase/migrations
```

**What gets generated:**
- `supabase/config.toml` — local development configuration
- `supabase/.gitignore`

**Creating an edge function:**
```bash
# From repo root (supabase/ must exist)
npx supabase functions new revenuecat-webhook
npx supabase functions new mux-webhook
```

This generates `supabase/functions/<name>/index.ts` and `supabase/functions/<name>/deno.json`.

### Pattern 4: Edge Function Structure (Deno)

**Current template (2026-05-25, Supabase CLI 2.101.0):**

```typescript
// supabase/functions/revenuecat-webhook/index.ts
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req, ctx) => {
    const body = await req.json();
    // Process webhook payload here
    // ctx.supabaseAdmin — service-role client, bypasses RLS
    return Response.json({ received: true });
  }),
};
```

**For RevenueCat webhook (upserts subscription):**
- Use `ctx.supabaseAdmin` (service role) to write to `subscriptions` table
- Verify `X-RevenueCat-Signature` header for authenticity
- Upsert on `revenuecat_customer_id` conflict

**For Mux webhook (updates exercise after video processing):**
- Listen for `video.asset.ready` event type
- Use `ctx.supabaseAdmin` to update `exercises.mux_playback_id`
- Verify `Mux-Signature` header

### Pattern 5: Flutter main.dart with ProviderScope

```dart
// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const ProviderScope(child: MwfApp()));
}
```

Note: `String.fromEnvironment` is the correct pattern for compile-time env vars in
Flutter. Alternatively, use `flutter_dotenv` or `envied` for runtime loading. The
plan should specify which approach to use (see Open Questions).

### Pattern 6: go_router Auth Guard (v17.x)

The redirect API is unchanged from earlier versions:

```dart
// mobile/lib/shared/router/app_router.dart
final GoRouter appRouter = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = /* read Riverpod auth provider */;
    if (!isAuthenticated && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;  // Allow navigation
  },
  routes: [
    GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/programs', builder: (ctx, state) => const ProgramListScreen()),
    // ...
  ],
);
```

To integrate Riverpod with go_router, use `ref.read` inside the redirect callback
by passing the `WidgetRef` via a `ConsumerStatefulWidget` shell, or use
`ProviderScope.containerOf(context)` to read outside a widget tree.

### Pattern 7: Drift + drift_flutter Setup

```dart
// mobile/lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [/* all table classes */])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mwf_local_db');
  }
}
```

`drift_flutter` handles `getApplicationDocumentsDirectory()` internally — no
explicit path_provider call required in the constructor.

**Code generation:**
```bash
cd mobile && dart run build_runner build --delete-conflicting-outputs
```

This generates `app_database.g.dart` and all `*.g.dart` files for tables and DAOs.

### Anti-Patterns to Avoid

- **`npm install shadcn-ui`**: This installs the unmaintained legacy package. Use `npx shadcn@latest init` instead.
- **`supabase init` inside `supabase/`**: Run `supabase init` from the repo root; it creates the `supabase/` directory.
- **Hard-coding Supabase URL/keys in Dart**: Use `String.fromEnvironment` or a secrets package; never commit keys.
- **`flutter create` inside `mobile/`**: The command takes the output directory as an argument. Run from repo root: `flutter create ... mobile`.
- **Skipping `build_runner` after adding freezed/drift**: Generated `.g.dart` files do not exist until build_runner runs; the project will not compile.
- **Using `withSupabase({ auth: [] })` with empty array for webhooks**: Webhooks from RevenueCat and Mux use a secret key, not a user JWT. Use `{ auth: ["secret"] }` and validate the webhook signature header separately.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| IAP receipt validation | Custom StoreKit/Play Billing integration | `purchases_flutter` (RevenueCat) | Server-side validation, cross-platform abstraction, webhook sync |
| Video CDN + transcoding | Custom upload/serve pipeline | Mux | Adaptive HLS, signed download URLs, webhook asset-ready events |
| Video UI controls | Custom video overlay widgets | `chewie` wrapping `video_player` | Buffering states, fullscreen, playback controls already handled |
| 3D model rendering | Custom WebGL | `model_viewer_plus` (WebView-backed) | Uses Google's `<model-viewer>` web component; GLB/glTF support |
| Background file downloads | Custom Dart isolate download queue | `background_downloader` | iOS Background Fetch, Android WorkManager, progress streams |
| SQLite platform setup | Manual `sqlite3_flutter_libs` wiring | `drift_flutter` | Single `driftDatabase()` call handles all platforms |
| Auth state management | Custom auth listener | `supabase_flutter` + Riverpod `StreamProvider` | `Supabase.instance.client.auth.onAuthStateChange` stream built-in |
| Push token → FCM bridge | Custom FCM integration | `firebase_messaging` + FlutterFire CLI | FlutterFire CLI generates `firebase_options.dart`; no manual plist editing |

**Key insight:** Every major subsystem in this project (IAP, video, 3D, offline downloads, auth, push) has a dedicated library that handles platform-specific edge cases. Hand-rolling any of these would take multiple sprint-weeks and still miss edge cases.

---

## Common Pitfalls

### Pitfall 1: model_viewer_plus requires Android minSdkVersion 24

**What goes wrong:** After adding `model_viewer_plus` to pubspec.yaml and running `flutter pub get`, the Android build fails with a manifest merger conflict because the generated Flutter project defaults to `minSdkVersion 21` (API 21 / Android 5.0) while `model_viewer_plus` requires API 24.

**Why it happens:** `model_viewer_plus` uses Google's Scene Viewer / `<model-viewer>` which requires API 24 minimum. Flutter's default template sets `minSdkVersion flutter.minSdkVersion` which resolves to 21.

**How to avoid:** In T004, immediately after adding dependencies, update `mobile/android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdk 24
    }
}
```
Also add to `mobile/ios/Runner/Info.plist`:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

**Warning signs:** `Manifest merger failed` with a minimum SDK requirement message during `flutter build apk`.

---

### Pitfall 2: background_downloader requires Kotlin 2.1.0+

**What goes wrong:** Android build fails with a Kotlin version error after adding `background_downloader`.

**Why it happens:** `background_downloader` 9.x uses Kotlin APIs requiring 2.1.0. Flutter's generated project template ships with an older Kotlin version in `android/settings.gradle`.

**How to avoid:** In T004, update `mobile/android/settings.gradle`:
```gradle
plugins {
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

Additionally, enable Background Fetch in Xcode (Runner target → Signing & Capabilities → + Background Modes → check "Background Fetch").

**Warning signs:** `Kotlin version X is not supported` during Android Gradle build.

---

### Pitfall 3: Next.js is at v16 (not v15) — async params required

**What goes wrong:** Page components using `params.id` directly will throw a type error or runtime warning in Next.js 16, which requires `params` to be awaited.

**Why it happens:** Next.js 16 made `params` and `searchParams` fully async `Promise<...>` types.

**How to avoid:** In T002, scaffold with `create-next-app@latest` (installs v16). Write all page components with async param access from the start:
```typescript
// admin/app/programs/[id]/page.tsx
export default async function ProgramPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  // ...
}
```

**Warning signs:** TypeScript errors about `params` type when using `{ params: { id: string } }` pattern from Next.js 14/15 tutorials.

---

### Pitfall 4: `shadcn-ui` npm package is abandoned — use CLI

**What goes wrong:** Running `npm install shadcn-ui` installs an unmaintained package (last release 2023) that does not work with Next.js 16 or the current Tailwind v4.

**Why it happens:** `shadcn/ui` deliberately does not ship as an npm package. Components are copied into your project via CLI.

**How to avoid:** After `create-next-app`, run:
```bash
npx shadcn@latest init
```
Do not add `shadcn-ui` to `package.json` dependencies.

**Warning signs:** Import errors for components that don't exist in `node_modules`.

---

### Pitfall 5: Supabase edge function auth mode for webhook handlers

**What goes wrong:** Using `{ auth: ["publishable"] }` on a webhook-receiving edge function causes all webhook calls from RevenueCat/Mux to be rejected with 401, because those services send a secret key (or no JWT at all).

**Why it happens:** `publishable` auth mode validates Supabase anon/user JWTs. RevenueCat/Mux use HMAC signature headers, not JWTs.

**How to avoid:** For webhook stubs (T011, T012), use `{ auth: ["secret"] }` or validate the external signature header manually after receiving the raw body. A simpler pattern for the stub:
```typescript
export default {
  fetch: withSupabase({ auth: ["secret"] }, async (req, ctx) => {
    // Validate webhook signature from request headers
    const body = await req.text();
    // ... HMAC verification ...
    return Response.json({ received: true });
  }),
};
```

---

### Pitfall 6: RevenueCat requires Xcode In-App Purchase capability + iOS 13 minimum

**What goes wrong:** `purchases_flutter` initialization succeeds at runtime but the SDK can't communicate with the App Store because the IAP capability is missing.

**Why it happens:** Xcode capabilities are not set by pubspec or CocoaPods; they require a manual step or entitlements file.

**How to avoid:** In T004's native setup step:
1. Open `mobile/ios/Runner.xcworkspace` in Xcode
2. Runner target → Signing & Capabilities → + → "In-App Purchase"
3. Ensure `ios/Podfile` has `platform :ios, '13.0'`
4. For Android, add to `mobile/android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

### Pitfall 7: Firebase setup requires FlutterFire CLI, not manual file placement

**What goes wrong:** Manually creating `google-services.json` and `GoogleService-Info.plist` stub files (as T013 implies) without running `flutterfire configure` means the app will crash at `Firebase.initializeApp()` because the generated `firebase_options.dart` is missing.

**Why it happens:** `firebase_messaging` depends on `firebase_core`, which requires `firebase_options.dart` (generated by FlutterFire CLI). A manually-created stub plist/json is not enough.

**How to avoid:** T013 should either:
- Run `flutterfire configure` against a real Firebase project (requires `firebase login` and project created at console.firebase.google.com), OR
- Create a minimal `lib/firebase_options.dart` stub with placeholder values and defer real Firebase setup to when the Firebase project is actually created

For Phase 1 scaffolding purposes, creating a `firebase_options.dart.stub` file with documentation of what's needed is acceptable. Mark it as a blocker for Phase 7 (FCM push).

---

### Pitfall 8: `drift_flutter` version is in pre-release (0.3.0)

**What goes wrong:** `drift_flutter` is at `0.3.0` (pre-1.0) — the API may change. Also, the pub.dev README references `0.3.1-wip` in examples but the published stable is `0.3.0`.

**Why it happens:** The `drift_flutter` package is a convenience wrapper under active development by the same author as drift (Simon Binder).

**How to avoid:** Pin to `^0.3.0`. The `driftDatabase()` API is stable for production use even at 0.x. Do not use `0.3.1-wip` (pre-release).

---

## Code Examples

### Complete pubspec.yaml dependencies section

```yaml
# Source: pub.dev verified 2026-05-25
environment:
  sdk: ^3.12.0
  flutter: ">=3.44.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2
  drift: ^2.33.0
  drift_flutter: ^0.3.0
  path_provider: ^2.1.5
  go_router: ^17.2.3
  supabase_flutter: ^2.12.4
  video_player: ^2.11.1
  chewie: ^1.14.1
  model_viewer_plus: ^1.10.0
  background_downloader: ^9.5.4
  purchases_flutter: ^10.1.1
  firebase_messaging: ^16.2.2
  firebase_core: ^4.9.0
  flutter_local_notifications: ^21.0.0
  dio: ^5.9.2
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.15.0
  riverpod_generator: ^4.0.3
  drift_dev: ^2.33.0
  freezed: ^3.2.5
  json_serializable: ^6.14.0
  mocktail: ^1.0.5
```

### Supabase RLS pattern for feedback_threads (private DM)

```sql
-- Source: data-model.md + Supabase RLS docs
-- Students see ONLY their own threads — strict private DM enforcement
CREATE POLICY "student_own_threads_only"
  ON feedback_threads
  FOR ALL
  USING (student_id = auth.uid());

-- Coach (service role) bypasses RLS — no additional policy needed
-- No policy allows reading other students' threads
```

### Supabase edge function webhook stub

```typescript
// supabase/functions/revenuecat-webhook/index.ts
// Generated by: npx supabase functions new revenuecat-webhook
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

export default {
  fetch: withSupabase({ auth: ["secret"] }, async (req, ctx) => {
    const body = await req.json();
    // TODO Phase 7: validate X-RevenueCat-Signature header
    // TODO Phase 7: upsert subscriptions table via ctx.supabaseAdmin
    console.log("RevenueCat webhook received:", body.event?.type);
    return Response.json({ received: true });
  }),
};
```

---

## Parallelization Analysis

### Can run fully in parallel (no shared state, different file trees)

| Group | Tasks | Shared dependency |
|-------|-------|-------------------|
| A | T001 | None — runs first |
| B (after T001) | T004, T005 | Both touch pubspec.yaml — must be sequential or merged |
| C | T002, T003 | Independent — different directories |
| D | T006 | After T002 (admin/ must exist) |
| E | T007, T008, T009 | After T001 + T004 (Flutter project + dependencies must exist) |
| F | T010, T011, T012 | After T003 (supabase/ must exist) |
| G | T013, T014 | After T001 (T013 needs mobile/ directory for config file paths) |

### Sequential requirements

1. **T001 must complete before T004/T005/T007/T008/T009/T013** — Flutter project must exist
2. **T002 must complete before T006** — Next.js project must exist for npm installs
3. **T003 must complete before T010/T011/T012** — Supabase project must exist

### Recommended execution order

```
Wave 0 (parallel): T001, T002, T003
Wave 1 (parallel, after respective Wave 0 parent):
  - After T001: T004+T005 (sequential — both touch pubspec), T013
  - After T002: T006
  - After T003: T010, T011, T012
Wave 2 (parallel, after T004 pubspec install):
  T007, T008, T009
Wave 3 (documentation only):
  T014 (RevenueCat dashboard config — no code)
```

---

## Environment Variables and Secrets Map

These files must NOT be committed to git. For each, a `.env.example` or stub with
placeholder values SHOULD be committed.

### Flutter (`mobile/`)

| Variable | Location | Used By | How Set |
|----------|----------|---------|---------|
| `SUPABASE_URL` | `--dart-define` or `.env` | `main.dart` Supabase.initialize | `flutter run --dart-define=SUPABASE_URL=...` |
| `SUPABASE_ANON_KEY` | `--dart-define` or `.env` | `main.dart` Supabase.initialize | `flutter run --dart-define=SUPABASE_ANON_KEY=...` |
| `REVENUECAT_APPLE_API_KEY` | `--dart-define` or `.env` | `purchases_flutter` configure | `Purchases.configure(PurchasesConfiguration(apiKey))` |
| `REVENUECAT_GOOGLE_API_KEY` | `--dart-define` or `.env` | `purchases_flutter` configure | |
| `google-services.json` | `mobile/android/app/` | Firebase Android | Generated by `flutterfire configure`; gitignored |
| `GoogleService-Info.plist` | `mobile/ios/Runner/` | Firebase iOS | Generated by `flutterfire configure`; gitignored |
| `firebase_options.dart` | `mobile/lib/` | `firebase_core` | Generated by `flutterfire configure`; gitignore or commit (non-secret) |

> Note: `firebase_options.dart` contains only **non-secret** identifiers per Firebase
> documentation. It is safe to commit. `google-services.json` and
> `GoogleService-Info.plist` contain API keys and SHOULD be gitignored in most
> setups.

### Next.js Admin (`admin/`)

| Variable | File | Used By |
|----------|------|---------|
| `NEXT_PUBLIC_SUPABASE_URL` | `.env.local` | `@supabase/ssr` client |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `.env.local` | `@supabase/ssr` client |
| `SUPABASE_SERVICE_ROLE_KEY` | `.env.local` | Server-side Supabase admin client |
| `MUX_TOKEN_ID` | `.env.local` | `@mux/mux-node` SDK |
| `MUX_TOKEN_SECRET` | `.env.local` | `@mux/mux-node` SDK |

### Supabase Edge Functions (`supabase/functions/`)

| Variable | Source | Used By |
|----------|--------|---------|
| `REVENUECAT_WEBHOOK_SECRET` | Supabase project secrets | HMAC validation in revenuecat-webhook |
| `MUX_WEBHOOK_SIGNING_SECRET` | Supabase project secrets | HMAC validation in mux-webhook |

Supabase secrets are set via:
```bash
npx supabase secrets set REVENUECAT_WEBHOOK_SECRET=xxx
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `middleware.ts` in Next.js | `proxy.ts` in Next.js 16 | Oct 2025 | Rename file + function; logic unchanged |
| `params: { id: string }` in pages | `params: Promise<{ id: string }>` + `await` | Next.js 16 | All `[id]` pages need async params |
| `sqlite3_flutter_libs` + manual path | `drift_flutter` package | 2023 | Single `driftDatabase()` call |
| `shadcn/ui` via npm package | `shadcn@latest` via CLI | 2024 | Components are copied into project |
| `npm install shadcn-ui` | `npx shadcn@latest init` | 2024 | Package-based approach abandoned |
| `riverpod` + `StateNotifier` | `riverpod_generator` + `AsyncNotifier` | Riverpod 2.0 | Code generation is now the standard path |

**Deprecated/outdated:**
- `sqlite3_flutter_libs`: Still works but `drift_flutter` is the recommended replacement for new projects
- `shadcn-ui` npm package: Unmaintained; `shadcn` is the correct package name (it's the CLI)
- Next.js `middleware.ts`: Deprecated in v16; `proxy.ts` is the replacement

---

## Open Questions

1. **Flutter environment variable strategy**
   - What we know: `String.fromEnvironment` works for compile-time vars; `flutter_dotenv` / `envied` for runtime
   - What's unclear: The tasks don't specify which approach to use; `--dart-define` is verbose in CI
   - Recommendation: Use `envied` (type-safe codegen approach) or `flutter_dotenv` for development simplicity; decide in T007 and document in mobile/README.md

2. **Firebase stub vs. real project for T013**
   - What we know: `firebase_messaging` requires `firebase_options.dart` which is generated by `flutterfire configure`; T013 says "add google-services.json and GoogleService-Info.plist stubs"
   - What's unclear: Can Phase 1 ship without a real Firebase project? Yes — but `firebase_messaging` won't function until Phase 7.
   - Recommendation: T013 should create placeholder stubs and a comment in `main.dart` saying "Firebase.initializeApp() deferred until Firebase project is created (see T013 completion notes)." The planner should mark T013 as partially-complete with a hardcoded TODO.

3. **RevenueCat dashboard configuration (T014) is pure documentation**
   - What we know: T014 is "configure RevenueCat dashboard" — entirely a human/manual step, not automatable
   - What's unclear: Should T014 produce a document (e.g., `docs/revenuecat-setup.md`) with the steps?
   - Recommendation: T014 should create `docs/external-service-setup.md` listing the RevenueCat dashboard steps (create entitlements, link App Store/Play Store product IDs) so a human can execute them.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter | T001, T004, T007–T009 | Yes | 3.44.0 | — |
| Dart SDK | Flutter build | Yes | 3.12.0 | — |
| Node.js 20.9+ | T002, T006 (Next.js 16 requires 20.9+) | Yes | 22.22.3 | — |
| npm | T002, T006 | Yes | 10.9.8 | — |
| Supabase CLI | T003, T010–T012 | Yes (via npx) | 2.101.0 | `npx supabase` on every invocation |
| Xcode 15+ | iOS simulator target | Yes | 26.5 | — |
| iOS Simulator (iPhone) | flutter run iOS | Yes | iPhone 17 Pro available | — |
| Android SDK | Android emulator | Yes | SDK 36.0.0 | — |
| Android Emulator | flutter run Android | Yes | Pixel_10_Pro | — |
| Android Licenses | flutter doctor | **NOT accepted** | 36.0.0 | Run `flutter doctor --android-licenses` |
| Firebase CLI | T013 (flutterfire configure) | No | — | Create firebase_options.dart stub manually |
| Supabase installed CLI | T003 | No (only npx) | 2.101.0 | Always use `npx supabase` |
| Docker | supabase start (local dev) | Unknown | — | Skip local Supabase; use cloud project |

**Missing dependencies with no fallback (blockers):**
- **Android licenses not accepted** — run `flutter doctor --android-licenses` before T001; otherwise Android build will fail at gradle sync. This is a one-time command.

**Missing dependencies with fallback:**
- **Firebase CLI** — T013 can create stub files; real `flutterfire configure` is deferred to when a Firebase project is created (not a Phase 1 blocker)
- **Supabase CLI (installed)** — all commands work via `npx supabase`; no install required
- **Docker** — `supabase start` (local Supabase stack) requires Docker, but Phase 1 only creates the migrations file; running migrations against local DB is deferred to development setup

---

## Validation Architecture

`workflow.nyquist_validation` is not set in `.planning/config.json` (key absent) —
treating as enabled.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (built-in) |
| Config file | none — uses `flutter test` CLI |
| Quick run command | `flutter test test/` (from `mobile/`) |
| Full suite command | `flutter test test/ --coverage` (from `mobile/`) |

### Phase 1 Success Criteria → Test Map

Phase 1 has no automated test requirements in the task list itself; the success
criteria are integration/smoke tests:

| Criterion | Behavior | Test Type | Command | File Exists? |
|-----------|----------|-----------|---------|-------------|
| SC-1 | `flutter run` launches on iOS sim without errors | Smoke (manual) | `flutter run -d "iPhone 17 Pro"` | — Wave 0 setup |
| SC-2 | `npm run dev` starts without errors | Smoke (manual) | `npm run dev` (from `admin/`) | — Wave 0 setup |
| SC-3 | `001_initial_schema.sql` exists with all tables | File existence | `ls supabase/migrations/001_initial_schema.sql` | ❌ Wave 0 |
| SC-4 | RevenueCat + Firebase config files exist | File existence | Manual check | ❌ Wave 0 |
| SC-5 | Edge function stubs exist | File existence | `ls supabase/functions/` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `flutter analyze` (from `mobile/`) after any Dart file changes
- **Per wave merge:** `flutter test test/` (when test files exist); `npm run build` (from `admin/`)
- **Phase gate:** All 5 success criteria verified manually before marking phase complete

### Wave 0 Gaps

- [ ] No test files exist yet (project hasn't been created)
- [ ] `flutter analyze` will be meaningful only after T004 (dependencies added)
- [ ] `flutter test` baseline: default `test/widget_test.dart` from `flutter create` output

*(Note: Phase 1 is primarily scaffolding; its verification is project creation success
and file existence checks, not logic tests. The first meaningful unit tests appear in
Phase 2 Foundation.)*

---

## Sources

### Primary (HIGH confidence)

- pub.dev API (`pub.dev/api/packages/*`) — all versions verified by direct API call on 2026-05-25
- npm registry (`npm view <package> version`) — all versions verified on 2026-05-25
- `flutter --version` — local machine confirms 3.44.0 / Dart 3.12.0
- `npx supabase --version` — confirms CLI 2.101.0
- `flutter create --help` — confirmed current CLI flags
- `npx create-next-app@latest --help` — confirmed v16 CLI flags
- `npx supabase init` + `supabase functions new` in temp dir — confirmed actual generated file structure
- `flutter doctor` — confirmed environment state including Android license issue
- drift.simonbinder.eu/setup/ — confirmed drift_flutter 0.3.0 setup pattern
- model_viewer_plus pub.dev page — confirmed minSdkVersion 24 requirement + Info.plist key
- background_downloader pub.dev page — confirmed Kotlin 2.1.0 requirement + Background Fetch capability
- go_router redirection docs — confirmed redirect API unchanged in v17
- supabase_flutter pub.dev — confirmed `Supabase.initialize()` signature
- nextjs.org/blog/next-16 — confirmed v16 breaking changes (async params, middleware → proxy)
- ui.shadcn.com/docs/installation/next — confirmed `npx shadcn@latest init` is correct
- revenuecat.com/docs/flutter — confirmed iOS IAP capability + Android billing permission

### Secondary (MEDIUM confidence)

- WebFetch of Firebase Flutter setup page — confirmed FlutterFire CLI workflow and `firebase_options.dart` generation
- WebFetch of purchases_flutter page — confirmed iOS/Android native requirements

### Tertiary (LOW confidence)

- None

---

## Metadata

**Confidence breakdown:**
- Standard stack (Flutter deps): HIGH — all versions verified via pub.dev API live
- Standard stack (npm deps): HIGH — all versions verified via npm registry live
- Architecture patterns: HIGH — confirmed via CLI help output and official docs
- Platform native setup: HIGH — confirmed via official package pub.dev pages
- Next.js version reality: HIGH — confirmed via `npm view next versions`
- Pitfalls: HIGH — confirmed via official package documentation
- Firebase stub strategy: MEDIUM — based on FlutterFire CLI documentation; exact stub format not tested

**Research date:** 2026-05-25
**Valid until:** 2026-06-25 (30 days for stable ecosystem; Next.js moves fast — recheck if > 2 weeks)
