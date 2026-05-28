// Wave 0 test stub — tests document expected behavior for Plan 05-02.
// All tests are in a skip group so flutter test exits 0 without production code.
// ignore_for_file: unused_import, unused_local_variable
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
      test('resets manifest to pending when remote video_version > local',
          () async {
        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-1'),
          videoVersion: const Value(1),
          downloadStatus: const Value('complete'),
          videoLocalPath: const Value('exercises/ex-1/ex-1_video.mp4'),
        ));

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
