import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/features/session/data/streak_calculator.dart';


void main() {
  group('computeCurrentStreak', () {
    test('returns 0 for empty records', () {
      expect(computeCurrentStreak([]), equals(0));
    });

    test('returns 1 for single completion today', () {
      final today = DateTime.now();
      expect(computeCurrentStreak([today]), equals(1));
    });

    test('returns 1 for single completion yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(computeCurrentStreak([yesterday]), equals(1));
    });

    test('returns consecutive day count for 3 days ending today', () {
      final now = DateTime.now();
      final dates = [
        now,
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
      ];
      expect(computeCurrentStreak(dates), equals(3));
    });

    test('returns 0 when most recent is 2+ days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      expect(computeCurrentStreak([twoDaysAgo]), equals(0));
    });

    test('handles multiple completions on same day (deduplicates)', () {
      final now = DateTime.now();
      final dates = [
        now,
        now.subtract(const Duration(hours: 2)),
        now.subtract(const Duration(days: 1)),
      ];
      // Today (2 entries) + yesterday = streak of 2
      expect(computeCurrentStreak(dates), equals(2));
    });

    test('breaks streak at gap', () {
      final now = DateTime.now();
      final dates = [
        now,
        now.subtract(const Duration(days: 1)),
        // gap: day 2 missing
        now.subtract(const Duration(days: 3)),
        now.subtract(const Duration(days: 4)),
      ];
      expect(computeCurrentStreak(dates), equals(2));
    });

    test('streak starting from yesterday works', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dates = [
        yesterday,
        yesterday.subtract(const Duration(days: 1)),
        yesterday.subtract(const Duration(days: 2)),
      ];
      expect(computeCurrentStreak(dates), equals(3));
    });
  });
}
