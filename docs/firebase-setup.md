# Firebase Setup Guide

This guide walks you through creating a Firebase project and wiring it into the MWF app for push notifications (FCM). The whole process takes about 15 minutes. You only do this once.

---

## What Firebase is used for

Only one thing: **push notifications**. When a coach replies to a student's feedback message, Firebase Cloud Messaging (FCM) delivers the notification to the student's device.

The app already has all the code. Firebase just needs to be configured with your own project credentials.

---

## Part 1 — Create a Firebase project

### Step 1: Create a Google account (if you don't have one)

Firebase is a Google product. You need a Google account. If you already have one (Gmail, Google Workspace), use that.

### Step 2: Go to the Firebase Console

Open your browser and go to:

```
https://console.firebase.google.com
```

Sign in with your Google account.

### Step 3: Create a new project

1. Click **"Add project"** (or **"Create a project"**)
2. Enter a project name: `move-with-fergie` (or anything you like)
3. **Disable Google Analytics** — toggle it off when asked. You don't need it.
4. Click **"Create project"**
5. Wait ~30 seconds, then click **"Continue"**

You'll land on the project dashboard. It looks like this:

```
Firebase Console
├── Project Overview
├── Build
│   ├── Authentication
│   ├── Firestore Database   ← you won't use this
│   ├── Realtime Database    ← you won't use this
│   ├── Storage              ← you won't use this
│   └── Functions            ← you won't use this (yet)
├── Engage
│   └── Messaging            ← this is FCM (push notifications)
└── Project settings         ← you'll be here a lot
```

---

## Part 2 — Add the iOS app

### Step 4: Register the iOS app

1. On the Project Overview page, click the **iOS icon** (looks like an Apple logo)
2. Fill in:
   - **Apple bundle ID**: `com.fererelabs.mwfMobile`
   - **App nickname**: `MWF iOS` (optional, just a label)
   - **App Store ID**: leave blank
3. Click **"Register app"**

### Step 5: Download the iOS config file

1. Click **"Download GoogleService-Info.plist"**
2. **Do not move or rename this file yet** — you'll copy values from it
3. Click **"Next"** through the remaining steps (they're for manual setup — our script handles it automatically)
4. Click **"Continue to console"**

### Step 6: Copy iOS values into your .env

Open the downloaded `GoogleService-Info.plist` in any text editor. It looks like this:

```xml
<dict>
  <key>API_KEY</key>
  <string>AIzaSyXXXXXXXXXXXXXXXXXXXXX</string>       ← FIREBASE_IOS_API_KEY

  <key>GCM_SENDER_ID</key>
  <string>826982012345</string>                        ← FIREBASE_IOS_MESSAGING_ID

  <key>PROJECT_ID</key>
  <string>move-with-fergie</string>                   ← FIREBASE_PROJECT_ID

  <key>STORAGE_BUCKET</key>
  <string>move-with-fergie.appspot.com</string>       ← FIREBASE_IOS_STORAGE_BUCKET

  <key>GOOGLE_APP_ID</key>
  <string>1:826982012345:ios:abc123def456</string>     ← FIREBASE_IOS_APP_ID
</dict>
```

Copy each value into `local-dev/.env`:

```bash
FIREBASE_PROJECT_ID=move-with-fergie
FIREBASE_IOS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXX
FIREBASE_IOS_APP_ID=1:826982012345:ios:abc123def456
FIREBASE_IOS_MESSAGING_ID=826982012345
FIREBASE_IOS_STORAGE_BUCKET=move-with-fergie.appspot.com
```

---

## Part 3 — Add the Android app

### Step 7: Register the Android app

1. Back on the Project Overview, click **"Add app"** → **Android icon**
2. Fill in:
   - **Android package name**: `com.fererelabs.mwf_mobile`
   - **App nickname**: `MWF Android` (optional)
   - **Debug signing certificate SHA-1**: leave blank for now
3. Click **"Register app"**

### Step 8: Download the Android config file

1. Click **"Download google-services.json"**
2. Open it in a text editor. It looks like this:

```json
{
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:826982012345:android:xyz789",   ← FIREBASE_ANDROID_APP_ID
    },
    "api_key": [{
      "current_key": "AIzaSyYYYYYYYYYYYYYYYYYYYYY"           ← FIREBASE_ANDROID_API_KEY
    }]
  }]
}
```

3. Copy the values into `local-dev/.env`:

```bash
FIREBASE_ANDROID_API_KEY=AIzaSyYYYYYYYYYYYYYYYYYYYYY
FIREBASE_ANDROID_APP_ID=1:826982012345:android:xyz789
```

---

## Part 4 — Enable Cloud Messaging

### Step 9: Confirm FCM is active

1. In the Firebase console left sidebar, click **"Engage" → "Messaging"**
2. If it says "Get started" or "Set up", click through it — FCM is enabled by default, this just shows the dashboard
3. You don't need to send any test notifications here yet

---

## Part 5 — iOS Push Notification Certificate (required for real devices)

> **Skip this if you're only testing on the iOS Simulator.** The simulator receives FCM notifications without APNs setup. Come back to this when you're ready to test on a physical iPhone.

### Step 10: Create an APNs key in Apple Developer portal

1. Go to: `https://developer.apple.com/account/resources/authkeys/list`
2. Click **"+"** to create a new key
3. Name it: `MWF FCM Key`
4. Check **"Apple Push Notifications service (APNs)"**
5. Click **"Continue"**, then **"Register"**
6. Click **"Download"** — you get a `.p8` file (e.g. `AuthKey_ABC123DEF.p8`)
7. Note the **Key ID** shown on the page (10-character string like `ABC123DEF0`)
8. Note your **Team ID** — it's in the top-right of the Apple Developer portal under your name

### Step 11: Upload the APNs key to Firebase

1. In Firebase Console → **Project settings** (gear icon, top left)
2. Click the **"Cloud Messaging"** tab
3. Scroll to **"Apple app configuration"**
4. Under **"APNs authentication key"**, click **"Upload"**
5. Upload the `.p8` file you downloaded
6. Enter:
   - **Key ID**: the 10-char string from Step 10
   - **Team ID**: from your Apple Developer account
7. Click **"Upload"**

---

## Part 6 — Generate the config files

Once all the values are in `local-dev/.env`, run:

```bash
./local-dev/setup-firebase.sh
```

This generates three files automatically:
- `mobile/lib/firebase_options.dart`
- `mobile/ios/Runner/GoogleService-Info.plist`
- `mobile/android/app/google-services.json`

These files are **gitignored** — they contain credentials and must never be committed.

**Verify it worked:**

```bash
# Should NOT contain "TODO-replace-with-real-api-key"
grep "TODO" mobile/lib/firebase_options.dart && echo "STILL A STUB" || echo "✓ Real credentials"
```

---

## Part 7 — Run the app

```bash
./local-dev/dev.sh
```

`dev.sh` automatically calls `setup-firebase.sh` whenever `FIREBASE_PROJECT_ID` is set in `.env`, so Firebase config stays in sync as you pull new changes.

---

## Verifying FCM token registration

After signing in on the app, the app registers the device with Firebase and stores a token in Supabase. To confirm it worked:

1. Sign into the app as `premium@test.mwf`
2. Navigate to the **Coach** tab (triggers `fcmInitProvider`)
3. Run this in the Supabase SQL Editor:

```sql
SELECT email, fcm_token
FROM students
WHERE email = 'premium@test.mwf';
```

Expected: `fcm_token` column has a long string starting with something like `fGk3...` or `eXk...`. If it's `null`, FCM token registration failed — check the Firebase credentials in `.env`.

---

## Full .env reference for Firebase

```bash
# ── Firebase / FCM ────────────────────────────────────────────────────────────
# Project ID — visible in Firebase Console → Project settings → General
FIREBASE_PROJECT_ID=move-with-fergie

# iOS — from GoogleService-Info.plist
FIREBASE_IOS_API_KEY=AIzaSy...
FIREBASE_IOS_APP_ID=1:826982012345:ios:...
FIREBASE_IOS_MESSAGING_ID=826982012345
FIREBASE_IOS_STORAGE_BUCKET=move-with-fergie.appspot.com

# Android — from google-services.json
FIREBASE_ANDROID_API_KEY=AIzaSy...
FIREBASE_ANDROID_APP_ID=1:826982012345:android:...
```

> `FIREBASE_IOS_MESSAGING_ID` and the project number in `google-services.json` are the same value.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| App crashes at launch with `[Firebase] FirebaseApp initialization failed` | Wrong `GOOGLE_APP_ID` in plist | Re-check `FIREBASE_IOS_APP_ID` in `.env`, re-run `setup-firebase.sh` |
| FCM token is `null` in Supabase | Firebase not initialized (still placeholder) | Check `grep "TODO" mobile/lib/firebase_options.dart` — should be empty |
| Notification not received on real device | APNs key not uploaded | Complete Step 10–11 (APNs key upload) |
| Notification not received on simulator | Expected — simulator FCM works differently | Use a real device for end-to-end push testing |
| `setup-firebase.sh` says "Missing credentials" | Not all vars set in `.env` | Script prints exactly which vars are missing |

---

## What happens end-to-end (for reference)

```
Student completes session
    → taps "Send Feedback to Coach"
    → FeedbackRepository writes to Drift (offline-first)
    → SyncQueue syncs to Supabase feedback_threads table

Coach sees new thread in admin panel (Phase 8)
    → types a reply, hits Send
    → Supabase Edge Function fires on feedback_threads UPDATE
    → Edge Function calls FCM API: "send notification to student's fcm_token"

Firebase delivers notification to student's device
    → student taps notification
    → app deep-links to /coach-chat?sessionId=...
    → CoachChatScreen scrolls to the relevant message
```

The server-side Edge Function (Supabase → Firebase) is Phase 8 work — the client is fully ready.
