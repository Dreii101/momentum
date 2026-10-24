import 'dart:math' as math;

enum SessionKind { starter, focus, rest }

enum SessionState { running, paused, awaitingReview, finalized }

enum SessionOutcome { completed, stoppedEarly, interrupted }

enum SegmentKind { active, pause, gap }

enum TimerAction {
  checkpoint,
  pause,
  resume,
  extend,
  end,
  recover,
  finalize,
  background,
  foreground,
}

/// Both sources are injected. Elapsed values are comparable only within epoch.
class TimeSample {
  TimeSample(DateTime wall, this.elapsedMs, this.epoch)
    : wallUtc = DateTime.fromMillisecondsSinceEpoch(
        wall.toUtc().millisecondsSinceEpoch,
        isUtc: true,
      );
  final DateTime wallUtc;
  final int elapsedMs;
  final String epoch;
}

class TimerRecord {
  const TimerRecord({
    required this.id,
    required this.kind,
    required this.state,
    required this.plannedMs,
    required this.elapsedMs,
    required this.eligibleMs,
    required this.uncertainMs,
    required this.hasUncertainty,
    required this.background,
    required this.checkpoint,
    this.outcome,
    this.reportedMs,
    this.finalizedUtc,
  });
  final String id;
  final SessionKind kind;
  final SessionState state;
  final int plannedMs, elapsedMs, eligibleMs, uncertainMs;
  final bool hasUncertainty, background;
  final TimeSample checkpoint;
  final SessionOutcome? outcome;
  final int? reportedMs;
  final DateTime? finalizedUtc;
  int get remainingMs => plannedMs - elapsedMs;
  TimerRecord copy({
    SessionState? state,
    int? plannedMs,
    int? elapsedMs,
    int? eligibleMs,
    int? uncertainMs,
    bool? hasUncertainty,
    bool? background,
    TimeSample? checkpoint,
    SessionOutcome? outcome,
    bool clearOutcome = false,
    int? reportedMs,
    DateTime? finalizedUtc,
  }) => TimerRecord(
    id: id,
    kind: kind,
    state: state ?? this.state,
    plannedMs: plannedMs ?? this.plannedMs,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    eligibleMs: eligibleMs ?? this.eligibleMs,
    uncertainMs: uncertainMs ?? this.uncertainMs,
    hasUncertainty: hasUncertainty ?? this.hasUncertainty,
    background: background ?? this.background,
    checkpoint: checkpoint ?? this.checkpoint,
    outcome: clearOutcome ? null : outcome ?? this.outcome,
    reportedMs: reportedMs ?? this.reportedMs,
    finalizedUtc: finalizedUtc ?? this.finalizedUtc,
  );
}

class SegmentDraft {
  const SegmentDraft({
    required this.kind,
    required this.from,
    required this.to,
    required this.spanMs,
    required this.elapsedMs,
    required this.eligibleMs,
    this.reason,
  });
  final SegmentKind kind;
  final DateTime from, to;
  final int spanMs, elapsedMs, eligibleMs;
  final String? reason;
}

class TimerTransition {
  const TimerTransition(this.record, [this.segments = const []]);
  final TimerRecord record;
  final List<SegmentDraft> segments;
}

/// Pure timing policy: no Flutter, database, tick counter or notifications.
class TimerMachine {
  static const checkpointGapMs = 15000;
  static const clockToleranceMs = 2000;
  static int duration(SessionKind kind, int minutes) {
    if (kind == SessionKind.starter) return 120000;
    final max = kind == SessionKind.focus ? 180 : 60;
    if (minutes < 1 || minutes > max) {
      throw FormatException('Choose 1–$max minutes.');
    }
    return minutes * 60000;
  }

  static TimerRecord start(
    String id,
    SessionKind kind,
    int minutes,
    TimeSample now,
  ) => TimerRecord(
    id: id,
    kind: kind,
    state: SessionState.running,
    plannedMs: duration(kind, minutes),
    elapsedMs: 0,
    eligibleMs: 0,
    uncertainMs: 0,
    hasUncertainty: false,
    background: false,
    checkpoint: now,
  );

  static TimerTransition recover(TimerRecord old, TimeSample now) {
    if (old.state == SessionState.awaitingReview ||
        old.state == SessionState.finalized) {
      return TimerTransition(old);
    }
    final wall = now.wallUtc.difference(old.checkpoint.wallUtc).inMilliseconds;
    final span = math.max(0, wall);
    final used = old.state == SessionState.running
        ? math.min(old.remainingMs, span)
        : 0;
    final next = old.copy(
      state: SessionState.awaitingReview,
      elapsedMs: old.elapsedMs + used,
      uncertainMs: old.uncertainMs + used,
      hasUncertainty: true,
      background: false,
      checkpoint: now,
      outcome: SessionOutcome.interrupted,
    );
    return TimerTransition(next, [
      SegmentDraft(
        kind: SegmentKind.gap,
        from: old.checkpoint.wallUtc,
        to: now.wallUtc,
        spanMs: span,
        elapsedMs: used,
        eligibleMs: 0,
        reason: wall < 0
            ? 'restart-and-wall-clock-backward'
            : 'process-restart',
      ),
    ]);
  }

  static TimerTransition advance(TimerRecord old, TimeSample now) {
    if (old.state == SessionState.awaitingReview ||
        old.state == SessionState.finalized) {
      return TimerTransition(old);
    }
    if (now.epoch != old.checkpoint.epoch) return recover(old, now);
    final mono = now.elapsedMs - old.checkpoint.elapsedMs;
    final wall = now.wallUtc.difference(old.checkpoint.wallUtc).inMilliseconds;
    if (mono == 0 && wall == 0) return TimerTransition(old);
    String? reason;
    if (mono < 0) {
      reason = 'elapsed-clock-backward';
    } else if ((wall - mono).abs() > clockToleranceMs) {
      reason = 'wall-elapsed-clock-disagreement';
    } else if (old.background) {
      reason = 'background';
    } else if (mono > checkpointGapMs) {
      reason = 'checkpoint-gap';
    }
    final span = reason == 'wall-elapsed-clock-disagreement' || mono < 0
        ? math.max(0, math.max(wall, mono))
        : math.max(0, mono);
    final used = old.state == SessionState.running
        ? math.min(old.remainingMs, span)
        : 0;
    final eligible = reason == null && old.kind != SessionKind.rest ? used : 0;
    final uncertain = reason != null ? used : 0;
    final expired =
        old.state == SessionState.running && used >= old.remainingMs;
    final next = old.copy(
      elapsedMs: old.elapsedMs + used,
      eligibleMs: old.eligibleMs + eligible,
      uncertainMs: old.uncertainMs + uncertain,
      hasUncertainty: old.hasUncertainty || reason != null,
      checkpoint: now,
      state: expired ? SessionState.awaitingReview : null,
      outcome: expired ? SessionOutcome.completed : null,
      background: expired ? false : null,
    );
    return TimerTransition(next, [
      SegmentDraft(
        kind: old.state == SessionState.paused
            ? SegmentKind.pause
            : reason == null
            ? SegmentKind.active
            : SegmentKind.gap,
        from: old.checkpoint.wallUtc,
        to: now.wallUtc,
        spanMs: span,
        elapsedMs: used,
        eligibleMs: eligible,
        reason: reason,
      ),
    ]);
  }

  static TimerTransition command(
    TimerRecord old,
    TimeSample now,
    TimerAction action, {
    int minutes = 0,
    int? reportedMs,
    bool confirmed = false,
  }) {
    if (action == TimerAction.recover) return recover(old, now);
    if (action == TimerAction.finalize) {
      if (!confirmed ||
          reportedMs == null ||
          reportedMs < 0 ||
          reportedMs > old.eligibleMs) {
        throw const FormatException(
          'Explicitly confirm work between zero and eligible elapsed time.',
        );
      }
      if (old.state == SessionState.finalized) {
        if (old.reportedMs != reportedMs) {
          throw StateError(
            'This session was already finalized with a different amount.',
          );
        }
        return TimerTransition(old);
      }
      if (old.state != SessionState.awaitingReview) {
        throw StateError('End or recover the session before finalizing.');
      }
      return TimerTransition(
        old.copy(
          state: SessionState.finalized,
          reportedMs: reportedMs,
          finalizedUtc: now.wallUtc,
        ),
      );
    }
    if ((action == TimerAction.pause && old.state == SessionState.paused) ||
        (action == TimerAction.resume && old.state == SessionState.running) ||
        (action == TimerAction.end &&
            (old.state == SessionState.awaitingReview ||
                old.state == SessionState.finalized))) {
      return TimerTransition(old);
    }
    final step = advance(old, now);
    var current = step.record;
    switch (action) {
      case TimerAction.checkpoint:
        return step;
      case TimerAction.background:
      case TimerAction.foreground:
        if (current.state == SessionState.running ||
            current.state == SessionState.paused) {
          current = current.copy(background: action == TimerAction.background);
        }
      case TimerAction.pause:
        if (current.state == SessionState.awaitingReview) return step;
        if (current.state != SessionState.running) {
          throw StateError('Only a running session can pause.');
        }
        current = current.copy(state: SessionState.paused);
      case TimerAction.resume:
        if (current.state != SessionState.paused) {
          throw StateError('Only a paused session can resume.');
        }
        current = current.copy(state: SessionState.running);
      case TimerAction.extend:
        if (current.kind == SessionKind.starter) {
          throw StateError(
            'A starter is exactly 120 seconds. Start a separate focus session after review.',
          );
        }
        final maxMinutes = current.kind == SessionKind.focus ? 180 : 60;
        if (minutes < 1 || minutes > maxMinutes) {
          throw FormatException(
            'Extend by 1–$maxMinutes minutes within the session limit.',
          );
        }
        final planned = current.plannedMs + minutes * 60000;
        if (planned > duration(current.kind, maxMinutes)) {
          throw const FormatException(
            'Extension exceeds the session duration limit.',
          );
        }
        if (current.state == SessionState.finalized ||
            (current.state == SessionState.awaitingReview &&
                current.outcome != SessionOutcome.completed)) {
          throw StateError(
            'Finalize the interrupted/stopped session before starting more work.',
          );
        }
        current = current.copy(
          plannedMs: planned,
          checkpoint: now,
          clearOutcome: true,
          state: current.state == SessionState.awaitingReview
              ? SessionState.running
              : current.state,
        );
      case TimerAction.end:
        if (current.state == SessionState.running ||
            current.state == SessionState.paused) {
          current = current.copy(
            state: SessionState.awaitingReview,
            outcome: SessionOutcome.stoppedEarly,
            background: false,
          );
        }
      case TimerAction.recover:
      case TimerAction.finalize:
        throw StateError('Handled above');
    }
    return TimerTransition(current, step.segments);
  }
}
