import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/focus/timer_engine.dart';

class FakeTimerClock implements TimerClock {
  DateTime wall = DateTime.utc(2026, 10, 21, 15, 59, 50);
  int elapsed = 0;
  String epoch = 'test-process';
  void advance(int ms, {int? wallMs}) {
    elapsed += ms;
    wall = wall.add(Duration(milliseconds: wallMs ?? ms));
  }

  @override
  TimeSample sample() => TimeSample(wall, elapsed, epoch);
}

void main() {
  late FakeTimerClock clock;
  setUp(() => clock = FakeTimerClock());
  TimerRecord start({SessionKind kind = SessionKind.focus, int minutes = 25}) =>
      TimerMachine.start('session', kind, minutes, clock.sample());
  TimerRecord apply(
    TimerRecord r,
    TimerAction action, {
    int minutes = 0,
    int? reported,
    bool confirmed = false,
  }) => TimerMachine.command(
    r,
    clock.sample(),
    action,
    minutes: minutes,
    reportedMs: reported,
    confirmed: confirmed,
  ).record;

  test('starter exactly 120 seconds; focus and break bounds', () {
    expect(start(kind: SessionKind.starter, minutes: 99).plannedMs, 120000);
    for (final n in [0, 181]) {
      expect(() => start(minutes: n), throwsFormatException);
    }
    expect(start(minutes: 180).plannedMs, 10800000);
    expect(
      () => start(kind: SessionKind.rest, minutes: 61),
      throwsFormatException,
    );
  });
  test(
    'elapsed clock determines observed duration; duplicate samples add nothing',
    () {
      var r = start();
      clock.advance(4999);
      r = apply(r, TimerAction.checkpoint);
      expect(r.elapsedMs, 4999);
      expect(r.eligibleMs, 4999);
      expect(r.reportedMs, isNull);
      final same = apply(r, TimerAction.checkpoint);
      expect(identical(same, r), isTrue);
      clock.advance(1);
      r = apply(r, TimerAction.checkpoint);
      expect(r.elapsedMs, 5000);
    },
  );
  test(
    'pause/resume excludes all pause time and repeated commands are harmless',
    () {
      var r = start();
      clock.advance(5000);
      r = apply(r, TimerAction.pause);
      final paused = r;
      clock.advance(60000);
      expect(identical(apply(r, TimerAction.pause), paused), isTrue);
      r = apply(r, TimerAction.resume);
      expect(r.elapsedMs, 5000);
      expect(identical(apply(r, TimerAction.resume), r), isTrue);
      clock.advance(5000);
      r = apply(r, TimerAction.end);
      expect(r.elapsedMs, 10000);
      expect(r.eligibleMs, 10000);
      expect(r.outcome, SessionOutcome.stoppedEarly);
      expect(identical(apply(r, TimerAction.end), r), isTrue);
    },
  );
  test('expiry clamps at intended endpoint and does not award work', () {
    var r = start(minutes: 1);
    for (var i = 0; i < 12; i++) {
      clock.advance(5000);
      r = apply(r, TimerAction.checkpoint);
    }
    expect(r.state, SessionState.awaitingReview);
    expect(r.elapsedMs, 60000);
    expect(r.eligibleMs, 60000);
    clock.advance(3600000);
    r = apply(r, TimerAction.checkpoint);
    expect(r.elapsedMs, 60000);
    expect(r.reportedMs, isNull);
  });
  test('explicit extension after expiry excludes idle review time; starter cannot extend', () {
    var r = start(minutes: 1);
    for (var i = 0; i < 12; i++) {
      clock.advance(5000);
      r = apply(r, TimerAction.checkpoint);
    }
    clock.advance(600000);
    r = apply(r, TimerAction.extend, minutes: 1);
    expect(r.state, SessionState.running);
    expect(r.outcome, isNull);
    expect(r.plannedMs, 120000);
    clock.advance(5000);
    r = apply(r, TimerAction.checkpoint);
    expect(r.elapsedMs, 65000);
    expect(
      () => apply(
        start(kind: SessionKind.starter),
        TimerAction.extend,
        minutes: 1,
      ),
      throwsStateError,
    );
    expect(
      () => apply(start(minutes: 180), TimerAction.extend, minutes: 1),
      throwsFormatException,
    );
  });
  test(
    'paused extension stays paused; zero and negative extension refused',
    () {
      var r = apply(start(), TimerAction.pause);
      clock.advance(10000);
      r = apply(r, TimerAction.extend, minutes: 5);
      expect(r.state, SessionState.paused);
      expect(r.elapsedMs, 0);
      expect(r.plannedMs, 1800000);
      expect(
        () => apply(r, TimerAction.extend, minutes: 0),
        throwsFormatException,
      );
      expect(
        () => apply(r, TimerAction.extend, minutes: 576460752303423489),
        throwsFormatException,
      );
    },
  );
  test('background and missing checkpoints expose uncertainty without granting eligibility', () {
    var r = start();
    clock.advance(5000);
    r = apply(r, TimerAction.background);
    clock.advance(10000);
    r = apply(r, TimerAction.foreground);
    expect(r.elapsedMs, 15000);
    expect(r.eligibleMs, 5000);
    expect(r.uncertainMs, 10000);
    clock.advance(60000);
    r = apply(r, TimerAction.checkpoint);
    expect(r.uncertainMs, 70000);
    expect(r.hasUncertainty, isTrue);
    expect(r.reportedMs, isNull);
  });
  test('wall clock forward/backward and elapsed counter reset are flagged, never credited', () {
    var r = start();
    clock.advance(5000, wallMs: -60000);
    var step = TimerMachine.advance(r, clock.sample());
    expect(step.segments.single.reason, 'wall-elapsed-clock-disagreement');
    expect(step.record.eligibleMs, 0);
    expect(step.record.elapsedMs, 5000);
    r = step.record;
    clock.advance(5000, wallMs: 3600000);
    r = apply(r, TimerAction.checkpoint);
    expect(r.elapsedMs, r.plannedMs);
    expect(r.state, SessionState.awaitingReview);
    expect(r.eligibleMs, 0);
    clock = FakeTimerClock();
    r = start();
    clock.advance(5000);
    r = apply(r, TimerAction.checkpoint);
    clock.elapsed = 1000;
    clock.wall = clock.wall.add(const Duration(seconds: 5));
    step = TimerMachine.advance(r, clock.sample());
    expect(step.segments.single.reason, 'elapsed-clock-backward');
    expect(step.record.eligibleMs, 5000);
  });
  test(
    'process/reboot epoch change recovers for review and caps restart gap',
    () {
      var r = start(minutes: 1);
      clock.advance(5000);
      r = apply(r, TimerAction.checkpoint);
      clock.advance(3600000);
      clock.epoch = 'new-boot';
      clock.elapsed = 0;
      r = apply(r, TimerAction.checkpoint);
      expect(r.state, SessionState.awaitingReview);
      expect(r.outcome, SessionOutcome.interrupted);
      expect(r.elapsedMs, 60000);
      expect(r.eligibleMs, 5000);
      expect(r.uncertainMs, 55000);
      expect(identical(apply(r, TimerAction.recover), r), isTrue);
      expect(() => apply(r, TimerAction.resume), throwsStateError);
    },
  );
  test('paused restart and backward wall gap never add active time', () {
    var r = start();
    clock.advance(5000);
    r = apply(r, TimerAction.pause);
    clock.advance(3600000);
    r = apply(r, TimerAction.recover);
    expect(r.elapsedMs, 5000);
    expect(r.eligibleMs, 5000);
    expect(r.hasUncertainty, isTrue);
    var active = start();
    clock.wall = clock.wall.subtract(const Duration(days: 1));
    active = apply(active, TimerAction.recover);
    expect(active.elapsedMs, 0);
    expect(active.state, SessionState.awaitingReview);
  });
  test(
    'break time never eligible and confirmation is bounded and idempotent',
    () {
      var r = start(kind: SessionKind.rest, minutes: 1);
      clock.advance(5000);
      r = apply(r, TimerAction.end);
      expect(r.elapsedMs, 5000);
      expect(r.eligibleMs, 0);
      expect(
        () => apply(r, TimerAction.finalize, reported: 1, confirmed: true),
        throwsFormatException,
      );
      expect(
        () => apply(r, TimerAction.finalize, reported: 0),
        throwsFormatException,
      );
      r = apply(r, TimerAction.finalize, reported: 0, confirmed: true);
      expect(r.state, SessionState.finalized);
      expect(
        identical(
          apply(r, TimerAction.finalize, reported: 0, confirmed: true),
          r,
        ),
        isTrue,
      );
    },
  );
  test('confirmed work must be nonnegative, within eligible time, and separate from ending', () {
    var r = start();
    clock.advance(5000);
    r = apply(r, TimerAction.end);
    for (final n in [-1, 5001]) {
      expect(
        () => apply(r, TimerAction.finalize, reported: n, confirmed: true),
        throwsFormatException,
      );
    }
    r = apply(r, TimerAction.finalize, reported: 4000, confirmed: true);
    expect(r.reportedMs, 4000);
    expect(
      () => apply(r, TimerAction.finalize, reported: 3000, confirmed: true),
      throwsStateError,
    );
  });
}
