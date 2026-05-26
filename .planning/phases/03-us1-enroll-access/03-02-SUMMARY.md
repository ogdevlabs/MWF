---
phase: 03-us1-enroll-access
plan: 02
subsystem: auth
tags: [domain-models, freezed, riverpod, revenuecat, supabase, student-profile]
dependency_graph:
  requires: [03-01]
  provides: [Student, Subscription, AuthRemoteDatasource, StudentRemoteDatasource]
  affects: [auth-screens-wave3, subscription-layer-wave4]
tech_stack:
  added: []
  patterns:
    - Freezed 3.x abstract class with _$ClassName pattern for value objects
    - Feature-layer datasource wrapping core repository with side-effects
    - Riverpod @riverpod provider for datasource injection
key_files:
  created:
    - mobile/lib/features/auth/domain/student_model.dart
    - mobile/lib/features/auth/domain/subscription_model.dart
    - mobile/lib/features/auth/data/auth_remote_datasource.dart
    - mobile/lib/features/auth/data/student_remote_datasource.dart
    - mobile/lib/features/auth/domain/student_model.freezed.dart
    - mobile/lib/features/auth/domain/student_model.g.dart
    - mobile/lib/features/auth/domain/subscription_model.freezed.dart
    - mobile/lib/features/auth/domain/subscription_model.g.dart
    - mobile/lib/features/auth/data/auth_remote_datasource.g.dart
    - mobile/lib/features/auth/data/student_remote_datasource.g.dart
  modified: []
decisions:
  - AuthRemoteDatasource calls Purchases.logIn(userId) after every successful sign-in and Purchases.logOut() before Supabase signOut
  - StudentRemoteDatasource uses onConflict:'id' upsert for idempotency across sign-up and repeated sign-in
  - Avatar URL included in Google social sign-in upsert via userMetadata['avatar_url']
metrics:
  duration: 2m
  completed_date: "2026-05-26"
  tasks_completed: 2
  files_created: 10
requirements: [FR-001, FR-002]
---

# Phase 3 Plan 02: Auth Domain Models and Data Layer Summary

Domain models (Student, Subscription) and feature-layer data sources (AuthRemoteDatasource, StudentRemoteDatasource) for the auth feature.

## What Was Built

**Student model** (`mobile/lib/features/auth/domain/student_model.dart`) — Freezed value class mapping to the `students` Supabase table. Fields: id, email, displayName, avatarUrl, timezone (default UTC), createdAt. Includes `fromJson` for JSON serde and `fromSupabaseRow` for direct DB row mapping.

**Subscription model** (`mobile/lib/features/auth/domain/subscription_model.dart`) — Freezed value class representing a student's subscription state. Fields: id, studentId, status, platform, productId, currentPeriodStart, currentPeriodEnd, createdAt. `SubscriptionStatus` extension provides `isActive`, `isGracePeriod`, `isExpired` computed properties.

**AuthRemoteDatasource** (`mobile/lib/features/auth/data/auth_remote_datasource.dart`) — Feature-layer wrapper around `AuthRepository`. Each sign-in method (email, Apple, Google) calls `studentDatasource.upsertStudentProfile(...)` then `Purchases.logIn(userId)` after success. `signOut()` calls `Purchases.logOut()` first, then `authRepository.signOut()`. Exposed as `authRemoteDatasourceProvider`.

**StudentRemoteDatasource** (`mobile/lib/features/auth/data/student_remote_datasource.dart`) — Supabase `students` table access. `upsertStudentProfile()` uses `onConflict: 'id'` for idempotency (safe for repeated sign-in). `getStudentProfile()` fetches a single row by ID. Exposed as `studentRemoteDatasourceProvider`.

## Verification Results

- `flutter analyze lib/features/auth/` — No issues found
- `grep "Purchases.logIn"` — PASS
- `grep "onConflict: 'id'"` — PASS
- `grep "abstract class Student with"` — PASS
- `grep "abstract class Subscription with"` — PASS
- `build_runner` — 20 outputs written cleanly

## Deviations from Plan

None — plan executed exactly as written.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | d7da1ae | feat(03-02): add Student and Subscription freezed domain models |
| Task 2 | da56fa7 | feat(03-02): add auth data layer with RevenueCat and student upsert |

## Self-Check: PASSED

All created files confirmed to exist. All commits verified in git log.
