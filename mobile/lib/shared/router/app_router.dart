import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/auth/data/onboarding_prefs_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/paywall_screen.dart';
import '../../features/coach_chat/presentation/coach_chat_screen.dart';
import '../../features/coach_chat/presentation/coach_tab_screen.dart';
import '../../features/coach_chat/presentation/notifications_screen.dart';
import '../../features/metrics/presentation/progress_screen.dart';
import '../../features/programs/presentation/program_list_screen.dart';
import '../../features/programs/presentation/program_detail_screen.dart';
import '../../features/session/presentation/session_completion_screen.dart';
import '../../features/session/presentation/session_player_screen.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

/// A [ChangeNotifier] that bridges Riverpod providers into a GoRouter
/// [refreshListenable]. GoRouter re-evaluates the redirect whenever notified.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Re-run redirect whenever auth or onboarding state changes.
    _ref.listen(isAuthenticatedProvider, (prev, next) => notifyListeners());
    _ref.listen(onboardingSeenProvider, (prev, next) => notifyListeners());
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
      // ── Auth routes (no bottom nav) ────────────────────────────────────────
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
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),

      // ── Main shell (4-tab bottom NavigationBar) ───────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          // Tab 0: Home / Programs
          StatefulShellBranch(
            routes: [
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
                          final extra =
                              state.extra as Map<String, dynamic>? ?? {};
                          return SessionCompletionScreen(
                            programId: state.pathParameters['programId']!,
                            sessionId: state.pathParameters['sessionId']!,
                            sessionTitle:
                                extra['sessionTitle'] as String? ?? 'Session',
                            durationSeconds:
                                extra['durationSeconds'] as int? ?? 0,
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
            ],
          ),

          // Tab 1: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                name: 'progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),

          // Tab 2: Coach chat (premium gate via CoachTabScreen;
          // sessionId query param supported for FCM deep-link scroll)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/coach-chat',
                name: 'coach-chat',
                builder: (context, state) {
                  final sessionId =
                      state.uri.queryParameters['sessionId'];
                  // CoachTabScreen handles the premium gate; passes sessionId
                  // through to CoachChatScreen when navigating via deep link.
                  if (sessionId != null) {
                    return CoachChatScreen(sessionId: sessionId);
                  }
                  return const CoachTabScreen();
                },
              ),
            ],
          ),

          // Tab 3: Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
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
