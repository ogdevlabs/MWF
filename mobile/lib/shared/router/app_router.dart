import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/auth/data/onboarding_prefs_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/paywall_screen.dart';
import '../../features/programs/presentation/program_list_screen.dart';
import '../../features/programs/presentation/program_detail_screen.dart';
import '../../features/session/presentation/session_player_screen.dart';

part 'app_router.g.dart';

/// Provides the app router with reactive auth-based redirects.
///
/// Redirect logic:
/// 1. Unauthenticated + not on auth route -> /login
/// 2. Authenticated + on auth route + onboarding unseen -> /onboarding
/// 3. Authenticated + on auth route + onboarding seen -> /programs
/// 4. Authenticated + on /onboarding + already seen -> /programs
///
/// Uses .valueOrNull ?? true for onboardingSeenProvider to default to "seen"
/// during async loading, preventing flash-redirect to /onboarding on every launch.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final onboardingSeen = ref.watch(onboardingSeenProvider).value ?? true;

  return GoRouter(
    initialLocation: '/programs',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Not authenticated -> force login (except if already on auth route)
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
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Session Complete'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Progress'),
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
