import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/session_download_state.dart';

export '../domain/session_download_state.dart' show SessionDownloadState;

part 'download_state_provider.g.dart';

/// Reactive provider that derives a session's [SessionDownloadState] by
/// watching the download_manifest table and joining against the session's
/// exercise IDs.
///
/// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
/// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
/// (vacuous every guard).
@riverpod
Stream<SessionDownloadState> sessionDownloadState(
  Ref ref, {
  required String sessionId,
}) async* {
  final db = ref.watch(appDatabaseProvider);
  final exercises = await db.exercisesDao.getExercisesBySession(sessionId);
  final exerciseIds = exercises.map((e) => e.id).toList();

  if (exerciseIds.isEmpty) {
    yield SessionDownloadState.notDownloaded;
    return;
  }

  yield* db.downloadManifestDao.watchAllEntries().map((entries) {
    return SessionDownloadState.derive(
      exerciseIds: exerciseIds,
      manifests: entries,
    );
  });
}
