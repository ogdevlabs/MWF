import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/supabase_client.dart';
import '../../../shared/router/app_router.dart';
import 'fcm_service.dart';

part 'fcm_providers.g.dart';

/// Provider that initializes FcmService and registers the FCM token
/// once the user is authenticated. Watches auth state — when a user
/// signs in, it calls FcmService.initialize() and registerToken(studentId).
///
/// This provider should be watched from CoachTabScreen or the app shell
/// to ensure FCM is active while the user is logged in.
@Riverpod(keepAlive: true)
Future<void> fcmInit(Ref ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final router = ref.watch(appRouterProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return; // Not authenticated yet — no-op

  try {
    final fcmService = FcmService(supabase: supabase, router: router);
    await fcmService.initialize();
    await fcmService.registerToken(user.id);
  } catch (e) {
    // FCM setup is non-critical — log and continue.
    // Common causes: Firebase placeholder config, simulator without push support,
    // or permission denied. The app remains fully functional without push.
    debugPrint('[FCM] Initialization failed (non-fatal): $e');
  }
}
