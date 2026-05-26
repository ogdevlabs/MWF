import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

part 'auth_provider.g.dart';

/// Provides a reactive stream of [AuthState] changes.
///
/// Uses keepAlive because auth state must persist for the entire app lifecycle.
/// Includes handleError to prevent crashes on network errors during token refresh.
@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.handleError((error, stackTrace) {
    // Swallow network errors during token refresh.
    // The stream will continue emitting once connectivity is restored.
    // Logging could be added here for monitoring.
  });
}

/// Synchronous accessor for the current user.
/// Returns null if no user is signed in or if auth state hasn't loaded yet.
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final authStateValue = ref.watch(authStateProvider);
  return authStateValue.value?.session?.user;
}

/// Whether the user is currently authenticated.
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}
