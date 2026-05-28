import '../../../core/database/app_database.dart';

/// Download state for a session, derived from the download_manifest table
/// entries for all exercises belonging to that session.
///
/// Rules (per D-07, D-10, D-12):
/// - All exercises have 'complete' manifest entries  => downloaded
/// - Any exercise has 'in_progress' manifest entry   => inProgress
/// - No or incomplete manifest entries               => notDownloaded
/// - Empty exerciseIds (vacuous guard)               => notDownloaded
enum SessionDownloadState {
  notDownloaded,
  inProgress,
  downloaded;

  /// Derives the download state for a session from a list of manifest entries.
  ///
  /// [exerciseIds] — the IDs of exercises belonging to the session.
  /// [manifests]   — all rows from the download_manifest table (or a filtered
  ///                  subset); unrelated entries are ignored.
  ///
  /// Per Pitfall 3: returns [notDownloaded] when [relevant.isEmpty] so that
  /// the vacuous-all guard never falsely reports [downloaded].
  static SessionDownloadState derive({
    required List<String> exerciseIds,
    required List<DownloadManifestData> manifests,
  }) {
    if (exerciseIds.isEmpty) return SessionDownloadState.notDownloaded;

    final exerciseIdSet = exerciseIds.toSet();
    final relevant =
        manifests.where((m) => exerciseIdSet.contains(m.exerciseId)).toList();

    // Vacuous guard: no manifest entries = not downloaded yet
    if (relevant.isEmpty) return SessionDownloadState.notDownloaded;

    // Any in_progress = overall in progress
    if (relevant.any((m) => m.downloadStatus == 'in_progress')) {
      return SessionDownloadState.inProgress;
    }

    // All exercises fully downloaded
    if (relevant.length == exerciseIds.length &&
        relevant.every((m) => m.downloadStatus == 'complete')) {
      return SessionDownloadState.downloaded;
    }

    // Partial / pending / failed
    return SessionDownloadState.notDownloaded;
  }
}
