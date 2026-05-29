import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/database/app_database.dart';

part 'metric_log_model.freezed.dart';
part 'metric_log_model.g.dart';

/// Domain model for a body metric log entry (FR-008).
///
/// Maps from the local_metric_logs Drift table.
/// metricType: 'weight' | 'measurement' | 'flexibility'
/// unit: 'kg' | 'cm' | 'degrees'
@freezed
abstract class MetricLog with _$MetricLog {
  const factory MetricLog({
    required String id,
    required String studentId,
    required String metricType,
    String? metricSubtype,
    required double value,
    required String unit,
    required DateTime loggedAt,
    required DateTime createdAt,
  }) = _MetricLog;

  factory MetricLog.fromJson(Map<String, dynamic> json) =>
      _$MetricLogFromJson(json);

  /// Construct from a Drift [LocalMetricLog] row.
  factory MetricLog.fromDrift(LocalMetricLog row) => MetricLog(
        id: row.id,
        studentId: row.studentId,
        metricType: row.metricType,
        metricSubtype: row.metricSubtype,
        value: row.value,
        unit: row.unit,
        loggedAt: row.loggedAt,
        createdAt: row.createdAt,
      );
}

/// Convenience helpers for metric type display.
extension MetricLogDisplay on MetricLog {
  /// Human-readable label for this metric type.
  String get typeLabel => switch (metricType) {
        'weight' => 'Weight',
        'measurement' => metricSubtype?.capitalize() ?? 'Measurement',
        'flexibility' => 'Flexibility',
        _ => metricType,
      };
}

extension _StringCapitalize on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
