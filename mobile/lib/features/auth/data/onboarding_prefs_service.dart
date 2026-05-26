import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_prefs_service.g.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

/// Manages the onboarding-seen flag in SharedPreferences.
/// Uses legacy SharedPreferences.getInstance() consistent with SyncService.
class OnboardingPrefsService {
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingSeenKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeenKey, true);
  }
}

/// Whether onboarding has been seen. Resolves once at startup.
/// Uses .value ?? true in router to avoid redirect loop during loading.
@Riverpod(keepAlive: true)
Future<bool> onboardingSeen(Ref ref) async {
  final service = OnboardingPrefsService();
  return service.hasSeenOnboarding();
}

@riverpod
OnboardingPrefsService onboardingPrefsService(Ref ref) {
  return OnboardingPrefsService();
}
