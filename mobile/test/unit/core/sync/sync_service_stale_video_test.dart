import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/core/sync/sync_service.dart';

// ---------------------------------------------------------------------------
// Supabase chain mocks.
//
// _pullTable builds: supabase.from(t).select().gte('updated_at', since)
// then awaits the result. All variables are `dynamic` in the production code.
//
// Each table gets its own _MockQueryBuilder + _MockFilterBuilder pair so that
// the `then()` stubs are independent and don't interfere across tables.
// ---------------------------------------------------------------------------

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class _MockFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

/// Create an independent pair of query/filter mocks for one table.
void _stubTable(
  _MockSupabaseClient client,
  String table,
  List<Map<String, dynamic>> rows,
) {
  final qb = _MockQueryBuilder();
  final fb = _MockFilterBuilder();

  when(() => client.from(table)).thenAnswer((_) => qb);
  when(() => qb.select(any())).thenAnswer((_) => fb);
  when(() => fb.gte(any(), any())).thenAnswer((_) => fb);
  when(() => fb.eq(any(), any())).thenAnswer((_) => fb);

  // Stub then() so `await fb` resolves to rows.
  // Using dynamic coercion to avoid the typed Function mismatch.
  when<dynamic>(() => fb.then<dynamic>(any(), onError: any(named: 'onError')))
      .thenAnswer((inv) {
    final dynamic onValue = inv.positionalArguments[0];
    final dynamic onError = inv.namedArguments[const Symbol('onError')];
    // Cast future to dynamic so .then() accepts (dynamic)->dynamic callback.
    final dynamic future = Future<List<Map<String, dynamic>>>.value(rows);
    return (future as dynamic).then(onValue, onError: onError);
  });
}

/// Build a complete exercise row with all fields required by the upsert.
Map<String, dynamic> _exerciseRow({
  String id = 'ex-1',
  String sessionId = 'session-1',
  int videoVersion = 2,
}) =>
    {
      'id': id,
      'session_id': sessionId,
      'display_order': 1,
      'title': 'Test Exercise',
      'cue_text': null,
      'mux_asset_id': null,
      'mux_playback_id': null,
      'mux_download_url': null,
      'model_asset_url': null,
      'rep_count': 10,
      'duration_seconds': null,
      'video_version': videoVersion,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };

void main() {
  late AppDatabase db;
  late _MockSupabaseClient mockSupabase;
  late SyncService syncService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    mockSupabase = _MockSupabaseClient();

    // Default: all tables return empty rows (each has its own mock pair)
    _stubTable(mockSupabase, 'programs', []);
    _stubTable(mockSupabase, 'sessions', []);
    _stubTable(mockSupabase, 'exercises', []);
    _stubTable(mockSupabase, 'enrollments', []);
    _stubTable(mockSupabase, 'progress_records', []);
    _stubTable(mockSupabase, 'feedback_threads', []);

    final syncQueue = SyncQueue(db: db, supabase: mockSupabase);
    syncService = SyncService(
      db: db,
      supabase: mockSupabase,
      syncQueue: syncQueue,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Stale video detection', () {
    test('resets manifest to pending when remote video_version > local',
        () async {
      await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
        exerciseId: const Value('ex-1'),
        videoVersion: const Value(1),
        downloadStatus: const Value('complete'),
        videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
      ));

      // Remote returns video_version=2 (newer than local version 1)
      _stubTable(mockSupabase, 'exercises', [_exerciseRow(videoVersion: 2)]);

      await syncService.sync();

      final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
      expect(manifest!.downloadStatus, equals('pending'));
    });

    test('clears videoLocalPath when stale version detected', () async {
      await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
        exerciseId: const Value('ex-1'),
        videoVersion: const Value(1),
        downloadStatus: const Value('complete'),
        videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
      ));

      _stubTable(mockSupabase, 'exercises', [_exerciseRow(videoVersion: 2)]);

      await syncService.sync();

      final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
      expect(manifest!.videoLocalPath, isNull);
    });

    test('updates videoVersion to remote version', () async {
      await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
        exerciseId: const Value('ex-1'),
        videoVersion: const Value(1),
        downloadStatus: const Value('complete'),
        videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
      ));

      _stubTable(mockSupabase, 'exercises', [_exerciseRow(videoVersion: 2)]);

      await syncService.sync();

      final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
      expect(manifest!.videoVersion, equals(2));
    });

    test('does NOT reset manifest when remote version equals local', () async {
      await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
        exerciseId: const Value('ex-1'),
        videoVersion: const Value(1),
        downloadStatus: const Value('complete'),
        videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
      ));

      // Remote returns video_version=1 (same — no reset expected)
      _stubTable(mockSupabase, 'exercises', [_exerciseRow(videoVersion: 1)]);

      await syncService.sync();

      final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
      expect(manifest!.downloadStatus, equals('complete'));
      expect(manifest.videoLocalPath, equals('exercises/ex-1/ex-1_video.mp4'));
    });
  });
}
