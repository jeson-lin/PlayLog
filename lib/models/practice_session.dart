
class PracticeSession {
  final DateTime start;
  final DateTime end;
  final String instrument;
  final double activeRatio;
  final double durationSec;

  PracticeSession({
    required this.start,
    required this.end,
    required this.instrument,
    required this.activeRatio,
    required this.durationSec,
  });

  Map<String, dynamic> toMap() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'instrument': instrument,
    'activeRatio': activeRatio,
    'durationSec': durationSec,
  };
}
