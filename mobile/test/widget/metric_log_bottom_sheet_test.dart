import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/metrics/presentation/log_metric_sheet.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('LogMetricSheet', () {
    Widget _buildSubject() {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LogMetricSheet(studentId: 'test-student'),
          ),
        ),
      );
    }

    testWidgets('renders metric type selector', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      // Should have at least one chip or button for 'Weight'
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('renders value text field', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Save button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
