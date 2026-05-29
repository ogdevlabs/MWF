import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/database/app_database.dart';
import '../../session/data/streak_calculator.dart';
import '../data/metrics_repository.dart';
import '../domain/metric_log_model.dart';
import 'log_metric_sheet.dart';

/// Progress dashboard screen (FR-009).
///
/// Shows:
/// 1. Streak card (current streak + longest streak)
/// 2. Metric type selector (Weight / Measurements / Flexibility)
/// 3. fl_chart line chart of selected metric trend over time
/// 4. Delta badge: change from first entry to latest
/// 5. FAB -> LogMetricSheet
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _selectedType = 'weight';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final studentId = user.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openLogSheet(context, studentId),
        tooltip: 'Log Metrics',
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StreakCard(studentId: studentId),
            const SizedBox(height: 24),
            Text('Metric Trends', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            // Metric type selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'weight', label: Text('Weight')),
                ButtonSegment(
                    value: 'measurement', label: Text('Measurement')),
                ButtonSegment(
                    value: 'flexibility', label: Text('Flexibility')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) =>
                  setState(() => _selectedType = set.first),
            ),
            const SizedBox(height: 16),
            _MetricChart(studentId: studentId, metricType: _selectedType),
          ],
        ),
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

/// Streak card showing current streak and longest streak.
class _StreakCard extends ConsumerWidget {
  const _StreakCard({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final theme = Theme.of(context);

    return FutureBuilder<({int current, int longest})>(
      future: _computeStreaks(db, studentId),
      builder: (context, snapshot) {
        final current = snapshot.data?.current ?? 0;
        final longest = snapshot.data?.longest ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStreakStat(
                    theme, current, 'Current Streak', Icons.local_fire_department),
                const VerticalDivider(),
                _buildStreakStat(
                    theme, longest, 'Longest Streak', Icons.emoji_events),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<({int current, int longest})> _computeStreaks(
      AppDatabase db, String studentId) async {
    final records = await db.progressDao.getProgressByStudent(studentId);
    final dates = records.map((r) => r.completedAt).toList();
    return (
      current: computeCurrentStreak(dates),
      longest: computeLongestStreak(dates),
    );
  }

  Widget _buildStreakStat(
      ThemeData theme, int value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 4),
            Text(
              '$value day${value == 1 ? '' : 's'}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Line chart for a specific metric type using fl_chart (FR-009).
class _MetricChart extends ConsumerWidget {
  const _MetricChart({required this.studentId, required this.metricType});
  final String studentId;
  final String metricType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(
      metricLogsStreamProvider(studentId, metricType),
    );

    return metricsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => const SizedBox(
        height: 200,
        child: Center(child: Text('Unable to load metrics')),
      ),
      data: (metrics) {
        if (metrics.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart,
                      size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 8),
                  Text(
                    'No ${_typeLabel(metricType)} entries yet.\nTap + to log your first metric.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DeltaBadge(metrics: metrics),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: _buildChart(metrics, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(List<MetricLog> metrics, ThemeData theme) {
    final first = metrics.first.loggedAt;
    final spots = metrics.asMap().entries.map((e) {
      final dayOffset =
          e.value.loggedAt.difference(first).inDays.toDouble();
      return FlSpot(dayOffset, e.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                'D${value.toInt()}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withAlpha(30),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'weight' => 'weight',
        'measurement' => 'measurement',
        'flexibility' => 'flexibility',
        _ => type,
      };
}

/// Delta badge showing change from first to latest metric entry.
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.metrics});
  final List<MetricLog> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.length < 2) return const SizedBox.shrink();

    final first = metrics.first.value;
    final latest = metrics.last.value;
    final delta = latest - first;
    final unit = metrics.first.unit;
    final isPositive = delta >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        '$sign${delta.toStringAsFixed(1)} $unit since start',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
