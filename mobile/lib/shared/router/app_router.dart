import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider.dart';

part 'app_router.g.dart';

/// Provides the app router with reactive auth-based redirects.
///
/// Uses refreshListenable pattern: router re-evaluates redirect whenever
/// auth state changes (sign in, sign out, token refresh).
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/programs',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/programs';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const _PlaceholderScreen(title: 'Sign Up'),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: '/programs',
        name: 'programs',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Programs'),
        routes: [
          GoRoute(
            path: ':programId',
            name: 'program-detail',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Program Detail'),
            routes: [
              GoRoute(
                path: 'session/:sessionId',
                name: 'session-player',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Session Player'),
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
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Paywall'),
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
          '$title\n(Placeholder — Feature phases will replace)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
