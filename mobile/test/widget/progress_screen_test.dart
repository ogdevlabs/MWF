import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/features/metrics/presentation/progress_screen.dart';
import 'package:mwf_mobile/features/metrics/data/metric_providers.dart';
import 'package:mwf_mobile/core/database/app_database.dart';

void main() {
  group('ProgressScreen', () {
    Widget _buildSubject({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: ProgressScreen(),
        ),
      );
    }

    testWidgets('shows empty state message when no metric logs exist',
        (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          overrides: [
            metricLogsByTypeProvider('weight').overrideWith(
              (ref, arg) => Stream.value(<LocalMetricLog>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No data yet'), findsWidgets);
    });

    testWidgets('shows streak card section', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      // Streak card header should be visible
      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('shows tab bar with Weight, Measurements, Flexibility tabs',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Measurements'), findsOneWidget);
      expect(find.text('Flexibility'), findsOneWidget);
    });

    testWidgets('shows Log Metrics button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      expect(find.text('Log Metrics'), findsOneWidget);
    });
  });
}
