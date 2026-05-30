import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/session/data/session_datasource.dart';
import 'package:mwf_mobile/features/session/domain/session_model.dart';
import 'package:mwf_mobile/features/session/presentation/session_player_screen.dart';

class _FakeDatasource extends Fake implements SessionDatasource {
  final List<ExerciseModel> exercises;
  _FakeDatasource(this.exercises);

  @override
  Future<List<ExerciseModel>> getExercisesBySession(String sessionId) async =>
      exercises;

  @override
  Future<List<SessionModel>> getSessionsWithState({
    required String programId,
    required int currentDay,
  }) async =>
      [];
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // Rep-based exercise so Next starts disabled (counter overlay shows)
  const repExercise = ExerciseModel(
    id: 'ex-1',
    sessionId: 'sess-1',
    displayOrder: 1,
    title: 'Test Exercise',
    cueText: 'Keep your core tight.',
    repCount: 10,
    durationSeconds: null,
    muxPlaybackId: null,
    localVideoPath: null,
    modelAssetUrl: null,
    localModelPath: null,
  );

  Widget buildSubject(AppDatabase database) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        sessionDatasourceProvider.overrideWithValue(
          _FakeDatasource([repExercise]),
        ),
      ],
      child: MaterialApp(
        home: const SessionPlayerScreen(
          programId: 'prog-1',
          sessionId: 'sess-1',
        ),
      ),
    );
  }

  group('SessionPlayerScreen widget', () {
    testWidgets('session player video area has accessibility label',
        (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(db));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.bySemanticsLabel(RegExp(r'Exercise video')),
        findsAtLeastNWidgets(1),
      );
      semanticsHandle.dispose();
    });

    testWidgets('screen builds and loads without crashing', (tester) async {
      await tester.pumpWidget(buildSubject(db));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(SessionPlayerScreen), findsOneWidget);
    });

    testWidgets('Next button is present after exercises load', (tester) async {
      await tester.pumpWidget(buildSubject(db));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data == 'Next Exercise' || w.data == 'Finish Session'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('cue text is displayed when present', (tester) async {
      await tester.pumpWidget(buildSubject(db));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Keep your core tight.'), findsOneWidget);
    });
  });
}
