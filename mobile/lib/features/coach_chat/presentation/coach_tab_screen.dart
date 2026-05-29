import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/subscription_provider.dart';
import '../data/fcm_providers.dart';
import 'coach_chat_screen.dart';
import 'coach_paywall_screen.dart';

/// Premium gate screen for the Coach tab.
///
/// - Premium subscribers see [CoachChatScreen].
/// - Non-premium (basic) subscribers see [CoachPaywallScreen].
/// - Also watches [fcmInitProvider] to ensure FCM is initialized on first load.
class CoachTabScreen extends ConsumerWidget {
  const CoachTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger FCM initialization (fire-and-forget — errors are non-blocking)
    ref.watch(fcmInitProvider);

    return ref.watch(isSubscribedProvider).when(
          data: (isSubscribed) =>
              isSubscribed ? const CoachChatScreen() : const CoachPaywallScreen(),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => const CoachPaywallScreen(),
        );
  }
}
