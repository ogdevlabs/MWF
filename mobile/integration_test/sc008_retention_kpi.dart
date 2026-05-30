// SC-008: 30-day retention rate KPI
//
// Success criterion: at least 60% of users who install the app and complete
// onboarding return and complete at least one session within 30 days.
//
// This is a post-launch KPI, not an automated test. No assertion is made here.
// Tracked via analytics dashboard (e.g., Firebase Analytics, Mixpanel).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-008: 30-day retention rate target >= 60%', (tester) async {
    // KPI metric — no automated assertion.
    // Monitor via analytics dashboard:
    //   - cohort retention report (D1, D7, D30)
    //   - target: >= 60% of onboarded users return within 30 days
  }, skip: true); // KPI metric — tracked via analytics dashboard post-launch
}
