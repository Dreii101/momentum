import '../../core/database/value_types.dart';
import 'timer_engine.dart';

abstract interface class TimerClock {
  TimeSample sample();
}

class SystemTimerClock implements TimerClock {
  SystemTimerClock({required this.wallClock, required this.epoch});
  final Clock wallClock;
  final String epoch;
  final Stopwatch _elapsed = Stopwatch()..start();
  @override
  TimeSample sample() =>
      TimeSample(wallClock(), _elapsed.elapsedMilliseconds, epoch);
}
