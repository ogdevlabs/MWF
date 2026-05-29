// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a stable [GoRouter] instance created once for the app lifetime.
///
/// Auth-driven redirects are handled via [_RouterNotifier] so the router
/// instance is never recreated — only the redirect logic re-runs.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides a stable [GoRouter] instance created once for the app lifetime.
///
/// Auth-driven redirects are handled via [_RouterNotifier] so the router
/// instance is never recreated — only the redirect logic re-runs.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides a stable [GoRouter] instance created once for the app lifetime.
  ///
  /// Auth-driven redirects are handled via [_RouterNotifier] so the router
  /// instance is never recreated — only the redirect logic re-runs.
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

String _$appRouterHash() => r'0810b0d2d51832d85a57e8b895008d1fd0e4aa83';
