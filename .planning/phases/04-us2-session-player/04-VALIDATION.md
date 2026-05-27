---
phase: 4
slug: us2-session-player
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-26
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) + mocktail ^1.0.5 |
| **Config file** | none — standard `flutter test` |
| **Quick run command** | `cd mobile && flutter test test/unit/features/session/ -x` |
| **Full suite command** | `cd mobile && flutter test` |
| **Estimated runtime** | ~15 seconds (unit), ~60 seconds (full suite) |

---

## Sampling Rate

- **After every task commit:** Run `cd mobile && flutter test test/unit/features/session/ -x`
- **After every plan wave:** Run `cd mobile && flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds (unit suite)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 0 | FR-004 | unit | `flutter test test/unit/features/session/session_lock_state_test.dart -x` | ❌ W0 | ⬜ pending |
| 04-01-02 | 01 | 0 | FR-013 | unit | `flutter test test/unit/features/session/session_resume_test.dart -x` | ❌ W0 | ⬜ pending |
| 04-01-03 | 01 | 0 | FR-014 | unit | `flutter test test/unit/features/session/streak_test.dart -x` | ❌ W0 | ⬜ pending |
| 04-01-04 | 01 | 0 | FR-012 | unit | `flutter test test/unit/features/session/session_completion_test.dart -x` | ❌ W0 | ⬜ pending |
| 04-01-05 | 01 | 0 | FR-005 | widget | `flutter test test/widget/session_player_screen_test.dart -x` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/unit/features/session/session_lock_state_test.dart` — stubs for FR-004 (lock state derivation)
- [ ] `test/unit/features/session/session_resume_test.dart` — stubs for FR-013 (resume index persistence)
- [ ] `test/unit/features/session/streak_test.dart` — stubs for FR-014 (streak computation)
- [ ] `test/unit/features/session/session_completion_test.dart` — stubs for FR-012 (progress record + currentDay)
- [ ] `test/widget/session_player_screen_test.dart` — widget smoke test for FR-005

*Existing flutter_test + mocktail infrastructure covers all phase requirements. No new framework install needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Video starts within 2s (pre-downloaded) | SC-002 | Requires real device timing | 1. Pre-download a session. 2. Tap session row. 3. Time from tap to first video frame. Target: ≤ 2s. |
| 3D model loads within 1s | SC-003 | Requires real device WebView timing | 1. Open session player. 2. Tap 3D icon. 3. Time from tap to model visible in sheet. Target: ≤ 1s. |
| Session resumes mid-session on app restart | FR-013 | Requires killing and relaunching app | 1. Start session, advance to exercise 2. 2. Force-close app. 3. Relaunch and tap same session. 4. Verify exercise 2 loads (not exercise 1). |

*SC-002 and SC-003 are performance benchmarks — full automation deferred to Phase 9 Polish & QA.*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
