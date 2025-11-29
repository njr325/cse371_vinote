import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is not supported for the current platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNEn5STm4fQGMjnQ4OZkvavkDO6c8PgWs',
    appId: '1:484633506634:android:1ccf496ff831600a74c7b3',
    messagingSenderId: '484633506634',
    projectId: 'vinote-c4419',
    storageBucket: '484633506634',
  );

}