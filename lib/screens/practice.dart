
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/stats_service.dart';
import '../services/ads_service.dart';
import '../services/practice_detector.dart';
import '../services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String instrument = 'piano';
  bool listening = false;
  Duration lastSession = Duration.zero;
  DateTime? lastStart;
  DateTime? lastEnd;
  late PracticeDetector detector;
  String status = 'Idle';

  @override
  void initState() {
    super.initState();
    detector = PracticeDetector(onClosed: _onSessionClosed);
    AdsService.instance.ensureInterstitialLoaded();
  }

  Future<void> _onSessionClosed(DateTime start, DateTime end, String inst, double activeRatio) async {
    final dur = end.difference(start);
    setState(() {
      lastSession = dur;
      lastStart = start;
      lastEnd = end;
      status = 'Session saved (${dur.inSeconds}s)';
    });
    try {
      await FirestoreService.instance.addPracticeSession(
        start: start,
        end: end,
        instrument: inst,
        durationSec: dur.inMilliseconds / 1000.0,
        activeRatio: activeRatio,
      );
      await StatsService.instance.updateAggregatesAndLeaderboards(
        start: start,
        end: end,
        instrument: inst,
        durationSec: dur.inMilliseconds / 1000.0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: ${inst} ${dur.inSeconds}s')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      AdsService.instance.showInterstitialIfReady();
      AdsService.instance.ensureInterstitialLoaded();
    }
  }

  Future<void> _toggle() async {
    if (listening) {
      await detector.stop();
      setState(() {
        listening = false;
        status = 'Idle';
      });
    } else {
      setState(() {
        status = 'Listening…';
      });
      try {
        final rms = await SettingsService.instance.getRmsThDb();
        final gaps = await SettingsService.instance.getGaps();
        detector = PracticeDetector(onClosed: _onSessionClosed, rmsDbfsTh: rms, gapToCloseSec: gaps);
        await detector.start(instrument);
        setState(() {
          listening = true;
          status = 'Listening…';
        });
      } catch (e) {
        setState(() => status = 'Mic permission needed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('需要麥克風權限：$e')));
        }
      }
    }
  }

  @override
  void dispose() {
    detector.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('🎶 ' + (AppLocalizations.of(context)?.practiceLogger ?? 'Practice Logger (Auto-Detect)'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(AppLocalizations.of(context)?.instrument ?? 'Instrument:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: instrument,
                items: const [
                  DropdownMenuItem(value: 'piano', child: Text('Piano')),
                  DropdownMenuItem(value: 'violin', child: Text('Violin')),
                  DropdownMenuItem(value: 'flute', child: Text('Flute')),
                  DropdownMenuItem(value: 'guitar', child: Text('Guitar')),
                  DropdownMenuItem(value: 'drums', child: Text('Drums')),
                ],
                onChanged: listening ? null : (v) => setState(() => instrument = v ?? 'piano'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _toggle,
                child: Text(listening ? (AppLocalizations.of(context)?.stop ?? 'Stop') : (AppLocalizations.of(context)?.start ?? 'Start')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((AppLocalizations.of(context)?.status ?? 'Status') + ': ' + status),
                  const SizedBox(height: 8),
                  Text((AppLocalizations.of(context)?.lastSession ?? 'Last session') + ': ${lastSession.inMinutes}m ${lastSession.inSeconds % 60}s'),
                  if (lastStart != null) Text((AppLocalizations.of(context)?.from ?? 'From') + ': ${lastStart}'),
                  if (lastEnd != null) Text((AppLocalizations.of(context)?.to ?? 'To') + ':   ${lastEnd}'),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)?.rulesHint ?? 'Rules'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
