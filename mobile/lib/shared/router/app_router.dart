import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({required bool isAuthenticated}) {
  return GoRouter(
    initialLocation: '/programs',
    redirect: (BuildContext context, GoRouterState state) {
      final loggingIn = state.matchedLocation == '/login';
      final signingUp = state.matchedLocation == '/signup';

      if (!isAuthenticated) {
        if (loggingIn || signingUp) return null;
        return '/login';
      }

      if (loggingIn || signingUp) return '/programs';
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
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Sign Up'),
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
          '$title\n(Placeholder — Phase 2+)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
