import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/features/session/domain/session_download_state.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group(
    'SessionDownloadState derivation',
    skip: 'Wave 0 stub — production code not yet created',
    () {
      test('returns downloaded when all exercises have complete manifest',
          () async {
        // Seed two exercises for a session
        final exerciseIds = ['ex-a', 'ex-b'];

        for (final id in exerciseIds) {
          await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
            exerciseId: Value(id),
            videoVersion: const Value(1),
            downloadStatus: const Value('complete'),
          ));
        }

        final manifests = await db.downloadManifestDao.getPendingDownloads();
        // None should be pending — all are complete
        expect(manifests, isEmpty);

        final allManifests = await db.downloadManifestDao.getCompletedDownloads();
        final state = SessionDownloadState.derive(
          exerciseIds: exerciseIds,
          manifests: allManifests,
        );
        expect(state, SessionDownloadState.downloaded);
      });

      test('returns inProgress when any exercise has in_progress manifest',
          () async {
        const exerciseIds = ['ex-a', 'ex-b'];

        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-a'),
          videoVersion: const Value(1),
          downloadStatus: const Value('complete'),
        ));
        await db.downloadManifestDao.upsertEntry(DownloadManifestCompanion(
          exerciseId: const Value('ex-b'),
          videoVersion: const Value(1),
          downloadStatus: const Value('in_progress'),
        ));

        final allManifests = await db.downloadManifestDao.getCompletedDownloads();
        final inProgressManifests =
            await db.downloadManifestDao.getPendingDownloads();
        final combined = [...allManifests, ...inProgressManifests];

        final state = SessionDownloadState.derive(
          exerciseIds: exerciseIds,
          manifests: combined,
        );
        expect(state, SessionDownloadState.inProgress);
      });

      test(
          'returns notDownloaded when no manifest entries exist for session exercises',
          () async {
        const exerciseIds = ['ex-a', 'ex-b'];

        // No manifest entries seeded
        final state = SessionDownloadState.derive(
          exerciseIds: exerciseIds,
          manifests: [],
        );
        expect(state, SessionDownloadState.notDownloaded);
      });

      test(
          'returns notDownloaded when relevant entries list is empty (vacuous every guard)',
          () {
        // Empty exerciseIds: vacuous-all guard means no progress recorded
        final state = SessionDownloadState.derive(
          exerciseIds: [],
          manifests: [],
        );
        expect(state, SessionDownloadState.notDownloaded);
      });
    },
  );
}
