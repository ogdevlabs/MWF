# Roadmap: Mat Pilates Coach

## Overview

Build an offline-first Flutter mobile app (iOS + Android) where students follow
coach-designed multi-week Mat Pilates programs with video + 3D animation exercise
playback, subscription gating via in-app purchase, body metric tracking, and
private 1-to-1 coach direct messaging. A companion Next.js admin panel lets the
coach create/publish programs and reply to student messages.

## Phases

- [x] **Phase 1: Setup & Scaffold** - Initialize Flutter + Next.js projects, provision Supabase, Mux, RevenueCat, Firebase (completed 2026-05-25)
- [x] **Phase 2: Foundation** - Auth, Drift database, sync engine, download service, CQRS infrastructure (completed 2026-05-25)
- [x] **Phase 3: US1 Enroll & Access** - Student signup, subscription, program browse and access (completed 2026-05-26)
- [x] **Phase 4: US2 Session Player** - Daily session player with video + 3D animation, completion tracking (completed 2026-05-27)
- [x] **Phase 5: US3 Offline-First** - Pre-download content, offline session completion, reconnect sync (completed 2026-05-28)
- [x] **Phase 6: US4 Metrics & Progress** - Body metric logging, trend charts, completion streaks (completed 2026-05-29)
- [x] **Phase 7: US5 Private Feedback** - Private student→coach DM, push notifications, reply threading (completed 2026-05-29)
- [x] **Phase 8: US6 Admin Panel** - Coach content creation, program publishing, private feedback replies (completed 2026-05-29)
- [ ] **Phase 9: Polish & QA** - Accessibility, error handling, performance benchmarks, analytics, final QA

## Phase Details

### Phase 1: Setup & Scaffold
**Goal**: Initialize both Flutter and Next.js projects, configure tooling, provision all external services (Supabase, Mux, RevenueCat, Firebase), and establish the project skeleton that all subsequent phases build on.
**Depends on**: Nothing (first phase)
**Requirements**: none
**Success Criteria** (what must be TRUE):
  1. `mobile/` Flutter project runs `flutter run` without errors on iOS simulator and Android emulator
  2. `admin/` Next.js 16 project runs `npm run dev` without errors
  3. `supabase/migrations/001_initial_schema.sql` exists with all tables from data-model.md
  4. RevenueCat dashboard has entitlements configured; Firebase project exists with config files
  5. Supabase edge functions directory exists with webhook stubs for RevenueCat and Mux
**Plans**: 3 plans
Plans:
- [x] 01-01-PLAN.md — Project initializations (Flutter, Next.js, Supabase)
- [x] 01-02-PLAN.md — Dependencies, schema migration, and edge function stubs
- [x] 01-03-PLAN.md — Flutter skeleton (main.dart, theme, router) + service stubs

### Phase 2: Foundation
**Goal**: Implement Drift local database, Supabase client, auth repository, offline sync queue, download service, and CQRS infrastructure. This phase blocks all feature phases.
**Depends on**: Phase 1
**Requirements**: none
**Success Criteria** (what must be TRUE):
  1. `flutter test test/unit/core/` passes — auth, sync queue, and download service tests pass
  2. Drift database opens in-memory with all tables and DAOs accessible
  3. SyncService can enqueue and replay operations against a mock Supabase client
  4. DownloadService can queue, download, and update manifest entries
  5. CQRS CommandBus and QueryGateway exist and are wired via Riverpod providers
**Plans**: 7 plans
Plans:
- [x] 02-01-PLAN.md — Missing packages + CQRS Supabase schema + projection-refresh edge function
- [x] 02-02-PLAN.md — Drift table definitions + Supabase client provider
- [x] 02-03-PLAN.md — Drift DAOs + AppDatabase class
- [x] 02-04-PLAN.md — Auth repository + provider + ConnectivityProvider
- [x] 02-05-PLAN.md — SyncQueue wrapper + DownloadService
- [x] 02-06-PLAN.md — SyncService + CommandBus + QueryGateway
- [x] 02-07-PLAN.md — App router completion + Admin CQRS query client + Unit tests

### Phase 3: US1 Enroll & Access
**Goal**: Student can sign up (email/password + Apple + Google), subscribe via in-app purchase through RevenueCat, browse published programs with lock/unlock state, and access enrolled program detail.
**Depends on**: Phase 2
**Requirements**: FR-001, FR-002, FR-003
**Success Criteria** (what must be TRUE):
  1. New user can sign up → subscribe → land on program list → open enrolled program detail
  2. Locked programs display paywall overlay; subscribed programs are accessible
  3. Subscription status is enforced via RevenueCat entitlement check
  4. Apple Sign-In and Google Sign-In buttons present and functional on iOS
**Plans**: 6 plans
Plans:
- [x] 03-01-PLAN.md — EnrollmentsDao fix + build_runner (Wave 1 blocker)
- [x] 03-02-PLAN.md — Domain models (Student, Subscription) + auth datasources
- [x] 03-03-PLAN.md — Auth screens (Login, Signup, Onboarding) + router wiring
- [x] 03-04-PLAN.md — Subscription repository + Paywall screen + RevenueCat init
- [x] 03-05-PLAN.md — Program domain model + datasources + repository
- [x] 03-06-PLAN.md — Program UI screens (list, detail, card widget)

### Phase 4: US2 Session Player
**Goal**: Subscribed enrolled student opens today's session, plays each exercise with a video player and 3D animation companion, tracks progress through the session, and reaches a completion screen.
**Depends on**: Phase 3
**Requirements**: FR-004, FR-005, FR-012, FR-013, FR-014
**Success Criteria** (what must be TRUE):
  1. Subscribed enrolled user can open session → play video → 3D model renders → complete all exercises → see completion screen
  2. Session is marked done in program calendar after completion
  3. Re-opening a mid-session app resumes from last incomplete exercise
  4. Streak counter increments after session completion
**Plans**: 6 plans
Plans:
- [x] 04-01-PLAN.md — Drift migration (session_resume_state, schemaVersion 2) + test stubs
- [x] 04-02-PLAN.md — Session domain models (Freezed) + datasource + providers
- [x] 04-03-PLAN.md — Session list UI (ProgramDetailScreen enhancement with lock state)
- [x] 04-04-PLAN.md — Session player screen core (Chewie video, exercise navigation, resume)
- [x] 04-05-PLAN.md — Rep/timer overlays + 3D model bottom sheet
- [x] 04-06-PLAN.md — Completion screen + streak calculator + completion service + tests

### Phase 5: US3 Offline-First
**Goal**: Student pre-downloads session content on Wi-Fi, completes a full session in airplane mode, and has progress automatically synced to the server when connectivity is restored.
**Depends on**: Phase 4
**Requirements**: FR-006, FR-007
**Success Criteria** (what must be TRUE):
  1. Airplane mode enabled after sync → student completes pre-downloaded session → reconnect → progress visible in program calendar
  2. Storage guard pauses downloads when free space < 500 MB
  3. Stale video versions are detected and re-queued for download on sync
  4. Sync queue replays in order on reconnect; retry_count stops at 5 failures
**Plans**: 4+ plans
Plans:
- [ ] 05-01-PLAN.md — (Wave 0) Test stubs
- [ ] 05-02-PLAN.md — Download queue + Mux signed URL fetch
- [ ] 05-03-PLAN.md — Reconnect sync trigger + stale version detection
- [x] 05-04-PLAN.md — Session download badge UI + offline guard + ProgramDetailScreen wiring

### Phase 6: US4 Metrics & Progress
**Goal**: Student can log body metrics (weight, measurements, flexibility) with date stamps, view trend line charts with delta badge, and see session completion streaks on a progress dashboard.
**Depends on**: Phase 5
**Requirements**: FR-008, FR-009
**Success Criteria** (what must be TRUE):
  1. Student can log 3 weight entries on different dates → Progress screen shows line chart with 3 data points and delta badge
  2. Streak card shows current streak and longest streak, updating after each session completion
  3. Metric log prompt appears (non-blocking) on session completion screen
  4. Offline metric logs enqueue in sync_queue and sync on reconnect
**Plans**: 4 plans
Plans:
- [x] 06-01-PLAN.md — Wave 0 test stubs (unit + widget tests for all new code)
- [x] 06-02-PLAN.md — Pure functions (computeLongestStreak, computeMetricDelta) + MetricRepository + SyncService pull
- [x] 06-03-PLAN.md — Progress screen UI (StreakCard, MetricLineChart, DeltaBadge, tab bar, router)
- [x] 06-04-PLAN.md — MetricLogBottomSheet + session completion prompt wiring

### Phase 7: US5 Private Feedback
**Goal**: Student submits a private post-session note and optional photo directly to the coach; receives a push notification when the coach replies; the full exchange is visible only to the student and coach (no community/public visibility).
**Depends on**: Phase 5
**Requirements**: FR-010, FR-010a, FR-011
**Success Criteria** (what must be TRUE):
  1. Submit private feedback → admin panel reply posted → student receives push notification within 60 s → reply visible in private thread
  2. No cross-student data access: RLS prevents student A from reading student B's threads
  3. Offline feedback notes save locally and submit on reconnect
  4. Notifications screen lists all coach replies with session links
**Plans**: 5 plans
Plans:
- [x] 07-01-PLAN.md — Wave 0: Drift migration (v3), platform config, test stubs, Supabase migration
- [x] 07-02-PLAN.md — FeedbackRepository (CQRS data layer) + domain model + providers
- [x] 07-03-PLAN.md — FCM service + Firebase init + push notification handling
- [x] 07-04-PLAN.md — Coach Chat UI (tab screen, paywall, chat thread, bubbles, compose bar)
- [x] 07-05-PLAN.md — FeedbackComposeBottomSheet + NotificationsScreen + router + bottom nav

### Phase 8: US6 Admin Panel
**Goal**: Coach can create and publish multi-week programs (with Mux video + GLB 3D asset uploads), manage sessions and exercises, and reply to individual student private feedback threads via the Next.js admin panel.
**Depends on**: Phase 7
**Requirements**: FR-015, FR-016, FR-017, FR-018, FR-019
**Success Criteria** (what must be TRUE):
  1. Coach creates program → adds session → uploads video via Mux Direct Upload → publishes → student app shows program within 60 s
  2. Coach replies to student feedback → student receives push notification → reply visible in student's private thread
  3. Updated video invalidates student cached version; re-download queued on next sync
  4. Program delete cleans up sessions and exercises without orphaned records
**Plans**: 5 plans
Plans:
- [x] 08-01-PLAN.md — Foundation: proxy.ts auth guard, Supabase clients, login, admin shell, shadcn, Mux route, migration
- [x] 08-02-PLAN.md — Programs CRUD: list, create, edit, delete pages + server actions + publish/unpublish
- [x] 08-03-PLAN.md — Feedback: thread list, detail, coach reply form + send-fcm Edge Function

- [x] 08-04-PLAN.md — Sessions & Exercises: editors, Mux video upload, GLB upload, mux-webhook completion
- [x] 08-05-PLAN.md — Integration: dashboard, root redirect, publish toggle wiring, final verification

### Phase 9: Polish & QA
**Goal**: Accessibility, comprehensive error handling, edge case coverage, performance benchmark tests for all SC-001..SC-008 success criteria, analytics scaffolding, localization scaffold, and final zero-error QA pass.
**Depends on**: Phase 8
**Requirements**: none
**Success Criteria** (what must be TRUE):
  1. `flutter analyze` + `flutter test` exits with zero errors and zero warnings
  2. SC-001..SC-008 benchmark integration tests exist and pass
  3. VoiceOver and TalkBack can navigate through the session player screen
  4. All AsyncValue widgets show an error state with retry on network failure
**Plans**: 4 plans
Plans:
- [x] 09-01-PLAN.md — Analyzer cleanup: fix all 15 static analysis issues (deprecated params, redundant imports, unused vars, identifier renames)

- [ ] 09-02-PLAN.md — Error+retry states on 5 screens + Semantics accessibility for ExerciseVideoPlayer
- [ ] 09-03-PLAN.md — SC-001..SC-008 integration test stubs + AnalyticsService scaffold (NoOp)
- [ ] 09-04-PLAN.md — Localization scaffold (gen-l10n pipeline + ARB template + MaterialApp wiring) + final QA pass
