// SC-005: Coach creates + publishes a program — manual verification stub
//
// Success criterion: a coach can create a new program, add a session with
// exercises, upload a video, publish the program, and verify it appears in
// the student app — all within 15 minutes.
//
// This criterion is verified manually via the Next.js admin panel.
// Flutter integration tests cannot automate the web admin UI.
//
// Manual test steps:
//   1. Log in to admin panel at /admin/login
//   2. Navigate to Programs > New Program
//   3. Fill in title, description; click Create
//   4. Add a session with at least one exercise
//   5. Upload a video for the exercise (Mux upload)
//   6. Click Publish on the program
//   7. Open the student mobile app; verify the program appears in Programs tab
//   8. Record total elapsed time — must be < 15 minutes
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-005: coach creates + publishes program in under 15 minutes',
      (tester) async {
    // No automation possible — see manual test steps in file header comment.
  },
      skip: true); // Manual verification — admin panel E2E not automatable in Flutter integration tests
}
