// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_bus.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(commandBus)
final commandBusProvider = CommandBusProvider._();

final class CommandBusProvider
    extends $FunctionalProvider<CommandBus, CommandBus, CommandBus>
    with $Provider<CommandBus> {
  CommandBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandBusHash();

  @$internal
  @override
  $ProviderElement<CommandBus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommandBus create(Ref ref) {
    return commandBus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandBus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandBus>(value),
    );
  }
}

String _$commandBusHash() => r'99b882d8fee78b368094083a78e5750b3320ebb3';
