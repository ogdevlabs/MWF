/// Computes the current streak from a list of progress records (FR-014).
/// Streak = consecutive calendar days with at least one completed session.
/// Uses device local timezone (known limitation — Phase 6 may add IANA-aware logic).
///
/// Algorithm:
/// 1. Extract unique calendar dates from completedAt timestamps
/// 2. Sort descending
/// 3. If most recent is not today or yesterday, streak is 0
/// 4. Count consecutive days backwards from most recent
int computeCurrentStreak(List<DateTime> completedDates) {
  if (completedDates.isEmpty) return 0;

  // Normalize to calendar dates (zeroed time)
  final uniqueDates = completedDates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // descending

  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final yesterday = today.subtract(const Duration(days: 1));

  // If most recent completion is not today or yesterday, streak is broken
  if (uniqueDates.first != today && uniqueDates.first != yesterday) {
    return 0;
  }

  int streak = 1;
  for (int i = 0; i < uniqueDates.length - 1; i++) {
    final diff = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/// Computes the longest streak ever recorded from a list of progress records.
///
/// Returns the longest run of consecutive calendar days with at least one
/// completed session. Returns 0 if no completions.
int computeLongestStreak(List<DateTime> completedDates) {
  if (completedDates.isEmpty) return 0;

  final uniqueDates = completedDates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => a.compareTo(b)); // ascending

  int longest = 1;
  int current = 1;
  for (int i = 1; i < uniqueDates.length; i++) {
    final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
    if (diff == 1) {
      current++;
      if (current > longest) longest = current;
    } else {
      current = 1;
    }
  }
  return longest;
}
