# External Service Setup

Manual configuration steps required outside of code before certain features function.

---

## 1. Firebase (Push Notifications)

**Required for:** Phase 7 — Push notifications for coach replies

1. Create project at https://console.firebase.google.com
2. Add iOS app (Bundle ID: `com.fererelabs.mwf`) → download `GoogleService-Info.plist` → place at `mobile/ios/Runner/GoogleService-Info.plist`
3. Add Android app (Package: `com.fererelabs.mwf`) → download `google-services.json` → place at `mobile/android/app/google-services.json`
4. Run FlutterFire CLI to regenerate `firebase_options.dart`:
   ```bash
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure --project=YOUR_PROJECT_ID
   ```
5. Enable Cloud Messaging in Firebase Console → Project Settings → Cloud Messaging

---

## 2. RevenueCat (In-App Purchases)

**Required for:** Phase 3 — Subscription gating
**Status: ⏳ Deferred until App Store submission** — not needed for development or testing.

> The app falls back to the Supabase `subscriptions` table when RevenueCat is not configured.
> The seeded test account `premium@test.mwf` works as premium without any RevenueCat setup.
> Complete this only when you are ready to submit to the App Store.

**Full step-by-step guide: [`docs/revenuecat-setup.md`](./revenuecat-setup.md)**

Summary of what's needed when you're ready:
1. Apple Developer account ($99/year) + Bundle ID `com.fererelabs.mwf` registered
2. App Store Connect app record created
3. App Store Connect API key (p8 file) generated
4. RevenueCat project → iOS app added with p8 file
5. Entitlement `premium_access` created
6. Products `mwf_monthly_premium` + `mwf_annual_premium` created in App Store Connect
7. Default offering with both packages
8. Webhook → `https://rlcgtqagfdweisnxrasn.supabase.co/functions/v1/revenuecat-webhook`
9. `REVENUECAT_APPLE_API_KEY` + `REVENUECAT_GOOGLE_API_KEY` added to `local-dev/.env`

---

## 3. Mux (Video Hosting)

**Required for:** Phase 8 — Admin panel video uploads

1. Create account at https://dashboard.mux.com
2. Generate API Access Token (Settings → API Access Tokens): note Token ID + Secret
3. Configure webhook:
   - URL: `https://YOUR_SUPABASE_PROJECT.supabase.co/functions/v1/mux-webhook`
   - Events: `video.asset.ready`, `video.asset.errored`
   - Set signing secret → `npx supabase secrets set MUX_WEBHOOK_SIGNING_SECRET=xxx`
4. Set in `admin/.env.local`: `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET`

---

## 4. Supabase (Backend)

**Required for:** All phases

1. Create project at https://supabase.com/dashboard → name: `move-with-fergie`
2. Note: Project URL, Publishable Key, Service Role Key (Settings → API)
3. Run migration:
   ```bash
   npx supabase link --project-ref YOUR_PROJECT_REF
   npx supabase db push
   ```
4. Create Storage buckets:
   - `exercise-models` (GLB assets) — public read
   - `feedback-photos` (student feedback images) — authenticated read
   - `program-thumbnails` (cover images) — public read
5. Set Flutter build vars: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
6. Set in `admin/.env.local`: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

---

## 5. iOS Capabilities (Xcode)

**Required for:** Phase 3 (IAP), Phase 7 (Push)

1. Open `mobile/ios/Runner.xcworkspace` in Xcode
2. Runner target → Signing & Capabilities → add:
   - **In-App Purchase**
   - **Push Notifications**
   - **Background Modes** → Background Fetch + Remote Notifications

---

## Checklist

**Development (required now):**
- [x] Firebase project created + credentials in `local-dev/.env` + `setup-firebase.sh` run
- [x] Mux API token created + webhook registered in dashboard + secrets pushed via `setup-secrets.sh`
- [x] Supabase project live + migrations applied + all 4 buckets created + `setup-supabase.sh` run
- [ ] iOS capabilities added in Xcode (Push Notifications + Background Modes)
- [ ] `SUPABASE_DB_PASSWORD` added to `local-dev/.env`

**App Store submission (deferred):**
- [ ] Apple Developer account enrolled ($99/year)
- [ ] RevenueCat fully configured — see `docs/revenuecat-setup.md`
- [ ] iOS In-App Purchase capability added in Xcode
