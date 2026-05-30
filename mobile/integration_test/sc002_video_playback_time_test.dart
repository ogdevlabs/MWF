// SC-002: Video playback start-time benchmark
//
// Success criterion: video playback begins within 2 seconds of the session
// screen opening, given the video content has already been downloaded.
//
// Requires: physical/simulated device with pre-downloaded video content.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-002: video playback starts within 2s (pre-downloaded)',
      (tester) async {
    // Arrange: device with pre-downloaded exercise video
    // Act: open session player screen
    // Assert: playback begins in < 2 seconds
    final stopwatch = Stopwatch()..start();
    // TODO: app.main(), navigate to session with pre-downloaded video
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  }, skip: true); // Requires device + pre-downloaded video content
}
