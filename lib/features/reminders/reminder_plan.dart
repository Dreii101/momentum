import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/database/value_types.dart';
import '../focus/timer_engine.dart';
import '../focus/timer_store.dart';
import '../schedule/recurrence.dart';
import 'reminder_store.dart';
import 'reminder_types.dart';

bool isQuiet(DateTime instant, ReminderPreferences p, String zone) {
  if (!p.quietEnabled) return false;
  final local = tz.TZDateTime.from(instant, requireTimeZone(zone));
  final minute = local.hour * 60 + local.minute;
  return p.quietStart < p.quietEnd
      ? minute >= p.quietStart && minute < p.quietEnd
      : minute >= p.quietStart || minute < p.quietEnd;
}

DateTime quietEnd(DateTime instant, ReminderPreferences p, String zone) {
  final local = tz.TZDateTime.from(instant, requireTimeZone(zone));
  var day = DateTime.utc(local.year, local.month, local.day);
  if (p.quietStart > p.quietEnd &&
      local.hour * 60 + local.minute >= p.quietStart) {
    day = day.add(const Duration(days: 1));
  }
  return resolveWall(day.add(Duration(minutes: p.quietEnd)), zone).instant;
}

class ReminderPlan {
  const ReminderPlan(
    this.targets,
    this.horizon,
    this.coverageEnd,
    this.truncated,
    this.quietSuppressed,
  );
  final List<ReminderTarget> targets;
  final DateTime horizon, coverageEnd;
  final int truncated, quietSuppressed;
}

ReminderPlan planReminders(ReminderInputs data, TimeSample sample) {
  final now = sample.wallUtc,
      horizon = sample.wallUtc.add(const Duration(days: 30));
  final all = <ReminderTarget>[];
  var suppressed = 0;
  bool available(Task t) =>
      t.deletedAt == null &&
      t.archivedAt == null &&
      t.status != TaskStatus.done;
  final tasks = {for (final t in data.planning.tasks.where(available)) t.id: t};
  void add(
    ReminderRule r,
    String suffix,
    DateTime source,
    String title, {
    String? date,
    String? session,
    DateTime? base,
  }) {
    var due = (base ?? source).subtract(Duration(minutes: r.leadMinutes));
    if (!due.isAfter(now) || due.isAfter(horizon)) return;
    if (isQuiet(due, data.preferences, data.settings.planningZone)) {
      if (r.kind == ReminderKind.timer) {
        suppressed++;
        return;
      }
      final shifted = quietEnd(
        due,
        data.preferences,
        data.settings.planningZone,
      );
      if (shifted.isAfter(source) || shifted.isAfter(horizon)) {
        suppressed++;
        return;
      }
      due = shifted;
    }
    all.add(
      ReminderTarget(
        key: '${r.id}/$suffix',
        ruleId: r.id,
        sourceUtc: source,
        dueUtc: due,
        title: title,
        body: r.kind == ReminderKind.timer
            ? 'Time to review your session. No work was credited.'
            : 'Open Momentum to see the current record. Delivery does not complete anything.',
        originalDate: date,
        sessionId: session,
      ),
    );
  }

  if (data.preferences.enabled) {
    for (final r in data.rules.where((r) => r.enabled)) {
      switch (r.kind) {
        case ReminderKind.deadline:
          final task = tasks[r.taskId];
          if (task == null || task.deadlineKind == DeadlineKind.none) continue;
          if (task.deadlineKind == DeadlineKind.dateOnly) {
            final day = task.deadlineDate!;
            final morning = resolveWall(
              DateTime.utc(day.year, day.month, day.day, 9),
              task.deadlineZone!,
            ).instant;
            add(
              r,
              'deadline',
              task.deadlineBoundaryUtc!,
              'Due $day · ${task.title}',
              base: morning,
            );
          } else {
            add(r, 'deadline', task.deadlineUtc!, 'Deadline · ${task.title}');
          }
        case ReminderKind.activity:
          final rangeEnd = horizon.add(Duration(minutes: r.leadMinutes));
          final schedule = data.planning.schedule;
          for (final occurrence in generateOccurrences(
            ScheduleSnapshot(
              schedule.series.where((s) => s.id == r.seriesId).toList(),
              schedule.exceptions
                  .where((e) => e.seriesId == r.seriesId)
                  .toList(),
              schedule.courses,
            ),
            now,
            rangeEnd,
          )) {
            if (occurrence.cancelled || occurrence.superseded) {
              continue;
            }
            add(
              r,
              occurrence.originalDate.toString(),
              occurrence.start,
              'Activity · ${occurrence.series.title}',
              date: occurrence.originalDate.toString(),
            );
          }
        case ReminderKind.work:
          final block = data.planning.blocks
              .where(
                (b) =>
                    b.id == r.workId &&
                    b.deletedAt == null &&
                    b.status == WorkBlockStatus.planned,
              )
              .firstOrNull;
          final task = tasks[block?.taskId];
          if (block != null && task != null) {
            add(r, 'work', block.startUtc, 'Planned work · ${task.title}');
          }
        case ReminderKind.timer:
          for (final s in data.sessions.where(
            (s) =>
                s.installationId == r.installationId &&
                s.state == SessionState.running,
          )) {
            final projected = TimerMachine.advance(
              timerRecord(s),
              sample,
            ).record;
            if (projected.state != SessionState.running) continue;
            final raw = now.add(Duration(milliseconds: projected.remainingMs));
            // Round the OS endpoint to a second so sub-millisecond clock jitter does not reschedule every checkpoint.
            final endpoint = DateTime.fromMillisecondsSinceEpoch(
              ((raw.millisecondsSinceEpoch + 999) ~/ 1000) * 1000,
              isUtc: true,
            );
            add(
              r,
              s.id,
              endpoint,
              s.kind == SessionKind.rest
                  ? 'Break ended'
                  : s.kind == SessionKind.starter
                  ? 'Starter ended'
                  : 'Focus interval ended',
              session: s.id,
            );
          }
      }
    }
  }
  all.sort((a, b) {
    final byTime = a.dueUtc.compareTo(b.dueUtc);
    return byTime != 0 ? byTime : a.key.compareTo(b.key);
  });
  final nonTimers = all.where((t) => t.sessionId == null).toList();
  final timers = all.where((t) => t.sessionId != null).take(1);
  final kept = [...nonTimers.take(127), ...timers]
    ..sort((a, b) => a.dueUtc.compareTo(b.dueUtc));
  final truncated = nonTimers.length > 127 ? nonTimers.length - 127 : 0;
  final coverage = truncated == 0
      ? horizon
      : nonTimers[127].dueUtc.subtract(const Duration(milliseconds: 1));
  return ReminderPlan(kept, horizon, coverage, truncated, suppressed);
}
