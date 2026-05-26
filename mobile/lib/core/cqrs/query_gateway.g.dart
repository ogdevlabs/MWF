// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(queryGateway)
final queryGatewayProvider = QueryGatewayProvider._();

final class QueryGatewayProvider
    extends $FunctionalProvider<QueryGateway, QueryGateway, QueryGateway>
    with $Provider<QueryGateway> {
  QueryGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queryGatewayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queryGatewayHash();

  @$internal
  @override
  $ProviderElement<QueryGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueryGateway create(Ref ref) {
    return queryGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueryGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueryGateway>(value),
    );
  }
}

String _$queryGatewayHash() => r'd6415cb050f9dfc41469d09a6a4e3920690237a5';
