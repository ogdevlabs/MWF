---
phase: 6
slug: us4-metrics-progress
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-28
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) + mocktail 1.0.5 |
| **Config file** | none — standard `flutter test` discovery |
| **Quick run command** | `flutter test test/unit/features/metrics/ --no-pub` |
| **Full suite command** | `flutter test --no-pub` |
| **Estimated runtime** | ~50 seconds (62 existing + ~14 new tests) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/unit/features/metrics/ --no-pub`
- **After every plan wave:** Run `flutter test --no-pub`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** ~50 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 6-01-01 | 01 | 0 | FR-008 FR-009 | unit | `flutter test test/unit/features/metrics/ --no-pub` | ❌ W0 | ⬜ pending |
| 6-01-02 | 01 | 0 | FR-008 | widget | `flutter test test/widget/ --no-pub` | ❌ W0 | ⬜ pending |
| 6-02-01 | 02 | 1 | FR-008 FR-009 | unit | `flutter test test/unit/features/session/streak_test.dart test/unit/features/metrics/ --no-pub` | ✅/❌ W0 | ⬜ pending |
| 6-02-02 | 02 | 1 | FR-008 | unit | `flutter test test/unit/features/metrics/ --no-pub` | ❌ W0 | ⬜ pending |
| 6-03-01 | 03 | 1 | FR-009 | unit+widget | `flutter test test/unit/features/metrics/ test/widget/ --no-pub` | ❌ W0 | ⬜ pending |
| 6-03-02 | 03 | 1 | FR-008 FR-009 | widget | `flutter test test/widget/ --no-pub` | ❌ W0 | ⬜ pending |
| 6-04-01 | 04 | 2 | FR-008 | unit | `flutter test test/unit/features/metrics/offline_metric_sync_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-04-02 | 04 | 2 | FR-008 FR-009 | widget | `flutter test test/widget/ --no-pub` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/unit/features/metrics/metric_delta_test.dart` — stubs for `computeMetricDelta()` (< 2 logs → null, weight down, two logs)
- [ ] `test/unit/features/metrics/metric_repository_test.dart` — stubs for `MetricRepository.logMetric()` (local Drift insert, sync_queue enqueue, date format)
- [ ] `test/unit/features/metrics/offline_metric_sync_test.dart` — stub for offline log → sync_queue → replay integration test
- [ ] `test/widget/metric_log_bottom_sheet_test.dart` — stubs for form renders, dismisses without crash
- [ ] `test/widget/progress_screen_test.dart` — stubs for empty state, streak card presence

Existing files to extend (not Wave 0 gaps):
- `test/unit/features/session/streak_test.dart` — add `computeLongestStreak()` group

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Line chart renders with correct data points visually | FR-009 | fl_chart CustomPainter can't be pixel-asserted headlessly | Open Progress screen on simulator with 3+ entries, verify dots + line |
| Delta badge shows correct sign and value | FR-009 | Visual rendering verification | Log weight 70kg then 68kg — badge should show "−2.0 kg" |
| Non-blocking metric prompt on completion screen | FR-008 | Navigation flow requires running app | Complete a session, verify prompt appears without blocking |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 50s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
