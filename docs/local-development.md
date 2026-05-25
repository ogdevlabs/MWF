# Local Development Guide

## Prerequisites

| Tool | Required Version | Install |
|------|-----------------|---------|
| Flutter | 3.44.0+ (stable) | https://docs.flutter.dev/get-started/install |
| Dart | 3.12.0+ (bundled with Flutter) | — |
| Node.js | 20.9+ (22.x recommended) | https://nodejs.org or `nvm install --lts` |
| npm | 10+ (bundled with Node) | — |
| Supabase CLI | latest | `npm install -g supabase` or `brew install supabase/tap/supabase` |
| Git | any | — |

**macOS only (iOS):** Xcode 16+ with Command Line Tools  
**macOS only (Android):** Android Studio with SDK Platform 34+

---

## 1. Clone & Install

```bash
git clone https://github.com/ogdevlabs/MWF.git
cd MWF
```

### Flutter mobile app

```bash
cd mobile
flutter pub get
cd ..
```

### Next.js admin panel

```bash
cd admin
npm install
cd ..
```

---

## 2. Environment Variables

### Flutter mobile (`--dart-define` at build/run time)

The app reads config via `String.fromEnvironment`. You don't need a `.env` file — pass values on the command line:

```bash
# Development (pointing to local Supabase)
cd mobile && flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=YOUR_LOCAL_ANON_KEY \
  --dart-define=REVENUECAT_APPLE_API_KEY=YOUR_KEY \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=YOUR_KEY
```

> Phase 1 note: Supabase is not yet initialized in `main.dart` (see `TODO Phase 2`). You can run the app without these values until Phase 2.

### Next.js admin (`admin/.env.local`)

Copy the example and fill in values:

```bash
cp admin/.env.local.example admin/.env.local
```

Edit `admin/.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_LOCAL_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=YOUR_LOCAL_SERVICE_ROLE_KEY
MUX_TOKEN_ID=YOUR_MUX_TOKEN_ID
MUX_TOKEN_SECRET=YOUR_MUX_TOKEN_SECRET
```

---

## 3. Local Supabase

Start a local Supabase stack (Postgres + Auth + Storage + Edge Functions):

```bash
# Start local stack (Docker required)
npx supabase start

# Apply the schema migration
npx supabase db push

# (Optional) Open Supabase Studio
open http://localhost:54323
```

The CLI will print your local `API URL`, `anon key`, and `service_role key` — use these in your env vars above.

> **Docker required.** Install Docker Desktop: https://www.docker.com/products/docker-desktop

To stop:

```bash
npx supabase stop
```

To reset the database to a clean state:

```bash
npx supabase db reset
```

---

## 4. Run the Apps

### Flutter mobile

**iOS Simulator:**

```bash
cd mobile
# List available simulators
flutter devices

# Run on iOS simulator (no env vars needed until Phase 2)
flutter run -d "iPhone 16 Pro"
```

**Android Emulator:**

```bash
# Accept licenses first (one-time, required)
flutter doctor --android-licenses

cd mobile
flutter run -d emulator-5554
```

You should see the **Login** placeholder screen — the auth guard redirects unauthenticated users to `/login`.

### Next.js admin panel

```bash
cd admin
npm run dev
# Open http://localhost:3000
```

---

## 5. Code Generation (Flutter)

After modifying Drift table definitions, Riverpod providers, or Freezed models, re-run the code generator:

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
```

For continuous watch mode during development:

```bash
cd mobile
dart run build_runner watch --delete-conflicting-outputs
```

---

## 6. Lint & Analyze

```bash
# Flutter
cd mobile && flutter analyze

# Next.js
cd admin && npm run lint

# Both (from repo root)
cd mobile && flutter analyze && cd ../admin && npm run lint
```

---

## 7. Tests

```bash
# Flutter unit + widget tests
cd mobile && flutter test

# Run a specific test file
cd mobile && flutter test test/unit/core/auth_test.dart

# Next.js (once tests are added in Phase 9)
cd admin && npm test
```

---

## 8. Supabase Edge Functions (local)

```bash
# Serve edge functions locally
npx supabase functions serve

# Test the RevenueCat webhook stub
curl -X POST http://localhost:54321/functions/v1/revenuecat-webhook \
  -H "Content-Type: application/json" \
  -d '{"event": {"type": "INITIAL_PURCHASE"}}'

# Test the Mux webhook stub
curl -X POST http://localhost:54321/functions/v1/mux-webhook \
  -H "Content-Type: application/json" \
  -d '{"type": "video.asset.ready", "data": {"id": "test"}}'
```

---

## 9. Database Migrations

```bash
# Create a new migration file
npx supabase migration new <migration_name>
# File created at: supabase/migrations/<timestamp>_<name>.sql

# Apply all pending migrations to local DB
npx supabase db push

# Check migration status
npx supabase migration list
```

---

## 10. Common Issues

**`flutter analyze` shows errors in Firebase package files**  
These are inside the cached Firebase Swift Package Manager sources at `mobile/build/macos/SourcePackages/`. They are in the package itself, not our code, and do not affect the build. Safe to ignore.

**`npx supabase start` fails — "Cannot connect to Docker"**  
Docker Desktop must be running. Open Docker Desktop and wait for it to fully start before retrying.

**Android build fails — "Installed Build Tools revision X.X.X is corrupted"**  
Run `flutter doctor --android-licenses` and accept all licenses. If that doesn't fix it, reinstall the Android Build Tools from Android Studio's SDK Manager.

**`flutter pub get` fails on `model_viewer_plus`**  
Ensure your Flutter SDK is 3.44.0+ (`flutter --version`). Earlier versions may not support the required `minSdkVersion 24`.

**`npm run build` fails with type errors in Next.js**  
Next.js 16 requires `params` and `searchParams` to be `Promise<...>` and awaited in Server Components. Example:
```typescript
// ✅ Next.js 16
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
}
```

---

## Project Structure Quick Reference

```
MWF/
├── mobile/          # Flutter app (iOS + Android)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── shared/
│   │   │   ├── theme/app_theme.dart
│   │   │   └── router/app_router.dart
│   │   └── features/    # Added Phase 2+
│   └── pubspec.yaml
├── admin/           # Next.js 16 admin panel
│   ├── app/
│   ├── components/
│   └── package.json
├── supabase/        # Supabase backend
│   ├── migrations/  # SQL migrations
│   └── functions/   # Edge functions (Deno)
└── docs/
    ├── local-development.md   ← you are here
    └── external-service-setup.md
```

---

## Phase Status

| Phase | Status | What it adds |
|-------|--------|--------------|
| 1 — Setup & Scaffold | ✅ Done | This skeleton — Flutter, Next.js, Supabase schema |
| 2 — Foundation | ⏳ Next | Auth, Drift DB, sync engine, CQRS |
| 3 — US1 Enroll & Access | ⏳ Planned | Signup, subscription, program browse |
| 4 — US2 Session Player | ⏳ Planned | Video + 3D exercise player |
| 5 — US3 Offline-First | ⏳ Planned | Pre-download, offline completion, sync |
| 6 — US4 Metrics | ⏳ Planned | Body metrics, trend charts, streaks |
| 7 — US5 Private Feedback | ⏳ Planned | Private coach DM, push notifications |
| 8 — US6 Admin Panel | ⏳ Planned | Coach content creation, feedback replies |
| 9 — Polish & QA | ⏳ Planned | Accessibility, benchmarks, final QA |
