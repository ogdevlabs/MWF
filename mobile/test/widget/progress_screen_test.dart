import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/metrics/data/metric_providers.dart';
import 'package:mwf_mobile/features/metrics/presentation/progress_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ProgressScreen', () {
    Widget _buildSubject() {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: ProgressScreen(),
        ),
      );
    }

    testWidgets('shows empty state message when no metric logs exist',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            // Override all metric tabs to return empty lists
            metricLogsByTypeProvider('weight')
                .overrideWith((ref) => Stream.value(<LocalMetricLog>[])),
            metricLogsByTypeProvider('measurement')
                .overrideWith((ref) => Stream.value(<LocalMetricLog>[])),
            metricLogsByTypeProvider('flexibility')
                .overrideWith((ref) => Stream.value(<LocalMetricLog>[])),
          ],
          child: const MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('No data yet'), findsWidgets);
    });

    testWidgets('shows streak card section', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
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
