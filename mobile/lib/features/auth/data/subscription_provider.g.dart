// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the current user has an active subscription.
///
/// Checks RevenueCat entitlement 'premium_access' first,
/// falls back to Supabase subscriptions table, then SharedPreferences cache.
/// Returns false if no user is signed in.

@ProviderFor(isSubscribed)
final isSubscribedProvider = IsSubscribedProvider._();

/// Whether the current user has an active subscription.
///
/// Checks RevenueCat entitlement 'premium_access' first,
/// falls back to Supabase subscriptions table, then SharedPreferences cache.
/// Returns false if no user is signed in.

final class IsSubscribedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the current user has an active subscription.
  ///
  /// Checks RevenueCat entitlement 'premium_access' first,
  /// falls back to Supabase subscriptions table, then SharedPreferences cache.
  /// Returns false if no user is signed in.
  IsSubscribedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSubscribedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSubscribedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isSubscribed(ref);
  }
}

String _$isSubscribedHash() => r'7b1dae9b6fb628d3c8ff9d2223df1053b60d04cc';
