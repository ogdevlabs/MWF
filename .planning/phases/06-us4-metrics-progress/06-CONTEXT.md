# Phase 6: US4 Metrics & Progress - Context

**Gathered:** 2026-05-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Student can log body metrics (weight, measurements, flexibility) with date stamps from
two entry points: a non-blocking prompt on the session completion screen, and a "Log
Metrics" button on the Progress tab. A Progress screen shows a streak card (current +
longest streak) and per-metric-type line charts with a first→latest delta badge.
Offline metric logs enqueue in sync_queue and sync on reconnect.

This phase does NOT include: coach feedback (Phase 7), admin panel (Phase 8), metric
goal-setting, reminders/notifications for logging, or multi-user comparison.

</domain>

<decisions>
## Implementation Decisions

### Chart Library
- **D-01:** Use `fl_chart` (MIT license) — the standard Flutter charting library.
  Add `fl_chart: ^0.69.0` (or latest stable) to `mobile/pubspec.yaml`.

### Metric Log Entry UX
- **D-02:** Two entry points:
  1. **Completion screen prompt**: After session complete, a non-blocking bottom sheet
     slides up offering "Log today's metrics?" with a compact form (metric type selector
     + value + unit). Student can dismiss. Does NOT block the completion screen flow.
  2. **Progress tab button**: "Log Metrics" button in the Progress screen header opens
     the same bottom sheet (or full-page form) at any time.
- **D-03:** The bottom sheet form allows logging ONE metric type at a time (weight, a
  specific measurement, or a flexibility score). A "Log another" option lets them add
  more without closing.
- **D-04:** Date defaults to today but is editable (date picker). Students may log
  retroactively for yesterday if they forgot.

### Progress Screen Layout
- **D-05:** Single-scroll `ProgressScreen` at `/progress` route (replace `_PlaceholderScreen`):
  1. **Streak card** at top — current streak (large number) + longest streak (subtitle)
  2. **"Log Metrics" button** — opens bottom sheet
  3. **Metric type tab bar** — three tabs: Weight | Measurements | Flexibility
  4. **Line chart** — below tabs, shows data for the selected metric type
  5. **Delta badge** — above or on the chart, shows first→latest value delta
     (e.g., "−2.3 kg since start")
- **D-06:** Empty state: when no logs exist for a metric type, show a friendly prompt
  ("No data yet — log your first entry!") instead of an empty chart.

### Chart Behavior
- **D-07:** X-axis: dates (calendar). Y-axis: metric value. One data point per log entry.
  When multiple entries exist on the same date, show the latest value for that date.
- **D-08:** Line chart shows dots at each data point, a smooth line connecting them.
  Color: `colorScheme.primary` (sage green). No grid lines, minimal axis labels (clean Pilates aesthetic).
- **D-09:** Delta badge shows net change from first recorded entry to latest. Green if
  improving direction (weight down, flexibility up), neutral gray otherwise. "Improving
  direction" for measurements is user-agnostic (show value + arrow, no judgment).

### Metric Types & Subtypes
- **D-10:** Weight tab: single series (no subtypes). Unit: kg or lbs (from log entry).
- **D-11:** Measurements tab: subtype selector (waist, hip, chest, thigh, arm) — one
  subtype visible at a time in the chart. Subtype chip row above chart.
- **D-12:** Flexibility tab: subtype selector (forward_bend, shoulder, hip_flexor) —
  same chip row pattern as measurements.
- **D-13:** All metric_type and metric_subtype values stored as lowercase strings
  matching the `metric_logs` Supabase table schema.

### Streak Data Source
- **D-14:** Streak is derived from `LocalProgressRecords` Drift table using the existing
  `computeCurrentStreak()` function from `streak_calculator.dart`. No new computation
  needed — reuse Phase 4 logic.
- **D-15:** Longest streak is computed from the same dataset by finding the maximum
  consecutive-day run. Add `computeLongestStreak()` to `streak_calculator.dart`.

### Offline Sync
- **D-16:** Metric log writes use the SyncQueue pattern:
  1. Insert into `local_metric_logs` (Drift) — immediate local write
  2. `SyncQueue.enqueue('insert', 'metric_logs', payload)` — queues remote write
  3. On reconnect, `SyncService.processQueue()` replays to Supabase `metric_logs` table
- **D-17:** `SyncService._pullRemoteChanges()` must also pull `metric_logs` from
  Supabase (like other mirrored tables) to handle multi-device sync.

### Claude's Discretion
- Exact bottom sheet height and animation (use `showModalBottomSheet` with `isScrollControlled: true`)
- Numeric input field style (use standard `TextField` with `keyboardType: TextInputType.numberWithOptions(decimal: true)`)
- Whether to use `DefaultTabController` or a custom tab bar for metric types
- Exact date picker widget (`showDatePicker` from Material)
- Chart touch/tooltip behavior (show value on tap — fl_chart built-in)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Specification & Requirements
- `specs/001-mat-pilates-coach/spec.md` — User Story 4 (FR-008, FR-009), acceptance scenarios US4-SC1..SC4
- `specs/001-mat-pilates-coach/data-model.md` — `metric_logs` Supabase table, `local_metric_logs` Drift table schema

### Existing Code (integration & reuse points)
- `mobile/lib/core/database/tables/metric_logs_table.dart` — `LocalMetricLogs` Drift table (already defined)
- `mobile/lib/core/database/daos/metric_logs_dao.dart` — `MetricLogsDao` with `watchMetricsByType`, `getMetricsByStudent`, `insertMetricLog`, `upsertMetricLog`
- `mobile/lib/features/session/data/streak_calculator.dart` — `computeCurrentStreak()` to reuse; add `computeLongestStreak()` here
- `mobile/lib/features/session/presentation/session_completion_screen.dart` — add non-blocking metric prompt CTA (currently has "Send Feedback to Coach" + "Back to Program")
- `mobile/lib/shared/router/app_router.dart` — `/progress` route is a `_PlaceholderScreen` to replace
- `mobile/lib/core/sync/sync_queue.dart` — `SyncQueue.enqueue()` for offline metric writes
- `mobile/lib/core/sync/sync_service.dart` — `_pullRemoteChanges()` needs `metric_logs` pull added

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MetricLogsDao.watchMetricsByType(studentId, metricType)`: reactive stream already ordered by `loggedAt` asc — perfect for feeding chart data
- `computeCurrentStreak(List<DateTime>)`: pure function, no modification needed
- `SessionCompletionScreen`: has two CTA buttons; add a third "Log Metrics" TextButton or trigger bottom sheet after brief delay (non-blocking)
- `SyncQueue.enqueue()`: same pattern used for progress_records — no new infrastructure needed
- Material `showModalBottomSheet` + `showDatePicker` already available (Flutter SDK)

### Established Patterns
- Riverpod + Freezed domain models (all features)
- CQRS: command writes to Drift + SyncQueue, query reads from Drift via DAO stream
- `ConsumerWidget` + `ref.watch(someProvider)` for reactive UI
- `AppTheme` sage-green Material 3 — use `colorScheme.primary` for chart line, `colorScheme.surface` for cards

### Integration Points
- Replace `_PlaceholderScreen` at `/progress` route in `app_router.dart`
- `session_completion_screen.dart`: add "Log Metrics?" prompt — a `TextButton` or auto-shown bottom sheet (non-blocking, dismissible)
- `SyncService._pullRemoteChanges()`: add `metric_logs` pull block (same pattern as other tables)
- New `metrics` feature directory: `mobile/lib/features/metrics/`

</code_context>

<specifics>
## Specific Ideas

- The metric prompt on completion should feel lightweight — not a full form interrupting the
  celebration. A single "Log metrics for today?" text button below the two main CTAs is enough.
  The full form is in the Progress tab.
- Delta badge should be simple: "−2.3 kg" with a down arrow for weight, not a percentage or
  complex calculation. Students relate to absolute values.
- Chart aesthetics: Pilates app — clean, minimal. No heavy grid, no neon colors. Sage green
  dots + line on white/surface background.

</specifics>

<deferred>
## Deferred Ideas

- Metric goal-setting (target weight, target measurement) — Phase 9 polish
- Metric entry reminders / push notifications — Phase 9
- Unit preference (kg vs lbs) stored in student profile — Phase 9
- Metric export (CSV download) — out of v1.0 scope
- Multi-metric overlay chart — Phase 9 polish

</deferred>

---

*Phase: 06-us4-metrics-progress*
*Context gathered: 2026-05-28*
