
import 'dart:async';
import 'package:record/record.dart';

typedef SessionClosed = Future<void> Function(DateTime start, DateTime end, String instrument, double activeRatio);

class PracticeDetector {
  final _rec = Record();
  StreamSubscription<Amplitude>? _sub;

  // Parameters
  final double rmsDbfsTh; // e.g., -45 dBFS
  final Map<String, double> gapToCloseSec; // instrument -> gap seconds
  final Duration minSession = const Duration(seconds: 15);
  final double minActiveRatio = 0.35;

  // State
  bool listening = false;
  String instrument = 'piano';
  DateTime? _startTs;
  DateTime? _lastActiveTs;
  int _activeFrames = 0;
  int _totalFrames = 0;

  final SessionClosed onClosed;

  PracticeDetector({
    required this.onClosed,
    this.rmsDbfsTh = -45.0,
    Map<String, double>? gapToCloseSec,
  }) : gapToCloseSec = gapToCloseSec ?? const {
          'piano': 20.0,
          'violin': 12.0,
          'flute': 12.0,
          'guitar': 25.0,
          'drums': 10.0,
        };

  Future<void> start(String inst) async {
    instrument = inst;
    if (listening) return;
    final perm = await _rec.hasPermission();
    if (!perm) {
      throw Exception('No mic permission');
    }
    listening = true;
    _startTs = null;
    _lastActiveTs = null;
    _activeFrames = 0;
    _totalFrames = 0;

    // Start dummy recording to enable amplitude stream (no file saved)
    await _rec.start(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      samplingRate: 16000,
      path: null, // some platforms ignore null; amplitudeStream works if recording active
    );
    _sub = _rec
        .amplitudeStream(const Duration(milliseconds: 250))
        .listen(_onAmp, onError: (_) {}, onDone: () {});
  }

  Future<void> stop() async {
    listening = false;
    await _sub?.cancel();
    _sub = null;
    await _rec.stop();
    await _tryClose(force: true);
  }

  void _onAmp(Amplitude a) {
    if (!listening) return;
    final db = a.current; // 0 .. negative dBFS values (record plugin reports negative)
    final now = DateTime.now();
    final isActive = db > rmsDbfsTh;
    _totalFrames += 1;
    if (isActive) _activeFrames += 1;

    if (_startTs == null && isActive) {
      _startTs = now;
      _lastActiveTs = now;
      return;
    }
    if (_startTs != null) {
      if (isActive) _lastActiveTs = now;
      _tryClose();
    }
  }

  Future<void> _tryClose({bool force = false}) async {
    if (_startTs == null) return;
    final gap = gapToCloseSec[instrument] ?? 20.0;
    final now = DateTime.now();
    final last = _lastActiveTs ?? _startTs!;
    final gapDur = now.difference(last).inMilliseconds / 1000.0;
    final dur = now.difference(_startTs!).inMilliseconds / 1000.0;

    final activeRatio = _totalFrames > 0 ? (_activeFrames / _totalFrames) : 0.0;

    if (force || gapDur >= gap) {
      // close
      final start = _startTs!;
      final end = last;
      _startTs = null;
      _lastActiveTs = null;
      final ok = (end.difference(start) >= minSession) && (activeRatio >= minActiveRatio);
      if (ok) {
        await onClosed(start, end, instrument, activeRatio);
      }
      // reset counters for next session
      _activeFrames = 0;
      _totalFrames = 0;
    }
  }
}
