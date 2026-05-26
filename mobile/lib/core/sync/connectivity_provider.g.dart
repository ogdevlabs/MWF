// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Raw connectivity stream — emits List<ConnectivityResult> on every change.
/// connectivity_plus 7.x returns a list (e.g., [wifi, vpn] or [none]).

@ProviderFor(connectivityStream)
final connectivityStreamProvider = ConnectivityStreamProvider._();

/// Raw connectivity stream — emits List<ConnectivityResult> on every change.
/// connectivity_plus 7.x returns a list (e.g., [wifi, vpn] or [none]).

final class ConnectivityStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Raw connectivity stream — emits List<ConnectivityResult> on every change.
  /// connectivity_plus 7.x returns a list (e.g., [wifi, vpn] or [none]).
  ConnectivityStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityStream(ref);
  }
}

String _$connectivityStreamHash() =>
    r'9f60aae6c128e0af3ad3f37236c4f05ce64c4a99';

/// Whether the device currently has network connectivity.

@ProviderFor(ConnectivityNotifier)
final connectivityProvider = ConnectivityNotifierProvider._();

/// Whether the device currently has network connectivity.
final class ConnectivityNotifierProvider
    extends $NotifierProvider<ConnectivityNotifier, bool> {
  /// Whether the device currently has network connectivity.
  ConnectivityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityNotifierHash();

  @$internal
  @override
  ConnectivityNotifier create() => ConnectivityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectivityNotifierHash() =>
    r'9927bbd16fe6b6c1240f426574c6a53ca048879f';

/// Whether the device currently has network connectivity.

abstract class _$ConnectivityNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
