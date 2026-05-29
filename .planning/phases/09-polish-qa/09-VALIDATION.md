---
phase: 9
slug: polish-qa
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-29
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) + integration_test (SDK) + flutter analyze |
| **Config file** | `mobile/analysis_options.yaml` |
| **Quick run command** | `cd mobile && flutter test test/` |
| **Full suite command** | `cd mobile && flutter analyze && flutter test test/` |
| **Integration test command** | `cd mobile && flutter test integration_test/ -d <device-id>` |
| **Estimated runtime** | ~15 seconds (unit/widget); integration tests require a device |

---

## Sampling Rate

- **After every task commit:** `cd mobile && flutter analyze && flutter test test/`
- **After every plan wave:** `cd mobile && flutter analyze --fatal-infos && flutter test test/`
- **Before `/gsd:verify-work`:** Full suite must exit 0 with zero warnings
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|----------|-----------|-------------------|-------------|--------|
| 09-analyze | 01 | 1 | `flutter analyze` exits 0 | static | `flutter analyze --fatal-infos` | N/A | ⬜ pending |
| 09-error-retry-stubs | 02 | 2 | Wave 0 test stubs for error+retry | widget | `flutter test test/widget/program_detail_screen_error_retry_test.dart test/widget/coach_chat_screen_error_retry_test.dart` | Plan 02 Task 1 creates them | ⬜ pending |
| 09-error-retry | 02 | 2 | Error+retry on network failure | widget | `flutter test test/widget/` | Covered by 02 Task 1 | ⬜ pending |
| 09-semantics | 02 | 2 | Session player screen reader labels | widget | `flutter test test/widget/session_player_screen_test.dart` | Covered by 02 Task 3 | ⬜ pending |
| 09-sc-tests | 03 | 3 | SC-001..SC-008 integration stubs | integration | `flutter test integration_test/` | Plan 03 Task 1 creates them | ⬜ pending |
| 09-analytics | 03 | 3 | NoOp AnalyticsService compiles | build | `flutter analyze` | Plan 03 Task 2 creates them | ⬜ pending |
| 09-l10n | 04 | 3 | gen-l10n pipeline produces AppLocalizations | build | `flutter gen-l10n && flutter analyze` | Plan 04 Task 1 creates them | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `mobile/test/widget/program_detail_screen_error_retry_test.dart` — Created by Plan 02 Task 1
- [x] `mobile/test/widget/coach_chat_screen_error_retry_test.dart` — Created by Plan 02 Task 1
- [x] `mobile/integration_test/sc001_onboarding_time_test.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc002_video_playback_time_test.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc003_model_load_time_test.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc004_offline_sync_time_test.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc005_admin_publish_manual.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc006_push_notification_time_test.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc007_app_rating_kpi.dart` — Created by Plan 03 Task 1
- [x] `mobile/integration_test/sc008_retention_kpi.dart` — Created by Plan 03 Task 1

All Wave 0 test stubs are covered by plan tasks. The widget test stubs (error+retry) are created as Task 1 of Plan 02, ensuring they exist before the implementation task (Task 2) runs.

---

## Manual-Only Verifications

| Behavior | Why Manual | Test Instructions |
|----------|------------|-------------------|
| VoiceOver navigates session player | Requires real iOS device + VoiceOver | Enable VoiceOver; navigate to session player; verify exercise name announced |
| TalkBack navigates session player | Requires real Android device + TalkBack | Enable TalkBack; navigate to session player; verify exercise name announced |
| SC-005: admin publish -> student sees within 60s | Requires both admin panel + Flutter app running | Publish from admin; measure time to appear in Flutter |
| SC-006: push notification < 60s | Requires real Firebase config + real device | Reply in admin; measure time to notification |
| SC-007 / SC-008: retention KPIs | Requires production user data | Track after launch |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 15s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending (awaiting execution)
