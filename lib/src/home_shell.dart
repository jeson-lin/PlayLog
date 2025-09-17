import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/practice_page.dart';
import 'pages/recorder_page.dart';
import 'pages/tuner_page.dart';
import 'pages/metronome_page.dart';
import 'pages/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final pages = const [
    HomePage(),
    PracticePage(),
    RecorderPage(),
    TunerPage(),
    MetronomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首頁'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: '練習'),
          NavigationDestination(icon: Icon(Icons.mic_none), label: '錄音'),
          NavigationDestination(icon: Icon(Icons.music_note_outlined), label: '調音'),
          NavigationDestination(icon: Icon(Icons.av_timer_outlined), label: '節拍'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: '設定'),
        ],
      ),
    );
  }
}
