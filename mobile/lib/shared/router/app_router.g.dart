// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app router with reactive auth-based redirects.
///
/// Redirect logic:
/// 1. Unauthenticated + not on auth route -> /login
/// 2. Authenticated + on auth route + onboarding unseen -> /onboarding
/// 3. Authenticated + on auth route + onboarding seen -> /programs
/// 4. Authenticated + on /onboarding + already seen -> /programs
///
/// Uses .valueOrNull ?? true for onboardingSeenProvider to default to "seen"
/// during async loading, preventing flash-redirect to /onboarding on every launch.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the app router with reactive auth-based redirects.
///
/// Redirect logic:
/// 1. Unauthenticated + not on auth route -> /login
/// 2. Authenticated + on auth route + onboarding unseen -> /onboarding
/// 3. Authenticated + on auth route + onboarding seen -> /programs
/// 4. Authenticated + on /onboarding + already seen -> /programs
///
/// Uses .valueOrNull ?? true for onboardingSeenProvider to default to "seen"
/// during async loading, preventing flash-redirect to /onboarding on every launch.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the app router with reactive auth-based redirects.
  ///
  /// Redirect logic:
  /// 1. Unauthenticated + not on auth route -> /login
  /// 2. Authenticated + on auth route + onboarding unseen -> /onboarding
  /// 3. Authenticated + on auth route + onboarding seen -> /programs
  /// 4. Authenticated + on /onboarding + already seen -> /programs
  ///
  /// Uses .valueOrNull ?? true for onboardingSeenProvider to default to "seen"
  /// during async loading, preventing flash-redirect to /onboarding on every launch.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'd9c17acdc8cd17e035fdeeaf00f93d2991898f8f';
