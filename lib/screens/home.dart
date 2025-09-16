
import 'package:flutter/material.dart';
import 'tuner.dart';
import 'metronome.dart';
import 'practice.dart';
import 'stats.dart';
import 'leaderboard.dart';
import 'ai_advice.dart';
import 'settings.dart';
import 'teacher.dart';
import 'tasks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [
    TunerScreen(),
    MetronomeScreen(),
    PracticeScreen(),
    StatsScreen(),
    LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎵 ' + (AppLocalizations.of(context)?.appTitle ?? 'Music Practice Assistant')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'tasks') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
              } else if (v == 'teacher') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherScreen()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'tasks', child: Text('📝 ' + (AppLocalizations.of(context)?.tasks ?? 'Tasks'))),
              PopupMenuItem(value: 'teacher', child: Text('👩‍🏫 ' + (AppLocalizations.of(context)?.teacher ?? 'Teacher'))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AiAdviceScreen()));
            },
          )
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.tune), label: AppLocalizations.of(context)?.tabTuner ?? 'Tuner'),
          NavigationDestination(icon: const Icon(Icons.av_timer), label: AppLocalizations.of(context)?.tabMetronome ?? 'Metronome'),
          NavigationDestination(icon: const Icon(Icons.fiber_manual_record), label: AppLocalizations.of(context)?.tabPractice ?? 'Practice'),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)?.tabStats ?? 'Stats'),
          NavigationDestination(icon: const Icon(Icons.emoji_events), label: AppLocalizations.of(context)?.tabRanks ?? 'Ranks'),
        ],
      ),
    );
  }
}
