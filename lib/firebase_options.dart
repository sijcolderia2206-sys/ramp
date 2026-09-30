import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEupEaVWNALulZdADc9s1KUImBHNz-ME0',
    appId: '1:744537744434:android:7f35c6f75e7d17d0fa882b',
    messagingSenderId: '744537744434',
    projectId: 'rampdb123',
    storageBucket: 'rampdb123.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0kBf8GfkO756xM8nQJx-CYlF7EVS6IWk',
    appId: '1:744537744434:web:1d24dd4108d92ff9fa882b',
    messagingSenderId: '744537744434',
    projectId: 'rampdb123',
    authDomain: 'rampdb123.firebaseapp.com',
    storageBucket: 'rampdb123.firebasestorage.app',
    measurementId: 'G-KZSCYGHT1Z',
  );
}
