import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/metrics/domain/metric_delta.dart';

void main() {
  group('computeMetricDelta', () {
    LocalMetricLog makeLog(double value, DateTime loggedAt) {
      return LocalMetricLog(
        id: 'log-${value.toString().replaceAll('.', '_')}',
        studentId: 'student-1',
        metricType: 'weight',
        metricSubtype: null,
        value: value,
        unit: 'kg',
        loggedAt: loggedAt,
        createdAt: loggedAt,
      );
    }

    test('returns null for empty list', () {
      expect(computeMetricDelta([]), isNull);
    });

    test('returns null for single log', () {
      final logs = [makeLog(72.0, DateTime(2026, 5, 1))];
      expect(computeMetricDelta(logs), isNull);
    });

    test('returns negative delta for weight decrease', () {
      final logs = [
        makeLog(72.0, DateTime(2026, 5, 1)),
        makeLog(69.7, DateTime(2026, 5, 28)),
      ];
      expect(computeMetricDelta(logs), closeTo(-2.3, 0.01));
    });

    test('returns positive delta for flexibility increase', () {
      final logs = [
        makeLog(15.0, DateTime(2026, 5, 1)),
        makeLog(22.0, DateTime(2026, 5, 28)),
      ];
      expect(computeMetricDelta(logs), closeTo(7.0, 0.01));
    });

    test('returns 0.0 for no change', () {
      final logs = [
        makeLog(70.0, DateTime(2026, 5, 1)),
        makeLog(70.0, DateTime(2026, 5, 28)),
      ];
      expect(computeMetricDelta(logs), closeTo(0.0, 0.001));
    });
  });
}
