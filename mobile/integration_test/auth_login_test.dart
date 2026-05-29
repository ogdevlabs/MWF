// Integration test: email/password login flow.
//
// Runs on a real simulator/device against the configured Supabase project.
//
// Run with:
//   flutter test integration_test/auth_login_test.dart \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_PUBLISHABLE_KEY=eyJ... \
//     --dart-define=TEST_EMAIL=user@example.com \
//     --dart-define=TEST_PASSWORD=yourpassword \
//     -d <device-id>
//
// Or use the convenience script:
//   ./local-dev/test-login.sh
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mwf_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = String.fromEnvironment('TEST_EMAIL');
  const testPassword = String.fromEnvironment('TEST_PASSWORD');

  group('Login flow', () {
    testWidgets('shows login screen on cold start', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Sign In'), findsOneWidget,
          reason: 'Login screen should be the first screen for unauthenticated users');
      expect(find.byType(TextField), findsWidgets,
          reason: 'Email and password fields should be visible');
    });

    testWidgets('email + password login succeeds and lands on Programs', (tester) async {
      if (testEmail.isEmpty || testPassword.isEmpty) {
        markTestSkipped(
          'TEST_EMAIL / TEST_PASSWORD not set. '
          'Pass via --dart-define=TEST_EMAIL=... --dart-define=TEST_PASSWORD=...',
        );
        return;
      }

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on login screen
      expect(find.text('Sign In'), findsOneWidget);

      // Enter email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, testEmail);

      // Enter password
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, testPassword);

      // Dismiss keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Tap Sign In button
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump(); // start loading

      // Wait for auth + navigation (allow up to 10s for network)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have navigated away from login
      expect(find.text('Sign In'), findsNothing,
          reason: 'Should be redirected away from login after successful auth');

      // Should be on Programs screen or onboarding
      final onPrograms = find.text('Programs');
      final onOnboarding = find.text('Welcome');
      expect(
        onPrograms.evaluate().isNotEmpty || onOnboarding.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should land on Programs or Onboarding after login',
      );
    });

    testWidgets('wrong password shows error message', (tester) async {
      if (testEmail.isEmpty) {
        markTestSkipped('TEST_EMAIL not set.');
        return;
      }

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Sign In'), findsOneWidget);

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, testEmail);

      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'definitely-wrong-password-12345');

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should still be on login with an error
      expect(find.text('Sign In'), findsOneWidget,
          reason: 'Should stay on login screen after failed auth');

      // Some error text should be visible
      final hasError = find.byType(Text).evaluate().any((e) {
        final widget = e.widget as Text;
        final text = widget.data ?? '';
        return text.toLowerCase().contains('invalid') ||
            text.toLowerCase().contains('error') ||
            text.toLowerCase().contains('wrong') ||
            text.toLowerCase().contains('incorrect') ||
            text.toLowerCase().contains('credentials');
      });
      expect(hasError, isTrue,
          reason: 'An error message should appear for wrong credentials');
    });
  });
}
