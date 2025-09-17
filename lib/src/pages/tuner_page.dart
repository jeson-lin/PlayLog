import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';
import 'dart:math' as math;

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});
  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final _fft = FlutterFft();
  bool _listening = false;
  double _freq = 0.0;
  String _note = '--';
  double _targetFreq = 0.0;

  static const List<String> _notes = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];

  double _noteToFreq(int midi) => 440.0 * math.pow(2, (midi - 69) / 12.0);
  int _freqToMidi(double f) => (69 + 12 * (math.log(f / 440.0) / math.ln2)).round();

  Future<void> _toggle() async {
    if (_listening) {
      await _fft.stopRecorder();
      setState(() => _listening = false);
    } else {
      await _fft.startRecorder();
      _fft.onRecorderStateChanged.listen((data) {
        final freq = (data[1] as double?) ?? 0.0;
        if (freq <= 0) return;
        final midi = _freqToMidi(freq);
        final idx = midi % 12;
        setState(() {
          _freq = freq;
          _note = _notes[idx];
          _targetFreq = _noteToFreq(midi);
        });
      });
      setState(() => _listening = true);
    }
  }

  double get _cents {
    if (_freq <= 0 || _targetFreq <= 0) return 0;
    return 1200 * (math.log(_freq / _targetFreq) / math.ln2);
  }

  @override
  Widget build(BuildContext context) {
    final cents = _cents.clamp(-100.0, 100.0);
    return Scaffold(
      appBar: AppBar(title: const Text('調音器')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('偵測頻率：${_freq.toStringAsFixed(2)} Hz', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('音名：$_note', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('偏差：${cents.toStringAsFixed(1)} cents'),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: (cents + 100) / 200,
              minHeight: 12,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_listening ? Icons.stop_circle_outlined : Icons.play_arrow),
              child: Text(_listening ? '停止偵測' : '開始偵測'),
            ),
          ],
        ),
      ),
    );
  }
}
