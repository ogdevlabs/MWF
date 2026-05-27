// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for sessions with lock state for a given program.
/// Parameters: programId and currentDay (from enrollment).

@ProviderFor(sessionsWithState)
final sessionsWithStateProvider = SessionsWithStateFamily._();

/// Provider for sessions with lock state for a given program.
/// Parameters: programId and currentDay (from enrollment).

final class SessionsWithStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SessionModel>>,
          List<SessionModel>,
          FutureOr<List<SessionModel>>
        >
    with
        $FutureModifier<List<SessionModel>>,
        $FutureProvider<List<SessionModel>> {
  /// Provider for sessions with lock state for a given program.
  /// Parameters: programId and currentDay (from enrollment).
  SessionsWithStateProvider._({
    required SessionsWithStateFamily super.from,
    required ({String programId, int currentDay}) super.argument,
  }) : super(
         retry: null,
         name: r'sessionsWithStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionsWithStateHash();

  @override
  String toString() {
    return r'sessionsWithStateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SessionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SessionModel>> create(Ref ref) {
    final argument = this.argument as ({String programId, int currentDay});
    return sessionsWithState(
      ref,
      programId: argument.programId,
      currentDay: argument.currentDay,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionsWithStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionsWithStateHash() => r'602f2c270569d9a8e3dc2858ba72813b02ffe0b2';

/// Provider for sessions with lock state for a given program.
/// Parameters: programId and currentDay (from enrollment).

final class SessionsWithStateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SessionModel>>,
          ({String programId, int currentDay})
        > {
  SessionsWithStateFamily._()
    : super(
        retry: null,
        name: r'sessionsWithStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for sessions with lock state for a given program.
  /// Parameters: programId and currentDay (from enrollment).

  SessionsWithStateProvider call({
    required String programId,
    required int currentDay,
  }) => SessionsWithStateProvider._(
    argument: (programId: programId, currentDay: currentDay),
    from: this,
  );

  @override
  String toString() => r'sessionsWithStateProvider';
}

/// Provider for exercises in a session, ordered by displayOrder.

@ProviderFor(sessionExercises)
final sessionExercisesProvider = SessionExercisesFamily._();

/// Provider for exercises in a session, ordered by displayOrder.

final class SessionExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseModel>>,
          List<ExerciseModel>,
          FutureOr<List<ExerciseModel>>
        >
    with
        $FutureModifier<List<ExerciseModel>>,
        $FutureProvider<List<ExerciseModel>> {
  /// Provider for exercises in a session, ordered by displayOrder.
  SessionExercisesProvider._({
    required SessionExercisesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionExercisesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionExercisesHash();

  @override
  String toString() {
    return r'sessionExercisesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExerciseModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExerciseModel>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionExercises(ref, sessionId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionExercisesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionExercisesHash() => r'3ebb4143bce9676ab22ee0badf473d94f29d9cde';

/// Provider for exercises in a session, ordered by displayOrder.

final class SessionExercisesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ExerciseModel>>, String> {
  SessionExercisesFamily._()
    : super(
        retry: null,
        name: r'sessionExercisesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for exercises in a session, ordered by displayOrder.

  SessionExercisesProvider call({required String sessionId}) =>
      SessionExercisesProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionExercisesProvider';
}
