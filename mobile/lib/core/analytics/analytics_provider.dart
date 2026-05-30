import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analytics_service.dart';

part 'analytics_provider.g.dart';

/// Provides the global [AnalyticsService] instance.
///
/// Currently returns [NoOpAnalyticsService]. Swap implementation
/// when a real analytics provider (Firebase Analytics, Mixpanel, etc.)
/// is integrated.
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  return const NoOpAnalyticsService();
}
