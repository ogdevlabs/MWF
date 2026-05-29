// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metricsRepository)
final metricsRepositoryProvider = MetricsRepositoryProvider._();

final class MetricsRepositoryProvider
    extends
        $FunctionalProvider<
          MetricsRepository,
          MetricsRepository,
          MetricsRepository
        >
    with $Provider<MetricsRepository> {
  MetricsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metricsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metricsRepositoryHash();

  @$internal
  @override
  $ProviderElement<MetricsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MetricsRepository create(Ref ref) {
    return metricsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetricsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetricsRepository>(value),
    );
  }
}

String _$metricsRepositoryHash() => r'c9b7b5d8b2bd3678b00105c9cf2923000d3f0dd6';

/// Reactive metric log stream for UI consumption (FR-009).

@ProviderFor(metricLogsStream)
final metricLogsStreamProvider = MetricLogsStreamFamily._();

/// Reactive metric log stream for UI consumption (FR-009).

final class MetricLogsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MetricLog>>,
          List<MetricLog>,
          Stream<List<MetricLog>>
        >
    with $FutureModifier<List<MetricLog>>, $StreamProvider<List<MetricLog>> {
  /// Reactive metric log stream for UI consumption (FR-009).
  MetricLogsStreamProvider._({
    required MetricLogsStreamFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'metricLogsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$metricLogsStreamHash();

  @override
  String toString() {
    return r'metricLogsStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MetricLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MetricLog>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return metricLogsStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MetricLogsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$metricLogsStreamHash() => r'd8ab69f1eb5be5a7d8582fb9c35ab45685a22f13';

/// Reactive metric log stream for UI consumption (FR-009).

final class MetricLogsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MetricLog>>, (String, String)> {
  MetricLogsStreamFamily._()
    : super(
        retry: null,
        name: r'metricLogsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive metric log stream for UI consumption (FR-009).

  MetricLogsStreamProvider call(String studentId, String metricType) =>
      MetricLogsStreamProvider._(argument: (studentId, metricType), from: this);

  @override
  String toString() => r'metricLogsStreamProvider';
}
