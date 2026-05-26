// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentRemoteDatasource)
final studentRemoteDatasourceProvider = StudentRemoteDatasourceProvider._();

final class StudentRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          StudentRemoteDatasource,
          StudentRemoteDatasource,
          StudentRemoteDatasource
        >
    with $Provider<StudentRemoteDatasource> {
  StudentRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<StudentRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudentRemoteDatasource create(Ref ref) {
    return studentRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentRemoteDatasource>(value),
    );
  }
}

String _$studentRemoteDatasourceHash() =>
    r'f8891270c4b8a95d120ae3a0570801131fb7a1ef';
