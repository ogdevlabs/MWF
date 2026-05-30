# RevenueCat Setup Guide

RevenueCat manages in-app subscriptions. It sits between your app and the App Store/Google Play, handling receipt validation, subscription status, and webhook events to Supabase.

> **Status: Deferred until App Store submission.**
> The app fully works without RevenueCat during development. The test account `premium@test.mwf` has a subscription row seeded directly in Supabase, so all premium features work in testing. Complete this guide only when you are ready to submit to the App Store.

---

## What RevenueCat does in this app

```
Student taps "Subscribe" in the app
        ↓
RevenueCat SDK handles App Store / Play Store purchase
        ↓
Apple/Google confirms payment to RevenueCat
        ↓
RevenueCat sends webhook to Supabase Edge Function
        ↓
Edge Function writes to subscriptions table
        ↓
App checks subscriptions table → unlocks Coach tab
```

Without RevenueCat, subscriptions cannot be sold through the App Store or Google Play. The app falls back to checking the Supabase `subscriptions` table directly — which works fine for development and testing.

---

## Prerequisites

Before starting RevenueCat setup you need:

### 1. Apple Developer Account ($99/year)

Required to generate receipts, test sandbox purchases, and eventually submit to the App Store.

- Sign up at: https://developer.apple.com/programs/enroll/
- Takes 1–2 days to be approved
- Once approved, you get access to App Store Connect

### 2. App Store Connect app record

Your app needs to exist in App Store Connect (even in a draft/incomplete state) before you can create in-app purchase products.

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. **My Apps** → **+** → **New App**
4. Fill in:
   - Platform: **iOS**
   - Name: **Move With Fergie**
   - Bundle ID: **com.fererelabs.mwf** (you must register this in your developer account first — see below)
   - SKU: `mwf-app` (any unique string)
5. Save — the app can stay in "Prepare for Submission" state

**Registering the Bundle ID first:**
1. https://developer.apple.com/account/resources/identifiers/list
2. **+** → **App IDs** → **App**
3. Description: `Move With Fergie`
4. Bundle ID: **Explicit** → `com.fererelabs.mwf`
5. Capabilities: check **In-App Purchase** and **Push Notifications**
6. Register

### 3. App Store Connect API Key (p8 file)

RevenueCat uses this to validate receipts with Apple.

1. Go to https://appstoreconnect.apple.com/access/api
2. **Keys** tab → **Generate API Key**
3. Name: `RevenueCat`
4. Access: **Admin**
5. Click **Generate**
6. **Download the `.p8` file immediately** — Apple only lets you download it once. Store it safely (password manager or secure folder).
7. Note the **Key ID** (10-character string shown on the page)
8. Note your **Issuer ID** (shown at the top of the Keys page)

---

## RevenueCat configuration

### Step 1: Create a RevenueCat project

1. Go to https://app.revenuecat.com
2. **+ New Project** → name: `Move With Fergie`
3. You land on the project overview

### Step 2: Add the iOS app

1. In the left sidebar: **Project Settings** → **Apps** (or look for a **+** button)
2. Select **App Store**
3. Fill in:
   - **App name**: Move With Fergie
   - **Bundle ID**: `com.fererelabs.mwf`
   - **App Store Connect API Key**: upload the `.p8` file you downloaded
   - **Key ID**: the 10-character key ID from App Store Connect
   - **Issuer ID**: from the top of the App Store Connect Keys page
4. Save
5. Copy the **Public API Key** shown on the app page — this is `REVENUECAT_APPLE_API_KEY`

### Step 3: Add the Android app

1. **+ New App** → **Google Play**
2. Fill in:
   - **Package name**: `com.fererelabs.mwf`
   - **Google Play service account credentials**: a JSON key from Google Play Console (see below)
3. Copy the **Public API Key** — this is `REVENUECAT_GOOGLE_API_KEY`

**Getting the Google Play service account JSON:**
1. Go to https://play.google.com/console
2. You need a Google Play Developer account ($25 one-time fee)
3. Setup → API access → Link to a Google Cloud project
4. Create service account → grant **Financial data / Orders and subscriptions (view)** permission
5. Download the JSON key file → upload to RevenueCat

### Step 4: Create the entitlement

Entitlements are what the app checks to decide if a user is subscribed.

1. Left sidebar → **Entitlements** → **+ New**
2. Identifier: `premium_access` ← **must match exactly** (this is what the app checks in code)
3. Display name: `Premium Access`
4. Save

### Step 5: Create products

Products are the actual subscription items sold in the App Store / Play Store.

**In App Store Connect first:**
1. https://appstoreconnect.apple.com → your app → **Subscriptions**
2. Create a **Subscription Group**: `Move With Fergie Premium`
3. Add subscriptions:
   - **Monthly**: Product ID `mwf_monthly_premium`, duration 1 month, price ~$9.99
   - **Annual**: Product ID `mwf_annual_premium`, duration 1 year, price ~$79.99

**Then in RevenueCat:**
1. Left sidebar → **Products** → **+ New**
2. Add both products, selecting the store they belong to
3. Product ID must match exactly what you created in App Store Connect

### Step 6: Create an offering

An offering is the set of products shown to the user.

1. Left sidebar → **Offerings** → **+ New Offering**
2. Identifier: `default` ← **must be `default`** (the app requests the default offering)
3. Add two packages:
   - **Monthly** (`$rc_monthly`) → attach the monthly product
   - **Annual** (`$rc_annual`) → attach the annual product
4. Save

### Step 7: Configure the webhook

RevenueCat sends events to Supabase when subscriptions change.

1. Left sidebar → **Project Settings** → **Integrations** → **Webhooks**
2. **Add webhook**:
   - URL: `https://rlcgtqagfdweisnxrasn.supabase.co/functions/v1/revenuecat-webhook`
   - Events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`
3. Copy the **Webhook Shared Secret**
4. Add to `local-dev/.env`:
   ```
   REVENUECAT_WEBHOOK_SECRET=your-secret-here
   ```
5. Push to Supabase Edge Function secrets:
   ```bash
   ./local-dev/setup-secrets.sh
   ```

### Step 8: Add API keys to your environment

```bash
# local-dev/.env
REVENUECAT_APPLE_API_KEY=appl_xxxxxxxxxxxxxxxxxxxx
REVENUECAT_GOOGLE_API_KEY=goog_xxxxxxxxxxxxxxxxxxxx
```

These are passed to Flutter as `--dart-define` values via `dev.sh` automatically.

---

## Testing subscriptions

RevenueCat provides a **sandbox environment** for testing without real money.

**iOS sandbox:**
1. On your iPhone: Settings → App Store → Sandbox Account → sign in with a sandbox tester email
2. Create a sandbox tester at: https://appstoreconnect.apple.com/access/testers
3. Run the app on a real device (sandbox purchases don't work on simulator)
4. Subscribe — Apple won't charge real money in sandbox

**RevenueCat debug:**
- In the app, add `Purchases.setLogLevel(.debug)` temporarily to see all SDK activity in the Xcode console
- RevenueCat dashboard → **Customer** search → find your test user ID to see their subscription history

---

## What happens in the app

The subscription check in `SubscriptionRepository` works in this priority order:

1. **RevenueCat** (`Purchases.getCustomerInfo()`) — real-time, handles renewals
2. **Supabase fallback** (`subscriptions` table) — used if RevenueCat is unavailable
3. **SharedPreferences cache** — offline fallback

During development with seeded test data, the Supabase fallback (step 2) is what makes `premium@test.mwf` work as a premium user without RevenueCat being configured.

---

## Checklist

- [ ] Apple Developer account enrolled ($99/year)
- [ ] Bundle ID `com.fererelabs.mwf` registered in Apple Developer portal
- [ ] App Store Connect app record created
- [ ] App Store Connect API key (p8 file) downloaded and stored safely
- [ ] RevenueCat iOS app added with p8 file
- [ ] RevenueCat Android app added (optional — needed for Play Store)
- [ ] Entitlement `premium_access` created
- [ ] Products `mwf_monthly_premium` and `mwf_annual_premium` created in App Store Connect
- [ ] Products added to RevenueCat and attached to offering `default`
- [ ] Webhook configured with Supabase Edge Function URL
- [ ] `REVENUECAT_APPLE_API_KEY` and `REVENUECAT_GOOGLE_API_KEY` added to `local-dev/.env`
- [ ] `REVENUECAT_WEBHOOK_SECRET` pushed to Supabase Edge Function secrets
