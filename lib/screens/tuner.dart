
import 'package:flutter/material.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  String note = 'A4';
  double cents = 0;

  // TODO: Implement mic capture + pitch detection via plugin/native channel.
  // For now, show a mock UI.

  @override
  Widget build(BuildContext context) {
    final isInTune = cents.abs() <= 5;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text('🎸 Tuner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Detected: $note', style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text('Deviation: ${cents.toStringAsFixed(1)} cents',
                      style: TextStyle(
                        fontSize: 18,
                        color: isInTune ? Colors.green : Colors.orange,
                      )),
                  const SizedBox(height: 24),
                  _TuningNeedle(cents: cents),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // mock wiggle
                        cents = ([-15, -7, -3, 0, 2, 6, 12]..shuffle()).first.toDouble();
                        note = (['E4', 'A4', 'D4', 'G3']..shuffle()).first;
                      });
                    },
                    child: const Text('Mock Detect'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tip: play one string/note at a time for best results.'),
        ],
      ),
    );
  }
}

class _TuningNeedle extends StatelessWidget {
  final double cents;
  const _TuningNeedle({required this.cents});

  @override
  Widget build(BuildContext context) {
    // Map cents (-50..+50) to alignment (-1..+1)
    final clamped = cents.clamp(-50, 50);
    final align = clamped / 50;
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Align(alignment: const Alignment(-1, 0), child: Text('Low')),
          const Align(alignment: Alignment(0, 0), child: Text('|')),
          Align(alignment: const Alignment(1, 0), child: Text('High')),
          Align(
            alignment: Alignment(align, 0.7),
            child: const Icon(Icons.arrow_drop_up, size: 40),
          ),
        ],
      ),
    );
  }
}
