import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_repository.dart';
import 'student_remote_datasource.dart';

part 'auth_remote_datasource.g.dart';

/// Feature-layer auth datasource.
///
/// Wraps AuthRepository and adds Phase 3 side-effects:
/// - RevenueCat logIn(supabaseUserId) after successful sign-in
/// - RevenueCat logOut() on sign-out
/// - Student profile upsert after sign-up/social-login
///
/// Auth screens (login_screen, signup_screen) call this instead of
/// AuthRepository directly.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required this.authRepository,
    required this.studentDatasource,
  });

  final AuthRepository authRepository;
  final StudentRemoteDatasource studentDatasource;

  /// Sign up with email + password.
  /// After success: upserts student profile + links RevenueCat user.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await authRepository.signUpWithEmail(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      await studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: email,
        displayName: displayName,
      );
      try { await Purchases.logIn(user.id); } on PlatformException catch (_) {}
    }

    return response;
  }

  /// Sign in with email + password.
  /// After success: upserts student profile (idempotent) + links RevenueCat.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      await studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: user.email ?? email,
      );
      try { await Purchases.logIn(user.id); } on PlatformException catch (_) {}
    }

    return response;
  }

  /// Sign in with Apple.
  /// After success: upserts student profile + links RevenueCat.
  Future<AuthResponse> signInWithApple() async {
    final response = await authRepository.signInWithApple();

    final user = response.user;
    if (user != null) {
      await studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
      );
      try { await Purchases.logIn(user.id); } on PlatformException catch (_) {}
    }

    return response;
  }

  /// Sign in with Google.
  /// After success: upserts student profile + links RevenueCat.
  Future<AuthResponse> signInWithGoogle() async {
    final response = await authRepository.signInWithGoogle();

    final user = response.user;
    if (user != null) {
      await studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
      try { await Purchases.logIn(user.id); } on PlatformException catch (_) {}
    }

    return response;
  }

  /// Sign out: RevenueCat logOut + Supabase sign out.
  Future<void> signOut() async {
    try { await Purchases.logOut(); } on PlatformException catch (_) {}
    await authRepository.signOut();
  }
}

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final studentDs = ref.watch(studentRemoteDatasourceProvider);
  return AuthRemoteDatasource(
    authRepository: authRepo,
    studentDatasource: studentDs,
  );
}
