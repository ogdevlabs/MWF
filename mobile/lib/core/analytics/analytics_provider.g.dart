// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the global [AnalyticsService] instance.
///
/// Currently returns [NoOpAnalyticsService]. Swap implementation
/// when a real analytics provider (Firebase Analytics, Mixpanel, etc.)
/// is integrated.

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

/// Provides the global [AnalyticsService] instance.
///
/// Currently returns [NoOpAnalyticsService]. Swap implementation
/// when a real analytics provider (Firebase Analytics, Mixpanel, etc.)
/// is integrated.

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  /// Provides the global [AnalyticsService] instance.
  ///
  /// Currently returns [NoOpAnalyticsService]. Swap implementation
  /// when a real analytics provider (Firebase Analytics, Mixpanel, etc.)
  /// is integrated.
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'1972137cc1cce0c5efe7821f85975209469e2029';
