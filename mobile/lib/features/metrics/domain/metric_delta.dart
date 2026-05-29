import 'package:mwf_mobile/core/database/app_database.dart';

/// Computes the net change from first recorded metric log to the latest.
/// Returns null if fewer than 2 entries (no delta possible).
/// Logs MUST be ordered by loggedAt ascending (DAO provides this ordering).
double? computeMetricDelta(List<LocalMetricLog> logs) {
  if (logs.length < 2) return null;
  return logs.last.value - logs.first.value;
}
