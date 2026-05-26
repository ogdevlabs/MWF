import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';

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

  test('database opens with all tables accessible', () async {
    // Verify all DAOs are accessible
    expect(db.programsDao, isNotNull);
    expect(db.sessionsDao, isNotNull);
    expect(db.exercisesDao, isNotNull);
    expect(db.progressDao, isNotNull);
    expect(db.metricLogsDao, isNotNull);
    expect(db.feedbackDao, isNotNull);
    expect(db.syncQueueDao, isNotNull);
    expect(db.downloadManifestDao, isNotNull);
  });

  test('sync_queue enqueue and retrieve', () async {
    await db.syncQueueDao.enqueue(
      SyncQueueCompanion(
        operation: const Value('insert'),
        targetTable: const Value('progress_records'),
        payload: const Value('{"id":"test-uuid","student_id":"student-1"}'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 1);
    expect(items.first.operation, 'insert');
    expect(items.first.targetTable, 'progress_records');
  });

  test('sync_queue respects retry limit', () async {
    await db.syncQueueDao.enqueue(
      SyncQueueCompanion(
        operation: const Value('insert'),
        targetTable: const Value('progress_records'),
        payload: const Value('{"id":"fail-uuid"}'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        retryCount: const Value(5),
      ),
    );

    final items = await db.syncQueueDao.getPendingItems();
    expect(items.length, 0); // Should not return items at retry limit
  });

  test('download_manifest upsert and query', () async {
    await db.downloadManifestDao.upsertEntry(
      DownloadManifestCompanion(
        exerciseId: const Value('ex-1'),
        videoVersion: const Value(1),
        downloadStatus: const Value('pending'),
      ),
    );

    final pending = await db.downloadManifestDao.getPendingDownloads();
    expect(pending.length, 1);
    expect(pending.first.exerciseId, 'ex-1');

    // Update status
    await db.downloadManifestDao.updateStatus('ex-1', 'complete');
    final pendingAfter = await db.downloadManifestDao.getPendingDownloads();
    expect(pendingAfter.length, 0);
  });
}
