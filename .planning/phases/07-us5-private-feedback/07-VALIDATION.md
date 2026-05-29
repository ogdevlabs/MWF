---
phase: 7
slug: us5-private-feedback
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-29
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (dart SDK 3.12.0) + mocktail 1.0.5 |
| **Config file** | `mobile/pubspec.yaml` (dev_dependencies) |
| **Quick run command** | `cd mobile && flutter test test/unit/features/coach_chat/` |
| **Full suite command** | `cd mobile && flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd mobile && flutter test test/unit/features/coach_chat/ test/widget/`
- **After every plan wave:** Run `cd mobile && flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green (currently 90 tests passing baseline)
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 07-W0-01 | 01 | 0 | FR-010 | unit stub | `flutter test test/unit/features/coach_chat/feedback_repository_test.dart` | ❌ W0 | ⬜ pending |
| 07-W0-02 | 01 | 0 | FR-011 | unit stub | `flutter test test/unit/features/coach_chat/fcm_service_test.dart` | ❌ W0 | ⬜ pending |
| 07-W0-03 | 01 | 0 | FR-010 | widget stub | `flutter test test/widget/coach_chat_screen_test.dart` | ❌ W0 | ⬜ pending |
| 07-W0-04 | 01 | 0 | FR-011 | widget stub | `flutter test test/widget/notifications_screen_test.dart` | ❌ W0 | ⬜ pending |
| 07-data | TBD | 1 | FR-010 | unit | `flutter test test/unit/features/coach_chat/feedback_repository_test.dart` | ❌ W0 | ⬜ pending |
| 07-fcm | TBD | 1 | FR-011 | unit | `flutter test test/unit/features/coach_chat/fcm_service_test.dart` | ❌ W0 | ⬜ pending |
| 07-chat-ui | TBD | 2 | FR-010 | widget | `flutter test test/widget/coach_chat_screen_test.dart` | ❌ W0 | ⬜ pending |
| 07-notify-ui | TBD | 2 | FR-011 | widget | `flutter test test/widget/notifications_screen_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/unit/features/coach_chat/feedback_repository_test.dart` — FR-010: local write + sync enqueue + offline status stubs
- [ ] `test/unit/features/coach_chat/fcm_service_test.dart` — FR-011: token registration with mock FirebaseMessaging stubs
- [ ] `test/widget/coach_chat_screen_test.dart` — FR-010: chat bubble rendering, pending clock icon, compose bar stubs
- [ ] `test/widget/notifications_screen_test.dart` — FR-011: reply list renders from mock stream stubs
- [ ] Create directory `test/unit/features/coach_chat/` (does not yet exist)

*Existing infrastructure covers framework — flutter_test + mocktail already declared in pubspec.yaml*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| FCM push notification delivered within 60s of coach reply | FR-011 | Requires live Firebase project + real device/simulator | 1. Run `flutterfire configure` 2. Install on real device 3. Coach posts reply in admin panel 4. Measure time to notification delivery |
| APNs entitlements on iOS | FR-011 | Requires Apple Developer account + provisioning profile | Verify push capability in Xcode → Signing & Capabilities |
| RLS prevents cross-student access | FR-010a | Requires Supabase SQL policy test with two real auth sessions | Run `SELECT * FROM feedback_threads` as student B — expect 0 rows from student A's threads |
| Photo picker permission flow on iOS | FR-010 | Requires real device (simulator has no camera roll) | Verify `NSPhotoLibraryUsageDescription` prompt appears on first tap |
| Offline feedback sync on reconnect | FR-010 | Requires network simulation | Enable airplane mode, compose message, re-enable, verify sent status updates |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
