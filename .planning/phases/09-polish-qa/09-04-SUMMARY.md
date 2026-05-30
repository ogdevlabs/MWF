---
phase: 09-polish-qa
plan: "04"
subsystem: mobile-l10n
tags: [flutter, dart, localization, gen-l10n, intl, arb]

# Dependency graph
requires:
  - phase: 09-01
    provides: flutter analyze --fatal-infos exits 0
  - phase: 09-02
    provides: error+retry UI and accessibility scaffold
provides:
  - gen-l10n pipeline with English ARB template (15 strings)
  - AppLocalizations wired into MaterialApp.router via localizationsDelegates + supportedLocales
  - flutter analyze --fatal-infos exits 0 (all integration test skip type errors fixed)
affects: []

# Tech tracking
tech-stack:
  added:
    - flutter_localizations (sdk: flutter)
    - intl 0.20.2
  patterns:
    - "l10n.yaml config file drives gen-l10n; arb-dir: lib/l10n, template-arb-file: app_en.arb"
    - "AppLocalizations generated to lib/l10n/app_localizations.dart (not .dart_tool/flutter_gen)"
    - "import relative path 'l10n/app_localizations.dart' in main.dart (not package:flutter_gen)"
    - "testWidgets skip: true (bool) not skip: 'reason' (String) — flutter_test API"

key-files:
  created:
    - mobile/lib/l10n/app_en.arb
    - mobile/l10n.yaml
    - mobile/lib/l10n/app_localizations.dart
    - mobile/lib/l10n/app_localizations_en.dart
  modified:
    - mobile/pubspec.yaml
    - mobile/pubspec.lock
    - mobile/lib/main.dart
    - mobile/integration_test/sc001_onboarding_time_test.dart
    - mobile/integration_test/sc002_video_playback_time_test.dart
    - mobile/integration_test/sc003_model_load_time_test.dart
    - mobile/integration_test/sc004_offline_sync_time_test.dart
    - mobile/integration_test/sc005_admin_publish_manual.dart
    - mobile/integration_test/sc006_push_notification_time_test.dart
    - mobile/integration_test/sc007_app_rating_kpi.dart
    - mobile/integration_test/sc008_retention_kpi.dart

key-decisions:
  - "intl version bumped to ^0.20.2 — flutter_localizations SDK pins intl 0.20.2; ^0.19.0 would fail pub get"
  - "Generated app_localizations.dart lives in lib/l10n/ (not .dart_tool/flutter_gen/) when l10n.yaml has no output-dir"
  - "main.dart uses relative import 'l10n/app_localizations.dart' not package:flutter_gen path"
  - "Integration test skip: true (bool) replaces skip: 'reason' (String) — current flutter_test only accepts bool?"

requirements-completed: []

# Metrics
duration: 6min
completed: "2026-05-30"
---

# Phase 09 Plan 04: Localization Scaffold Summary

**gen-l10n pipeline established with English ARB template (15 strings), AppLocalizations wired into MaterialApp.router via localizationsDelegates + supportedLocales; flutter analyze --fatal-infos exits 0, 114 unit/widget tests pass**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-05-30T00:56:12Z
- **Completed:** 2026-05-30T01:02:00Z
- **Tasks:** 2
- **Files created:** 4 (ARB template, l10n.yaml, generated app_localizations.dart, app_localizations_en.dart)
- **Files modified:** 11 (pubspec.yaml, pubspec.lock, main.dart, 8 integration test stubs)

## Accomplishments

- Added `flutter_localizations` (sdk: flutter) and `intl: ^0.20.2` to `mobile/pubspec.yaml` dependencies
- Added `generate: true` under `flutter:` section in `mobile/pubspec.yaml`
- Created `mobile/l10n.yaml` with `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`
- Created `mobile/lib/l10n/app_en.arb` with `@@locale: en` and 15 high-frequency strings (screen titles, buttons, error states, empty states)
- `flutter gen-l10n` generated `mobile/lib/l10n/app_localizations.dart` and `mobile/lib/l10n/app_localizations_en.dart`
- Wired `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales` into `MaterialApp.router` in `mobile/lib/main.dart`
- Fixed pre-existing `skip: String` type errors in all 8 integration test stubs — changed to `skip: true` (bool) per current `flutter_test` API
- `flutter analyze --fatal-infos` exits 0 — zero issues
- `flutter test test/` passes: **114 tests pass**, 1 pre-existing skip (unchanged from Phase 9-02)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add l10n deps, ARB template, gen-l10n pipeline** - `4cf339a` (feat)
2. **Task 2: Wire delegates into MaterialApp + final QA pass** - `ae59312` (feat)

## Files Created/Modified

- `mobile/lib/l10n/app_en.arb` — new: English ARB template with 15 strings + `@@locale: en`
- `mobile/l10n.yaml` — new: gen-l10n config (arb-dir, template-arb-file, output-localization-file)
- `mobile/lib/l10n/app_localizations.dart` — generated: AppLocalizations class with localizationsDelegates + supportedLocales
- `mobile/lib/l10n/app_localizations_en.dart` — generated: English implementation class
- `mobile/pubspec.yaml` — flutter_localizations (sdk) + intl ^0.20.2 + generate: true
- `mobile/pubspec.lock` — updated lock file with new intl 0.20.2
- `mobile/lib/main.dart` — import + localizationsDelegates + supportedLocales wired in MaterialApp.router
- `mobile/integration_test/sc00[1-8]*.dart` — skip parameter type fixed: String → bool (8 files)

## Decisions Made

- `intl` version set to `^0.20.2` not `^0.19.0` as in plan — the Flutter SDK pins `flutter_localizations` to `intl 0.20.2`; specifying `^0.19.0` causes `pub get` to fail with a version solve error
- Generated `app_localizations.dart` output location is `lib/l10n/` (same directory as ARB) when no `output-dir` is specified in `l10n.yaml` — the plan's note about `.dart_tool/flutter_gen/` was not applicable; the correct import is `'l10n/app_localizations.dart'` (relative), not `package:flutter_gen/gen_l10n/app_localizations.dart`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] intl version constraint bumped to ^0.20.2**
- **Found during:** Task 1 (flutter pub get failed)
- **Issue:** Plan specified `intl: ^0.19.0` but Flutter SDK pins `flutter_localizations` to `intl 0.20.2`; version constraint `^0.19.0` is incompatible with the pinned `0.20.2`
- **Fix:** Changed `intl: ^0.19.0` to `intl: ^0.20.2` in pubspec.yaml
- **Files modified:** `mobile/pubspec.yaml`
- **Commit:** 4cf339a

**2. [Rule 1 - Bug] Integration test skip parameter type: String → bool**
- **Found during:** Task 1 (flutter analyze --fatal-infos reported 8 errors)
- **Issue:** All 8 integration test stubs used `skip: 'reason string'` but current `flutter_test` `testWidgets` API only accepts `skip: bool?` — pre-existing errors that blocked `flutter analyze --fatal-infos` from exiting 0
- **Fix:** Changed all 8 occurrences from `skip: 'reason'` to `skip: true` (with reason preserved in inline comment)
- **Files modified:** `mobile/integration_test/sc001-008_*.dart` (8 files)
- **Commit:** 4cf339a

**3. [Rule 3 - Blocking] Import path for AppLocalizations differs from plan**
- **Found during:** Task 2
- **Issue:** Plan suggested `package:flutter_gen/gen_l10n/app_localizations.dart` as the import path; actual generated file is at `mobile/lib/l10n/app_localizations.dart` (in lib/ tree, not .dart_tool)
- **Fix:** Used relative import `'l10n/app_localizations.dart'` in main.dart — resolves correctly and passes analysis
- **Files modified:** `mobile/lib/main.dart`
- **Commit:** ae59312

## Issues Encountered

None beyond the three auto-fixed issues above.

## User Setup Required

None.

## Known Stubs

None. No strings have been replaced with AppLocalizations lookups — this plan is scaffold only as specified. Future plans will replace hardcoded strings by adding ARB keys and calling `AppLocalizations.of(context)!.keyName`.

## Next Phase Readiness

- gen-l10n pipeline operational: adding new ARB files and running `flutter gen-l10n` is all that's needed
- `AppLocalizations.of(context)` available in any widget that descends from MaterialApp
- 114 tests passing — clean base
- `flutter analyze --fatal-infos` exits 0 — all 8 integration test skip type errors resolved
- Phase 9 localization scaffold complete

## Self-Check: PASSED

- mobile/lib/l10n/app_en.arb: FOUND
- mobile/l10n.yaml: FOUND
- mobile/lib/l10n/app_localizations.dart: FOUND
- mobile/lib/l10n/app_localizations_en.dart: FOUND
- grep flutter_localizations mobile/pubspec.yaml: PASS
- grep generate: true mobile/pubspec.yaml: PASS
- grep @@locale mobile/lib/l10n/app_en.arb: PASS
- grep arb-dir mobile/l10n.yaml: PASS
- grep localizationsDelegates mobile/lib/main.dart: PASS
- grep supportedLocales mobile/lib/main.dart: PASS
- grep AppLocalizations mobile/lib/main.dart: PASS
- Commit 4cf339a: FOUND
- Commit ae59312: FOUND
- flutter analyze --fatal-infos exits 0: PASS
- flutter test test/ exits 0 (114 tests): PASS

---
*Phase: 09-polish-qa*
*Completed: 2026-05-30*
