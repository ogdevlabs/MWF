import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mwf_mobile/features/programs/data/programs_repository.dart';
import 'package:mwf_mobile/features/programs/presentation/program_detail_screen.dart';

void main() {
  testWidgets('shows error and retry on network failure', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          programsListProvider.overrideWith(
            (ref) async => throw Exception('Network error'),
          ),
        ],
        child: const MaterialApp(
          home: ProgramDetailScreen(programId: 'prog-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsAtLeastNWidgets(1));
    expect(find.text('Retry'), findsAtLeastNWidgets(1));
  });
}
