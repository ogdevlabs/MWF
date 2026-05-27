import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/features/session/domain/session_model.dart';

void main() {
  group('deriveSessionState', () {
    test('session with dayNumber less than currentDay is COMPLETE', () {
      final state = deriveSessionState(dayNumber: 1, currentDay: 3);
      expect(state, equals(SessionState.complete));
    });

    test('session with dayNumber equal to currentDay is CURRENT', () {
      final state = deriveSessionState(dayNumber: 3, currentDay: 3);
      expect(state, equals(SessionState.current));
    });

    test('session with dayNumber greater than currentDay is LOCKED', () {
      final state = deriveSessionState(dayNumber: 5, currentDay: 3);
      expect(state, equals(SessionState.locked));
    });

    test('first day session is CURRENT when currentDay is 1', () {
      final state = deriveSessionState(dayNumber: 1, currentDay: 1);
      expect(state, equals(SessionState.current));
    });
  });
}
