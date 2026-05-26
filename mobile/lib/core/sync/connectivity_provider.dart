import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Raw connectivity stream — emits `List<ConnectivityResult>` on every change.
/// connectivity_plus 7.x returns a list (e.g., `[wifi, vpn]` or `[none]`).
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

/// Whether the device currently has network connectivity.
@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  List<ConnectivityResult> _previousResults = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    ref.onDispose(() => _subscription?.cancel());

    // Assume online initially — will be corrected by first stream event
    return true;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isNowOnline = !results.contains(ConnectivityResult.none);
    final wasOffline = _previousResults.contains(ConnectivityResult.none);

    state = isNowOnline;

    if (isNowOnline && wasOffline) {
      // Device reconnected — trigger sync and download resume.
      // SyncService and DownloadService listen to this via ref.listen
      // and will be wired in Plan 02-06.
      _onReconnect();
    }

    _previousResults = List.from(results);
  }

  /// Called when device transitions from offline to online.
  /// Override point for triggering sync and download resume.
  void _onReconnect() {
    // Will be wired to SyncService.sync() and DownloadService.resumeQueue()
    // in Plan 02-06 (SyncService) and Plan 02-05 (DownloadService).
    // For now, this is the detection point — consumers ref.listen to
    // connectivityNotifierProvider and react to true transitions.
  }

  /// Check current connectivity status on-demand.
  Future<void> checkNow() async {
    final results = await Connectivity().checkConnectivity();
    _onConnectivityChanged(results);
  }
}
