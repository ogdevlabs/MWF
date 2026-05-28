import 'package:mwf_mobile/core/database/app_database.dart';

/// Per-session download state derived from download_manifest entries.
///
/// Phase 5 implementation stub — full derivation logic in Plan 05-03.
///
/// - downloaded: all exercises for session have downloadStatus == 'complete'
/// - inProgress: at least one exercise has downloadStatus == 'in_progress'
/// - notDownloaded: no manifest entries exist for session exercises
enum SessionDownloadState {
  downloaded,
  inProgress,
  notDownloaded;

  /// Derive the download state for a session given its exercise IDs and
  /// the current manifest entries.
  ///
  /// Full implementation in Plan 05-03.
  static SessionDownloadState derive({
    required List<String> exerciseIds,
    required List<DownloadManifestData> manifests,
  }) {
    throw UnimplementedError('SessionDownloadState.derive — Plan 05-03');
  }
}
