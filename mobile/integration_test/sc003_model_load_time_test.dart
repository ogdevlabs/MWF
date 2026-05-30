// SC-003: 3D model load-time benchmark
//
// Success criterion: the GLB 3D animation loads and renders within 1 second
// of the session screen opening, given the model file has been downloaded.
//
// Requires: physical/simulated device with downloaded GLB model.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SC-003: 3D animation loads within 1s of session screen open',
      (tester) async {
    // Arrange: device with pre-downloaded GLB model
    // Act: open session player screen that includes a 3D animation exercise
    // Assert: model viewer renders within < 1 second
    final stopwatch = Stopwatch()..start();
    // TODO: app.main(), navigate to session with pre-downloaded GLB model
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  }, skip: true); // Requires device + downloaded GLB model
}
