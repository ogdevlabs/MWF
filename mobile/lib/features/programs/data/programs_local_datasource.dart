import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/program_model.dart';

part 'programs_local_datasource.g.dart';

/// Reads/writes local programs via Drift ProgramsDao.
///
/// Used to:
/// 1. Cache programs fetched from remote for offline availability
/// 2. Read cached programs when QueryGateway falls back to local
class ProgramsLocalDatasource {
  ProgramsLocalDatasource(this._db);
  final AppDatabase _db;

  /// Get all locally cached programs.
  Future<List<ProgramModel>> getCachedPrograms() async {
    final rows = await _db.programsDao.getAllPrograms();
    return rows
        .map((p) => ProgramModel(
              id: p.id,
              title: p.title,
              description: p.description,
              difficulty: p.difficulty,
              durationWeeks: p.durationWeeks,
              thumbnailUrl: p.thumbnailUrl,
              publishedAt: p.publishedAt,
              // Local fallback has no subscription/enrollment overlay
              enrollmentId: null,
              currentDay: 1,
              isSubscribed: false,
            ))
        .toList();
  }

  /// Cache a program locally for offline access.
  Future<void> cacheProgram(ProgramModel program) async {
    final now = DateTime.now();
    await _db.programsDao.upsertProgram(LocalProgramsCompanion(
      id: Value(program.id),
      title: Value(program.title),
      description: Value(program.description),
      difficulty: Value(program.difficulty),
      durationWeeks: Value(program.durationWeeks),
      thumbnailUrl: Value(program.thumbnailUrl),
      publishedAt: Value(program.publishedAt),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// Cache multiple programs.
  Future<void> cachePrograms(List<ProgramModel> programs) async {
    for (final program in programs) {
      await cacheProgram(program);
    }
  }

  /// Watch all cached programs as a stream (for reactive UI).
  Stream<List<ProgramModel>> watchCachedPrograms() {
    return _db.programsDao.watchAllPrograms().map((rows) => rows
        .map((p) => ProgramModel(
              id: p.id,
              title: p.title,
              description: p.description,
              difficulty: p.difficulty,
              durationWeeks: p.durationWeeks,
              thumbnailUrl: p.thumbnailUrl,
              publishedAt: p.publishedAt,
              enrollmentId: null,
              currentDay: 1,
              isSubscribed: false,
            ))
        .toList());
  }
}

@riverpod
ProgramsLocalDatasource programsLocalDatasource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProgramsLocalDatasource(db);
}
