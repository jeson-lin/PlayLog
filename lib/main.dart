import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PlayLogApp()));
}

class PlayLogApp extends StatefulWidget {
  const PlayLogApp({super.key});
  @override
  State<PlayLogApp> createState() => _PlayLogAppState();
}

class _PlayLogAppState extends State<PlayLogApp> {
  late final Future<FirebaseApp> _initFirebase;
  @override
  void initState() {
    super.initState();
    _initFirebase = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _initFirebase,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('初始化失敗')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Firebase 初始化錯誤：\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          } else {
            return const HomePage();
          }
        },
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(practiceTimerProvider);
    final sessions = ref.watch(practiceSessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlayLog 首頁'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            _fmt(timer.elapsed),
            style: const TextStyle(fontSize: 36, fontFeatures: [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(timer.isRunning ? '暫停' : '開始'),
                onPressed: () => timer.isRunning
                    ? ref.read(practiceTimerProvider.notifier).pause()
                    : ref.read(practiceTimerProvider.notifier).start(),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('存成一筆練習'),
                onPressed: timer.elapsed.inSeconds > 0
                    ? () => ref.read(practiceTimerProvider.notifier).saveCurrent(ref)
                    : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('重置'),
                onPressed: () => ref.read(practiceTimerProvider.notifier).reset(),
              ),
            ],
          ),
          const Divider(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('練習紀錄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (_, i) {
                final s = sessions[i];
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text('${_fmt(s.duration)}  •  ${s.instrument ?? "未指定"}'),
                  subtitle: Text('${s.startedAt}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(practiceSessionsProvider.notifier).removeAt(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('關於 PlayLog')),
      body: const Center(
        child: Text(
          '這是一個結合 Firebase + Riverpod 的 Flutter 範例。\n'
          '之後可擴充錄音、雲端同步、統計報表與分享等功能。',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _fmt(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = two(d.inHours);
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  return '$h:$m:$s';
}
