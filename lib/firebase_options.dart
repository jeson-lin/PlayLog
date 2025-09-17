// ignore_for_file: constant_identifier_names
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
        return linux;
      default:
        return android;
    }
  }

  // 下面的值都是占位用，之後請用 flutterfire 重新產生
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'xxx',
    appId: '1:xxx:android:xxx',
    messagingSenderId: 'xxx',
    projectId: 'xxx',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'xxx',
    appId: '1:xxx:ios:xxx',
    messagingSenderId: 'xxx',
    projectId: 'xxx',
    iosBundleId: 'com.example.playlogFix',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}
