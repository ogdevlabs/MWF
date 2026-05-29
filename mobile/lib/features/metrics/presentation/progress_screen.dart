import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/database/app_database.dart';
import '../../session/data/streak_calculator.dart';
import '../data/metric_providers.dart';
import '../domain/metric_delta.dart';
import 'log_metric_sheet.dart';
import 'metric_line_chart.dart';
import 'widgets/delta_badge.dart';
import 'widgets/streak_card.dart';

/// Progress dashboard screen (FR-009).
///
/// Layout per D-05:
/// 1. StreakCard (current + longest streak)
/// 2. "Log Metrics" FilledButton.tonal
/// 3. TabBar (Weight / Measurements / Flexibility)
/// 4. TabBarView with chart area + delta badge, or empty state
///
/// Uses ConsumerStatefulWidget + SingleTickerProviderStateMixin to avoid
/// TabController reset on stream rebuilds (Pitfall 4).
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Metric type strings matching Supabase schema CHECK constraint (D-13).
  /// Note: 'measurement' is singular per DB schema; tab label is 'Measurements'.
  static const _metricTypes = ['weight', 'measurement', 'flexibility'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final studentId = user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weight'),
            Tab(text: 'Measurements'),
            Tab(text: 'Flexibility'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StreakSection(studentId: studentId),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _openLogSheet(context, studentId),
                  child: const Text('Log Metrics'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _metricTypes.map((metricType) {
                return _MetricTabContent(
                  metricType: metricType,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openLogSheet(BuildContext context, String studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LogMetricSheet(studentId: studentId),
    );
  }
}

/// Streak section watching progressDao stream and computing both streaks.
class _StreakSection extends ConsumerWidget {
  const _StreakSection({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (studentId.isEmpty) {
      return const StreakCard(currentStreak: 0, longestStreak: 0);
    }
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<({int current, int longest})>(
      stream: _streakStream(db),
      initialData: const (current: 0, longest: 0),
      builder: (context, snapshot) {
        final data = snapshot.data ?? const (current: 0, longest: 0);
        return StreakCard(
          currentStreak: data.current,
          longestStreak: data.longest,
        );
      },
    );
  }

  Stream<({int current, int longest})> _streakStream(AppDatabase db) =>
      db.progressDao.watchProgressByStudent(studentId).map((records) {
        final dates = records.map((r) => r.completedAt).toList();
        return (
          current: computeCurrentStreak(dates),
          longest: computeLongestStreak(dates),
        );
      });
}

/// Tab content for a single metric type. Shows chart + delta, or empty state.
/// For 'measurement' and 'flexibility' types, adds a subtype chip selector (D-11, D-12).
class _MetricTabContent extends ConsumerStatefulWidget {
  const _MetricTabContent({required this.metricType});
  final String metricType;

  @override
  ConsumerState<_MetricTabContent> createState() => _MetricTabContentState();
}

class _MetricTabContentState extends ConsumerState<_MetricTabContent>
    with AutomaticKeepAliveClientMixin {
  String? _selectedSubtype;

  /// Subtypes per D-11 (measurements) and D-12 (flexibility).
  static const _measurementSubtypes = ['waist', 'hip', 'chest', 'thigh', 'arm'];
  static const _flexibilitySubtypes = ['forward_bend', 'shoulder', 'hip_flexor'];

  @override
  bool get wantKeepAlive => true;

  List<String>? get _subtypes => switch (widget.metricType) {
        'measurement' => _measurementSubtypes,
        'flexibility' => _flexibilitySubtypes,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final logsAsync =
        ref.watch(metricLogsByTypeProvider(widget.metricType));

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const Center(child: Text('Unable to load metrics')),
      data: (allLogs) {
        // Filter by subtype when applicable (D-11, D-12).
        final logs = _selectedSubtype != null
            ? allLogs
                .where((l) => l.metricSubtype == _selectedSubtype)
                .toList()
            : (_subtypes != null ? <LocalMetricLog>[] : allLogs);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtype chip row for measurement/flexibility (D-11, D-12)
              if (_subtypes != null) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _subtypes!.map((sub) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                              '${sub[0].toUpperCase()}${sub.substring(1).replaceAll('_', ' ')}'),
                          selected: _selectedSubtype == sub,
                          onSelected: (selected) => setState(() {
                            _selectedSubtype = selected ? sub : null;
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Empty state (D-06)
              if (logs.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No data yet',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Log your first entry!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Delta badge (D-09)
                _buildDeltaBadge(logs),
                const SizedBox(height: 12),
                // fl_chart line chart (D-08)
                SizedBox(
                  height: 250,
                  child: MetricLineChart(logs: logs),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeltaBadge(List<LocalMetricLog> logs) {
    final delta = computeMetricDelta(logs);
    if (delta == null) return const SizedBox.shrink();
    final unit = logs.first.unit;
    return DeltaBadge(
      delta: delta,
      unit: unit,
      metricType: widget.metricType,
    );
  }
}
