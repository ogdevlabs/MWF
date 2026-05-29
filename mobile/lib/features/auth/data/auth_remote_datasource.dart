import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_repository.dart';
import 'student_remote_datasource.dart';

part 'auth_remote_datasource.g.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required this.authRepository,
    required this.studentDatasource,
  });

  final AuthRepository authRepository;
  final StudentRemoteDatasource studentDatasource;

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
      unawaited(studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: email,
        displayName: displayName,
      ).catchError((_) {}));
      if (await Purchases.isConfigured) { try { await Purchases.logIn(user.id); } catch (_) {} }
    }
    return response;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('[AUTH] signInWithEmail called for $email');
    try {
      final response = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      debugPrint('[AUTH] Supabase signInWithPassword done. user=${response.user?.id}');

      final user = response.user;
      if (user != null) {
        debugPrint('[AUTH] User is non-null, returning response');
        unawaited(studentDatasource.upsertStudentProfile(
          userId: user.id,
          email: user.email ?? email,
        ).catchError((e) => debugPrint('[AUTH] profile upsert error (ignored): $e')));
        if (await Purchases.isConfigured) { try { await Purchases.logIn(user.id); } catch (_) {} }
      } else {
        debugPrint('[AUTH] WARNING: response.user is null after signIn');
      }

      debugPrint('[AUTH] returning response');
      return response;
    } catch (e, st) {
      debugPrint('[AUTH] signInWithEmail THREW: $e\n$st');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple() async {
    final response = await authRepository.signInWithApple();
    final user = response.user;
    if (user != null) {
      unawaited(studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
      ).catchError((_) {}));
      if (await Purchases.isConfigured) { try { await Purchases.logIn(user.id); } catch (_) {} }
    }
    return response;
  }

  Future<AuthResponse> signInWithGoogle() async {
    final response = await authRepository.signInWithGoogle();
    final user = response.user;
    if (user != null) {
      unawaited(studentDatasource.upsertStudentProfile(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      ).catchError((_) {}));
      if (await Purchases.isConfigured) { try { await Purchases.logIn(user.id); } catch (_) {} }
    }
    return response;
  }

  Future<void> signOut() async {
    if (await Purchases.isConfigured) { try { await Purchases.logOut(); } catch (_) {} }
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
