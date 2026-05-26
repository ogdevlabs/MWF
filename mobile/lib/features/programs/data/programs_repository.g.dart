// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programsRepository)
final programsRepositoryProvider = ProgramsRepositoryProvider._();

final class ProgramsRepositoryProvider
    extends
        $FunctionalProvider<
          ProgramsRepository,
          ProgramsRepository,
          ProgramsRepository
        >
    with $Provider<ProgramsRepository> {
  ProgramsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgramsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramsRepository create(Ref ref) {
    return programsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramsRepository>(value),
    );
  }
}

String _$programsRepositoryHash() =>
    r'd611f78509d42ecc6bb48030649f4f412de6bf9f';

/// Provides the list of programs for UI consumption.
/// Auto-refreshes when dependencies change.

@ProviderFor(programsList)
final programsListProvider = ProgramsListProvider._();

/// Provides the list of programs for UI consumption.
/// Auto-refreshes when dependencies change.

final class ProgramsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProgramModel>>,
          List<ProgramModel>,
          FutureOr<List<ProgramModel>>
        >
    with
        $FutureModifier<List<ProgramModel>>,
        $FutureProvider<List<ProgramModel>> {
  /// Provides the list of programs for UI consumption.
  /// Auto-refreshes when dependencies change.
  ProgramsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programsListHash();

  @$internal
  @override
  $FutureProviderElement<List<ProgramModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProgramModel>> create(Ref ref) {
    return programsList(ref);
  }
}

String _$programsListHash() => r'a3bf0e522510f0697fa0e1e5a0bc2dd68bf5cbb8';
