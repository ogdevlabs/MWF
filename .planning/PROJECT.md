# Mat Pilates Coach — Student App

**Version**: v1.0
**Created**: 2026-05-25
**Status**: Active

## Vision

An offline-first Flutter mobile app (iOS + Android) where students follow
coach-designed multi-week Mat Pilates programs featuring video + 3D animation
exercise playback, subscription gating via in-app purchase, body metric tracking,
and a private bidirectional coach direct-message feedback loop.

A companion Next.js web admin panel allows the coach to create and publish programs
and respond to individual student messages.

## Key Constraints

- Offline-first: full functionality after initial sync; reconnect-triggered sync
- Single-coach brand (not a multi-tenant marketplace)
- Student–coach communication is strictly private direct messaging (1-to-1); no
  community feed, public comments, or cross-student visibility
- In-app purchases via RevenueCat (no raw StoreKit/Play Billing in app code)
- Video hosting via Mux (HLS + signed download URLs); never Supabase Storage
- Apple Sign-In mandatory (App Store policy) when Google Sign-In is offered
- Persistence pattern: CQRS — command writes to normalized tables; queries read
  from denormalized projections

## Target Platforms

- Mobile: iOS 16+ / Android 10+ (API 29+)
- Admin: Web (Next.js 15)

## Tech Stack

- Flutter 3.22 / Dart 3.4
- Supabase (Postgres + Auth + Storage + Realtime)
- Mux (video CDN)
- RevenueCat (subscriptions)
- Firebase Cloud Messaging (push notifications)
- Drift (SQLite offline DB)
- Riverpod (state management)
- Next.js 15 + shadcn/ui (admin panel)

## Current State

Phase 5 complete — Offline-first: Wi-Fi-only background downloads on enrollment, StorageGuard, resumeQueue on reconnect, stale video detection (Value(null) path clearing), session row download badges, offline-unavailable guard, SyncQueue dead-letter at retry_count=5. 62 tests passing.

## Source Artifacts

- `specs/001-mat-pilates-coach/spec.md` — user stories, requirements, success criteria
- `specs/001-mat-pilates-coach/plan.md` — architecture + project structure
- `specs/001-mat-pilates-coach/data-model.md` — full DB schema (Supabase + Drift)
- `specs/001-mat-pilates-coach/tasks.md` — full task list (T001–T136)
