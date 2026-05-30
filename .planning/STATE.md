---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: Ready to plan
last_updated: "2026-05-30T01:02:00Z"
progress:
  total_phases: 18
  completed_phases: 7
  total_plans: 44
  completed_plans: 40
---

# GSD State

**Last Updated**: 2026-05-30
**Current Phase**: 9
**Current Plan**: 09-04 (complete)
**Status**: Phase 9 in progress — 09-04 complete (localization scaffold done)

## Session Context

Initialized GSD project from existing spec/plan/tasks artifacts in
`specs/001-mat-pilates-coach/`. Messaging change applied: student–coach interaction
is private direct messaging only; no public community comments.

Phase 2 foundation in progress. Plans 02-01 and 02-02 complete.

## Decisions

- Use existing 8-phase task breakdown (T001–T136) as the roadmap phases
- Messaging architecture: private DM only (no community/public feed) — enforced at
  RLS level in Supabase and no UI surface for public commenting

- CQRS persistence pattern as specified in data-model.md
- SyncQueue column getter named `targetTable` with `.named('table_name')` to avoid Drift Table.tableName getter conflict
- DownloadManifest uses text PK on exerciseId
- Supabase provider uses `@Riverpod(keepAlive: true)` — client must survive full app lifecycle
- Google Sign-In uses 7.x constructor (GoogleSignIn(serverClientId:, clientId:)) — pubspec.lock shows 7.2.0 installed
- authStateProvider watches supabaseClientProvider directly; ConnectivityNotifier assumes online initially
- [Phase 02]: Insert operations use upsert for idempotent SyncQueue replay
- [Phase 02]: DownloadService stores relative paths only (iOS absolute path safety)
- [Phase 02]: App router uses @Riverpod(keepAlive: true) appRouter watching isAuthenticatedProvider — reactive redirect without manual router refresh
- [Phase 02]: Admin query client uses SUPABASE_SERVICE_ROLE_KEY bypassing RLS for full coach access to student data
- [Phase 02]: connectivityProvider is the riverpod 4.x generated name for ConnectivityNotifier (Notifier suffix dropped)
- [Phase 02]: GoogleSignIn 7.x: singleton initialize()+authenticate() replaces constructor+signIn() pattern
- [Phase 03]: EnrollmentsDao was Phase 2 gap; resolved in 03-01 before any enrollment feature work
- [Phase 03]: AuthRemoteDatasource calls Purchases.logIn(userId) after every successful sign-in; upsert uses onConflict:'id' for idempotency
- [Phase 03]: Use AsyncValue.value ?? true (not .valueOrNull) for onboardingSeenProvider in router — Riverpod 3.x dropped .valueOrNull
- [Phase 03]: Default onboarding_seen=true during async loading to prevent flash-redirect to /onboarding on relaunch
- [Phase 03]: PurchaseParams.package(pkg) named constructor — purchases_flutter 10.1.1 has no unnamed constructor
- [Phase 03]: Purchases.configure() guarded by rcApiKey.isNotEmpty to allow dev runs without dart-define keys
- [Phase 03]: uuid package added to pubspec for enrollment ID generation in ProgramsRepository
- [Phase 03]: LocalProgramsCompanion.cacheProgram supplies createdAt/updatedAt = DateTime.now() for non-nullable Drift columns
- [Phase 03]: AsyncValue.value ?? true (not .valueOrNull) for onboardingSeenProvider — Riverpod 3.x dropped .valueOrNull
- [Phase 03]: errorBuilder uses (_, _, _) all-underscore wildcards to satisfy unnecessary_underscores lint
- [Phase 04]: SessionState lock derivation is a pure function (deriveSessionState) decoupled from DB — easy to unit test
- [Phase 04]: Riverpod family providers use named params (programId/currentDay) for sessionsWithState and sessionExercises — matches plan spec
- [Phase 04]: _onOverlayTargetReached removed from SessionPlayerScreen until Plan 05 adds rep/timer overlays
- [Phase 04]: session-complete placeholder route added to router; Plan 06 builds SessionCompletionScreen
- [Phase 04]: RepCounterOverlay uses _targetHit bool guard to prevent double-firing onTargetReached callback
- [Phase 04]: TimerCountdownOverlay cancels Timer in dispose to prevent setState-after-dispose
- [Phase 04]: ModelViewerSheet resolves localModelPath via getApplicationDocumentsDirectory for file:// URI, no-ops if both model fields null
- [Phase 04]: Streak computed synchronously after Drift write inside SessionCompletionService, not via reactive stream
- [Phase 04]: mocktail registerFallbackValue required for CommandType enum in tests
- [Phase 04]: drift isNull/isNotNull must be hidden in test imports to avoid matcher ambiguity
- [Phase 05]: SessionDownloadState placed in domain/ for pure testability; provider in data/ re-exports it
- [Phase 05]: connectivityProvider (not connectivityNotifierProvider) — Riverpod 4.x drops Notifier suffix
- [Phase 05]: dlStateAsync.value (not .valueOrNull) — Riverpod 3.x removed .valueOrNull
- [Phase 05]: Fake stub for PostgrestFilterBuilder — Future-implementing class requires Fake not Mock + thenAnswer not thenReturn
- [Phase 06]: fl_chart 0.69.2 used for metric trend charts in ProgressScreen
- [Phase 06]: studentId optional on SessionCompletionScreen for backward compatibility with existing router usage
- [Phase 06]: computeLongestStreak added to streak_calculator.dart alongside computeCurrentStreak for co-location
- [Phase 06]: Empty state split into two Text widgets for exact test match with find.text('No data yet')
- [Phase 06]: [Phase 06-03]: flutter_riverpod 3.3.1 does not export Override type — widget tests use plain ProviderScope.overrides without type annotation
- [Phase 06]: [Phase 06-03]: StreakCard uses StreamBuilder over progressDao.watchProgressByStudent for reactive streak updates
- [Phase 06-us4-metrics-progress]: [Phase 06-04]: MetricLogBottomSheet uses metricRepositoryProvider (canonical); LogMetricSheet retained for backward compat
- [Phase 06-us4-metrics-progress]: [Phase 06-04]: Widget test migrated to metricRepositoryProvider.overrideWithValue pattern with MockSyncQueue + in-memory MetricRepository
- [Phase 07-us5-private-feedback]: Drift schemaVersion 3 with addColumn migration for status (default 'sent') and localPhotoPath (nullable) on LocalFeedbackThreads
- [Phase 07-us5-private-feedback]: feedback-photos Storage bucket is private with per-student folder RLS using (storage.foldername(name))[1] = auth.uid()::text
- [Phase 07-03]: FcmService.registerTokenDirect(@visibleForTesting) bypasses FirebaseMessaging.instance for unit testability — registerToken() calls it internally after getToken()
- [Phase 07-03]: handleMessageNavigation and onNotificationTap exposed with @visibleForTesting for direct unit test invocation — avoids need for RemoteMessage platform mocking
- [Phase 07-03]: Firebase.initializeApp() called in main.dart; FcmService.initialize() and registerToken() deferred to post-auth fcmInitProvider (Plan 07-04)
- [Phase 07]: LocalFeedbackThread constructed directly in widget tests (not via DB) — Drift reactive streams cause test pump() hangs
- [Phase 07]: fcmInitProvider fire-and-forget: ref.watch(fcmInitProvider) in CoachTabScreen.build() triggers FCM once per auth session
- [Phase 07]: ChatBubble uses manual time formatter instead of intl package — intl not in pubspec.yaml; avoids new dependency
- [Phase 07]: StatefulShellRoute.indexedStack wraps 4 branches (programs, progress, coach-chat, notifications) with ScaffoldWithNavBar — auth/paywall/settings remain outside shell
- [Phase 07]: [Phase 07-05]: /coach-chat route: when sessionId query param present -> CoachChatScreen(sessionId) for FCM deep-link; without sessionId -> CoachTabScreen (premium gate)
- [Phase 07]: [Phase 07-05]: GoRouter navigation widget test pattern — MaterialApp.router + GoRouter with test routes to verify navigation targets
- [Phase 08]: Next.js 16 proxy.ts (not middleware.ts): file and exported function must both be named 'proxy'
- [Phase 08]: [Phase 08-01]: getUser() (not getSession()) used in every Server Action and Route Handler for verified auth — getSession() returns unverified cookie data
- [Phase 08]: [Phase 08-01]: shadcn CLI requires manual install of lucide-react, class-variance-authority, tailwind-merge — these are peer deps not auto-added to package.json
- [Phase 08]: [Phase 08-01]: Login page uses 'use client' + useActionState — required because useActionState is a React hook; Server Action in actions.ts remains server-only
- [Phase 08-us6-admin-panel]: [Phase 08-02]: export const dynamic='force-dynamic' required on RSC pages calling createServiceClient() — Next.js static prerender fails without runtime env vars
- [Phase 08-us6-admin-panel]: [Phase 08-02]: publish/unpublish uses form action={fn.bind(null, id)} in RSC — no client component needed for simple toggle
- [Phase 08-us6-admin-panel]: [Phase 08-02]: ThumbnailUploader rendered only in edit mode — programId required for upload path, program must exist first
- [Phase 08]: [Phase 08-03]: RSC pages calling createServiceClient() require export const dynamic = 'force-dynamic' — Next.js 16 prerender at build time throws 'supabaseUrl is required' without env vars
- [Phase 08]: [Phase 08-03]: FCM failure in send-fcm is non-fatal — coach_reply DB write succeeds unconditionally; push errors only logged
- [Phase 08]: [Phase 08-03]: send-fcm uses crypto.subtle RSASSA-PKCS1-v1_5 (no third-party JWT lib) — Deno edge runtime compatible
- [Phase 08-us6-admin-panel]: [Phase 08-04]: Mux webhook uses upload_id (stored in mux_asset_id) to find exercise — upload_id is written at upload time; asset_id only known after Mux processing
- [Phase 08-us6-admin-panel]: [Phase 08-04]: VideoUploader and GlbUploader rendered only in exercise edit mode — exercise ID required for updateExerciseVideo path construction
- [Phase 08-us6-admin-panel]: [Phase 08-04]: Empty string form fields for optional numeric inputs stripped to undefined before Zod parse to allow nullable coerce to work correctly
- [Phase 08-us6-admin-panel]: [Phase 08-05]: Dashboard placed in (admin) route group; root app/page.tsx handles redirect — proxy.ts auth guard protects the (admin) group
- [Phase 08-us6-admin-panel]: [Phase 08-05]: Dashboard counts pending feedback via .is('coach_reply', null) — matches the column used in feedback reply flow
- [Phase 09]: [Phase 09-01]: DropdownButtonFormField.value deprecated after Flutter 3.33.0-1.0.pre — replacement is initialValue on FormField variant only; regular DropdownButton.value unaffected
- [Phase 09]: [Phase 09-01]: postgrest types (PostgrestFilterBuilder, PostgrestList) are transitively re-exported by supabase_flutter — direct package:postgrest imports are unnecessary_import + depend_on_referenced_packages violations
- [Phase 09]: [Phase 09-01]: no_leading_underscores_for_local_identifiers lint applies to local function declarations in test files — _makeLog, _buildSubject must be renamed without underscore
- [Phase 09]: [Phase 09-02]: Semantics wrapper on ExerciseVideoPlayer covers all build paths (loading/unavailable/playing) — placed in build() root wrapping _buildContent() so bySemanticsLabel works in no-video test environments

## Blockers

None

## Notes

- `SPEC.md` and `specs/001-mat-pilates-coach/spec.md` are kept in sync
- All feedback_threads RLS updated to document private-only access
- 9 DAOs created in mobile/lib/core/database/daos/ (03-01 adds EnrollmentsDao)
- AppDatabase class wires all 9 tables + 9 DAOs with test-injectable constructor (03-01 complete)
- build_runner regenerated all .g.dart files cleanly (03-01 complete)
- AuthRepository, auth providers, ConnectivityProvider created (02-04 complete)
- Google Sign-In defers credentials to Phase 3; throws descriptive AuthException if GOOGLE_WEB_CLIENT_ID empty

## Performance Metrics

| Phase | Plan | Duration | Tasks | Files |
|-------|------|----------|-------|-------|
| 02 | 02-01 | — | — | — |
| 02 | 02-02 | 2m | 2 | 11 |
| 02 | 02-03 | 8m | 2 | 9 |
| 02 | 02-04 | 6m | 3 | 3 |
| Phase 02 P02-05 | 82 | 2 tasks | 2 files |
| Phase 02 P02-07 | 7m | 3 tasks | 26 files |
| 03 | 03-01 | 5m | 2 | 12 |
| 03 | 03-02 | 2m | 2 | 10 |
| Phase 03 P03-03 | 157s | 2 tasks | 7 files |
| Phase 03 P04 | 8m | 2 tasks | 6 files |
| Phase 03 P03-05 | 205 | 2 tasks | 11 files |
| Phase 03 P03-06 | 183s | 2 tasks | 4 files |
| Phase 04 P04-02 | 8m | 2 tasks | 8 files |
| Phase 04 P04 | 3min | 2 tasks | 4 files |
| Phase 04 P04-05 | 122s | 2 tasks | 4 files |
| Phase 04 P04-06 | 306s | 3 tasks | 10 files |
| 05 | 05-04 | 469s | 2 tasks | 8 files |
| Phase 06 P01 | 435s | 7 tasks | 13 files |
| Phase 06 P06-03 | 25m | 2 tasks | 6 files |
| Phase 06-us4-metrics-progress P06-04 | 165s | 2 tasks | 4 files |
| Phase 07 P07-01 | 8m | 2 tasks | 16 files |
| Phase 07 P07-02 | 149s | 2 tasks | 5 files |
| Phase 07 P07-03 | 4m | 2 tasks | 3 files |
| Phase 07 P07-04 | 29min | 2 tasks | 9 files |
| Phase 07 P07-05 | 295s | 3 tasks | 6 files |
| Phase 08 P08-01 | 202 | 2 tasks | 24 files |
| Phase 08-us6-admin-panel P08-02 | 194s | 2 tasks | 7 files |
| Phase 08-us6-admin-panel P08-04 | 3min | 2 tasks | 11 files |
| Phase 08-us6-admin-panel P08-05 | 2min | 1 task | 3 files |
| Phase 09-polish-qa P09-01 | 3min | 2 tasks | 9 files |
| Phase 09-polish-qa P09-02 | 4min | 3 tasks | 8 files |
| Phase 09-polish-qa P09-04 | 6min | 2 tasks | 12 files |

## Stopped At

Completed 09-04-PLAN.md — gen-l10n scaffold, ARB template (15 strings), AppLocalizations wired in MaterialApp.router, 114 tests pass
