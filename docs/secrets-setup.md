# Secrets & Environment Setup

All runtime secrets are managed in one place and deployed with a single command. No manual console steps.

---

## How it works

```
local-dev/.env          ← your credentials (gitignored, never committed)
        │
        ▼
./local-dev/setup-secrets.sh --env dev
./local-dev/setup-secrets.sh --env prod
        │
        ├── supabase secrets set   → Supabase Edge Function env vars
        ├── supabase functions deploy → send-fcm, mux-webhook, etc.
        ├── curl Mux API           → register webhook endpoint
        └── setup-firebase.sh      → generate firebase_options.dart + platform files

GitHub Actions: .github/workflows/deploy-secrets.yml
        → triggers automatically on merge to main
        → reads secrets from GitHub repository secrets / variables
        → same steps as the local script
```

---

## First-time setup

### Step 1: Gather credentials

You need 4 things. Each takes 2–5 minutes to get.

#### Supabase
| Var | Where to get it |
|-----|----------------|
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase dashboard → Settings → API → `service_role` key |
| `SUPABASE_PROJECT_REF_DEV` | Supabase dashboard → Settings → General → Reference ID (e.g. `rlcgtqagfdweisnxrasn`) |

#### Firebase (for push notifications)
| Var | Where to get it |
|-----|----------------|
| `FIREBASE_PROJECT_ID` | Firebase Console → Project settings → General → Project ID |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase Console → Project settings → Service accounts → **Generate new private key** → download JSON → minify to one line |
| `FIREBASE_IOS_API_KEY` etc. | See `docs/firebase-setup.md` |

**Minifying the service account JSON:**
```bash
# On macOS / Linux:
cat ~/Downloads/your-service-account.json | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)))"
# Paste the single-line output as FIREBASE_SERVICE_ACCOUNT_JSON
```

#### Mux (for video upload + webhook)
| Var | Where to get it |
|-----|----------------|
| `MUX_TOKEN_ID` | dashboard.mux.com → Settings → API Access Tokens → Create new token |
| `MUX_TOKEN_SECRET` | Same token creation page — copy immediately, shown only once |
| `MUX_WEBHOOK_SIGNING_SECRET` | dashboard.mux.com → Settings → Webhooks → any webhook → Signing secret |

> **Mux webhook** must be registered manually in the Mux dashboard — the API does not allow webhook creation via tokens. `setup-secrets.sh` will print the exact URL and steps.

---

### Step 2: Add credentials to local-dev/.env

Open `local-dev/.env` and fill in the values:

```bash
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
SUPABASE_PROJECT_REF_DEV=rlcgtqagfdweisnxrasn

FIREBASE_PROJECT_ID=move-with-fergie
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"move-with-fergie",...}
FIREBASE_IOS_API_KEY=AIzaSy...
FIREBASE_IOS_APP_ID=1:826982012345:ios:...
FIREBASE_IOS_MESSAGING_ID=826982012345
FIREBASE_IOS_STORAGE_BUCKET=move-with-fergie.appspot.com
FIREBASE_ANDROID_API_KEY=AIzaSy...
FIREBASE_ANDROID_APP_ID=1:826982012345:android:...

MUX_TOKEN_ID=your-token-id
MUX_TOKEN_SECRET=your-token-secret
MUX_WEBHOOK_SIGNING_SECRET=your-signing-secret
```

---

### Step 3: Run setup

```bash
# Dev environment (default)
./local-dev/setup-secrets.sh

# Verify what would be set first (no writes)
./local-dev/setup-secrets.sh --dry-run
```

This command:
1. Pushes 7 secrets to Supabase Edge Functions (`send-fcm`, `mux-webhook`, etc.)
2. Deploys all 4 Edge Functions
3. Prints Mux webhook setup instructions (manual dashboard step — API does not support creation via token)
4. Generates `firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`

After this, `./local-dev/dev.sh` calls `setup-secrets.sh` automatically on every start (when credentials are present).

---

## Environment promotion (dev → prod)

### Step 1: Add prod vars to local-dev/.env

```bash
SUPABASE_PROJECT_REF_PROD=your-prod-project-ref
SUPABASE_URL_PROD=https://your-prod-project-ref.supabase.co
SUPABASE_ACCESS_TOKEN=sbp_...   # supabase.com → Account → Access Tokens
```

### Step 2: Run for prod

```bash
./local-dev/setup-secrets.sh --env prod
```

Same secrets, different project ref. Register the Mux webhook manually in the dashboard pointing to the prod Edge Function URL.

---

## GitHub Actions (CI/CD)

`.github/workflows/deploy-secrets.yml` automates deployment on every merge to `main`.

### Required GitHub repository secrets

Go to: GitHub → repo → Settings → Secrets and variables → Actions

**Secrets** (sensitive — encrypted):
| Secret | Value |
|--------|-------|
| `SUPABASE_ACCESS_TOKEN` | Supabase personal access token |
| `SUPABASE_SERVICE_ROLE_KEY` | service_role key |
| `SUPABASE_DB_PASSWORD` | Supabase DB password (for migrations) |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full service account JSON (minified) |
| `MUX_TOKEN_ID` | Mux API token ID |
| `MUX_TOKEN_SECRET` | Mux API token secret |
| `MUX_WEBHOOK_SIGNING_SECRET` | Mux webhook signing secret |

**Variables** (non-sensitive — plaintext):
| Variable | Value |
|----------|-------|
| `SUPABASE_PROJECT_REF` | e.g. `rlcgtqagfdweisnxrasn` |
| `FIREBASE_PROJECT_ID` | e.g. `move-with-fergie` |

> For multiple environments (dev/prod), configure these on the GitHub **environment** (Settings → Environments), not the repo level. The workflow uses `environment: ${{ inputs.environment || 'prod' }}` which maps to the GitHub environment of the same name.

### Manual trigger (environment promotion)

Go to: GitHub → Actions → Deploy Secrets & Edge Functions → Run workflow

Select:
- **environment**: `dev` or `prod`
- **dry_run**: `true` to preview, `false` to apply

---

## What each secret does

| Secret | Used by | What happens without it |
|--------|---------|------------------------|
| `SUPABASE_SERVICE_ROLE_KEY` | All Edge Functions | Functions can't query DB |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | `send-fcm` | Push notifications silently fail |
| `FIREBASE_PROJECT_ID` | `send-fcm` | FCM API URL missing — push fails |
| `MUX_TOKEN_ID` + `MUX_TOKEN_SECRET` | `admin/app/api/mux-upload/route.ts` | Video upload returns 401 |
| `MUX_WEBHOOK_SIGNING_SECRET` | `mux-webhook` | Webhook accepts unsigned events (security warning) |

---

## Verify secrets are live

```bash
# List secrets on the linked project
npx supabase secrets list --project-ref <your-ref>
```

Should show all 7 secret names (values are not shown — that's correct).

```bash
# Test FCM end-to-end
# 1. Sign in on the mobile app as premium@test.mwf
# 2. Navigate to Coach tab (triggers FCM token registration)
# 3. In admin panel, reply to a feedback thread
# 4. Verify push notification appears on the device
```

---

## Rotating secrets

When you rotate a key (e.g. Mux token, Firebase service account):

1. Update the value in `local-dev/.env`
2. Run `./local-dev/setup-secrets.sh --env prod`

The `supabase secrets set` command upserts — it overwrites existing values. No delete step needed.

For GitHub Actions, update the secret in Settings → Secrets → edit the value. The next `deploy-secrets.yml` run will pick up the new value.
