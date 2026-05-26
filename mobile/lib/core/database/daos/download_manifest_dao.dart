import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/download_manifest_table.dart';

part 'download_manifest_dao.g.dart';

@DriftAccessor(tables: [DownloadManifest])
class DownloadManifestDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadManifestDaoMixin {
  DownloadManifestDao(super.attachedDatabase);

  Future<void> upsertEntry(DownloadManifestCompanion entry) =>
      into(downloadManifest).insertOnConflictUpdate(entry);

  Future<DownloadManifestData?> getByExerciseId(String exerciseId) =>
      (select(downloadManifest)
            ..where((t) => t.exerciseId.equals(exerciseId)))
          .getSingleOrNull();

  Future<List<DownloadManifestData>> getPendingDownloads() =>
      (select(downloadManifest)
            ..where((t) => t.downloadStatus.equals('pending')))
          .get();

  Future<List<DownloadManifestData>> getCompletedDownloads() =>
      (select(downloadManifest)
            ..where((t) => t.downloadStatus.equals('complete')))
          .get();

  Stream<List<DownloadManifestData>> watchAllEntries() =>
      select(downloadManifest).watch();

  Future<void> updateStatus(String exerciseId, String status) =>
      (update(downloadManifest)
            ..where((t) => t.exerciseId.equals(exerciseId)))
          .write(DownloadManifestCompanion(downloadStatus: Value(status)));
}
