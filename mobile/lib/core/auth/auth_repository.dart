import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

part 'auth_repository.g.dart';

/// Repository wrapping Supabase Auth operations.
///
/// All sign-in methods return void on success and throw [AuthException] on failure.
/// Use [authStateProvider] to reactively observe auth state changes.
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  /// Sign up with email and password.
  /// Creates a new user account. Does NOT auto-confirm — user must verify email
  /// unless Supabase project has email confirmation disabled.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Apple (iOS native flow).
  ///
  /// Uses sign_in_with_apple package + SHA-256 nonce for security.
  /// Requires "Sign In with Apple" capability in Xcode.
  Future<AuthResponse> signInWithApple() async {
    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('No ID token returned from Apple Sign-In');
    }

    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  /// Sign in with Google.
  ///
  /// TODO Phase 3: Configure actual Google OAuth client IDs.
  /// Requires --dart-define=GOOGLE_WEB_CLIENT_ID=xxx and
  /// --dart-define=GOOGLE_IOS_CLIENT_ID=xxx at build time.
  /// Until credentials are configured, this method will throw.
  Future<AuthResponse> signInWithGoogle() async {
    // TODO(phase3): Set up Google OAuth credentials in Google Cloud Console.
    // Pass via: --dart-define=GOOGLE_WEB_CLIENT_ID=your_web_client_id
    //           --dart-define=GOOGLE_IOS_CLIENT_ID=your_ios_client_id
    // See: https://supabase.com/docs/guides/auth/social-login/auth-google?platform=flutter
    //
    // google_sign_in 7.x uses a singleton with initialize() + authenticate().
    // Credentials must be configured before calling this method.
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

    if (webClientId.isEmpty) {
      throw const AuthException(
        'GOOGLE_WEB_CLIENT_ID not configured. '
        'Pass via --dart-define=GOOGLE_WEB_CLIENT_ID=your_id',
      );
    }

    // Initialize the GoogleSignIn singleton with credentials (7.x API).
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
      clientId: iosClientId.isNotEmpty ? iosClientId : null,
    );

    // Use authenticate() — replaces signIn() in google_sign_in 7.x.
    final googleUser = await GoogleSignIn.instance.authenticate();

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('No ID token from Google Sign-In');
    }

    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get the currently authenticated user (null if not signed in).
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  ///
  /// CRITICAL: Must have onError handler — network errors during token refresh
  /// will crash the app if unhandled.
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
}
