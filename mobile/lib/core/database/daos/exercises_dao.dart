import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/exercises_table.dart';

part 'exercises_dao.g.dart';

@DriftAccessor(tables: [LocalExercises])
class ExercisesDao extends DatabaseAccessor<AppDatabase> with _$ExercisesDaoMixin {
  ExercisesDao(super.attachedDatabase);

  Stream<List<LocalExercise>> watchExercisesBySession(String sessionId) =>
      (select(localExercises)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
          .watch();

  Future<List<LocalExercise>> getExercisesBySession(String sessionId) =>
      (select(localExercises)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
          .get();

  Future<LocalExercise?> getExerciseById(String id) =>
      (select(localExercises)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertExercise(LocalExercisesCompanion entry) =>
      into(localExercises).insertOnConflictUpdate(entry);

  Future<int> deleteExerciseById(String id) =>
      (delete(localExercises)..where((t) => t.id.equals(id))).go();

  /// Returns the number of exercises belonging to [sessionId].
  Future<int> getExerciseCountBySession(String sessionId) async {
    final countExpr = countAll();
    final query = selectOnly(localExercises)
      ..where(localExercises.sessionId.equals(sessionId))
      ..addColumns([countExpr]);
    final count = await query.map((row) => row.read(countExpr)).getSingle();
    return count ?? 0;
  }
}
