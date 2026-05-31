#!/usr/bin/env python3
"""Generate mobile/lib/firebase_options.dart from committed config files."""
import json, plistlib, pathlib, textwrap

gsf = json.loads(pathlib.Path('mobile/android/app/google-services.json').read_text())
client = gsf['client'][0]
android_api_key = client['api_key'][0]['current_key']
android_app_id = client['client_info']['mobilesdk_app_id']
sender_id = gsf['project_info']['project_number']
project_id = gsf['project_info']['project_id']
storage_bucket = gsf['project_info']['storage_bucket']

plist = plistlib.loads(pathlib.Path('mobile/ios/Runner/GoogleService-Info.plist').read_bytes())
ios_api_key = plist['API_KEY']
ios_app_id = plist['GOOGLE_APP_ID']
ios_bundle_id = plist['BUNDLE_ID']

content = textwrap.dedent(f"""\
    // GENERATED FILE — DO NOT EDIT MANUALLY
    // Generated in CI from google-services.json and GoogleService-Info.plist

    import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
    import 'package:flutter/foundation.dart'
        show defaultTargetPlatform, TargetPlatform;

    class DefaultFirebaseOptions {{
      static FirebaseOptions get currentPlatform {{
        switch (defaultTargetPlatform) {{
          case TargetPlatform.android:
            return android;
          case TargetPlatform.iOS:
            return ios;
          default:
            throw UnsupportedError(
              'DefaultFirebaseOptions are not supported for this platform.',
            );
        }}
      }}

      static const FirebaseOptions android = FirebaseOptions(
        apiKey: '{android_api_key}',
        appId: '{android_app_id}',
        messagingSenderId: '{sender_id}',
        projectId: '{project_id}',
        storageBucket: '{storage_bucket}',
      );

      static const FirebaseOptions ios = FirebaseOptions(
        apiKey: '{ios_api_key}',
        appId: '{ios_app_id}',
        messagingSenderId: '{sender_id}',
        projectId: '{project_id}',
        storageBucket: '{storage_bucket}',
        iosBundleId: '{ios_bundle_id}',
      );
    }}
    """)

pathlib.Path('mobile/lib/firebase_options.dart').write_text(content)
print('Generated mobile/lib/firebase_options.dart')
