// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionDatasource)
final sessionDatasourceProvider = SessionDatasourceProvider._();

final class SessionDatasourceProvider
    extends
        $FunctionalProvider<
          SessionDatasource,
          SessionDatasource,
          SessionDatasource
        >
    with $Provider<SessionDatasource> {
  SessionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionDatasourceHash();

  @$internal
  @override
  $ProviderElement<SessionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionDatasource create(Ref ref) {
    return sessionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionDatasource>(value),
    );
  }
}

String _$sessionDatasourceHash() => r'46ac763d8471f0bdde04e1fc03a347bac6ec43d1';
