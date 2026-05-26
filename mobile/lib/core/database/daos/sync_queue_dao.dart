import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.attachedDatabase);

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  /// Returns pending items ordered by creation time.
  /// Only items with retry_count < 5 are returned.
  Future<List<SyncQueueData>> getPendingItems() =>
      (select(syncQueue)
            ..where((t) => t.retryCount.isSmallerThanValue(5))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> deleteById(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> incrementRetry(int id, String error) async {
    final item =
        await (select(syncQueue)..where((t) => t.id.equals(id))).getSingle();
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(item.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<int> pendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..where(syncQueue.retryCount.isSmallerThanValue(5))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
