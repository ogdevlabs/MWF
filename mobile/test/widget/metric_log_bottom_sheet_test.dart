import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/features/metrics/presentation/metric_log_bottom_sheet.dart';

void main() {
  group('MetricLogBottomSheet', () {
    Widget _buildSubject({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: Scaffold(
            body: MetricLogBottomSheet(),
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
