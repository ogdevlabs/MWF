import 'package:flutter_test/flutter_test.dart';

// Wave 0 stub — tests will be filled when FeedbackRepository is implemented
void main() {
  group('FeedbackRepository', () {
    test('submitFeedback writes to Drift and enqueues SyncQueue', () {
      // TODO: implement after FeedbackRepository exists
    });

    test('submitFeedback with offline status sets pending', () {
      // TODO: implement — verify status='pending' when offline
    });

    test('submitFeedback stores localPhotoPath when offline with photo', () {
      // TODO: implement — verify localPhotoPath is set
    });

    test('watchThread returns ordered stream of feedback messages', () {
      // TODO: implement — verify stream emission
    });
  });
}
