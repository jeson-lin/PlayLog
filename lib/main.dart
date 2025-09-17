import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PlayLogApp());
}

class PlayLogApp extends StatelessWidget {
  const PlayLogApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const AuthGate(),
    );
  }
}
