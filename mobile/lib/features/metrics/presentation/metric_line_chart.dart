import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mwf_mobile/core/database/app_database.dart';

/// Renders a line chart from metric log entries using fl_chart.
/// Per D-08: dots at each data point, smooth line, colorScheme.primary,
/// no grid lines, minimal axis labels.
class MetricLineChart extends StatelessWidget {
  const MetricLineChart({super.key, required this.logs});

  final List<LocalMetricLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = logsToSpots(logs);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: theme.colorScheme.primary,
            isCurved: true,
            barWidth: 2.5,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final dt =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${dt.month}/${dt.day}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false), // D-08: no grid lines
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots
                .map(
                  (s) => LineTooltipItem(
                    s.y.toStringAsFixed(1),
                    TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Pure function: converts LocalMetricLog list to FlSpot list.
  /// Extracted for testability (can unit test without rendering).
  /// Per D-07: if multiple entries on same date, use latest (last in asc list).
  static List<FlSpot> logsToSpots(List<LocalMetricLog> logs) {
    // logs are ordered by loggedAt asc from DAO
    // D-07: latest value per date
    final byDate = <String, LocalMetricLog>{};
    for (final log in logs) {
      final key =
          '${log.loggedAt.year}-${log.loggedAt.month}-${log.loggedAt.day}';
      byDate[key] = log; // last write wins = latest for that date
    }
    final deduped = byDate.values.toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    return deduped
        .map((e) => FlSpot(
              e.loggedAt.millisecondsSinceEpoch.toDouble(),
              e.value,
            ))
        .toList();
  }
}
