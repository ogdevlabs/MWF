// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programsRemoteDatasource)
final programsRemoteDatasourceProvider = ProgramsRemoteDatasourceProvider._();

final class ProgramsRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          ProgramsRemoteDatasource,
          ProgramsRemoteDatasource,
          ProgramsRemoteDatasource
        >
    with $Provider<ProgramsRemoteDatasource> {
  ProgramsRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programsRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ProgramsRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramsRemoteDatasource create(Ref ref) {
    return programsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramsRemoteDatasource>(value),
    );
  }
}

String _$programsRemoteDatasourceHash() =>
    r'707df8189c17454cfcbb93703ecf0cfb4744a289';
