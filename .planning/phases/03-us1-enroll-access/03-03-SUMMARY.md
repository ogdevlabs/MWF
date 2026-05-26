---
phase: 03-us1-enroll-access
plan: 03
subsystem: auth-ui
tags: [flutter, auth, riverpod, go_router, shared_preferences, onboarding]
dependency_graph:
  requires: [03-02]
  provides: [LoginScreen, SignupScreen, OnboardingScreen, OnboardingPrefsService, onboardingSeenProvider, updated-appRouterProvider]
  affects: [app_router.dart, auth flow]
tech_stack:
  added: [shared_preferences (OnboardingPrefsService)]
  patterns: [ConsumerStatefulWidget, GoRouter redirect, AsyncValue.value ?? default]
key_files:
  created:
    - mobile/lib/features/auth/presentation/login_screen.dart
    - mobile/lib/features/auth/presentation/signup_screen.dart
    - mobile/lib/features/auth/presentation/onboarding_screen.dart
    - mobile/lib/features/auth/data/onboarding_prefs_service.dart
    - mobile/lib/features/auth/data/onboarding_prefs_service.g.dart
  modified:
    - mobile/lib/shared/router/app_router.dart
    - mobile/lib/shared/router/app_router.g.dart
decisions:
  - "Use AsyncValue.value ?? true (not .valueOrNull) for onboardingSeenProvider in router — Riverpod 3.x dropped .valueOrNull"
  - "Default onboarding_seen=true during async loading to prevent flash-redirect to /onboarding on relaunch"
metrics:
  duration: "157s"
  completed_date: "2026-05-26"
  tasks_completed: 2
  files_created: 5
  files_modified: 2
---

# Phase 03 Plan 03: Auth Screens + Router Wiring Summary

One-liner: Email/social login screens, 3-slide onboarding carousel, and GoRouter 3-way redirect using SharedPreferences-backed onboarding flag.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create OnboardingPrefsService + Login + Signup + Onboarding screens | 0593cca | onboarding_prefs_service.dart, login_screen.dart, signup_screen.dart, onboarding_screen.dart |
| 2 | Wire app_router with real screens + onboarding redirect | 717a8d1 | app_router.dart, app_router.g.dart, onboarding_prefs_service.g.dart |

## What Was Built

**LoginScreen** (`ConsumerStatefulWidget`) — Email/password form with validation, Apple Sign-In button, Google Sign-In button, error display banner. Calls `authRemoteDatasourceProvider`; router redirect handles post-login navigation.

**SignupScreen** (`ConsumerStatefulWidget`) — Email/password/displayName form. Calls `signUpWithEmail` which upserts student profile via `AuthRemoteDatasource`. Navigation handled by router.

**OnboardingScreen** (`ConsumerStatefulWidget`) — 3-slide PageView carousel (Coach-Designed Programs, Video+3D Guidance, Track Progress). Animated dot indicators. "Next"/"Get Started"/"Skip" CTA. On completion: calls `OnboardingPrefsService.markOnboardingSeen()`, invalidates `onboardingSeenProvider`, navigates to `/programs`.

**OnboardingPrefsService** — SharedPreferences wrapper for `onboarding_seen` boolean key. Exposes `onboardingSeenProvider` (keepAlive async, resolves at startup) and `onboardingPrefsServiceProvider` (sync, used by OnboardingScreen).

**app_router.dart (updated)** — Replaced placeholder builders for `/login`, `/signup`, `/onboarding` with real screen classes. Added `onboardingSeenProvider` watch. Redirect logic:
1. Unauthenticated + not on auth route → `/login`
2. Authenticated + on auth route + unseen → `/onboarding`
3. Authenticated + on auth route + seen → `/programs`
4. Authenticated + on `/onboarding` + already seen → `/programs`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] AsyncValue.valueOrNull not available in Riverpod 3.x**
- **Found during:** Task 2, flutter analyze
- **Issue:** Plan specified `.valueOrNull` on `AsyncValue<bool>`, but Riverpod 3.x removed this getter — only `.value` exists.
- **Fix:** Changed `ref.watch(onboardingSeenProvider).valueOrNull ?? true` to `ref.watch(onboardingSeenProvider).value ?? true`. Semantics identical: returns `null` when loading/error, defaults to `true`.
- **Files modified:** `mobile/lib/shared/router/app_router.dart`, `mobile/lib/features/auth/data/onboarding_prefs_service.dart` (comment update)
- **Commit:** 717a8d1

## Known Stubs

None. All screens are fully wired to their datasources. Placeholder screens remain only for routes outside this plan's scope (programs, progress, paywall, etc.) which will be replaced in later plans as documented in the router.

## Self-Check: PASSED

Files verified:
- FOUND: mobile/lib/features/auth/presentation/login_screen.dart
- FOUND: mobile/lib/features/auth/presentation/signup_screen.dart
- FOUND: mobile/lib/features/auth/presentation/onboarding_screen.dart
- FOUND: mobile/lib/features/auth/data/onboarding_prefs_service.dart
- FOUND: mobile/lib/shared/router/app_router.dart

Commits verified:
- FOUND: 0593cca (feat(03-03): add auth screens and OnboardingPrefsService)
- FOUND: 717a8d1 (feat(03-03): wire app_router with real screens + onboarding redirect)

flutter analyze: No issues found.
