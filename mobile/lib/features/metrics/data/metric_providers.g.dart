// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metricRepository)
final metricRepositoryProvider = MetricRepositoryProvider._();

final class MetricRepositoryProvider
    extends
        $FunctionalProvider<
          MetricRepository,
          MetricRepository,
          MetricRepository
        >
    with $Provider<MetricRepository> {
  MetricRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metricRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metricRepositoryHash();

  @$internal
  @override
  $ProviderElement<MetricRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MetricRepository create(Ref ref) {
    return metricRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetricRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetricRepository>(value),
    );
  }
}

String _$metricRepositoryHash() => r'06d6c4e8bc7faaf130d72a2878dd2438cbc5ee98';
