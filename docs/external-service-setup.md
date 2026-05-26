# External Service Setup

Manual configuration steps required outside of code before certain features function.

---

## 1. Firebase (Push Notifications)

**Required for:** Phase 7 — Push notifications for coach replies

1. Create project at https://console.firebase.google.com
2. Add iOS app (Bundle ID: `com.fererelabs.mwfMobile`) → download `GoogleService-Info.plist` → place at `mobile/ios/Runner/GoogleService-Info.plist`
3. Add Android app (Package: `com.fererelabs.mwf_mobile`) → download `google-services.json` → place at `mobile/android/app/google-services.json`
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

1. Create project at https://app.revenuecat.com → name: `Move With Fergie`
2. Configure platforms (App Store Connect API key + Google Play service account)
3. Create entitlement: `premium_access`
4. Create products: `mwf_monthly_premium` (monthly), `mwf_annual_premium` (annual)
5. Create default offering with both packages
6. Configure webhook:
   - URL: `https://YOUR_SUPABASE_PROJECT.supabase.co/functions/v1/revenuecat-webhook`
   - Events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`
   - Set webhook secret → `npx supabase secrets set REVENUECAT_WEBHOOK_SECRET=xxx`
7. Note API keys: `REVENUECAT_APPLE_API_KEY` and `REVENUECAT_GOOGLE_API_KEY` (used as `--dart-define` in Flutter builds)

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

- [ ] Firebase project created + `flutterfire configure` run
- [ ] RevenueCat: entitlement `premium_access` + products `mwf_monthly_premium` / `mwf_annual_premium` created
- [ ] RevenueCat webhook URL + secret configured
- [ ] Mux API token created + webhook configured
- [ ] Supabase project created + migration pushed + buckets created
- [ ] iOS capabilities added in Xcode
- [ ] All environment variables set in respective config files
