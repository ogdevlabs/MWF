# local-dev/

Scripts for running the full MWF stack locally.

## First-time setup (fresh checkout)

Run these once in order:

```bash
# 1. Install Flutter + npm dependencies
./local-dev/install.sh

# 2. Fill in credentials
cp local-dev/.env.example local-dev/.env   # then edit with your values
# Required: SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, SUPABASE_SERVICE_ROLE_KEY,
#           SUPABASE_ACCESS_TOKEN, SUPABASE_DB_PASSWORD,
#           FIREBASE_PROJECT_ID + all FIREBASE_* vars,
#           MUX_TOKEN_ID, MUX_TOKEN_SECRET, MUX_WEBHOOK_SIGNING_SECRET

# 3. Set up Supabase (link, push migrations, create buckets, write admin .env)
./local-dev/setup-supabase.sh

# 4. Push FCM/Mux secrets + deploy edge functions + generate Firebase config
./local-dev/setup-secrets.sh

# 5. Seed test data (test users, program, sessions, coach replies)
./local-dev/seed-test-data.sh

# 6. Start the full stack
./local-dev/dev.sh
```

See `docs/secrets-setup.md` for where to get each credential.
See `docs/firebase-setup.md` for Firebase-specific setup.

---

## Daily use

```bash
./local-dev/dev.sh              # Start full stack (iOS + admin panel)
./local-dev/dev.sh android      # Android + admin panel
./local-dev/dev.sh mobile-only  # Flutter only
./local-dev/dev.sh admin-only   # Admin panel only
```

---

## Scripts

| Script | What it does |
|--------|-------------|
| `install.sh` | Install Flutter + npm deps, accept Android licenses |
| `setup-supabase.sh` | Link project, push migrations, verify/create storage buckets, write admin/.env.local |
| `setup-secrets.sh` | Push FCM/Mux secrets to Supabase Edge Functions, deploy functions, generate Firebase config |
| `setup-firebase.sh` | Generate `firebase_options.dart` + platform config files from `.env` |
| `seed-test-data.sh` | Create test users + seed program/sessions/feedback (idempotent) |
| `dev.sh` | Start full stack — auto-runs `setup-secrets.sh` when credentials are set |
| `run-mobile.sh` | Run Flutter app — auto-discovers simulator/emulator |
| `run-admin.sh` | Run Next.js admin panel at `http://localhost:3555` |
| `supabase.sh` | Manage local Docker Supabase stack |

---

## Test credentials (after seed-test-data.sh)

| Role | Email | Password |
|------|-------|----------|
| Premium student | `premium@test.mwf` | `Test1234!` |
| Basic student (paywall) | `basic@test.mwf` | `Test1234!` |

---

## Storage buckets

| Bucket | Access | Usage |
|--------|--------|-------|
| `exercise-models` | Public read | GLB 3D asset files |
| `program-thumbnails` | Public read | Program cover images |
| `program-assets` | Authenticated | General coach uploads |
| `feedback-photos` | Authenticated | Student feedback photos |

---

## Requirements

- Flutter 3.44+ on PATH
- Node.js 20.9+
- Xcode (iOS) or Android Studio (Android)
- Supabase account + project
- Firebase project (for push notifications)
- Mux account (for video upload)
