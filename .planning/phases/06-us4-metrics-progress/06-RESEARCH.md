# Phase 6: US4 Metrics & Progress - Research

**Researched:** 2026-05-28
**Domain:** Flutter charting (fl_chart), body metric CRUD, Drift reactive streams, offline sync extension
**Confidence:** HIGH

## Summary

Phase 6 adds a `metrics` feature directory that provides two entry points for logging body
metrics (session completion prompt + progress tab button) and a `ProgressScreen` that renders
streak data and per-type line charts. Almost all infrastructure already exists: `MetricLogsDao`,
`LocalMetricLogs` table, `SyncQueue.enqueue()`, and the `_pullTable` pattern in `SyncService`.
The only missing pieces are `computeLongestStreak()`, the `fl_chart` dependency, all presentation
widgets, a `MetricRepository`/providers layer, and the `body_metrics` pull block in
`_pullRemoteChanges()`.

The `logged_at` column in the Supabase `metric_logs` table is `date` (not `timestamptz`), which
is critical: the Drift `LocalMetricLogs` table stores it as `dateTime()` (maps to an INTEGER epoch
in SQLite). The sync payload must serialize `logged_at` as a date string (`YYYY-MM-DD`) not a
full ISO-8601 timestamp when writing to Supabase, because Postgres will reject a full timestamp
for a `date` column.

The existing test baseline is 62 tests passing (confirmed). All new tests must keep that green.

**Primary recommendation:** Build `features/metrics/` with the standard Riverpod + Freezed +
Drift DAO stack. Add `fl_chart: ^1.2.0` to pubspec. Test the computation logic (streak, delta)
as pure functions and the repository as unit tests against real in-memory Drift. Keep the
`LineChart` widget out of headless test scope — stub the data layer instead.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Use `fl_chart` (MIT license). Add `fl_chart: ^0.69.0` (or latest stable) to
  `mobile/pubspec.yaml`. (Latest stable confirmed as 1.2.0 — use `fl_chart: ^1.2.0`.)
- **D-02:** Two metric log entry points: (1) non-blocking bottom sheet on session completion
  screen, (2) "Log Metrics" button on Progress screen header.
- **D-03:** Bottom sheet logs ONE metric type at a time; "Log another" option available.
- **D-04:** Date defaults to today; editable via date picker; retroactive entry allowed.
- **D-05:** `ProgressScreen` layout: streak card → "Log Metrics" button → metric type tab bar
  (Weight | Measurements | Flexibility) → line chart → delta badge.
- **D-06:** Empty state when no logs: friendly prompt, not an empty chart.
- **D-07:** X-axis = dates; Y-axis = metric value; one data point per log entry (latest per date).
- **D-08:** Line chart: dots at each data point, smooth line, `colorScheme.primary`, no grid,
  minimal axis labels.
- **D-09:** Delta badge: net change first→latest. Green if improving; neutral gray otherwise.
- **D-10:** Weight tab: single series, unit kg/lbs from log entry.
- **D-11:** Measurements tab: subtype chip row (waist, hip, chest, thigh, arm).
- **D-12:** Flexibility tab: subtype chip row (forward_bend, shoulder, hip_flexor).
- **D-13:** All `metric_type` / `metric_subtype` stored lowercase matching Supabase schema.
- **D-14:** Streak uses existing `computeCurrentStreak()` from `streak_calculator.dart`.
- **D-15:** Add `computeLongestStreak()` to `streak_calculator.dart`.
- **D-16:** Offline sync: (1) insert into `local_metric_logs`, (2) `SyncQueue.enqueue('insert',
  'body_metrics', payload)`, (3) replay on reconnect.
- **D-17:** `SyncService._pullRemoteChanges()` must pull `body_metrics` table.

### Claude's Discretion
- Exact bottom sheet height and animation (`showModalBottomSheet` with `isScrollControlled: true`)
- Numeric input field style (`TextField` with `keyboardType: TextInputType.numberWithOptions(decimal: true)`)
- Whether to use `DefaultTabController` or custom tab bar for metric types
- Exact date picker widget (`showDatePicker` from Material)
- Chart touch/tooltip behavior (show value on tap — fl_chart built-in)

### Deferred Ideas (OUT OF SCOPE)
- Metric goal-setting (target weight, target measurement) — Phase 9 polish
- Metric entry reminders / push notifications — Phase 9
- Unit preference (kg vs lbs) stored in student profile — Phase 9
- Metric export (CSV download) — out of v1.0 scope
- Multi-metric overlay chart — Phase 9 polish
</user_constraints>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fl_chart | ^1.2.0 | LineChart widget | Locked (D-01). MIT. Standard Flutter chart library. Latest stable confirmed 2026-05-28 via `dart pub add --dry-run`. |
| drift / drift/native.dart | ^2.33.0 (already installed) | In-memory DB in tests | Already the project DB layer |
| flutter_riverpod / riverpod_annotation | ^3.3.1 / ^4.0.2 (already installed) | State + codegen | Project standard |
| freezed_annotation | ^3.1.0 (already installed) | Domain model immutability | Project standard |
| mocktail | ^1.0.5 (already installed) | Mock Supabase in tests | Project standard |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| uuid | ^4.5.1 (already installed) | Generate metric log IDs | In `MetricRepository.logMetric()` — same pattern as `ProgramsRepository` |
| shared_preferences | ^2.5.5 (already installed) | Last sync timestamp | Already used by SyncService |

### Installation
```bash
# In mobile/ directory
flutter pub add fl_chart
```

**Version verification:** `dart pub add fl_chart --dry-run` confirms `fl_chart 1.2.0` resolves
cleanly against the existing lock file (2026-05-28).

---

## Architecture Patterns

### Recommended Project Structure
```
mobile/lib/features/metrics/
├── domain/
│   └── metric_log_model.dart        # Freezed immutable model
├── data/
│   ├── metric_repository.dart       # logMetric() command + watchMetrics() query
│   └── metric_providers.dart        # Riverpod providers (generated)
└── presentation/
    ├── progress_screen.dart          # Replaces _PlaceholderScreen at /progress
    ├── metric_log_bottom_sheet.dart  # showModalBottomSheet content
    └── metric_line_chart.dart        # fl_chart LineChart wrapper widget

mobile/test/unit/features/metrics/
├── metric_repository_test.dart       # real in-memory Drift
├── streak_longest_test.dart          # pure function tests
└── metric_delta_test.dart            # pure function tests

mobile/test/widget/
├── metric_log_bottom_sheet_test.dart # widget: form renders, dismiss works
└── progress_screen_empty_state_test.dart # widget: empty state message

mobile/test/unit/features/session/
└── offline_metric_sync_test.dart     # extend existing pattern
```

### Pattern 1: MetricRepository (CQRS Command + Query)

**What:** Command side writes to Drift + SyncQueue. Query side reads from Drift DAO stream.
**When to use:** All metric log writes and reads go through this class.

```dart
// Source: established project CQRS pattern (session_completion_service.dart, programs_repository.dart)
class MetricRepository {
  MetricRepository({required this.db, required this.syncQueue, required this.studentId});

  final AppDatabase db;
  final SyncQueue syncQueue;
  final String studentId;

  /// Command: insert metric log locally and enqueue remote write.
  Future<void> logMetric({
    required String metricType,
    String? metricSubtype,
    required double value,
    required String unit,
    required DateTime loggedAt,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // 1. Local write (immediate)
    await db.metricLogsDao.upsertMetricLog(LocalMetricLogsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      metricType: Value(metricType),
      metricSubtype: Value(metricSubtype),
      value: Value(value),
      unit: Value(unit),
      loggedAt: Value(loggedAt),
      createdAt: Value(now),
    ));

    // 2. Enqueue remote write (D-16)
    await syncQueue.enqueue(
      operation: 'insert',
      targetTable: 'body_metrics',
      payload: {
        'id': id,
        'student_id': studentId,
        'metric_type': metricType,
        'metric_subtype': metricSubtype,
        'value': value,
        'unit': unit,
        // CRITICAL: Supabase metric_logs.logged_at is DATE not TIMESTAMPTZ
        // Format as YYYY-MM-DD — Postgres rejects full ISO-8601 for date columns
        'logged_at': '${loggedAt.year.toString().padLeft(4,'0')}'
            '-${loggedAt.month.toString().padLeft(2,'0')}'
            '-${loggedAt.day.toString().padLeft(2,'0')}',
        'created_at': now.toUtc().toIso8601String(),
      },
    );
  }

  /// Query: reactive stream of metrics by type, ordered by loggedAt asc.
  /// Already implemented in MetricLogsDao.watchMetricsByType().
  Stream<List<LocalMetricLog>> watchMetricsByType(String metricType) =>
      db.metricLogsDao.watchMetricsByType(studentId, metricType);
}
```

### Pattern 2: computeLongestStreak() — pure function addition

**What:** Add alongside `computeCurrentStreak()` in `streak_calculator.dart`.
**When to use:** Displayed in streak card as "Longest streak" subtitle.

```dart
// Source: same file as computeCurrentStreak — mobile/lib/features/session/data/streak_calculator.dart
int computeLongestStreak(List<DateTime> completedDates) {
  if (completedDates.isEmpty) return 0;

  final uniqueDates = completedDates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => a.compareTo(b)); // ascending

  int longest = 1;
  int current = 1;
  for (int i = 1; i < uniqueDates.length; i++) {
    final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
    if (diff == 1) {
      current++;
      if (current > longest) longest = current;
    } else {
      current = 1;
    }
  }
  return longest;
}
```

### Pattern 3: Delta Badge computation — pure function

**What:** Standalone function; takes a list of `LocalMetricLog` and returns the delta string.
**When to use:** Called in `ProgressScreen` / `MetricLineChart` widget with the filtered dataset.

```dart
// Proposed location: mobile/lib/features/metrics/domain/metric_delta.dart
double? computeMetricDelta(List<LocalMetricLog> logs) {
  if (logs.length < 2) return null;
  // logs are ordered loggedAt asc by DAO
  return logs.last.value - logs.first.value;
}
```

**Delta badge render rule (D-09):**
- Weight: negative delta = green (lost weight = improving), positive = gray
- Flexibility: positive delta = green (more range = improving), negative = gray
- Measurements: show absolute value + arrow, no color judgment (D-09 explicitly: "user-agnostic")

### Pattern 4: fl_chart LineChart Widget

**What:** Wrapper widget that takes `List<LocalMetricLog>` and renders a `LineChart`.
**Key API (fl_chart 1.2.0):**

```dart
// Source: fl_chart GitHub docs — repo_files/documentations/line_chart.md
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: logs.map((e) => FlSpot(
          e.loggedAt.millisecondsSinceEpoch.toDouble(),
          e.value,
        )).toList(),
        color: Theme.of(context).colorScheme.primary,
        isCurved: true,
        barWidth: 2.5,
        dotData: FlDotData(show: true),
      ),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => _dateLabel(value),
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    gridData: FlGridData(show: false),    // D-08: no grid lines
    borderData: FlBorderData(show: false),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) => touchedSpots.map((s) =>
          LineTooltipItem('${s.y}', const TextStyle())).toList(),
      ),
    ),
  ),
)
```

**X-axis date label approach:** Convert `millisecondsSinceEpoch` double back to `DateTime` in
`getTitlesWidget`. Show abbreviated date (e.g., `DateFormat('M/d')` from `intl` — but `intl` is
not yet in pubspec. Use manual formatting: `'${dt.month}/${dt.day}'`).

### Pattern 5: SyncService body_metrics pull block

**What:** Add one `_pullTable` call in `_pullRemoteChanges()`, matching the progress_records block.
**When to use:** On every sync cycle (reconnect + startup + pull-to-refresh).

```dart
// Source: sync_service.dart — _pullRemoteChanges() — add after progress_records block
totalPulled += await _pullTable(
  tableName: 'body_metrics',
  since: lastSync,
  upsert: (rows) async {
    for (final row in rows) {
      await db.metricLogsDao.upsertMetricLog(LocalMetricLogsCompanion(
        id: Value(row['id'] as String),
        studentId: Value(row['student_id'] as String),
        metricType: Value(row['metric_type'] as String),
        metricSubtype: Value(row['metric_subtype'] as String?),
        value: Value((row['value'] as num).toDouble()),
        unit: Value(row['unit'] as String),
        // body_metrics.logged_at is a DATE in Postgres — arrives as 'YYYY-MM-DD' string
        loggedAt: Value(DateTime.parse(row['logged_at'] as String)),
        createdAt: Value(DateTime.parse(row['created_at'] as String)),
      ));
    }
  },
);
```

### Pattern 6: Non-blocking metric prompt on SessionCompletionScreen

**What:** Add a `TextButton` ("Log today's metrics?") below the two existing CTAs. Tapping opens
the `MetricLogBottomSheet` without blocking the completion flow.
**Implementation:** The screen already uses `ConsumerStatefulWidget`. Add one `TextButton` after
the existing `OutlinedButton` in the `Column`. The bottom sheet is shown with
`showModalBottomSheet(..., isScrollControlled: true)`.

```dart
// Add below the existing OutlinedButton in SessionCompletionScreen._build()
const SizedBox(height: 8),
TextButton(
  onPressed: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const MetricLogBottomSheet(),
  ),
  child: const Text('Log today\'s metrics?'),
),
```

### Anti-Patterns to Avoid

- **Rendering LineChart in unit tests:** fl_chart uses a custom `Canvas`-based renderer that
  throws `PlatformException` or silently degrades in headless `flutter_test` environments without
  a real render tree. Test the data layer (providers, repository, computations) — not the widget.
- **Storing `logged_at` as full ISO-8601 in Supabase payload:** `metric_logs.logged_at` is a
  `date` column in Postgres, not `timestamptz`. Sending `2026-05-28T10:30:00Z` will cause a
  Postgres type cast error. Always serialize as `YYYY-MM-DD`.
- **Pulling body_metrics without `updated_at` filter:** The `_pullTable` helper filters on
  `updated_at >= since`. The `metric_logs` Supabase table does NOT have an `updated_at` column
  (see data-model.md — only `created_at`). Use `created_at` in the filter instead. Pass
  `filter: (q) => since != null ? q.gte('created_at', since) : q` OR add an `updated_at`
  migration. Simplest: extend `_pullTable` to accept a custom timestamp column, or just filter on
  `created_at` for this table since metric logs are insert-only (no edits).
- **watchMetricsByType without subtype filter for Measurements/Flexibility tabs:** The DAO
  `watchMetricsByType` returns ALL subtypes for a given `metricType`. For the chip-selected subtype
  view, filter the returned list in the provider/widget — don't create a new DAO method.
- **Using `DefaultTabController` with `ConsumerWidget` that rebuilds:** `DefaultTabController` is
  an `InheritedWidget` provider; if the parent rebuilds (e.g. stream update), the tab index resets.
  Manage tab state with a `TabController` in a `ConsumerStatefulWidget` or use a simple `int
  _selectedTab` state variable.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Line charts | Custom `CustomPainter` chart | `fl_chart LineChart` | Touch handling, animation, axis labels — months of work |
| Date ranges for X axis | Custom date bucketing | `FlSpot(loggedAt.millisecondsSinceEpoch.toDouble(), value)` + label formatter | fl_chart handles axis space naturally |
| Reactive stream → UI | Manual `StreamSubscription` + `setState` | `ref.watch(streamProvider)` — Riverpod `StreamProvider` | Drift `watchMetricsByType` already returns a `Stream` |
| Modal bottom sheet | Custom overlay widget | `showModalBottomSheet` (Flutter SDK) | Handles keyboard, scroll, dismiss — decided in D-02 |
| Date picker | Custom calendar widget | `showDatePicker` (Flutter SDK) | Decided in D-04 |
| UUID generation | Manual timestamp IDs | `const Uuid().v4()` — already in pubspec | Collision-free, matches Supabase PK expectations |

---

## Common Pitfalls

### Pitfall 1: `logged_at` DATE vs DATETIME type mismatch
**What goes wrong:** Supabase upsert rejects payload with full ISO-8601 timestamp for a `date`
column. SyncQueue item reaches retry_count=5 and dead-letters.
**Why it happens:** `LocalMetricLogs` stores `loggedAt` as `dateTime()` (Drift stores as INTEGER
epoch). When serializing for Supabase, the naive `.toIso8601String()` produces a full timestamp.
**How to avoid:** Always format `logged_at` in the SyncQueue payload as `YYYY-MM-DD`:
`'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'`
**Warning signs:** `SyncQueue` items for `body_metrics` not clearing after processQueue(); Supabase
logs show `invalid input syntax for type date`.

### Pitfall 2: `body_metrics` pull uses `created_at` not `updated_at`
**What goes wrong:** `_pullTable` applies `updated_at >= since` filter. `metric_logs` Supabase
table has only `created_at`, not `updated_at`. The query either errors or returns nothing.
**Why it happens:** The generic `_pullTable` helper was written for tables with `updated_at`.
**How to avoid:** Add a `sinceColumn` parameter to `_pullTable` (default: `'updated_at'`), or
for the `body_metrics` block, pass `filter: (q) => since != null ? q.gte('created_at', since) : q`
and skip the built-in timestamp filter. Since metric logs are insert-only, filtering on
`created_at` is correct.
**Warning signs:** `GET body_metrics?updated_at=gte....` 400 error in Supabase logs.

### Pitfall 3: fl_chart renders zero-width chart in tests
**What goes wrong:** `testWidgets` renders widgets at 800x600 by default. `LineChart` needs a
bounded parent or it renders zero-sized and may throw or show nothing.
**Why it happens:** `LineChart` uses `LayoutBuilder` internally and requests unbounded height from
a flex container.
**How to avoid:** In any widget test that includes `MetricLineChart`, wrap in
`SizedBox(width: 300, height: 200, child: ...)`. However, avoid testing the chart widget at all
in unit tests — test the data layer only.
**Warning signs:** `RenderFlex overflow`, `Null check operator on null value` in widget tests
involving fl_chart.

### Pitfall 4: Tab controller state reset on stream rebuild
**What goes wrong:** The metric type tab resets to index 0 whenever the parent widget rebuilds
(e.g., when the Drift stream emits a new list after a log is inserted).
**Why it happens:** `DefaultTabController` does not persist tab index across widget rebuilds if
its parent widget is recreated.
**How to avoid:** Use `ConsumerStatefulWidget` for `ProgressScreen` and instantiate a
`TabController` in `initState` with a fixed `length: 3`. The controller survives rebuilds.
**Warning signs:** User logs a metric and the tab jumps back to "Weight".

### Pitfall 5: Drift `isNull`/`isNotNull` import conflict in tests
**What goes wrong:** `import 'package:drift/drift.dart'` exports `isNull` and `isNotNull`
matchers that conflict with `package:flutter_test/flutter_test.dart` matchers.
**Why it happens:** Known project-wide conflict documented in STATE.md Phase 04 decisions.
**How to avoid:** All test files that import both must hide drift's matchers:
`import 'package:drift/drift.dart' hide isNull, isNotNull;`
**Warning signs:** Compile error: `'isNull' is imported from both 'package:drift/drift.dart'
and 'package:flutter_test/flutter_test.dart'`.

### Pitfall 6: "Log another" flow leaks bottom sheet context
**What goes wrong:** The "Log another" button inside the bottom sheet pops and re-shows the
sheet. If using `Navigator.pop(context)` then `showModalBottomSheet`, the parent might not have
focus or the scaffold might be disposed.
**Why it happens:** Bottom sheet context is different from the screen's `BuildContext`.
**How to avoid:** Keep the bottom sheet stateful. Use an internal `setState` to show a new
form inline rather than closing and re-opening. A `_formKey` + `GlobalKey<FormState>` pattern
with `reset()` is cleaner.

---

## Code Examples

### Verified: In-memory Drift DB pattern (used in all existing tests)
```dart
// Source: mobile/test/unit/features/session/session_completion_test.dart
db = AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(),
    closeStreamsSynchronously: true,
  ),
);
```

### Verified: SyncQueue.enqueue pattern for body_metrics
```dart
// Source: mobile/lib/core/sync/sync_queue.dart — enqueue() signature
await syncQueue.enqueue(
  operation: 'insert',
  targetTable: 'body_metrics',
  payload: {
    'id': id,
    'student_id': studentId,
    'metric_type': 'weight',
    'value': 75.5,
    'unit': 'kg',
    'logged_at': '2026-05-28',   // DATE format — not full ISO-8601
    'created_at': DateTime.now().toUtc().toIso8601String(),
  },
);
```

### Verified: Drift hide pattern for test imports
```dart
// Source: mobile/test/unit/features/session/session_completion_test.dart line 1
import 'package:drift/drift.dart' hide isNull, isNotNull;
```

### Verified: Fake PostgrestFilterBuilder pattern (for Supabase mock in tests)
```dart
// Source: mobile/test/unit/features/session/offline_sync_integration_test.dart
// Use Fake (not Mock) for PostgrestFilterBuilder — it implements Future
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder { ... }
class _CompletedFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> { ... }
```

### Verified: MetricLogsDao.watchMetricsByType already returns ordered stream
```dart
// Source: mobile/lib/core/database/daos/metric_logs_dao.dart
Stream<List<LocalMetricLog>> watchMetricsByType(String studentId, String metricType) =>
    (select(localMetricLogs)
          ..where((t) => t.studentId.equals(studentId) & t.metricType.equals(metricType))
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .watch();
// No subtype filter — filter subtype in the presentation/provider layer
```

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (Flutter SDK) + mocktail ^1.0.5 |
| Config file | none — tests run via `flutter test` |
| Quick run command | `flutter test test/unit/features/metrics/ --no-pub` |
| Full suite command | `flutter test --no-pub` |

**Baseline:** 62 tests passing as of 2026-05-28. All new tests must keep this green.
Quick run for new files only: `flutter test test/unit/features/metrics/ test/widget/ --no-pub`

---

### fl_chart Widget Test Strategy

**Rule: Do NOT render `LineChart` in headless widget tests.**

fl_chart's `LineChart` is a `CustomPainter`-based widget that relies on a real render tree for
canvas sizing. In headless `flutter_test` it either works with a bounded `SizedBox` wrapper or
throws unbounded constraint errors. More importantly, it provides zero business value to test the
charting library's rendering.

**Instead, test:**
1. The data transformation: `List<LocalMetricLog>` → `List<FlSpot>` is a pure function. Extract
   it from the widget and unit test it directly.
2. The widget tree structure: `find.byType(LineChart)` in a widget test that wraps with a
   `SizedBox(width:300, height:200)` confirms the chart is included, without asserting rendering.

```dart
// test/widget/metric_line_chart_test.dart — safe pattern
testWidgets('MetricLineChart renders LineChart widget when data provided', (tester) async {
  final logs = [/* test data */];
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 200,
          child: MetricLineChart(logs: logs),
        ),
      ),
    ),
  ));
  await tester.pump();
  expect(find.byType(LineChart), findsOneWidget);
});
```

---

### Phase Requirements → Test Map

| Behavior | Test Type | Automated Command | File |
|----------|-----------|-------------------|------|
| `computeLongestStreak()` — empty list → 0 | unit | `flutter test test/unit/features/session/streak_test.dart --no-pub` | Extend existing `streak_test.dart` |
| `computeLongestStreak()` — 5-day run → 5 | unit | same | same |
| `computeLongestStreak()` — gap in middle → max run | unit | same | same |
| `computeMetricDelta()` — < 2 logs → null | unit | `flutter test test/unit/features/metrics/ --no-pub` | `metric_delta_test.dart` (Wave 0 gap) |
| `computeMetricDelta()` — weight down → negative double | unit | same | same |
| `MetricRepository.logMetric()` — inserts into Drift local_metric_logs | unit | same | `metric_repository_test.dart` (Wave 0 gap) |
| `MetricRepository.logMetric()` — enqueues to sync_queue with body_metrics target | unit | same | same |
| `MetricRepository.logMetric()` — payload `logged_at` is DATE string not full ISO | unit | same | same |
| `watchMetricsByType()` — returns ordered stream from real in-memory Drift | unit | same | same |
| `MetricLogBottomSheet` — renders form fields (metric type, value, date) | widget | `flutter test test/widget/ --no-pub` | `metric_log_bottom_sheet_test.dart` (Wave 0 gap) |
| `MetricLogBottomSheet` — dismisses without crashing | widget | same | same |
| `ProgressScreen` — shows empty state message when no logs | widget | same | `progress_screen_empty_state_test.dart` (Wave 0 gap) |
| `ProgressScreen` — shows streak card with current + longest streak | widget | same | same |
| Offline metric log → sync_queue → replay to body_metrics | integration | `flutter test test/unit/features/metrics/offline_metric_sync_test.dart --no-pub` | `offline_metric_sync_test.dart` (Wave 0 gap) |

---

### Unit Test Strategy: `computeLongestStreak()` and `MetricRepository`

**`computeLongestStreak()` — pure function, zero mocks:**
- Extend `test/unit/features/session/streak_test.dart` with a new `group('computeLongestStreak', ...)`.
- Test cases: empty list, single date, two consecutive days, gap in middle, all same day,
  5-day run followed by isolated date (longest = 5 not 6).
- No setup required — pure function.

**`MetricRepository` — real in-memory Drift + mock SyncQueue:**
- Use `AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true))`.
- Mock `SyncQueue` with mocktail: `class MockSyncQueue extends Mock implements SyncQueue {}`.
- Assert: after `logMetric()`, `db.metricLogsDao.getMetricsByStudent(studentId)` returns 1 row.
- Assert: `verify(() => mockSyncQueue.enqueue(operation: 'insert', targetTable: 'body_metrics', payload: any(named: 'payload'))).called(1)`.
- Assert payload `logged_at` key: `captureAny` on payload map → expect value matches `RegExp(r'^\d{4}-\d{2}-\d{2}$')`.

**`computeMetricDelta()` — pure function:**
- Separate file `metric_delta_test.dart`.
- Test: empty list → null, single log → null, two logs same value → 0.0,
  weight down 2.3 kg → -2.3, flexibility up → positive.

---

### Widget Test Strategy: `MetricLogBottomSheet` and `ProgressScreen` Empty State

**`MetricLogBottomSheet`:**
- Must override `appDatabaseProvider` and relevant metric providers.
- Assert `find.byType(DropdownButton)` or chip row for metric type selection.
- Assert `find.byType(TextField)` for value input.
- Assert `find.byType(TextButton)` with "Log another" text.
- Test dismiss: tap outside → bottom sheet closes (flutter_test `tester.tapAt(Offset(400, 100))`).
- Do NOT test the fl_chart rendering in this widget (the bottom sheet contains no chart).

**`ProgressScreen` empty state:**
- Override `metricLogsProvider` (or equivalent stream provider) to return empty list.
- Override streak providers to return `StreakData(current: 0, longest: 0)`.
- Assert `find.text('No data yet')` or similar empty state text is visible.
- Assert `find.byType(LineChart)` is NOT present (or that a placeholder widget is shown).
- The progress screen instantiation must NOT require a real GoRouter — wrap with `MaterialApp`
  directly, same pattern as `session_player_screen_test.dart`.

---

### Integration Test: Offline Metric Log → SyncQueue → Replay

**Pattern:** Mirror `offline_sync_integration_test.dart` exactly — real in-memory Drift,
mock SupabaseClient with `_FakeQueryBuilder` for `body_metrics`.

```
test file: test/unit/features/metrics/offline_metric_sync_test.dart

1. Create AppDatabase(NativeDatabase.memory())
2. Create MockSupabaseClient + _FakeQueryBuilder for 'body_metrics'
3. Create SyncQueue(db, mockSupabase)
4. Create MetricRepository(db, syncQueue, 'student-1')
5. Call repo.logMetric(metricType: 'weight', value: 75.0, unit: 'kg', loggedAt: today)
6. Assert: db.metricLogsDao.getMetricsByStudent('student-1') has length 1
7. Assert: db.syncQueueDao.getPendingItems() has length 1, targetTable == 'body_metrics'
8. wire up: when(() => mockSupabase.from('body_metrics')).thenAnswer((_) => fakeQueryBuilder)
9. Call syncQueue.processQueue()
10. Assert: db.syncQueueDao.getPendingItems() is empty
11. Assert: fakeQueryBuilder.upsertedPayloads.first['metric_type'] == 'weight'
12. Assert: fakeQueryBuilder.upsertedPayloads.first['logged_at'] matches date regex
```

---

### What to Mock vs Real In-Memory Drift

| Component | Approach | Reason |
|-----------|----------|--------|
| `AppDatabase` | REAL — `NativeDatabase.memory()` | Already the project standard for all unit tests; validates DAO SQL queries work correctly |
| `SyncQueue` | MOCK (mocktail) when testing `MetricRepository` in isolation; REAL when testing full offline→sync flow | Mock lets you assert enqueue call without a real Supabase; real needed for end-to-end |
| `SupabaseClient` | MOCK (mocktail) + `_FakeQueryBuilder` | Same pattern as `offline_sync_integration_test.dart` — Future-implementing class requires Fake not Mock |
| `MetricRepository` | REAL when testing UI providers; MOCK in widget tests | Widget tests override providers — no need to construct real repo |
| `computeLongestStreak()`, `computeMetricDelta()` | No mocks — pure functions | Pure functions don't need any infrastructure |
| fl_chart `LineChart` | NOT TESTED directly | Canvas renderer requires real display — test data transformation only |

---

### Sampling Rate
- **Per task commit:** `flutter test test/unit/features/metrics/ --no-pub`
- **Per wave merge:** `flutter test --no-pub` (full 62+ test suite)
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps (test files that must exist before implementation)
- [ ] `test/unit/features/metrics/metric_repository_test.dart` — covers MetricRepository.logMetric()
- [ ] `test/unit/features/metrics/metric_delta_test.dart` — covers computeMetricDelta()
- [ ] `test/unit/features/metrics/offline_metric_sync_test.dart` — covers offline→sync integration
- [ ] `test/widget/metric_log_bottom_sheet_test.dart` — covers bottom sheet form
- [ ] `test/widget/progress_screen_empty_state_test.dart` — covers empty state + streak card
- [ ] Add `group('computeLongestStreak', ...)` to existing `test/unit/features/session/streak_test.dart`
- [ ] Create `test/unit/features/metrics/` directory

---

## State of the Art

| Old Approach | Current Approach | Notes |
|--------------|------------------|-------|
| charts_flutter (Google) | fl_chart | charts_flutter is unmaintained as of 2023. fl_chart is the community standard. |
| Riverpod 2.x `.valueOrNull` | Riverpod 3.x `.value` | Documented in STATE.md — `.valueOrNull` dropped in Riverpod 3.x |
| Constructor `@riverpod` global fn | `@Riverpod(keepAlive: true)` for long-lived providers | Pattern established in project |

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | all | ✓ | 3.44.0 | — |
| Dart SDK | all | ✓ | 3.12.0 | — |
| fl_chart | LineChart widget | ✓ (add to pubspec) | 1.2.0 (resolves cleanly) | — |
| NativeDatabase.memory() (drift/native.dart) | all unit tests | ✓ | 2.33.0 | — |

Step 2.6: No external services required for this phase beyond what is already provisioned.
Supabase is already running (Phase 2 foundation). No new services to check.

---

## Open Questions

1. **`_pullTable` timestamp column for `body_metrics`**
   - What we know: `_pullTable` applies `.gte('updated_at', since)` universally. `metric_logs`
     Supabase table has only `created_at`, not `updated_at`.
   - What's unclear: Whether to (a) add `updated_at` column to `metric_logs` via migration,
     (b) add a Supabase trigger to maintain `updated_at`, or (c) extend `_pullTable` to accept
     a `sinceColumn` parameter.
   - Recommendation: Option (c) is the cleanest — add optional `sinceColumn` parameter to
     `_pullTable` defaulting to `'updated_at'`; pass `sinceColumn: 'created_at'` for the
     `body_metrics` block. Since metric logs are insert-only (no edits), this is semantically
     correct.

2. **Supabase table name: `body_metrics` vs `metric_logs`**
   - What we know: The data model Supabase schema calls the table `metric_logs`. CONTEXT.md D-16
     says `SyncQueue.enqueue('insert', 'body_metrics', payload)`.
   - What's unclear: Whether `body_metrics` is the actual Supabase table name or a typo/alias.
   - Recommendation: Check `supabase/migrations/` to confirm the table name before implementing
     the sync payload. Use whatever the migration file defines as the canonical name. (The
     CONTEXT.md author wrote `body_metrics` for the SyncQueue target but the data model uses
     `metric_logs`.) This discrepancy MUST be resolved in Wave 0.

---

## Sources

### Primary (HIGH confidence)
- Mobile codebase direct read — `metric_logs_table.dart`, `metric_logs_dao.dart`,
  `streak_calculator.dart`, `sync_queue.dart`, `sync_service.dart`, `app_database.dart`,
  `session_completion_screen.dart`, `app_router.dart`, all existing test files
- `specs/001-mat-pilates-coach/data-model.md` — Supabase schema (metric_logs table columns)
- `pub.dev/packages/fl_chart` + `dart pub add --dry-run` — version 1.2.0 confirmed
- fl_chart GitHub docs `repo_files/documentations/line_chart.md` — LineChart API

### Secondary (MEDIUM confidence)
- fl_chart WebFetch of pub.dev documentation page — API classes confirmed

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — fl_chart 1.2.0 confirmed via pub resolution; all other libs already in pubspec
- Architecture: HIGH — patterns extracted directly from existing codebase; new code follows established conventions
- Pitfalls: HIGH — date type mismatch and `updated_at` issue found via direct schema inspection; Drift import conflict documented in STATE.md
- Test strategy: HIGH — mirrors verified working test patterns from codebase

**Research date:** 2026-05-28
**Valid until:** 2026-06-28 (fl_chart minor releases are frequent; re-check if > 30 days)

---

## Project Constraints (from CLAUDE.md)

- Never push directly to `main` — always create a feature branch and open a PR
- All implementation work for this phase must happen on a branch, not committed to main
