// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app router with reactive auth-based redirects.
///
/// Uses refreshListenable pattern: router re-evaluates redirect whenever
/// auth state changes (sign in, sign out, token refresh).

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the app router with reactive auth-based redirects.
///
/// Uses refreshListenable pattern: router re-evaluates redirect whenever
/// auth state changes (sign in, sign out, token refresh).

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the app router with reactive auth-based redirects.
  ///
  /// Uses refreshListenable pattern: router re-evaluates redirect whenever
  /// auth state changes (sign in, sign out, token refresh).
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

String _$appRouterHash() => r'366cf8079594a6f688fa7542b80081d36ce3d2db';
