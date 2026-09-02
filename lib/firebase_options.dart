// File generated for MyDigi Firebase Project (mydigi-a2402).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyMyDigiWebKey740310683452A2402Project',
    appId: '1:740310683452:web:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: '740310683452',
    projectId: 'mydigi-a2402',
    authDomain: 'mydigi-a2402.firebaseapp.com',
    storageBucket: 'mydigi-a2402.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyMyDigiAndroidKey740310683452A2402',
    appId: '1:740310683452:android:694f58c49e5d4821a2402b',
    messagingSenderId: '740310683452',
    projectId: 'mydigi-a2402',
    storageBucket: 'mydigi-a2402.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyMyDigiIosKey740310683452A2402Proj',
    appId: '1:740310683452:ios:78324e931ca8b271a2402c',
    messagingSenderId: '740310683452',
    projectId: 'mydigi-a2402',
    storageBucket: 'mydigi-a2402.appspot.com',
    iosBundleId: 'com.warrantyx.app.warrantyxApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyMyDigiIosKey740310683452A2402Proj',
    appId: '1:740310683452:ios:78324e931ca8b271a2402c',
    messagingSenderId: '740310683452',
    projectId: 'mydigi-a2402',
    storageBucket: 'mydigi-a2402.appspot.com',
    iosBundleId: 'com.warrantyx.app.warrantyxApp',
  );
}
