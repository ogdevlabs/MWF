/// Analytics service abstraction for event tracking.
///
/// Phase 9 scaffold — uses NoOpAnalyticsService.
/// Replace with a real implementation (Firebase Analytics, Mixpanel, etc.)
/// when analytics provider is selected.
abstract class AnalyticsService {
  /// Log a named event with optional parameters.
  void logEvent(String name, {Map<String, Object>? parameters});

  /// Set the current user ID for analytics attribution.
  void setUserId(String? userId);
}

/// No-op implementation that discards all events.
/// Used as scaffold until a real analytics provider is integrated.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  void logEvent(String name, {Map<String, Object>? parameters}) {}

  @override
  void setUserId(String? userId) {}
}
