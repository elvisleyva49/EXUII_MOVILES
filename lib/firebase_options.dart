// File generated by FlutterFire CLI.
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
        return windows;
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
    apiKey: 'AIzaSyA6-7zXwGkxTV4hGvXjnZvAAO8sRifEslk',
    appId: '1:484645194479:web:56a5cd85e7aec76cbca91a',
    messagingSenderId: '484645194479',
    projectId: 'proyectoleyva-9cf94',
    authDomain: 'proyectoleyva-9cf94.firebaseapp.com',
    storageBucket: 'proyectoleyva-9cf94.firebasestorage.app',
    measurementId: 'G-01YL3J7R96',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBANwBdACLH9SChXX17-NlpQEFq4W4yAS0',
    appId: '1:484645194479:android:f9d53a34a707ae81bca91a',
    messagingSenderId: '484645194479',
    projectId: 'proyectoleyva-9cf94',
    storageBucket: 'proyectoleyva-9cf94.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzXDIF3TeKa4feZzCA1Nf0z3P3VUykCcw',
    appId: '1:484645194479:ios:9b349b61494af0ebbca91a',
    messagingSenderId: '484645194479',
    projectId: 'proyectoleyva-9cf94',
    storageBucket: 'proyectoleyva-9cf94.firebasestorage.app',
    iosBundleId: 'com.example.exuiiElrs',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzXDIF3TeKa4feZzCA1Nf0z3P3VUykCcw',
    appId: '1:484645194479:ios:9b349b61494af0ebbca91a',
    messagingSenderId: '484645194479',
    projectId: 'proyectoleyva-9cf94',
    storageBucket: 'proyectoleyva-9cf94.firebasestorage.app',
    iosBundleId: 'com.example.exuiiElrs',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA6-7zXwGkxTV4hGvXjnZvAAO8sRifEslk',
    appId: '1:484645194479:web:894628b6fd26de1bbca91a',
    messagingSenderId: '484645194479',
    projectId: 'proyectoleyva-9cf94',
    authDomain: 'proyectoleyva-9cf94.firebaseapp.com',
    storageBucket: 'proyectoleyva-9cf94.firebasestorage.app',
    measurementId: 'G-E6GSLM8524',
  );
}
