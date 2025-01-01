import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY_WEB',
    appId: 'VOTRE_APP_ID_WEB',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    authDomain: 'VOTRE_AUTH_DOMAIN',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY_ANDROID',
    appId: 'VOTRE_APP_ID_ANDROID',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY_IOS',
    appId: 'VOTRE_APP_ID_IOS',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
    iosClientId: 'VOTRE_IOS_CLIENT_ID',
    iosBundleId: 'com.shayniss.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY_MACOS',
    appId: 'VOTRE_APP_ID_MACOS',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
    iosClientId: 'VOTRE_MACOS_CLIENT_ID',
    iosBundleId: 'com.shayniss.app',
  );
}
