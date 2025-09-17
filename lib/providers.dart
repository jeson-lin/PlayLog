import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PracticeSession {
  final DateTime startedAt;
  final Duration duration;
  final String? instrument;

  PracticeSession({
    required this.startedAt,
    required this.duration,
    this.instrument,
  });
}

class PracticeSessionsNotifier extends StateNotifier<List<PracticeSession>> {
  PracticeSessionsNotifier() : super(const []);

  void add(PracticeSession s) => state = [s, ...state];
  void removeAt(int index) {
    final list = [...state]..removeAt(index);
    state = list;
  }
  void clear() => state = const [];
}

final practiceSessionsProvider =
    StateNotifierProvider<PracticeSessionsNotifier, List<PracticeSession>>(
  (ref) => PracticeSessionsNotifier(),
);

class PracticeTimerState {
  final bool isRunning;
  final Duration elapsed;
  final DateTime? startedAt;

  const PracticeTimerState({
    required this.isRunning,
    required this.elapsed,
    required this.startedAt,
  });

  PracticeTimerState copyWith({
    bool? isRunning,
    Duration? elapsed,
    DateTime? startedAt,
  }) {
    return PracticeTimerState(
      isRunning: isRunning ?? this.isRunning,
      elapsed: elapsed ?? this.elapsed,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  static const initial = PracticeTimerState(
    isRunning: false,
    elapsed: Duration.zero,
    startedAt: null,
  );
}

class PracticeTimerNotifier extends StateNotifier<PracticeTimerState> {
  PracticeTimerNotifier() : super(PracticeTimerState.initial);
  Timer? _ticker;

  void start() {
    if (state.isRunning) return;
    final startBase = state.startedAt ?? DateTime.now();
    state = state.copyWith(isRunning: true, startedAt: startBase);
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final base = state.startedAt ?? DateTime.now();
      final elapsed = DateTime.now().difference(base);
      state = state.copyWith(elapsed: elapsed, isRunning: true);
    });
  }

  void pause() {
    if (!state.isRunning) return;
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    state = PracticeTimerState.initial;
  }

  void saveCurrent(WidgetRef ref, {String? instrument}) {
    if (state.elapsed.inSeconds <= 0) return;
    final startedAt = state.startedAt ?? DateTime.now().subtract(state.elapsed);
    final session = PracticeSession(
      startedAt: startedAt,
      duration: state.elapsed,
      instrument: instrument,
    );
    ref.read(practiceSessionsProvider.notifier).add(session);
    reset();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final practiceTimerProvider =
    StateNotifierProvider<PracticeTimerNotifier, PracticeTimerState>(
  (ref) => PracticeTimerNotifier(),
);
