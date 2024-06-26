// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyCKxSETXWhR4JkddHz_U_HZpi470wYjycE',
    appId: '1:1013381454417:web:15e239ad52a880b7b03670',
    messagingSenderId: '1013381454417',
    projectId: 'location-chat-6c668',
    authDomain: 'location-chat-6c668.firebaseapp.com',
    storageBucket: 'location-chat-6c668.appspot.com',
    measurementId: 'G-BG10S3W3CP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDocKgwjhTlRN_wYC4auBOlpjsYNp8uO-4',
    appId: '1:1013381454417:android:e52ac7ab9ccb2ffbb03670',
    messagingSenderId: '1013381454417',
    projectId: 'location-chat-6c668',
    storageBucket: 'location-chat-6c668.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwb4vXfbUa4RH5yOedxlJ9W3KpfJur2MI',
    appId: '1:1013381454417:ios:995e0cc01a56dfbcb03670',
    messagingSenderId: '1013381454417',
    projectId: 'location-chat-6c668',
    storageBucket: 'location-chat-6c668.appspot.com',
    iosBundleId: 'com.example.chatapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDwb4vXfbUa4RH5yOedxlJ9W3KpfJur2MI',
    appId: '1:1013381454417:ios:e18d5914d53186efb03670',
    messagingSenderId: '1013381454417',
    projectId: 'location-chat-6c668',
    storageBucket: 'location-chat-6c668.appspot.com',
    iosBundleId: 'com.example.chatapp.RunnerTests',
  );
}
