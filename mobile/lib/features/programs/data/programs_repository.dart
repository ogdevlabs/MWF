import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/cqrs/command_bus.dart';
import '../../../core/database/app_database.dart';
import '../../../core/downloads/download_service.dart';
import '../domain/program_model.dart';
import 'programs_local_datasource.dart';
import 'programs_remote_datasource.dart';

part 'programs_repository.g.dart';

const _kSubscriptionIsActiveKey = 'subscription_is_active';

/// Repository that merges remote program catalog with local cache.
///
/// Read flow:
/// 1. Fetch from remote (via QueryGateway -> program_catalog_view)
/// 2. Cache results locally for offline
/// 3. If remote unavailable, serve cached + overlay local subscription status
///
/// Write flow (enrollment):
/// 1. Write to local Drift immediately (optimistic)
/// 2. Enqueue to CommandBus for Supabase sync
class ProgramsRepository {
  ProgramsRepository({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.commandBus,
    required this.db,
    required this.downloadService,
  });

  final ProgramsRemoteDatasource remoteDatasource;
  final ProgramsLocalDatasource localDatasource;
  final CommandBus commandBus;
  final AppDatabase db;
  final DownloadService downloadService;

  /// Get all published programs with subscription/enrollment overlay.
  ///
  /// Remote-first with local cache fallback.
  /// When offline, overlays cached subscription status from SharedPreferences.
  Future<List<ProgramModel>> getPrograms() async {
    try {
      final programs = await remoteDatasource.getPrograms();
      // Cache for offline
      await localDatasource.cachePrograms(programs);
      return programs;
    } catch (_) {
      // Remote failed — serve cached programs with local subscription overlay
      final cached = await localDatasource.getCachedPrograms();
      final isSubActive = await _getCachedSubscriptionStatus();
      return cached
          .map((p) => p.copyWith(isSubscribed: isSubActive))
          .toList();
    }
  }

  /// Get a single program by ID.
  Future<ProgramModel?> getProgramById(String programId) async {
    final programs = await getPrograms();
    return programs.where((p) => p.id == programId).firstOrNull;
  }

  /// Enroll student in a program.
  ///
  /// 1. Write to local Drift immediately (optimistic UI)
  /// 2. Enqueue for Supabase sync via CommandBus
  Future<void> enrollStudent({
    required String studentId,
    required String programId,
  }) async {
    final enrollmentId = const Uuid().v4();
    final now = DateTime.now();

    // 1. Write to local Drift immediately
    await db.enrollmentsDao.upsertEnrollment(LocalEnrollmentsCompanion(
      id: Value(enrollmentId),
      studentId: Value(studentId),
      programId: Value(programId),
      enrolledAt: Value(now),
      currentDay: const Value(1),
    ));

    // 2. Enqueue for Supabase sync via CommandBus
    await commandBus.dispatch(
      CommandType.enrollProgram,
      {
        'id': enrollmentId,
        'student_id': studentId,
        'program_id': programId,
        'enrolled_at': now.toIso8601String(),
        'current_day': 1,
      },
    );

    // D-01: Auto-enqueue downloads for all exercises in enrolled program
    final sessions = await db.sessionsDao.getSessionsByProgram(programId);
    for (final session in sessions) {
      final exercises = await db.exercisesDao.getExercisesBySession(session.id);
      for (final exercise in exercises) {
        await downloadService.downloadExerciseMedia(
          exerciseId: exercise.id,
          videoUrl: exercise.muxDownloadUrl,
          modelUrl: exercise.modelAssetUrl,
          videoVersion: exercise.videoVersion,
        );
      }
    }
  }

  /// Check if student is enrolled in a specific program (local check).
  Future<bool> isEnrolled({
    required String studentId,
    required String programId,
  }) async {
    final enrollment = await db.enrollmentsDao.getEnrollment(
      studentId: studentId,
      programId: programId,
    );
    return enrollment != null;
  }

  Future<bool> _getCachedSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSubscriptionIsActiveKey) ?? false;
  }
}

@riverpod
ProgramsRepository programsRepository(Ref ref) {
  final remote = ref.watch(programsRemoteDatasourceProvider);
  final local = ref.watch(programsLocalDatasourceProvider);
  final cmdBus = ref.watch(commandBusProvider);
  final db = ref.watch(appDatabaseProvider);
  final dlService = ref.watch(downloadServiceProvider);
  return ProgramsRepository(
    remoteDatasource: remote,
    localDatasource: local,
    commandBus: cmdBus,
    db: db,
    downloadService: dlService,
  );
}

/// Provides the list of programs for UI consumption.
/// Auto-refreshes when dependencies change.
@riverpod
Future<List<ProgramModel>> programsList(Ref ref) async {
  final repo = ref.watch(programsRepositoryProvider);
  return repo.getPrograms();
}
