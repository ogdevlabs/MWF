import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/auth/data/onboarding_prefs_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/paywall_screen.dart';
import '../../features/metrics/presentation/progress_screen.dart';
import '../../features/programs/presentation/program_list_screen.dart';
import '../../features/programs/presentation/program_detail_screen.dart';
import '../../features/session/presentation/session_completion_screen.dart';
import '../../features/session/presentation/session_player_screen.dart';

part 'app_router.g.dart';

/// A [ChangeNotifier] that bridges Riverpod providers into a GoRouter
/// [refreshListenable]. GoRouter re-evaluates the redirect whenever notified.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Re-run redirect whenever auth or onboarding state changes.
    _ref.listen(isAuthenticatedProvider, (_, _a) => notifyListeners());
    _ref.listen(onboardingSeenProvider, (_, _a) => notifyListeners());
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(isAuthenticatedProvider);
  bool get onboardingSeen => _ref.read(onboardingSeenProvider).value ?? true;
}

/// Provides a stable [GoRouter] instance created once for the app lifetime.
///
/// Auth-driven redirects are handled via [_RouterNotifier] so the router
/// instance is never recreated — only the redirect logic re-runs.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = notifier.isAuthenticated;
      final onboardingSeen = notifier.onboardingSeen;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Not authenticated -> force login
      if (!isAuth && !isAuthRoute) return '/login';

      // Authenticated + on auth route -> redirect away
      if (isAuth && isAuthRoute) {
        return onboardingSeen ? '/programs' : '/onboarding';
      }

      // Authenticated + on onboarding but already seen -> skip
      if (isAuth && isOnboardingRoute && onboardingSeen) return '/programs';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/programs',
        name: 'programs',
        builder: (context, state) => const ProgramListScreen(),
        routes: [
          GoRoute(
            path: ':programId',
            name: 'program-detail',
            builder: (context, state) => ProgramDetailScreen(
              programId: state.pathParameters['programId']!,
            ),
            routes: [
              GoRoute(
                path: 'session/:sessionId',
                name: 'session-player',
                builder: (context, state) => SessionPlayerScreen(
                  programId: state.pathParameters['programId']!,
                  sessionId: state.pathParameters['sessionId']!,
                ),
              ),
              GoRoute(
                path: 'session/:sessionId/complete',
                name: 'session-complete',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  return SessionCompletionScreen(
                    programId: state.pathParameters['programId']!,
                    sessionId: state.pathParameters['sessionId']!,
                    sessionTitle: extra['sessionTitle'] as String? ?? 'Session',
                    durationSeconds: extra['durationSeconds'] as int? ?? 0,
                    exerciseCount: extra['exerciseCount'] as int? ?? 0,
                    streak: extra['streak'] as int? ?? 0,
                    studentId: extra['studentId'] as String?,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Notifications'),
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/feedback/:sessionId',
        name: 'feedback',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Feedback'),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(Placeholder - will be replaced in later phases)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
