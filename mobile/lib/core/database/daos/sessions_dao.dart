import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sessions_table.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [LocalSessions])
class SessionsDao extends DatabaseAccessor<AppDatabase> with _$SessionsDaoMixin {
  SessionsDao(super.attachedDatabase);

  Stream<List<LocalSession>> watchSessionsByProgram(String programId) =>
      (select(localSessions)
            ..where((t) => t.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm.asc(t.dayNumber)]))
          .watch();

  Future<List<LocalSession>> getSessionsByProgram(String programId) =>
      (select(localSessions)
            ..where((t) => t.programId.equals(programId))
            ..orderBy([(t) => OrderingTerm.asc(t.dayNumber)]))
          .get();

  Future<LocalSession?> getSessionById(String id) =>
      (select(localSessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertSession(LocalSessionsCompanion entry) =>
      into(localSessions).insertOnConflictUpdate(entry);

  Future<int> deleteSessionById(String id) =>
      (delete(localSessions)..where((t) => t.id.equals(id))).go();
}
