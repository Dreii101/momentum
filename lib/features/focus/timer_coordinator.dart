import 'dart:async';

import '../../core/database/app_database.dart';
import 'timer_clock.dart';
import 'timer_engine.dart';
import 'timer_store.dart';

class TimerEngineView {
  const TimerEngineView({
    this.session,
    this.segments = const [],
    this.error,
    this.saving = false,
    this.ready = false,
  });
  final FocusSession? session;
  final List<FocusSegment> segments;
  final Object? error;
  final bool saving, ready;
}

/// Installation-owned writer. Screens observe it; they never own its clock or
/// checkpoint timer. State is published only after the transaction succeeds.
class TimerCoordinator {
  TimerCoordinator(
    this.store,
    this.clock, {
    this.period = const Duration(seconds: 5),
  });
  final TimerStore store;
  final TimerClock clock;
  final Duration? period;
  TimerEngineView view = const TimerEngineView();
  final _changes = StreamController<TimerEngineView>.broadcast();
  Stream<TimerEngineView> get changes => _changes.stream;
  Future<void> _tail = Future.value();
  Timer? _ticker;
  bool _disposed = false, _checkpointPending = false;
  Object? _error;
  Future<FocusSession?> Function()? _failed;
  void _publish({
    FocusSession? session,
    List<FocusSegment>? segments,
    bool? ready,
    bool saving = false,
  }) {
    if (_disposed) return;
    view = TimerEngineView(
      session: session ?? view.session,
      segments: segments ?? view.segments,
      error: _error,
      saving: saving,
      ready: ready ?? view.ready,
    );
    final active =
        view.session?.state == SessionState.running ||
        view.session?.state == SessionState.paused;
    if (period != null && active) {
      _ticker ??= Timer.periodic(period!, (_) {
        if (_checkpointPending || _disposed) return;
        _checkpointPending = true;
        unawaited(
          checkpoint()
              .catchError((Object _) => null)
              .whenComplete(() => _checkpointPending = false),
        );
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
    _changes.add(view);
  }

  Future<FocusSession?> _run(
    Future<FocusSession?> Function() action, {
    bool user = true,
  }) {
    final result = Completer<FocusSession?>();
    _tail = _tail.then((_) async {
      if (_disposed) {
        result.completeError(StateError('Timer coordinator closed.'));
        return;
      }
      _publish(saving: true);
      try {
        final next = await action();
        final segments = next == null
            ? <FocusSegment>[]
            : await store.segments(next.id);
        if (user) {
          _error = null;
          _failed = null;
        }
        _publish(session: next, segments: segments, ready: true);
        result.complete(next);
      } catch (e, stack) {
        if (user || _failed == null) {
          _error = e;
          _failed = action;
        }
        _publish();
        result.completeError(e, stack);
      }
    });
    return result.future;
  }

  Future<void> initialize() async {
    await _run(() async {
      final old = await store.unfinished();
      final next = old == null
          ? null
          : await store.apply(
              old.id,
              TimerAction.recover,
              clock.sample(),
              commandId: store.repository.ids(),
            );
      return next;
    });
  }

  Future<FocusSession?> start(
    SessionKind kind, {
    int minutes = 25,
    String zone = 'Asia/Manila',
    String? taskId,
    String? subtaskId,
    String? commandId,
  }) {
    final id = store.repository.ids(),
        request = commandId ?? store.repository.ids();
    return _run(
      () => store.start(
        commandId: request,
        sessionId: id,
        kind: kind,
        minutes: minutes,
        zone: zone,
        now: clock.sample(),
        taskId: taskId,
        subtaskId: subtaskId,
      ),
    );
  }

  Future<FocusSession?> command(
    TimerAction action, {
    int minutes = 0,
    int? reportedMs,
    bool confirmed = false,
    String? commandId,
  }) {
    final id = view.session?.id, request = commandId ?? store.repository.ids();
    return _run(() async {
      if (id == null) throw StateError('No timer session is selected.');
      return store.apply(
        id,
        action,
        clock.sample(),
        commandId: request,
        minutes: minutes,
        reportedMs: reportedMs,
        confirmed: confirmed,
      );
    });
  }

  Future<FocusSession?> checkpoint() => _run(() async {
    final id = view.session?.id;
    if (id == null) return null;
    return store.apply(id, TimerAction.checkpoint, clock.sample());
  }, user: false);
  Future<FocusSession?> retry() {
    final action = _failed;
    if (action == null) return Future.value(view.session);
    return _run(action);
  }

  Future<FocusSession?> lifecycle(bool background) => _run(() async {
    final id = view.session?.id;
    if (id == null) return null;
    return store.apply(
      id,
      background ? TimerAction.background : TimerAction.foreground,
      clock.sample(),
      commandId: store.repository.ids(),
    );
  }, user: false);

  Future<T> withDataReplacement<T>(Future<T> Function() replace) {
    final result = _tail.then((_) async {
      if (_disposed) throw StateError('Timer coordinator closed.');
      final value = await replace();
      _error = null;
      _failed = null;
      view = const TimerEngineView();
      try {
        final session = await store.unfinished();
        _publish(
          session: session,
          segments: session == null ? [] : await store.segments(session.id),
          ready: true,
        );
      } catch (error) {
        _error = error;
        _publish();
      }
      return value;
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _ticker?.cancel();
    unawaited(_changes.close());
  }

  Future<void> close() async {
    _ticker?.cancel();
    await _tail;
    dispose();
  }
}
