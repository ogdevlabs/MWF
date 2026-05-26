import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/programs_table.dart';

part 'programs_dao.g.dart';

@DriftAccessor(tables: [LocalPrograms])
class ProgramsDao extends DatabaseAccessor<AppDatabase> with _$ProgramsDaoMixin {
  ProgramsDao(super.attachedDatabase);

  Stream<List<LocalProgram>> watchAllPrograms() =>
      select(localPrograms).watch();

  Future<List<LocalProgram>> getAllPrograms() =>
      select(localPrograms).get();

  Future<LocalProgram?> getProgramById(String id) =>
      (select(localPrograms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertProgram(LocalProgramsCompanion entry) =>
      into(localPrograms).insertOnConflictUpdate(entry);

  Future<int> deleteProgramById(String id) =>
      (delete(localPrograms)..where((t) => t.id.equals(id))).go();
}
