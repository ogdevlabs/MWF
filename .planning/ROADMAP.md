# Roadmap — Mat Pilates Coach v1.0

**Milestone**: v1.0 — Full MVP + P2 Features
**Created**: 2026-05-25

---

## Phase 1 — Setup & Scaffold

**Goal**: Initialize both Flutter and Next.js projects, provision Supabase and
external services (Mux, RevenueCat, Firebase), and establish CI foundations.

**Tasks**: T001–T014 (see `specs/001-mat-pilates-coach/tasks.md`)

**Dependencies**: None — start immediately
**Parallel opportunities**: T001, T002, T003 (three separate project initializations)

---

## Phase 2 — Foundation: Auth, Database & Sync Engine

**Goal**: Implement Drift local database, Supabase client, auth repository, offline
sync queue, download service, and CQRS infrastructure. Blocks all feature phases.

**Tasks**: T015–T040, T131–T136

**Dependencies**: Phase 1 complete
**Parallel opportunities**: All table (T016–T024) and DAO (T025–T032) tasks run in parallel

---

## Phase 3 — US1: Enroll & Access a Program (P1 MVP)

**Goal**: Student can sign up, subscribe via in-app purchase, browse programs, and
access enrolled program detail.

**Tasks**: T041–T058

**Dependencies**: Phase 2 complete
**Success Test**: New user signs up → subscribes → lands on program list → opens enrolled program detail.

---

## Phase 4 — US2: Daily Session Player (P1 MVP)

**Goal**: Student opens today's session, plays exercises with video + 3D animation,
marks session complete.

**Tasks**: T059–T069

**Dependencies**: Phase 3 complete (requires auth + enrollment)
**Success Test**: Subscribed enrolled user completes full session → completion screen → session marked done.

---

## Phase 5 — US3: Offline-First (P1 MVP)

**Goal**: Student pre-downloads content, completes session with no internet, syncs
progress on reconnect.

**Tasks**: T070–T078

**Dependencies**: Phase 4 complete (offline wraps the session player)
**Success Test**: Airplane mode → complete pre-synced session → reconnect → progress synced.

---

## Phase 6 — US4: Body Metrics & Progress Dashboard (P2)

**Goal**: Student logs body metrics, views trend charts, sees session completion
streaks on a dashboard.

**Tasks**: T079–T087

**Dependencies**: Phase 5 complete
**Success Test**: Log 3 weight entries → Progress screen shows line chart with delta badge.

---

## Phase 7 — US5: Private Coach Feedback & Notifications (P2)

**Goal**: Student submits private post-session note/photo directly to coach; receives
coach reply as push notification. Strictly 1-to-1 — no community visibility.

**Tasks**: T088–T096

**Dependencies**: Phase 5 complete (can run in parallel with Phase 6)
**Success Test**: Submit private feedback → admin panel reply → student push notification within 60 s → reply in private thread.

---

## Phase 8 — US6: Admin Panel — Coach Content Creation (P2)

**Goal**: Coach creates programs, uploads video + 3D assets, publishes to student
app, and replies to private student feedback.

**Tasks**: T097–T109, T122

**Dependencies**: Phase 7 complete (feedback reply flow)
**Success Test**: Coach creates program → adds session → uploads video → publishes → student sees content.

---

## Phase 9 — Polish & Cross-Cutting Concerns

**Goal**: Accessibility, error handling, edge cases, performance benchmarks,
analytics scaffolding, localization, and final QA.

**Tasks**: T110–T121, T123–T130

**Dependencies**: All user story phases complete
**Success Test**: `flutter analyze` + `flutter test` → zero errors. SC-001..SC-008 benchmark tests pass.

---

## MVP Milestone Gate (after Phase 5)

Validate full P1 flow before continuing to P2 phases:
signup → subscribe → program browse → session player → offline completion → sync

---

## Phase Summary

| # | Name | Priority | Blocks |
|---|------|----------|--------|
| 1 | Setup & Scaffold | — | 2 |
| 2 | Foundation | Critical | 3–9 |
| 3 | US1: Enroll & Access | P1 MVP | 4 |
| 4 | US2: Session Player | P1 MVP | 5 |
| 5 | US3: Offline-First | P1 MVP | 6, 7 |
| 6 | US4: Metrics & Progress | P2 | 9 |
| 7 | US5: Private Feedback | P2 | 8 |
| 8 | US6: Admin Panel | P2 | 9 |
| 9 | Polish & QA | — | — |
