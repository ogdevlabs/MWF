# Tasks: Mat Pilates Coach — Student App

**Input**: `specs/001-mat-pilates-coach/` (spec.md, plan.md, data-model.md)

**Organization**: Tasks grouped by phase → user story for independent delivery.
Each P1 user story is an independently shippable MVP slice.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (independent files, no shared state)
- **[Story]**: Maps to user story (US1–US6)
- File paths relative to repo root

---

## Phase 0: Setup

**Purpose**: Scaffold both projects, configure CI, provision external services.

- [ ] T001 Initialize Flutter project at `mobile/` (`flutter create --org com.fererelabs --project-name mwf_mobile`)
- [ ] T002 [P] Initialize Next.js 15 admin panel at `admin/` (`npx create-next-app@latest admin --typescript --tailwind --app`)
- [ ] T003 [P] Initialize Supabase project (CLI: `supabase init` in `supabase/`); create `supabase/migrations/` directory
- [ ] T004 Add Flutter dependencies to `mobile/pubspec.yaml`: `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `drift`, `drift_flutter`, `go_router`, `supabase_flutter`, `video_player`, `chewie`, `model_viewer_plus`, `background_downloader`, `purchases_flutter`, `firebase_messaging`, `flutter_local_notifications`, `dio`, `freezed`, `json_serializable`
- [ ] T005 [P] Add dev dependencies to `mobile/pubspec.yaml`: `build_runner`, `riverpod_generator`, `drift_dev`, `freezed_annotation`, `json_annotation`, `mocktail`, `flutter_test`
- [ ] T006 [P] Add Next.js dependencies to `admin/package.json`: `@supabase/supabase-js`, `@supabase/ssr`, `@mux/mux-node`, `@mux/mux-uploader-react`, `shadcn-ui`, `recharts`, `react-hook-form`, `zod`
- [ ] T007 Configure `mobile/lib/main.dart` entry point with `ProviderScope` and `MaterialApp.router`
- [ ] T008 [P] Create `mobile/lib/shared/theme/app_theme.dart` — define `ColorScheme`, typography, and component themes (brand: clean white + sage green)
- [ ] T009 [P] Create `mobile/lib/shared/router/app_router.dart` — define all named routes with `go_router`; add auth guard redirecting unauthenticated users to `/login`
- [ ] T010 [P] Create `supabase/migrations/001_initial_schema.sql` — all tables from data-model.md with RLS policies
- [ ] T011 [P] Create `supabase/functions/revenuecat-webhook/index.ts` — handle RevenueCat webhook; upsert `subscriptions` row
- [ ] T012 [P] Create `supabase/functions/mux-webhook/index.ts` — handle Mux `video.asset.ready`; update `exercises.mux_playback_id` and `mux_download_url`
- [ ] T013 [P] Configure Firebase project; add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to `mobile/`
- [ ] T014 [P] Configure RevenueCat dashboard: create entitlements, link to App Store + Play Store products

---

## Phase 1: Foundation (Blocks All User Stories)

**Purpose**: Auth, local database, sync engine — must be complete before any feature work.

**⚠️ CRITICAL**: No user story can be implemented until this phase is complete.

- [ ] T015 Create `mobile/lib/core/database/app_database.dart` — Drift `@DriftDatabase` class referencing all tables
- [ ] T016 [P] Create `mobile/lib/core/database/tables/programs_table.dart` — Drift table for `local_programs`
- [ ] T017 [P] Create `mobile/lib/core/database/tables/sessions_table.dart` — Drift table for `local_sessions`
- [ ] T018 [P] Create `mobile/lib/core/database/tables/exercises_table.dart` — Drift table for `local_exercises` with `local_video_path` and `local_model_path`
- [ ] T019 [P] Create `mobile/lib/core/database/tables/enrollments_table.dart`
- [ ] T020 [P] Create `mobile/lib/core/database/tables/progress_records_table.dart`
- [ ] T021 [P] Create `mobile/lib/core/database/tables/metric_logs_table.dart`
- [ ] T022 [P] Create `mobile/lib/core/database/tables/feedback_threads_table.dart`
- [ ] T023 [P] Create `mobile/lib/core/database/tables/sync_queue_table.dart`
- [ ] T024 [P] Create `mobile/lib/core/database/tables/download_manifest_table.dart`
- [ ] T025 Create `mobile/lib/core/database/daos/programs_dao.dart` — CRUD + watch stream
- [ ] T026 [P] Create `mobile/lib/core/database/daos/sessions_dao.dart`
- [ ] T027 [P] Create `mobile/lib/core/database/daos/exercises_dao.dart`
- [ ] T028 [P] Create `mobile/lib/core/database/daos/progress_dao.dart`
- [ ] T029 [P] Create `mobile/lib/core/database/daos/metric_logs_dao.dart`
- [ ] T030 [P] Create `mobile/lib/core/database/daos/feedback_dao.dart`
- [ ] T031 [P] Create `mobile/lib/core/database/daos/sync_queue_dao.dart`
- [ ] T032 [P] Create `mobile/lib/core/database/daos/download_manifest_dao.dart`
- [ ] T033 Create `mobile/lib/core/network/supabase_client.dart` — initialize Supabase client; expose singleton via Riverpod provider
- [ ] T034 [P] Create `mobile/lib/core/auth/auth_repository.dart` — wrap Supabase Auth; methods: `signUpWithEmail`, `signInWithEmail`, `signInWithApple`, `signInWithGoogle`, `signOut`, `currentUser` stream
- [ ] T035 [P] Create `mobile/lib/core/auth/auth_provider.dart` — Riverpod `StreamProvider` over `authRepository.currentUser`
- [ ] T036 Create `mobile/lib/core/sync/sync_queue.dart` — enqueue write operations; dequeue and replay against Supabase on connectivity restored
- [ ] T037 Create `mobile/lib/core/sync/sync_service.dart` — orchestrate full sync: pull remote changes since last sync timestamp → update local Drift tables; process `sync_queue`
- [ ] T038 Create `mobile/lib/core/sync/connectivity_provider.dart` — Riverpod provider wrapping `connectivity_plus`; triggers `SyncService.sync()` on reconnect
- [ ] T039 Create `mobile/lib/core/downloads/download_service.dart` — wrap `background_downloader`; expose `downloadExerciseMedia(exerciseId)`, `cancelDownload(exerciseId)`, progress stream; update `download_manifest` in Drift
- [ ] T040 Update `mobile/lib/shared/router/app_router.dart` — complete all route definitions now that features are known

**Checkpoint**: Run `flutter test test/unit/core/` — auth, sync queue, and download service tests pass.

---

## Phase 2: User Story 1 — Enroll & Access a Program (Priority: P1) 🎯 MVP

**Goal**: Student can sign up, subscribe, and browse/access programs.

**Independent Test**: New user signs up → subscribes → lands on program list → opens an enrolled program detail.

### Implementation — Auth & Onboarding

- [ ] T041 Create `mobile/lib/features/auth/domain/student_model.dart` — `@freezed` Student entity
- [ ] T042 [P] Create `mobile/lib/features/auth/data/auth_remote_datasource.dart` — Supabase Auth calls
- [ ] T043 [P] Create `mobile/lib/features/auth/data/student_remote_datasource.dart` — upsert student profile in `students` table after signup
- [ ] T044 Create `mobile/lib/features/auth/presentation/login_screen.dart` — email/password + Apple + Google sign-in buttons; error display
- [ ] T045 [P] Create `mobile/lib/features/auth/presentation/signup_screen.dart` — email/password/display_name form; on success upsert student profile
- [ ] T046 [P] Create `mobile/lib/features/auth/presentation/onboarding_screen.dart` — 3-slide value-prop carousel shown once after first signup; stored in SharedPreferences
- [ ] T047 Wire `auth_provider.dart` redirect: unauthenticated → `/login`; authenticated + onboarding unseen → `/onboarding`; else → `/programs`

### Implementation — Subscription & Paywall

- [ ] T048 Create `mobile/lib/features/auth/domain/subscription_model.dart` — `@freezed` Subscription entity
- [ ] T049 Create `mobile/lib/features/auth/data/subscription_repository.dart` — fetch active subscription from Supabase; expose `isActive` bool; cache in Drift `local_subscriptions`
- [ ] T050 Create `mobile/lib/features/auth/presentation/paywall_screen.dart` — display available plans from RevenueCat `Offerings`; handle purchase via `purchases_flutter`; on success show confirmation and navigate to `/programs`
- [ ] T051 Add `subscription_provider.dart` Riverpod provider; expose subscription status app-wide

### Implementation — Programs Browse

- [ ] T052 Create `mobile/lib/features/programs/domain/program_model.dart` — `@freezed` Program entity
- [ ] T053 [P] Create `mobile/lib/features/programs/data/programs_remote_datasource.dart` — fetch published programs from Supabase
- [ ] T054 [P] Create `mobile/lib/features/programs/data/programs_local_datasource.dart` — read/write `local_programs` via Drift DAO
- [ ] T055 Create `mobile/lib/features/programs/data/programs_repository.dart` — merge remote + local; write to Drift; enroll student if they tap Enroll
- [ ] T056 Create `mobile/lib/features/programs/presentation/program_list_screen.dart` — grid of program cards; locked badge for non-subscribed users; tap locked → `/paywall`
- [ ] T057 [P] Create `mobile/lib/features/programs/presentation/program_detail_screen.dart` — header image, description, difficulty, session list (locked future days, completed past days, today's CTA)
- [ ] T058 [P] Create `mobile/lib/features/programs/presentation/program_card_widget.dart` — thumbnail, title, difficulty badge, duration, locked overlay

**Checkpoint**: US1 fully functional. New user can sign up, subscribe, and see program list.

---

## Phase 3: User Story 2 — Daily Session Player (Priority: P1) 🎯 MVP

**Goal**: Student opens today's session, plays exercises (video + 3D), marks session complete.

**Independent Test**: Subscribed enrolled user opens session → plays video → 3D model renders → completes all exercises → sees completion screen → session marked done.

- [ ] T059 Create `mobile/lib/features/session/domain/session_model.dart` — `@freezed` Session + Exercise entities
- [ ] T060 [P] Create `mobile/lib/features/session/data/session_repository.dart` — fetch session + exercises (remote or Drift); resolve local media paths from `download_manifest`
- [ ] T061 Create `mobile/lib/features/session/domain/session_player_state.dart` — `@freezed` state: `currentExerciseIndex`, `isPlaying`, `isComplete`, `startTime`
- [ ] T062 Create `mobile/lib/features/session/domain/session_player_notifier.dart` — `AsyncNotifier`; handles next/prev exercise, completion write (via `SyncQueue`), elapsed timer
- [ ] T063 Create `mobile/lib/features/session/presentation/video_player_widget.dart` — `video_player` + `chewie` controller; HLS URL from `mux_playback_id` or local file path; auto-play on mount; handle buffering state
- [ ] T064 [P] Create `mobile/lib/features/session/presentation/model_viewer_widget.dart` — `model_viewer_plus` loading GLB from local path or remote URL; loading skeleton; error fallback (hide panel, show icon)
- [ ] T065 Create `mobile/lib/features/session/presentation/exercise_card.dart` — displays cue text, rep count or countdown timer, video + model panels side-by-side (or tabbed on small screens)
- [ ] T066 Create `mobile/lib/features/session/presentation/session_player_screen.dart` — orchestrates `exercise_card.dart`, progress bar (X of N), prev/next buttons, exit confirmation dialog
- [ ] T067 [P] Create `mobile/lib/features/session/presentation/session_completion_screen.dart` — summary card (duration, exercises done, streak update); CTA to log metrics or give feedback; confetti animation
- [ ] T068 [P] Create `mobile/lib/features/session/presentation/rep_timer_widget.dart` — animated countdown for duration-based exercises; vibrates at zero
- [ ] T069 Write progress record to `sync_queue` in `session_player_notifier.dart` on session complete; update `enrollment.current_day` locally

**Checkpoint**: US2 fully functional. Student can complete a full session and see the completion screen.

---

## Phase 4: User Story 3 — Offline-First (Priority: P1) 🎯 MVP

**Goal**: Student pre-downloads content, completes session offline, syncs on reconnect.

**Independent Test**: Airplane mode → open pre-synced session → complete → reconnect → progress visible in program calendar.

- [ ] T070 Implement background pre-download trigger in `programs_repository.dart`: after enrollment confirmed, enqueue download of all exercises in `session day_number <= current_day + 2`
- [ ] T071 Implement `download_service.dart` worker: iterate `download_manifest` rows with status `pending`; download video (from `mux_download_url`) and GLB (from `model_asset_url`) to `getApplicationDocumentsDirectory()`; update status to `complete`
- [ ] T072 [P] Implement storage-guard in `download_service.dart`: before each download check available storage via `disk_space` package; pause queue if < 500 MB free; surface warning banner in UI
- [ ] T073 Implement video version staleness check in `sync_service.dart`: on sync, compare `exercises.video_version` with `download_manifest.video_version`; mark stale entries `pending` for re-download
- [ ] T074 [P] Implement `sync_service.dart` `processQueue()`: dequeue `sync_queue` rows ordered by `created_at`; replay against Supabase; on success delete row; on failure increment `retry_count`; skip if `retry_count >= 5`
- [ ] T075 Implement pull-sync in `sync_service.dart`: store last-sync timestamp in SharedPreferences; fetch rows modified since that timestamp for all mirrored tables; upsert into Drift
- [ ] T076 Wire `connectivity_provider.dart`: on status change to `online` → call `sync_service.sync()` then `download_service.resumeQueue()`
- [ ] T077 [P] Add download progress indicator to `program_detail_screen.dart` — per-session download badge (`downloaded` / `downloading X%` / `available online only`)
- [ ] T078 [P] Add "Download required" empty state to `session_player_screen.dart` when offline and session not downloaded; show "Will download when online" message

**Checkpoint**: US3 fully functional. Airplane mode test passes: complete session offline → reconnect → progress synced.

---

## Phase 5: User Story 4 — Body Metrics & Progress Dashboard (Priority: P2)

**Goal**: Student logs metrics, views trend charts, sees completion streaks.

**Independent Test**: Log 3 weight entries on different dates → view Progress screen → line chart shows 3 data points with delta badge.

- [ ] T079 Create `mobile/lib/features/progress/domain/metric_log_model.dart` — `@freezed` MetricLog; `metric_type` enum
- [ ] T080 [P] Create `mobile/lib/features/progress/data/metric_logs_repository.dart` — write to Drift + enqueue to `sync_queue`; read from Drift via `metric_logs_dao`
- [ ] T081 Create `mobile/lib/features/progress/domain/streak_calculator.dart` — pure function: given list of `completed_at` dates and student timezone → return current streak, longest streak
- [ ] T082 Create `mobile/lib/features/progress/presentation/metric_log_screen.dart` — form to enter metric type (segmented control: Weight / Measurement / Flexibility), sub-type picker, value + unit, date picker; save via repository
- [ ] T083 [P] Create `mobile/lib/features/progress/presentation/metric_chart_widget.dart` — `fl_chart` (or `syncfusion_flutter_charts`) line chart; accepts list of `MetricLog`; shows delta chip (first vs latest)
- [ ] T084 Create `mobile/lib/features/progress/presentation/progress_dashboard_screen.dart` — sections: streak card, program completion calendar (heatmap), metrics chart with type selector, recent completions list
- [ ] T085 [P] Create `mobile/lib/features/progress/presentation/streak_card_widget.dart` — flame icon, current streak count, longest streak
- [ ] T086 [P] Create `mobile/lib/features/progress/presentation/completion_calendar_widget.dart` — monthly grid; green dots on completed days; tap day → show session name tooltip
- [ ] T087 Add "Log Metrics" prompt to `session_completion_screen.dart` (non-blocking bottom sheet); tapping opens `metric_log_screen.dart`

**Checkpoint**: US4 fully functional. Log → chart → delta visible. Streak updates after session completion.

---

## Phase 6: User Story 5 — Coach Feedback & Notifications (Priority: P2)

**Goal**: Student submits post-session note/photo; receives coach reply as push notification.

**Independent Test**: Submit feedback on completed session → admin panel reply posted → student receives push notification within 60 s → reply visible in thread.

- [ ] T088 Create `mobile/lib/features/feedback/domain/feedback_thread_model.dart` — `@freezed` FeedbackThread
- [ ] T089 Create `mobile/lib/features/feedback/data/feedback_repository.dart` — insert thread to Drift + enqueue sync; watch Realtime subscription on `feedback_threads` for coach replies; update local on reply
- [ ] T090 Create `mobile/lib/features/feedback/presentation/feedback_thread_screen.dart` — student message bubble + optional photo; coach reply bubble; text input + image picker; submit via repository; show pending state while offline
- [ ] T091 [P] Create `mobile/lib/features/feedback/presentation/notifications_screen.dart` — list of received coach replies with timestamp, session title, excerpt; tap → navigate to `feedback_thread_screen`
- [ ] T092 Create `mobile/lib/core/notifications/fcm_service.dart` — initialize `firebase_messaging`; request permission; register token with Supabase `students` table (`fcm_token` column); handle foreground + background tap routing
- [ ] T093 [P] Create `mobile/lib/core/notifications/local_notification_service.dart` — `flutter_local_notifications` for foreground message display
- [ ] T094 Create `supabase/functions/send-reply-notification/index.ts` — Supabase Database Webhook on `feedback_threads.coach_reply` column update → look up student FCM token → call FCM HTTP v1 API
- [ ] T095 Add `fcm_token TEXT` column to `students` table in `supabase/migrations/002_add_fcm_token.sql`
- [ ] T096 Add feedback entry point to `session_completion_screen.dart` and `session_detail_screen.dart`

**Checkpoint**: US5 fully functional. Full feedback round-trip tested; push notification delivered within 60 s.

---

## Phase 7: User Story 6 — Admin Panel (Coach Content Creation) (Priority: P2)

**Goal**: Coach creates programs, uploads video + 3D assets, publishes, replies to feedback.

**Independent Test**: Coach creates program → adds session → uploads video → publishes → student app shows program in list.

- [ ] T097 Create `admin/lib/supabase.ts` — Supabase server client using service role key (env var)
- [ ] T098 [P] Create `admin/lib/mux.ts` — Mux SDK client; `createDirectUpload()`, `getPlaybackId()` helpers
- [ ] T099 Create `admin/app/(auth)/login/page.tsx` — Supabase Auth email/password login for coach
- [ ] T100 Create `admin/app/layout.tsx` — sidebar nav (Programs, Students, Feedback); auth guard redirect
- [ ] T101 Create `admin/app/programs/page.tsx` — program list table (title, difficulty, sessions count, published status, actions)
- [ ] T102 [P] Create `admin/app/programs/new/page.tsx` — create program form (title, description, difficulty, duration, thumbnail upload); POST to Supabase
- [ ] T103 Create `admin/app/programs/[id]/page.tsx` — program detail: edit metadata, session list, Publish/Unpublish toggle
- [ ] T104 Create `admin/app/programs/[id]/sessions/[sessionId]/page.tsx` — session editor: ordered exercise list with drag-to-reorder; Add Exercise button
- [ ] T105 Create `admin/components/exercise-editor.tsx` — inline exercise form: title, cues, rep/duration toggle, video uploader, GLB asset uploader
- [ ] T106 Create `admin/components/video-uploader.tsx` — Mux Direct Upload flow using `@mux/mux-uploader-react`; on upload complete → save `mux_asset_id` to DB; poll Mux webhook (or poll asset status) until `ready`
- [ ] T107 [P] Create `admin/components/asset-uploader.tsx` — GLB file upload to Supabase Storage `exercise-models/` bucket; save URL to exercise record
- [ ] T108 Create `admin/app/students/[id]/feedback/page.tsx` — list feedback threads for student; reply form; POST reply → triggers Supabase Realtime + notification webhook
- [ ] T109 [P] Create `admin/app/api/programs/[id]/publish/route.ts` — server action: set `published = true|false`; on publish set `published_at = now()`
- [ ] T122 [P] Create `admin/app/api/programs/[id]/delete/route.ts` — delete program (hard delete or soft delete strategy), enforce referential cleanup for sessions/exercises

**Checkpoint**: US6 fully functional. Full coach → publish → student sees content flow verified.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Accessibility, error handling, edge cases, performance.

- [ ] T110 [P] Add `Semantics` wrappers to all custom widgets in `mobile/lib/shared/widgets/`; verify VoiceOver and TalkBack navigation through session player
- [ ] T111 [P] Add error boundaries to all `AsyncValue` widgets — show `ErrorWidget` with retry button for network errors; never show raw exceptions to user
- [ ] T112 Add empty states for: no programs enrolled, no metrics logged, no feedback threads
- [ ] T113 [P] Implement token refresh: intercept Supabase 401 in `supabase_client.dart`; refresh session; retry request once
- [ ] T114 [P] Add `Sentry.init` (or `firebase_crashlytics`) in `mobile/lib/main.dart`; capture unhandled exceptions with user context (no PII beyond user ID)
- [ ] T115 Add download size warning dialog in `download_service.dart` when total pending download > 500 MB; ask user to confirm on mobile data
- [ ] T116 [P] Localization scaffold: add `flutter_localizations` + `intl`; extract all user-facing strings to `mobile/lib/l10n/app_en.arb`; English only at launch
- [ ] T117 [P] Write widget tests for `session_player_screen.dart`, `program_list_screen.dart`, `paywall_screen.dart` in `mobile/test/widget/`
- [ ] T118 Write integration test for offline flow in `mobile/test/integration/offline_flow_test.dart` using in-memory Drift DB and mocked network
- [ ] T119 [P] Add `README.md` to `mobile/` with setup steps (env vars, Firebase config, Supabase URL)
- [ ] T120 [P] Add `README.md` to `admin/` with setup, env vars, local Supabase instructions
- [ ] T121 Run `flutter analyze` + `flutter test` → zero errors, zero warnings
- [ ] T123 Implement subscription grace-period UX in `mobile/lib/features/auth/`: while status is `grace_period`, allow access with warning banner and retry verification CTA
- [ ] T124 Implement multi-device conflict policy in `mobile/lib/core/auth/`: define and enforce behavior for concurrent phone/tablet sessions; add user-facing messaging when token/session is revoked
- [ ] T125 Implement deleted-session reconciliation in `mobile/lib/core/sync/sync_service.dart`: if a completed session is removed by coach, preserve historical completion snapshot in local/remote progress history
- [ ] T126 Add SC benchmark integration tests in `mobile/test/integration/`: measure SC-001 (signup to first session), SC-002 (playback startup), SC-003 (3D render latency), SC-004 (offline sync latency), SC-006 (reply notification latency)
- [ ] T127 [P] Add coach-flow benchmark in `admin/test/e2e/program_publish.spec.ts`: validate SC-005 (create + publish single-session program under 15 min target)
- [ ] T128 [P] Implement analytics event schema in `mobile/lib/core/analytics/`: onboarding funnel and workout playback QoE events needed for SC-007 tracking
- [ ] T129 [P] Add retention cohort job in `supabase/functions/retention-cohorts/index.ts`: compute 30-day active-subscriber retention for SC-008
- [ ] T130 Add KPI dashboard docs in `specs/001-mat-pilates-coach/metrics.md`: source-of-truth queries and alert thresholds for SC-001..SC-008

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 0 (Setup)**: No dependencies — start immediately; T001–T014 mostly parallel
- **Phase 1 (Foundation)**: Requires Phase 0 complete — **blocks all features**
- **Phases 2–7 (User Stories)**: Require Phase 1; can start in priority order (P1 first)
  - Phase 2 (US1) must precede Phase 3 (US2) — session player requires auth + enrollment
  - Phase 3 (US2) must precede Phase 4 (US3) — offline needs the session player to exist
  - Phases 5, 6, 7 can run in parallel after Phase 3
- **Phase 8 (Polish)**: After all user stories

### Parallel Opportunities

Within Phase 0: T001, T002, T003 — three separate project initializations
Within Phase 1: All table definitions (T016–T024) and DAO definitions (T025–T032) can run in parallel; sync and download services depend on DAOs
Within each user story: model + datasource + repository tasks marked [P] can run in parallel; presentation tasks depend on domain/data tasks

---

## Implementation Strategy

### MVP (P1 Stories Only)

1. Phase 0: Setup
2. Phase 1: Foundation
3. Phase 2: US1 — Enroll & Access
4. Phase 3: US2 — Daily Session Player
5. Phase 4: US3 — Offline-First
6. **STOP → validate full P1 flow** (signup → subscribe → program → session → offline → sync)

### Full Delivery

Continue with Phases 5–7 (metrics, feedback, admin panel) then Phase 8 (polish).

---

## Notes

- `[P]` tasks touch different files — safe to parallelize
- Commit after each phase checkpoint
- All Supabase queries MUST use parameterized inputs — no string interpolation
- RevenueCat + Supabase secrets MUST be in `.env` files, never committed
- `model_viewer_plus` uses a WebView; test on physical devices for 3D rendering
- Mux signed download URLs expire; edge function refresh should be called before offline sync packages URLs into `download_manifest`

---

## Requirements Traceability

### Functional Requirements → Tasks

- FR-001 → T034, T044, T045
- FR-002 → T049, T050, T051
- FR-003 → T053, T055, T056, T058
- FR-004 → T057, T060, T066, T069
- FR-005 → T063, T064, T065, T068
- FR-006 → T039, T070, T071, T078
- FR-007 → T036, T037, T074, T075, T076
- FR-008 → T079, T080, T082
- FR-009 → T083, T084
- FR-010 → T088, T089, T090, T096
- FR-011 → T092, T093, T094
- FR-012 → T067
- FR-013 → T061, T062, T066
- FR-014 → T081, T085
- FR-015 → T101, T102, T103, T122
- FR-016 → T104, T105, T106, T107
- FR-017 → T103, T109
- FR-018 → T108
- FR-019 → T073

### Success Criteria → Tasks

- SC-001 → T126
- SC-002 → T063, T126
- SC-003 → T064, T126
- SC-004 → T074, T075, T076, T126
- SC-005 → T101, T102, T103, T104, T105, T106, T107, T109, T127
- SC-006 → T092, T093, T094, T126
- SC-007 → T128, T130
- SC-008 → T129, T130
