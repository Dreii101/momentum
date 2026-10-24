import 'dart:async';
import 'dart:convert';

import '../../core/database/app_database.dart';
import '../../core/database/value_types.dart';
import '../focus/timer_clock.dart';
import '../focus/timer_engine.dart';
import 'notification_service.dart';
import 'reminder_plan.dart';
import 'reminder_store.dart';
import 'reminder_types.dart';

class ReminderView {
  const ReminderView({
    this.inputs,
    this.capability,
    this.plan,
    this.registrations = const [],
    this.error,
    this.checkedUtc,
    this.scheduledThrough,
    this.coverageThrough,
    this.busy = false,
  });
  final ReminderInputs? inputs;
  final NotificationCapability? capability;
  final ReminderPlan? plan;
  final List<ReminderRegistration> registrations;
  final Object? error;
  final DateTime? checkedUtc, scheduledThrough, coverageThrough;
  final bool busy;
}

/// Native effects follow committed intents. Source saves are separate transactions.
class ReminderCoordinator {
  ReminderCoordinator(
    this.store,
    this.service,
    this.clock, {
    required this.onResponse,
  });
  final ReminderStore store;
  final NotificationService service;
  final TimerClock clock;
  final Future<void> Function(String) onResponse;
  final _changes = StreamController<ReminderView>.broadcast();
  Stream<ReminderView> get changes => _changes.stream;
  ReminderView view = const ReminderView();
  Future<void> _tail = Future.value();
  StreamSubscription<void>? _source;
  StreamSubscription<String>? _responses;
  Timer? _refresh;
  bool disposed = false, queued = false;
  bool _restorePending = true;

  void publish(ReminderView next) {
    if (disposed) return;
    view = next;
    _changes.add(next);
    if (next.inputs?.preferences.enabled == true) {
      _refresh ??= Timer.periodic(
        const Duration(minutes: 15),
        (_) => request(),
      );
    } else {
      _refresh?.cancel();
      _refresh = null;
    }
  }

  Future<void> initialize() async {
    await store.initialize();
    _responses = service.responses.listen((payload) {
      unawaited(onResponse(payload).catchError((Object e) => fail(e)));
    });
    _source = store.changes.listen(
      (_) => request(),
      onError: (Object e) => fail(e),
    );
    await reconcile();
    if (view.inputs?.preferences.enabled == true &&
        view.capability?.supported == true) {
      try {
        final payload = await service.launchPayload();
        if (payload != null) await onResponse(payload);
      } catch (e) {
        fail(e);
      }
    }
  }

  void request() {
    if (queued || disposed) return;
    queued = true;
    scheduleMicrotask(() {
      queued = false;
      if (!disposed) unawaited(reconcile());
    });
  }

  void fail(Object error) => publish(
    ReminderView(
      inputs: view.inputs,
      capability: view.capability,
      plan: view.plan,
      registrations: view.registrations,
      error: error,
      checkedUtc: view.checkedUtc,
    ),
  );
  Future<void> reconcile({bool refreshStatus = false}) {
    final result = _tail.then((_) async {
      if (disposed) return;
      try {
        await _reconcile(refreshStatus);
      } catch (e) {
        fail(e);
      }
    });
    _tail = result;
    return result;
  }

  Future<void> _reconcile(bool refreshStatus) async {
    final data = await store.read(), sample = clock.sample();
    final old = await store.registrations();
    publish(
      ReminderView(
        inputs: data,
        registrations: old,
        busy: true,
        capability: view.capability,
      ),
    );
    // Publish current records first so a failed cleanup has visible Retry UI.
    final cancellations = await store.db
        .select(store.db.notificationCleanupRows)
        .get();
    for (final row in cancellations) {
      await service.cancel(row.notificationId);
      await (store.db.delete(
        store.db.notificationCleanupRows,
      )..where((r) => r.notificationId.equals(row.notificationId))).go();
    }
    var plan = planReminders(data, sample);
    final needsNative =
        data.preferences.enabled ||
        refreshStatus ||
        old.any(
          (r) =>
              r.state != RegistrationState.cancelled &&
              r.state != RegistrationState.elapsed,
        );
    if (!needsNative) {
      publish(
        ReminderView(
          inputs: data,
          registrations: old,
          plan: plan,
          capability: view.capability,
          checkedUtc: sample.wallUtc,
        ),
      );
      return;
    }
    var capability = await service.capability();
    var pending = capability.supported ? await service.pending() : <int>{};
    final errors = <String>[];
    final past = planReminders(
      data,
      TimeSample(
        sample.wallUtc.subtract(const Duration(hours: 1)),
        sample.elapsedMs,
        sample.epoch,
      ),
    );
    final pastByKey = {
      for (final t in past.targets.where((t) => t.sessionId == null)) t.key: t,
    };
    bool sourceActive(ReminderRegistration row) {
      if (!data.preferences.enabled) return false;
      final rule = data.rules
          .where((r) => r.id == row.ruleId && r.enabled)
          .firstOrNull;
      if (rule == null) return false;
      bool taskActive(String? id) => data.planning.tasks.any(
        (t) =>
            t.id == id &&
            t.deletedAt == null &&
            t.archivedAt == null &&
            t.status != TaskStatus.done,
      );
      switch (rule.kind) {
        case ReminderKind.deadline:
          return taskActive(rule.taskId) &&
              data.planning.tasks.any(
                (t) =>
                    t.id == rule.taskId &&
                    t.deadlineKind != DeadlineKind.none &&
                    t.deadlineBoundaryUtc == row.sourceUtc,
              );
        case ReminderKind.work:
          return data.planning.blocks.any(
            (b) =>
                b.id == rule.workId &&
                b.deletedAt == null &&
                b.status == WorkBlockStatus.planned &&
                b.startUtc == row.sourceUtc &&
                taskActive(b.taskId),
          );
        case ReminderKind.activity:
          if (row.originalDate == null ||
              !data.planning.schedule.series.any(
                (s) => s.id == rule.seriesId && s.deletedAt == null,
              )) {
            return false;
          }
          final occurrence = data.planning.schedule.occurrence(
            rule.seriesId!,
            CalendarDate.parse(row.originalDate!),
          );
          return !occurrence.cancelled &&
              !occurrence.superseded &&
              occurrence.start == row.sourceUtc;
        case ReminderKind.timer:
          return data.sessions.any(
            (s) =>
                s.id == row.sessionId &&
                (s.state == SessionState.running ||
                    (s.state == SessionState.awaitingReview &&
                        s.outcome == SessionOutcome.completed)),
          );
      }
    }

    bool current(ReminderRegistration row) {
      if (row.sessionId == null) {
        return pastByKey[row.identityKey]?.dueUtc == row.dueUtc &&
            pastByKey[row.identityKey]?.sourceUtc == row.sourceUtc;
      }
      return data.preferences.enabled &&
          data.rules.any((r) => r.id == row.ruleId && r.enabled) &&
          data.sessions.any(
            (s) =>
                s.id == row.sessionId &&
                s.state == SessionState.awaitingReview &&
                s.outcome == SessionOutcome.completed,
          );
    }

    final late = old
        .where(
          (r) =>
              !r.dueUtc.isAfter(sample.wallUtc) &&
              r.dueUtc.isAfter(
                sample.wallUtc.subtract(const Duration(hours: 1)),
              ) &&
              current(r) &&
              capability.allowed &&
              pending.contains(r.notificationId),
        )
        .toList();
    final lateNormal = late
        .where((r) => r.sessionId == null)
        .take(127)
        .toList();
    final lateTimers = late.where((r) => r.sessionId != null).take(1).toList();
    final retained = {...lateNormal, ...lateTimers}.map((r) => r.id).toSet();
    final targets = [
      ...plan.targets
          .where((t) => t.sessionId == null)
          .take(127 - lateNormal.length),
      ...plan.targets
          .where((t) => t.sessionId != null)
          .take(1 - lateTimers.length),
    ];
    final keptKeys = targets.map((t) => t.key).toSet();
    final omitted = plan.targets
        .where((t) => !keptKeys.contains(t.key))
        .toList();
    final coverage =
        omitted.isNotEmpty && omitted.first.dueUtc.isBefore(plan.coverageEnd)
        ? omitted.first.dueUtc.subtract(const Duration(milliseconds: 1))
        : plan.coverageEnd;
    plan = ReminderPlan(
      targets,
      plan.horizon,
      coverage,
      plan.truncated + omitted.length,
      plan.quietSuppressed,
    );
    final wanted = <String, ReminderRegistration>{};
    final targetById = <String, ReminderTarget>{};
    for (final target in plan.targets) {
      final fingerprint = jsonEncode([
        target.sourceUtc.millisecondsSinceEpoch,
        target.dueUtc.millisecondsSinceEpoch,
        target.title,
        target.body,
        capability.exact,
      ]);
      final row = await store.prepare(target, fingerprint);
      wanted[row.identityKey] = row;
      targetById[row.id] = target;
    }
    Future<void> cancel(
      ReminderRegistration row, {
      bool elapsed = false,
    }) async {
      try {
        if (!capability.supported) throw StateError(capability.message);
        await service.cancel(row.notificationId);
        if ((await service.pending()).contains(row.notificationId)) {
          throw StateError(
            'The operating system still reports this reminder pending.',
          );
        }
        pending.remove(row.notificationId);
        await store.state(
          row.id,
          elapsed ? RegistrationState.elapsed : RegistrationState.cancelled,
          error: elapsed ? row.error : null,
        );
      } catch (e) {
        await store.state(
          row.id,
          RegistrationState.cancelFailed,
          error: e.toString(),
        );
        errors.add(e.toString());
      }
    }

    for (final row in old.where((r) => !wanted.containsKey(r.identityKey))) {
      final due = !row.dueUtc.isAfter(sample.wallUtc);
      // Approximate OS delivery can be late. Keep one already-registered current alert for at most an hour; never schedule past alerts again.
      if (retained.contains(row.id)) continue;
      if (row.state == RegistrationState.cancelled &&
          !pending.contains(row.notificationId)) {
        continue;
      }
      if (row.state == RegistrationState.elapsed &&
          !pending.contains(row.notificationId) &&
          sourceActive(row)) {
        continue;
      }
      if (due &&
          sourceActive(row) &&
          !pending.contains(row.notificationId) &&
          capability.supported) {
        await store.state(row.id, RegistrationState.elapsed, error: row.error);
        continue;
      }
      await cancel(row, elapsed: due && sourceActive(row));
    }
    final known = {
      for (final row in [...old, ...wanted.values]) row.notificationId,
    };
    for (final id
        in pending
            .where(
              (id) => id >= 1000000 && id <= 2147483000 && !known.contains(id),
            )
            .toList()) {
      try {
        await service.cancel(id);
        if ((await service.pending()).contains(id)) {
          throw StateError('Orphan reminder $id could not be cancelled.');
        }
        pending.remove(id);
      } catch (e) {
        errors.add(e.toString());
      }
    }
    DateTime? failedAt;
    final registered = <DateTime>[];
    for (final row in wanted.values) {
      if (!capability.allowed || !capability.supported) {
        if (pending.contains(row.notificationId)) await cancel(row);
        await store.state(
          row.id,
          RegistrationState.scheduleFailed,
          error: capability.message,
        );
        failedAt = failedAt == null || row.dueUtc.isBefore(failedAt)
            ? row.dueUtc
            : failedAt;
        continue;
      }
      try {
        // Android reports cached schedules; reinstall future IDs once per process to repair lost native alarms.
        if (_restorePending ||
            row.state != RegistrationState.scheduled ||
            !pending.contains(row.notificationId)) {
          if (pending.contains(row.notificationId)) {
            await service.cancel(row.notificationId);
            pending = await service.pending();
            if (pending.contains(row.notificationId)) {
              throw StateError(
                'The previous trigger is still pending. Retry cancellation first.',
              );
            }
          }
          final owned = pending
              .where((id) => id >= 1000000 && id <= 2147483000)
              .toSet();
          final timerIds = {...old, ...wanted.values}
              .where((r) => r.sessionId != null)
              .map((r) => r.notificationId)
              .toSet();
          if (owned.length >= 128 ||
              (row.sessionId == null &&
                  owned.difference(timerIds).length >= 127) ||
              (row.sessionId != null &&
                  owned.intersection(timerIds).isNotEmpty)) {
            throw StateError(
              'Pending reminders already fill this slot. Resolve cancellation failures before scheduling more.',
            );
          }
          try {
            await service.schedule(
              row.notificationId,
              targetById[row.id]!,
              'momentum:${row.id}',
              exact: capability.exact,
            );
          } catch (_) {
            final latest = await service.capability();
            if (!capability.exact || latest.exact || !latest.allowed) rethrow;
            capability = latest;
            await service.schedule(
              row.notificationId,
              targetById[row.id]!,
              'momentum:${row.id}',
              exact: false,
            );
          }
          pending = await service.pending();
          if (!pending.contains(row.notificationId)) {
            throw StateError(
              'Scheduling returned without a pending registration.',
            );
          }
          await store.state(
            row.id,
            RegistrationState.scheduled,
            registered: true,
          );
        }
        registered.add(row.dueUtc);
      } catch (e) {
        await store.state(
          row.id,
          RegistrationState.scheduleFailed,
          error: e.toString(),
        );
        errors.add(e.toString());
        failedAt = failedAt == null || row.dueUtc.isBefore(failedAt)
            ? row.dueUtc
            : failedAt;
      }
    }
    _restorePending = false;
    registered.sort();
    final checkedThrough =
        failedAt != null && failedAt.isBefore(plan.coverageEnd)
        ? failedAt.subtract(const Duration(milliseconds: 1))
        : plan.coverageEnd;
    publish(
      ReminderView(
        inputs: data,
        capability: capability,
        plan: plan,
        registrations: await store.registrations(),
        checkedUtc: sample.wallUtc,
        scheduledThrough: registered.lastOrNull,
        coverageThrough: capability.allowed && registered.isNotEmpty
            ? checkedThrough
            : null,
        error: errors.isEmpty ? null : errors.join('\n'),
      ),
    );
  }

  Future<void> enable(bool enabled) async {
    if (enabled) {
      await service
          .requestPermission(); // Only called by the contextual Enable control.
    }
    final data = await store.read(), p = data.preferences;
    await store.preferences(
      enabled: enabled,
      quietEnabled: p.quietEnabled,
      start: p.quietStart,
      end: p.quietEnd,
    );
    await reconcile(refreshStatus: true);
  }

  Future<void> testNotification() async {
    final data = await store.read();
    if (!data.preferences.enabled) {
      throw StateError('Enable reminders before sending a test.');
    }
    if (isQuiet(
      clock.sample().wallUtc,
      data.preferences,
      data.settings.planningZone,
    )) {
      throw StateError(
        'The test is suppressed by your quiet hours. Change them or try later.',
      );
    }
    final capability = await service.capability();
    if (!capability.allowed) throw StateError(capability.message);
    await service.test();
  }

  Future<T> withDataReplacement<T>(Future<T> Function() replace) {
    final result = _tail.then((_) => replace());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  void dispose() {
    if (disposed) return;
    disposed = true;
    _refresh?.cancel();
    unawaited(_source?.cancel());
    unawaited(_responses?.cancel());
    unawaited(_changes.close());
  }

  Future<void> close() async {
    _refresh?.cancel();
    await _source?.cancel();
    await _responses?.cancel();
    await _tail;
    dispose();
  }
}
