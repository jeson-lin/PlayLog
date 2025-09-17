
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int bpm = 80;
  int beats = 4;
  Timer? _timer;
  int _count = 0;
  final _player = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _tick() async {
    _count = (_count % beats) + 1;
    // Load once
    if (_player.audioSource == null) {
      await _player.setAsset('assets/audio/tick.mp3');
    }
    await _player.seek(Duration.zero);
    await _player.play();
    setState(() {});
  }

  void _start() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / bpm).round());
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void _stop() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('🥁 Metronome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => setState(() => bpm = (bpm - 1).clamp(30, 240)), icon: const Icon(Icons.remove)),
              Text('$bpm BPM', style: const TextStyle(fontSize: 24)),
              IconButton(onPressed: () => setState(() => bpm = (bpm + 1).clamp(30, 240)), icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Beats:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: beats,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2/4')),
                  DropdownMenuItem(value: 3, child: Text('3/4')),
                  DropdownMenuItem(value: 4, child: Text('4/4')),
                  DropdownMenuItem(value: 6, child: Text('6/8')),
                ],
                onChanged: (v) => setState(() => beats = v ?? 4),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(beats, (i) {
              final active = (i + 1) == _count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CircleAvatar(
                  radius: active ? 12 : 8,
                  backgroundColor: active ? Colors.red : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _start, child: const Text('Start')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _stop, child: const Text('Stop')),
            ],
          )
        ],
      ),
    );
  }
}
