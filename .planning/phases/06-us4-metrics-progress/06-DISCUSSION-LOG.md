# Phase 6: US4 Metrics & Progress - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-28
**Phase:** 06-us4-metrics-progress
**Mode:** --auto (all decisions auto-selected with recommended defaults)
**Areas discussed:** Chart library, Metric log entry UX, Progress screen layout, Streak data source, Offline sync

---

## Chart Library

| Option | Description | Selected |
|--------|-------------|----------|
| fl_chart | MIT, most widely adopted Flutter chart lib | ✓ |
| syncfusion_flutter_charts | Feature-rich but commercial license | |
| custom Canvas paint | Full control, high effort | |

**Auto-selected:** `fl_chart` — zero license friction, widely maintained, line chart support.

---

## Metric Log Entry UX

| Option | Description | Selected |
|--------|-------------|----------|
| Non-blocking bottom sheet from completion + Progress tab button | Two entry points, bottom sheet is dismissible | ✓ |
| Full-page form navigated from completion screen | Blocking navigation | |
| Only Progress tab (no completion prompt) | Single entry point | |

**Auto-selected:** Non-blocking bottom sheet from both entry points. Recommended for a calm app aesthetic.

---

## Progress Screen Layout

| Option | Description | Selected |
|--------|-------------|----------|
| Streak card + tab switcher + line chart (single scroll) | Clean single-screen layout | ✓ |
| Separate Streak screen and Charts screen | Multiple navigations | |
| Dashboard grid of all metric types | Dense, harder to read | |

**Auto-selected:** Single-scroll with streak card at top, tab bar for metric types, chart below.

---

## Streak Data Source

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse computeCurrentStreak() + add computeLongestStreak() | No new infrastructure | ✓ |
| New streak table in Drift | Extra complexity | |
| Server-side computation | Requires online | |

**Auto-selected:** Reuse existing `streak_calculator.dart` functions — pure functions, no DB overhead.

---

## Offline Sync

| Option | Description | Selected |
|--------|-------------|----------|
| SyncQueue.enqueue() same as progress_records | Established pattern | ✓ |
| Direct Supabase write with optimistic local | Requires online | |
| Batch sync only | Poor UX | |

**Auto-selected:** SyncQueue pattern — consistent with all other offline writes in the app.

---

## Claude's Discretion

- Bottom sheet height and animation style
- Numeric input field type and validation
- Tab bar implementation (DefaultTabController vs custom)
- Date picker widget
- Chart touch/tooltip behavior
