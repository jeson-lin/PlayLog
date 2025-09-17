import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});
  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  int _bpm = 100;
  bool _running = false;
  Timer? _timer;
  bool _blink = false;

  void _start() {
    _timer?.cancel();
    final interval = Duration(milliseconds: (60000 / _bpm).round());
    _timer = Timer.periodic(interval, (_) async {
      setState(() => _blink = !_blink);
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 20, amplitude: 64);
      }
    });
    setState(() => _running = true);
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _blink = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('節拍器')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('BPM: $_bpm', style: Theme.of(context).textTheme.titleLarge),
            Slider(
              value: _bpm.toDouble(),
              min: 30,
              max: 240,
              divisions: 210,
              label: '$_bpm',
              onChanged: (v) {
                setState(() => _bpm = v.round());
                if (_running) _start();
              },
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 120,
              decoration: BoxDecoration(
                color: _blink ? Colors.greenAccent.withOpacity(.5) : Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('Tick')),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _running ? null : _start,
                    child: const Text('開始'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _running ? _stop : null,
                    child: const Text('停止'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
