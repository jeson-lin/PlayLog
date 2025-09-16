// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

// 如果你已經用 flutterfire 產生了 lib/firebase_options.dart，保留下面這行；
// 若尚未產生，先暫時註解掉，並改用下方的「沒有 options 的初始化」。
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 跨平台安全初始化
  // - Web：一定需要 options（走 firebase_options.dart 的 web 常數）
  // - Android/iOS：可使用原生檔案自動初始化（Android 用 google-services.json、iOS 用 GoogleService-Info.plist）
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlayLog',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlayLog Home')),
      body: const Center(child: Text('Firebase initialized!')),
    );
  }
}
