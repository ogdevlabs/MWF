// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_prefs_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether onboarding has been seen. Resolves once at startup.
/// Uses .valueOrNull ?? true in router to avoid redirect loop during loading.

@ProviderFor(onboardingSeen)
final onboardingSeenProvider = OnboardingSeenProvider._();

/// Whether onboarding has been seen. Resolves once at startup.
/// Uses .valueOrNull ?? true in router to avoid redirect loop during loading.

final class OnboardingSeenProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether onboarding has been seen. Resolves once at startup.
  /// Uses .valueOrNull ?? true in router to avoid redirect loop during loading.
  OnboardingSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSeenHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return onboardingSeen(ref);
  }
}

String _$onboardingSeenHash() => r'9151485f8f9160a0e15c2c7a5bc8b4112a03c3b7';

@ProviderFor(onboardingPrefsService)
final onboardingPrefsServiceProvider = OnboardingPrefsServiceProvider._();

final class OnboardingPrefsServiceProvider
    extends
        $FunctionalProvider<
          OnboardingPrefsService,
          OnboardingPrefsService,
          OnboardingPrefsService
        >
    with $Provider<OnboardingPrefsService> {
  OnboardingPrefsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingPrefsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingPrefsServiceHash();

  @$internal
  @override
  $ProviderElement<OnboardingPrefsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingPrefsService create(Ref ref) {
    return onboardingPrefsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingPrefsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingPrefsService>(value),
    );
  }
}

String _$onboardingPrefsServiceHash() =>
    r'332778bdbde660bd3924ee9e63e4fe436e467977';
