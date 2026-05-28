// Wave 0 test stub — tests document expected behavior for Plan 05-02.
// All tests are in a skip group so flutter test exits 0 without production code.
// Plan 05-02 will implement SyncService stale video detection and turn these green.
//
// Note: Supabase query chain mocking requires SupabaseQueryBuilder which has no
// public constructor. Skip is the correct Wave 0 approach; real integration tests
// use the existing _pullTable dynamic pattern in Plan 05-02.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/sync/sync_queue.dart';
import 'package:mwf_mobile/core/sync/sync_service.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late AppDatabase db;
  late _MockSupabaseClient mockSupabase;
  late SyncQueue syncQueue;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    mockSupabase = _MockSupabaseClient();
    syncQueue = SyncQueue(db: db, supabase: mockSupabase);
    syncService = SyncService(
      db: db,
      supabase: mockSupabase,
      syncQueue: syncQueue,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group(
    'Stale video detection',
    skip: 'Wave 0 stub — production code not yet created',
    () {
      /// Behavior (D-15, D-16): when _pullRemoteChanges() pulls an exercise row
      /// where remote video_version > manifest videoVersion, the manifest entry
      /// should be reset to downloadStatus='pending' and videoLocalPath=null.
      ///
      /// Implementation: Plan 05-02 extends SyncService._pullRemoteChanges()
      /// to compare exercise.video_version against manifest.videoVersion.
      test('resets manifest to pending when remote video_version > local',
          () async {
        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-1'),
          videoVersion: const Value(1),
          downloadStatus: const Value('complete'),
          videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
        ));

        // Plan 05-02: stub Supabase to return exercise with video_version=2
        await syncService.sync();

        final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
        expect(manifest!.downloadStatus, equals('pending'));
      });

      test('clears videoLocalPath with Value(null) not Value.absent()', () async {
        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-1'),
          videoVersion: const Value(1),
          downloadStatus: const Value('complete'),
          videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
        ));

        await syncService.sync();

        final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
        // Must use Value(null) explicitly to clear — Value.absent() is a no-op
        expect(manifest!.videoLocalPath, isNull);
      });

      test('updates videoVersion to remote version', () async {
        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-1'),
          videoVersion: const Value(1),
          downloadStatus: const Value('complete'),
          videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
        ));

        await syncService.sync();

        final manifest = await db.downloadManifestDao.getByExerciseId('ex-1');
        expect(manifest!.videoVersion, equals(2));
      });
    },
  );
}
