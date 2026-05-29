import 'package:flutter/material.dart';

/// Shows net change from first recorded entry to latest.
/// Per D-09:
///   - Weight: negative = green (weight loss = improving), positive = gray
///   - Flexibility: positive = green (more range = improving), negative = gray
///   - Measurements: show absolute value + arrow, neutral gray (no judgment)
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({
    super.key,
    required this.delta,
    required this.unit,
    required this.metricType,
  });

  final double delta;
  final String unit;
  final String metricType; // 'weight', 'measurement', 'flexibility'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImproving = _isImproving();
    final color = metricType == 'measurement'
        ? theme.colorScheme.onSurfaceVariant // neutral for measurements per D-09
        : (isImproving
            ? Colors.green.shade700
            : theme.colorScheme.onSurfaceVariant);
    final arrow = delta > 0 ? '↑' : (delta < 0 ? '↓' : '↔');
    final sign = delta > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$arrow $sign${delta.toStringAsFixed(1)} $unit since start',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _isImproving() {
    switch (metricType) {
      case 'weight':
        return delta < 0; // losing weight = improving
      case 'flexibility':
        return delta > 0; // more range = improving
      default:
        return false; // measurements: no judgment
    }
  }
}
