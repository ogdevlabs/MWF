// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the initialized [SupabaseClient] singleton.
///
/// Requires [Supabase.initialize] to have been called in main() before
/// the app starts. Uses keepAlive because the client must persist for
/// the entire app lifecycle — autoDispose would close connections mid-operation.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Provides the initialized [SupabaseClient] singleton.
///
/// Requires [Supabase.initialize] to have been called in main() before
/// the app starts. Uses keepAlive because the client must persist for
/// the entire app lifecycle — autoDispose would close connections mid-operation.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Provides the initialized [SupabaseClient] singleton.
  ///
  /// Requires [Supabase.initialize] to have been called in main() before
  /// the app starts. Uses keepAlive because the client must persist for
  /// the entire app lifecycle — autoDispose would close connections mid-operation.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'2df5a38617329a3bb0a7e149189bea875722d7b8';
