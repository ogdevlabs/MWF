// GENERATED FILE — DO NOT EDIT MANUALLY
// This is a placeholder stub. Replace with output of:
//   flutterfire configure
//
// Prerequisites:
//   1. Install Firebase CLI: npm install -g firebase-tools
//   2. Install FlutterFire CLI: dart pub global activate flutterfire_cli
//   3. Login: firebase login
//   4. Create a Firebase project at https://console.firebase.google.com
//   5. Run: flutterfire configure --project=YOUR_PROJECT_ID
//
// This stub allows the project to compile without a real Firebase project.
// Firebase features (push notifications) will not function until this is
// replaced with real values.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with real values from flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO-replace-with-real-api-key',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'mwf-pilates-placeholder',
    storageBucket: 'mwf-pilates-placeholder.appspot.com',
  );

  // TODO: Replace with real values from flutterfire configure
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO-replace-with-real-api-key',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'mwf-pilates-placeholder',
    storageBucket: 'mwf-pilates-placeholder.appspot.com',
    iosBundleId: 'com.fererelabs.mwfMobile',
  );
}
