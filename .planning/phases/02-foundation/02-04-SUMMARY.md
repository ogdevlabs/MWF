---
plan: 02-04
phase: 2
subsystem: auth
tags: [auth, riverpod, connectivity, supabase, google-sign-in, apple-sign-in]
dependency_graph:
  requires: [02-02, 02-03]
  provides: [auth_repository, auth_provider, connectivity_provider]
  affects: [02-06, 02-07]
tech_stack:
  added: []
  patterns:
    - AuthRepository wraps SupabaseClient with nonce-based Apple Sign-In (crypto SHA-256)
    - Google Sign-In defers credentials to Phase 3 via String.fromEnvironment guard
    - keepAlive StreamProvider with handleError prevents token refresh crashes
    - ConnectivityNotifier tracks previous List<ConnectivityResult> for reconnect detection
key_files:
  created:
    - mobile/lib/core/auth/auth_repository.dart
    - mobile/lib/core/auth/auth_provider.dart
    - mobile/lib/core/sync/connectivity_provider.dart
  modified: []
decisions:
  - Google Sign-In uses 7.x constructor GoogleSignIn(serverClientId:, clientId:) — pubspec.lock shows google_sign_in 7.2.0, not 8.x
  - authStateProvider watches supabaseClientProvider directly (not authRepositoryProvider) to minimize indirection for the stream
  - ConnectivityNotifier builds with assume-online default; first stream event corrects this
metrics:
  duration: 6m
  completed: 2026-05-25
  tasks_completed: 3
  files_created: 3
---

# Phase 2 Plan 04: Auth Repository + Provider + ConnectivityProvider Summary

**One-liner:** Auth repository with email/password + Apple nonce + Google credential guard, keepAlive stream providers with error handling, and connectivity reconnect detector using `List<ConnectivityResult>` comparison.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create AuthRepository (T034) | a2a148f | mobile/lib/core/auth/auth_repository.dart |
| 2 | Create auth providers (T035) | fbd258f | mobile/lib/core/auth/auth_provider.dart |
| 3 | Create ConnectivityProvider (T038) | e3b1bcd | mobile/lib/core/sync/connectivity_provider.dart |

## What Was Built

### AuthRepository (`mobile/lib/core/auth/auth_repository.dart`)

Wraps all Supabase auth operations:
- `signUpWithEmail` / `signInWithEmail` — standard email/password flows
- `signInWithApple` — native iOS nonce flow: `generateRawNonce()` + SHA-256 from `crypto` package, then `signInWithIdToken(provider: OAuthProvider.apple)`
- `signInWithGoogle` — checks `String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')` and throws descriptive `AuthException` if empty; uses `GoogleSignIn(serverClientId:, clientId:)` constructor (7.x API matching installed version)
- `signOut` / `currentUser` / `onAuthStateChange` stream
- `@Riverpod(keepAlive: true)` provider function `authRepository`

### Auth Providers (`mobile/lib/core/auth/auth_provider.dart`)

- `authStateProvider` — keepAlive `Stream<AuthState>` wrapping `supabaseClientProvider` stream with `.handleError(...)` to swallow network errors during token refresh
- `currentUserProvider` — keepAlive `User?` derived from `authStateProvider.valueOrNull?.session?.user`
- `isAuthenticatedProvider` — boolean `user != null` derivation for router redirect logic

### ConnectivityProvider (`mobile/lib/core/sync/connectivity_provider.dart`)

- `connectivityStreamProvider` — raw keepAlive stream of `List<ConnectivityResult>` for consumers needing every event
- `ConnectivityNotifier` — class-based keepAlive notifier that:
  - Tracks `_previousResults` to detect offline-to-online transition
  - Calls `_onReconnect()` only when `wasOffline && isNowOnline`
  - `_onReconnect()` is the wiring hook for SyncService (02-06) and DownloadService (02-05)
  - `checkNow()` for on-demand status at app startup
  - Assumes online initially; corrected by first platform event

## Deviations from Plan

### Auto-adjusted: Google Sign-In API version

**Found during:** Task 1

**Issue:** Research doc noted `google_sign_in ^8.0.0` with `GoogleSignIn.instance.initialize()` API. pubspec.yaml specifies `^7.2.0` and pubspec.lock shows `7.2.0` is installed.

**Fix:** Used the 7.x constructor `GoogleSignIn(serverClientId:, clientId:)` as already specified in the plan's code block. The plan's own code example already used this older API — no functional change needed.

**Files modified:** mobile/lib/core/auth/auth_repository.dart

**Commit:** a2a148f

### Minor: authStateProvider variable naming

**Found during:** Task 2

**Issue:** The local variable `authState` in `currentUserProvider` would shadow the generated `authStateProvider` reference.

**Fix:** Renamed local variable to `authStateValue` to avoid shadowing.

**Files modified:** mobile/lib/core/auth/auth_provider.dart

**Commit:** fbd258f

## Known Stubs

None — all three files are complete implementations. Google Sign-In will throw a descriptive error until Phase 3 credentials are configured, which is intentional and documented with `TODO(phase3)` comments.

## Self-Check: PASSED

Files exist:
- FOUND: mobile/lib/core/auth/auth_repository.dart
- FOUND: mobile/lib/core/auth/auth_provider.dart
- FOUND: mobile/lib/core/sync/connectivity_provider.dart

Commits exist:
- a2a148f: feat(02-04): create AuthRepository
- fbd258f: feat(02-04): create auth Riverpod providers
- e3b1bcd: feat(02-04): create ConnectivityProvider
