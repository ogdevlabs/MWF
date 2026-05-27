// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionCompletionService)
final sessionCompletionServiceProvider = SessionCompletionServiceProvider._();

final class SessionCompletionServiceProvider
    extends
        $FunctionalProvider<
          SessionCompletionService,
          SessionCompletionService,
          SessionCompletionService
        >
    with $Provider<SessionCompletionService> {
  SessionCompletionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionCompletionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionCompletionServiceHash();

  @$internal
  @override
  $ProviderElement<SessionCompletionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionCompletionService create(Ref ref) {
    return sessionCompletionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionCompletionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionCompletionService>(value),
    );
  }
}

String _$sessionCompletionServiceHash() =>
    r'8041025574ce23239182e64c7b0d251a1516fd18';
