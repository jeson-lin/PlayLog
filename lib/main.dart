// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 如果你已經用 flutterfire 產生了 lib/firebase_options.dart，保留下面這行；
// 若尚未產生，先暫時註解掉，並改用下方的「沒有 options 的初始化」。
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 正式做法（已產生 firebase_options.dart）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ❌ 如果還沒產生 firebase_options.dart，請先用這個暫時跑 Android：
  // await Firebase.initializeApp(); // Android 會讀 android/app/google-services.json

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
