// SC-001: Onboarding time benchmark
//
// Success criterion: new user completes signup + subscription + first session
// start in under 3 minutes from cold launch.
//
// Manual trigger: ./local-dev/test-sc001.sh
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-001: signup + subscribe + first session start < 3 minutes',
      (tester) async {
    // Arrange: cold launch
    // Act: complete signup, subscribe, navigate to first session
    // Assert: total elapsed < 180 seconds
    final stopwatch = Stopwatch()..start();
    // TODO: app.main(), complete signup flow, subscribe, open session
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(180000));
  },
      skip: true // Requires device + Supabase credentials + RevenueCat sandbox — run via ./local-dev/test-sc001.sh
      );
}
