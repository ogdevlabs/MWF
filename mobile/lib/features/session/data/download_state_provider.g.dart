// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive provider that derives a session's [SessionDownloadState] by
/// watching the download_manifest table and joining against the session's
/// exercise IDs.
///
/// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
/// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
/// (vacuous every guard).

@ProviderFor(sessionDownloadState)
final sessionDownloadStateProvider = SessionDownloadStateFamily._();

/// Reactive provider that derives a session's [SessionDownloadState] by
/// watching the download_manifest table and joining against the session's
/// exercise IDs.
///
/// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
/// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
/// (vacuous every guard).

final class SessionDownloadStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionDownloadState>,
          SessionDownloadState,
          Stream<SessionDownloadState>
        >
    with
        $FutureModifier<SessionDownloadState>,
        $StreamProvider<SessionDownloadState> {
  /// Reactive provider that derives a session's [SessionDownloadState] by
  /// watching the download_manifest table and joining against the session's
  /// exercise IDs.
  ///
  /// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
  /// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
  /// (vacuous every guard).
  SessionDownloadStateProvider._({
    required SessionDownloadStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionDownloadStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionDownloadStateHash();

  @override
  String toString() {
    return r'sessionDownloadStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SessionDownloadState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SessionDownloadState> create(Ref ref) {
    final argument = this.argument as String;
    return sessionDownloadState(ref, sessionId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDownloadStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionDownloadStateHash() =>
    r'e0a0760a05a64640ba05064362c772cc2dc03fc8';

/// Reactive provider that derives a session's [SessionDownloadState] by
/// watching the download_manifest table and joining against the session's
/// exercise IDs.
///
/// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
/// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
/// (vacuous every guard).

final class SessionDownloadStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SessionDownloadState>, String> {
  SessionDownloadStateFamily._()
    : super(
        retry: null,
        name: r'sessionDownloadStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive provider that derives a session's [SessionDownloadState] by
  /// watching the download_manifest table and joining against the session's
  /// exercise IDs.
  ///
  /// Per D-07: uses DownloadManifestDao.watchAllEntries() for reactivity.
  /// Per Pitfall 3: returns notDownloaded when relevant entries list is empty
  /// (vacuous every guard).

  SessionDownloadStateProvider call({required String sessionId}) =>
      SessionDownloadStateProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionDownloadStateProvider';
}
