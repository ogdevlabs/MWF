import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Bridges Supabase's auth stream directly into GoRouter — no Riverpod layers.
/// Supabase fires onAuthStateChange immediately on sign-in/out, so the router
/// redirect runs synchronously after the auth response.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      debugPrint('[ROUTER] auth event: ${state.event} user=${state.session?.user.id}');
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _sub;

  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authNotifier = _AuthNotifier();
  ref.onDispose(authNotifier.dispose);

  final onboardingService = OnboardingPrefsService();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuth = authNotifier.isAuthenticated;
      final onboardingSeen = await onboardingService.hasSeenOnboarding();

      debugPrint('[ROUTER] redirect: ${state.matchedLocation} isAuth=$isAuth');

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) {
        return onboardingSeen ? '/programs' : '/onboarding';
      }
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
          '$title\n(Placeholder)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
