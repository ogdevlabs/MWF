import 'package:flutter_test/flutter_test.dart';

// Wave 0 stub — tests will be filled when FcmService is implemented
void main() {
  group('FcmService', () {
    test('registerToken obtains FCM token and upserts to students table', () {
      // TODO: implement with mock FirebaseMessaging
    });

    test('onTokenRefresh updates token in students table', () {
      // TODO: implement with mock token refresh stream
    });

    test('handleMessage navigates to /coach-chat on coach_reply type', () {
      // TODO: implement with mock RemoteMessage
    });
  });
}
