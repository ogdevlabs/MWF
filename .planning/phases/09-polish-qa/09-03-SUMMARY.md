---
phase: 09-polish-qa
plan: "03"
subsystem: testing
tags: [flutter, dart, integration-tests, riverpod, analytics, sc-benchmarks]

# Dependency graph
requires:
  - phase: 09-02
    provides: flutter analyze --fatal-infos exits 0; 114 unit tests passing
provides:
  - SC-001..SC-008 integration test stubs (all skipped, passes on any host)
  - AnalyticsService abstract class + NoOpAnalyticsService implementation
  - analyticsServiceProvider (Riverpod, keepAlive) returning NoOpAnalyticsService
affects: [09-04-accessibility, future-analytics-integration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Integration test stub pattern: IntegrationTestWidgetsFlutterBinding.ensureInitialized() + testWidgets with skip: true for device-gated tests"
    - "Analytics abstraction: abstract class + NoOp implementation scaffold with Riverpod keepAlive provider — no external dependency added"
    - "Riverpod 4.x provider signature: Ref ref (not FooRef ref) in functional providers"

key-files:
  created:
    - mobile/integration_test/sc001_onboarding_time_test.dart
    - mobile/integration_test/sc002_video_playback_time_test.dart
    - mobile/integration_test/sc003_model_load_time_test.dart
    - mobile/integration_test/sc004_offline_sync_time_test.dart
    - mobile/integration_test/sc005_admin_publish_manual.dart
    - mobile/integration_test/sc006_push_notification_time_test.dart
    - mobile/integration_test/sc007_app_rating_kpi.dart
    - mobile/integration_test/sc008_retention_kpi.dart
    - mobile/lib/core/analytics/analytics_service.dart
    - mobile/lib/core/analytics/analytics_provider.dart
    - mobile/lib/core/analytics/analytics_provider.g.dart
  modified: []

key-decisions:
  - "Riverpod 4.x uses Ref (not AnalyticsServiceRef) in functional provider signatures — plan template was written for Riverpod 2.x style; corrected to match project convention"
  - "Integration test skip: parameter uses bool true (not string) — flutter_test API change detected by linter; consistent with 09-04 agent's prior fix in 4cf339a"
  - "SC-001..SC-008 files were pre-created in commit 4cf339a by the 09-04 plan agent running ahead; Task 1 is complete by inheritance; Task 2 (analytics) was the primary new work"

patterns-established:
  - "Pattern: AnalyticsService abstract class + NoOpAnalyticsService for zero-dependency analytics scaffold; real provider swapped in later phase"
  - "Pattern: Integration test stubs use skip: true bool (not string) per flutter_test 1.31.x API"

requirements-completed: []

# Metrics
duration: 8min
completed: "2026-05-30"
---

# Phase 09 Plan 03: SC Integration Test Stubs + Analytics Scaffold Summary

**8 SC-001..SC-008 integration test stubs (all skip: true) and AnalyticsService/NoOpAnalyticsService scaffold with keepAlive Riverpod provider — no external dependencies added**

## Performance

- **Duration:** ~8 min
- **Started:** 2026-05-30T00:56:38Z
- **Completed:** 2026-05-30T01:05:00Z
- **Tasks:** 2
- **Files created:** 11 (8 integration tests + 3 analytics files)
- **Files modified:** 0

## Accomplishments

- Created 8 integration test stubs (SC-001..SC-008) in `mobile/integration_test/` — each uses `IntegrationTestWidgetsFlutterBinding`, a named `testWidgets`, and `skip: true`
- Created `analytics_service.dart` with `abstract class AnalyticsService` (logEvent, setUserId) and `NoOpAnalyticsService` (no-op implementation)
- Created `analytics_provider.dart` with `@Riverpod(keepAlive: true) AnalyticsService analyticsService(Ref ref)` — returns `NoOpAnalyticsService`
- Generated `analytics_provider.g.dart` via build_runner — `analyticsServiceProvider` is accessible project-wide
- `flutter analyze --fatal-infos` exits 0; 114 unit tests pass; no regressions

## Task Commits

Each task was committed atomically:

1. **Task 1: SC-001..SC-008 integration test stubs** - `4cf339a` (feat — committed by 09-04 agent; files verified identical to plan spec)
2. **Task 2: AnalyticsService + Riverpod provider** - `c0ad06b` (feat)

**Plan metadata:** (see below)

## Files Created/Modified

- `mobile/integration_test/sc001_onboarding_time_test.dart` — SC-001 benchmark stub: signup+subscribe+first session < 3 min, Stopwatch assertion `lessThan(180000)`, `skip: true`
- `mobile/integration_test/sc002_video_playback_time_test.dart` — SC-002: video playback < 2s, `lessThan(2000)`, `skip: true`
- `mobile/integration_test/sc003_model_load_time_test.dart` — SC-003: 3D model load < 1s, `lessThan(1000)`, `skip: true`
- `mobile/integration_test/sc004_offline_sync_time_test.dart` — SC-004: offline sync < 10s, `lessThan(10000)`, `skip: true`
- `mobile/integration_test/sc005_admin_publish_manual.dart` — SC-005: manual admin panel verification stub, `skip: true`
- `mobile/integration_test/sc006_push_notification_time_test.dart` — SC-006: FCM notification < 60s, `lessThan(60000)`, `skip: true`
- `mobile/integration_test/sc007_app_rating_kpi.dart` — SC-007: App Store rating KPI (no assertion), `skip: true`
- `mobile/integration_test/sc008_retention_kpi.dart` — SC-008: 30-day retention KPI (no assertion), `skip: true`
- `mobile/lib/core/analytics/analytics_service.dart` — abstract `AnalyticsService` + `NoOpAnalyticsService`
- `mobile/lib/core/analytics/analytics_provider.dart` — `@Riverpod(keepAlive: true)` functional provider
- `mobile/lib/core/analytics/analytics_provider.g.dart` — generated by build_runner; exports `analyticsServiceProvider`

## Decisions Made

- Used `Ref ref` (not `AnalyticsServiceRef ref`) in the provider function signature — Riverpod 4.x uses plain `Ref` for functional providers; the plan template reflected the old 2.x convention. This is consistent with all other functional providers in the project (authStateProvider, currentUserProvider, etc.)
- `skip: true` (bool) instead of `skip: 'reason string'` — `flutter_test` 1.31.x changed the `skip` parameter to accept a bool; string skip messages now go in comments. Linter auto-detected and corrected this; consistent with fix already applied by the 09-04 agent.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Provider ref type AnalyticsServiceRef → Ref (Riverpod 4.x)**
- **Found during:** Task 2 (analytics provider)
- **Issue:** Plan template used `AnalyticsServiceRef ref` which is Riverpod 2.x code-gen style. This project uses Riverpod 4.x where functional providers take `Ref ref`; `AnalyticsServiceRef` is undefined, causing `flutter analyze` to fail with `undefined_class`
- **Fix:** Changed function signature from `analyticsService(AnalyticsServiceRef ref)` to `analyticsService(Ref ref)`; regenerated `.g.dart`
- **Files modified:** `mobile/lib/core/analytics/analytics_provider.dart`, `mobile/lib/core/analytics/analytics_provider.g.dart`
- **Verification:** `flutter analyze --fatal-infos` exits 0 — No issues found
- **Committed in:** c0ad06b (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug — wrong Riverpod API version in plan template)
**Impact on plan:** Required fix; would have caused compile failure. No scope creep.

## Issues Encountered

- SC-001..SC-008 test files were already committed in `4cf339a` by the 09-04 plan agent (which ran ahead and created them as part of its own fix). Task 1 work is complete by inheritance. Verified all 8 files match plan spec including `skip:` and expected `lessThan(N)` assertions.

## User Setup Required

None — no external service configuration required. AnalyticsService is a no-op scaffold with zero external dependencies.

## Next Phase Readiness

- 114 unit tests passing; `flutter analyze --fatal-infos` exits 0 — clean base for Plan 09-04
- All 8 SC integration test stubs exist and are skipped; ready for future device-based runs
- `analyticsServiceProvider` accessible project-wide via `package:mwf_mobile/core/analytics/analytics_provider.dart`
- Analytics call sites not yet wired (intentional per plan note) — future phase task

## Known Stubs

SC-001..SC-008 integration tests are intentional stubs (all `skip: true`). They serve as placeholders for device-gated benchmark tests. Skipped tests pass in CI. Device runs triggered manually via `./local-dev/test-sc00N.sh` scripts.

## Self-Check: PASSED

- sc001_onboarding_time_test.dart: FOUND
- sc002_video_playback_time_test.dart: FOUND
- sc003_model_load_time_test.dart: FOUND
- sc004_offline_sync_time_test.dart: FOUND
- sc005_admin_publish_manual.dart: FOUND
- sc006_push_notification_time_test.dart: FOUND
- sc007_app_rating_kpi.dart: FOUND
- sc008_retention_kpi.dart: FOUND
- analytics_service.dart NoOpAnalyticsService: FOUND
- analytics_provider.dart analyticsServiceProvider: FOUND
- analytics_provider.g.dart: FOUND
- flutter analyze --fatal-infos exits 0: PASS
- flutter test test/ exits 0 (114 tests): PASS
- Commit 4cf339a (SC test stubs): FOUND
- Commit c0ad06b (analytics scaffold): FOUND

---
*Phase: 09-polish-qa*
*Completed: 2026-05-30*
