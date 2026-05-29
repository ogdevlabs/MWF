import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.handleError((error, stackTrace) {
    debugPrint('[AUTH_PROVIDER] authState stream error: $error');
  }).map((state) {
    debugPrint('[AUTH_PROVIDER] authState event: ${state.event} user=${state.session?.user.id}');
    return state;
  });
}

@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final authStateValue = ref.watch(authStateProvider);
  final user = authStateValue.value?.session?.user;
  debugPrint('[AUTH_PROVIDER] currentUser: ${user?.id ?? 'null'} (asyncState=${authStateValue.runtimeType})');
  return user;
}

@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  debugPrint('[AUTH_PROVIDER] isAuthenticated: ${user != null}');
  return user != null;
}
