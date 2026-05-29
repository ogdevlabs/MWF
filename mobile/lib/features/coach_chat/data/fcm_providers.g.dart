// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that initializes FcmService and registers the FCM token
/// once the user is authenticated. Watches auth state — when a user
/// signs in, it calls FcmService.initialize() and registerToken(studentId).
///
/// This provider should be watched from CoachTabScreen or the app shell
/// to ensure FCM is active while the user is logged in.

@ProviderFor(fcmInit)
final fcmInitProvider = FcmInitProvider._();

/// Provider that initializes FcmService and registers the FCM token
/// once the user is authenticated. Watches auth state — when a user
/// signs in, it calls FcmService.initialize() and registerToken(studentId).
///
/// This provider should be watched from CoachTabScreen or the app shell
/// to ensure FCM is active while the user is logged in.

final class FcmInitProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider that initializes FcmService and registers the FCM token
  /// once the user is authenticated. Watches auth state — when a user
  /// signs in, it calls FcmService.initialize() and registerToken(studentId).
  ///
  /// This provider should be watched from CoachTabScreen or the app shell
  /// to ensure FCM is active while the user is logged in.
  FcmInitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmInitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmInitHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return fcmInit(ref);
  }
}

String _$fcmInitHash() => r'b8dc4f148d3982033ff6642173be4e0d109f4e07';
