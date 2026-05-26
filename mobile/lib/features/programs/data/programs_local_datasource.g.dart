// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programsLocalDatasource)
final programsLocalDatasourceProvider = ProgramsLocalDatasourceProvider._();

final class ProgramsLocalDatasourceProvider
    extends
        $FunctionalProvider<
          ProgramsLocalDatasource,
          ProgramsLocalDatasource,
          ProgramsLocalDatasource
        >
    with $Provider<ProgramsLocalDatasource> {
  ProgramsLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programsLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programsLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<ProgramsLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramsLocalDatasource create(Ref ref) {
    return programsLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramsLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramsLocalDatasource>(value),
    );
  }
}

String _$programsLocalDatasourceHash() =>
    r'f1b258be91fe53086e8916026cdac4b5e19e9b14';
