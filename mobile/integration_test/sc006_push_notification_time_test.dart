// SC-006: Push notification delivery time benchmark
//
// Success criterion: a push notification is delivered to the student's device
// within 60 seconds of the coach sending a reply in the admin panel.
//
// Requires: physical device + Firebase Cloud Messaging configured + admin panel
// with an active coach session.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-006: push notification delivered within 60s of coach reply',
      (tester) async {
    // Arrange: student device registered for FCM, admin panel open
    // Act: coach sends a reply to a student message
    // Assert: push notification arrives on student device within 60 seconds
    final stopwatch = Stopwatch()..start();
    // TODO: app.main(), trigger coach reply, wait for notification, stop stopwatch
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(60000));
  },
      skip: true); // Requires device + Firebase Cloud Messaging credentials + admin panel
}
