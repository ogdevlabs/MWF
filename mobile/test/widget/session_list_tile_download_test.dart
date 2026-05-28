import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/features/session/domain/session_download_state.dart';
import 'package:mwf_mobile/features/session/domain/session_model.dart';
import 'package:mwf_mobile/features/session/presentation/session_list_tile.dart';

/// Minimal test session used across widget tests.
const _testSession = SessionModel(
  id: 'sess-1',
  programId: 'prog-1',
  dayNumber: 1,
  title: 'Test Session',
  exerciseCount: 5,
  state: SessionState.current,
);

void main() {
  group('SessionListTile download state', () {
    testWidgets(
        'shows download_outlined icon when downloadState is notDownloaded',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.notDownloaded,
              isOnline: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('shows circular progress when downloadState is inProgress',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.inProgress,
              isOnline: true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows check icon when downloadState is downloaded',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.downloaded,
              isOnline: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.download_done), findsOneWidget);
    });

    testWidgets(
        'shows Not available offline text when offline and not downloaded',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.notDownloaded,
              isOnline: false,
            ),
          ),
        ),
      );
      expect(find.text('Not available offline'), findsOneWidget);
    });

    testWidgets('tile onTap is null when offline and not downloaded',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.notDownloaded,
              isOnline: false,
            ),
          ),
        ),
      );
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.onTap, isNull);
    });

    testWidgets('tile onTap is active when online and not downloaded',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionListTile(
              session: _testSession,
              downloadState: SessionDownloadState.notDownloaded,
              isOnline: true,
              onTap: () {},
            ),
          ),
        ),
      );
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.onTap, isNotNull);
    });
  });
}
