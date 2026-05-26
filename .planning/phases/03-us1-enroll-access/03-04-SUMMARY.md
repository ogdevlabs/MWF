---
phase: 03-us1-enroll-access
plan: 04
subsystem: subscription
tags: [revenuecat, purchases_flutter, subscription, paywall, riverpod, shared_preferences]
dependency_graph:
  requires: [03-02, 03-03]
  provides: [subscription-repository, paywall-screen, revenuecat-init]
  affects: [app-router, programs-screen]
tech_stack:
  added: [purchases_flutter 10.1.1, shared_preferences 2.5.5]
  patterns: [RC-entitlement-check, supabase-fallback, sharedprefs-cache, riverpod-future-provider]
key_files:
  created:
    - mobile/lib/features/auth/data/subscription_repository.dart
    - mobile/lib/features/auth/data/subscription_provider.dart
    - mobile/lib/features/auth/data/subscription_provider.g.dart
    - mobile/lib/features/auth/data/subscription_repository.g.dart
    - mobile/lib/features/auth/presentation/paywall_screen.dart
  modified:
    - mobile/lib/main.dart
decisions:
  - "PurchaseParams.package(pkg) named constructor used — purchases_flutter 10.1.1 has no unnamed constructor"
  - "Purchases.configure() guarded by rcApiKey.isNotEmpty to allow running without dart-define in dev"
  - "auth_provider.dart import removed from subscription_repository.dart — only supabase_client needed"
metrics:
  duration: "~8m"
  completed: "2026-05-25"
  tasks_completed: 2
  files_changed: 6
requirements_satisfied: [FR-002]
---

# Phase 03 Plan 04: RevenueCat Subscription Layer Summary

RevenueCat subscription layer: entitlement check with Supabase fallback and SharedPreferences cache, isSubscribedProvider, PaywallScreen with offerings + purchase flow, and main.dart SDK initialization.

## What Was Built

### SubscriptionRepository (`subscription_repository.dart`)
Manages subscription state with a three-tier priority:
1. `Purchases.getCustomerInfo()` — real-time RC entitlement check for `premium_access`
2. Supabase `subscriptions` table — webhook-written fallback on `PlatformException`
3. SharedPreferences `subscription_is_active` — offline-last-known-state cache

Methods exported: `isSubscribed(userId)`, `getSubscription(userId)`, `getCachedSubscriptionStatus()`.
Riverpod provider: `subscriptionRepositoryProvider`.

### isSubscribedProvider (`subscription_provider.dart`)
Async FutureProvider returning `bool`. Watches `currentUserProvider`; returns `false` immediately if no user. Delegates to `SubscriptionRepository.isSubscribed()`. Consumers call `ref.watch(isSubscribedProvider)` to gate program access.

### PaywallScreen (`paywall_screen.dart`)
ConsumerStatefulWidget that:
- Calls `Purchases.getOfferings()` on init, displays `offerings.current.availablePackages`
- Each package rendered as a `_PackageCard` (title, description, priceString)
- Purchase via `Purchases.purchase(PurchaseParams.package(pkg))`
- On success: checks `entitlements.active.containsKey('premium_access')`, invalidates `isSubscribedProvider`, navigates to `programs` route
- Cancellation (`purchaseCancelledError`) swallowed — no error shown to user
- Network/loading/retry states handled

### main.dart
`Purchases.configure(PurchasesConfiguration(rcApiKey))` added after `Supabase.initialize()`. Platform branch on `defaultTargetPlatform == TargetPlatform.iOS` selects `REVENUECAT_APPLE_API_KEY` vs `REVENUECAT_GOOGLE_API_KEY` (both from `dart-define`). Guard: skips configure if key is empty (local dev without keys).

## Task Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | `114307b` | feat(03-04): add SubscriptionRepository + isSubscribedProvider |
| 2 | `92f0b37` | feat(03-04): add PaywallScreen + RevenueCat init in main.dart |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] PurchaseParams unnamed constructor does not exist in purchases_flutter 10.1.1**
- **Found during:** Task 2 — flutter analyze
- **Issue:** Plan specified `PurchaseParams(package: package)` but the class only has named constructors: `PurchaseParams.package()`, `PurchaseParams.storeProduct()`, `PurchaseParams.subscriptionOption()`. The unnamed constructor does not exist.
- **Fix:** Changed to `PurchaseParams.package(package)` — the correct named constructor for purchasing a `Package`.
- **Files modified:** `mobile/lib/features/auth/presentation/paywall_screen.dart`
- **Commit:** `92f0b37`

**2. [Rule 1 - Bug] Unused import in subscription_repository.dart**
- **Found during:** Task 2 — flutter analyze
- **Issue:** `auth_provider.dart` was imported but not referenced; `currentUser` is not needed directly in the repository (consumed by the provider layer).
- **Fix:** Removed unused import.
- **Files modified:** `mobile/lib/features/auth/data/subscription_repository.dart`
- **Commit:** `92f0b37`

## Known Stubs

None. All data flows are wired:
- `isSubscribedProvider` → `SubscriptionRepository.isSubscribed()` → `Purchases.getCustomerInfo()` (live RC)
- `PaywallScreen` → `Purchases.getOfferings()` → live RC offerings
- Both stub-free; require RevenueCat credentials at runtime to return real data (expected — external service).

## Self-Check: PASSED

Files created/exist:
- mobile/lib/features/auth/data/subscription_repository.dart: FOUND
- mobile/lib/features/auth/data/subscription_provider.dart: FOUND
- mobile/lib/features/auth/presentation/paywall_screen.dart: FOUND
- mobile/lib/main.dart (contains Purchases.configure): FOUND

Commits exist:
- 114307b: feat(03-04): add SubscriptionRepository + isSubscribedProvider
- 92f0b37: feat(03-04): add PaywallScreen + RevenueCat init in main.dart

flutter analyze: No issues found.
build_runner: Outputs generated cleanly.
