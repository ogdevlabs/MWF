import 'package:path_provider/path_provider.dart';

/// Best-effort free-space check (D-13, D-14).
/// Fail-open: returns true if the platform check fails or is unavailable.
/// Injectable [freeSpaceProvider] allows unit testing without platform channels.
class StorageGuard {
  /// Returns true if free space >= [thresholdBytes].
  /// Default threshold: 500 MB (500 * 1024 * 1024 = 524288000).
  /// If [freeSpaceProvider] is null, uses platform default (fail-open stub in Phase 5).
  static Future<bool> hasEnoughSpace({
    int thresholdBytes = 524288000,
    Future<int?> Function()? freeSpaceProvider,
  }) async {
    try {
      if (freeSpaceProvider != null) {
        final freeSpace = await freeSpaceProvider();
        if (freeSpace == null) return true; // null = unknown = fail-open
        return freeSpace >= thresholdBytes;
      }
      // Production path: fail-open stub until Phase 9 adds real platform check
      // ignore: unused_local_variable
      final dir = await getApplicationDocumentsDirectory();
      return true; // fail-open — dart:io FileStat doesn't expose free space
    } catch (_) {
      return true; // fail-open per D-14
    }
  }
}
