import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';

final taskRecordsProvider = StreamProvider<List<Task>>(
  (ref) => repositoryStream(
    ref,
    (r) => r.watchTasks(includeArchived: true, includeDeleted: true),
  ),
);
final taskRecordProvider = StreamProvider.family<Task?, String>(
  (ref, id) => repositoryStream(ref, (r) => r.watchTask(id)),
);
final dailyTasksProvider = StreamProvider.family<List<Task>, CalendarDate>(
  (ref, day) => repositoryStream(ref, (r) => r.watchDailyTasks(day)),
);
final upcomingTasksProvider = StreamProvider<List<Task>>(
  (ref) => repositoryStream(ref, (r) => r.watchUpcomingTasks()),
);
final taskCoursesProvider = StreamProvider<List<Course>>(
  (ref) => repositoryStream(
    ref,
    (r) => r.watchCourses(includeArchived: true, includeDeleted: true),
  ),
);

/// One transient clock, also refreshed when the application resumes.
class WorkflowInstant extends Notifier<DateTime> {
  @override
  DateTime build() {
    final clock = ref.watch(clockProvider);
    Timer? timer;
    void start() {
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        state = clock().toUtc();
      });
    }

    start();
    ref.onCancel(() => timer?.cancel());
    ref.onResume(() {
      start();
      scheduleMicrotask(() {
        if (ref.mounted) state = clock().toUtc();
      });
    });
    ref.onDispose(() => timer?.cancel());
    return clock().toUtc();
  }

  void refresh() => state = ref.read(clockProvider)().toUtc();
}

final workflowInstantProvider = NotifierProvider<WorkflowInstant, DateTime>(
  WorkflowInstant.new,
);

CalendarDate localDay(DateTime instant, String zone) {
  final local = tz.TZDateTime.from(instant, requireTimeZone(zone));
  return CalendarDate(local.year, local.month, local.day);
}

bool isTaskOverdue(Task task, DateTime now) {
  if (task.status == TaskStatus.done ||
      task.deletedAt != null ||
      task.archivedAt != null) {
    return false;
  }
  final boundary = task.deadlineBoundaryUtc;
  if (boundary == null) return false;
  return task.deadlineKind == DeadlineKind.dateOnly
      ? !now.isBefore(boundary)
      : now.isAfter(boundary);
}

String localInput(DateTime instant, String zone) {
  final local = tz.TZDateTime.from(instant, requireTimeZone(zone));
  String two(int value) => value.toString().padLeft(2, '0');
  return '${localDay(instant, zone)} ${two(local.hour)}:${two(local.minute)}';
}

String deadlineLabel(Task task) => switch (task.deadlineKind) {
  DeadlineKind.none => 'No deadline',
  DeadlineKind.dateOnly =>
    'Due ${task.deadlineDate} · ${task.deadlineZone!} (all day)',
  DeadlineKind.timed =>
    'Due ${localInput(task.deadlineUtc!, task.deadlineZone!)} · ${task.deadlineZone!}',
};

/// Reject skipped/repeated wall times rather than silently changing an instant.
DateTime parseWallTime(String dateText, String timeText, String zone) {
  final date = CalendarDate.parse(dateText.trim());
  final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$')
      .firstMatch(timeText.trim());
  if (match == null) {
    throw const FormatException('Enter a time as HH:MM (24-hour).');
  }
  final location = requireTimeZone(zone.trim());
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final wall = DateTime.utc(date.year, date.month, date.day, hour, minute);
  final offsets = <int>{};
  for (var hours = -48; hours <= 48; hours += 6) {
    offsets.add(
      tz.TZDateTime.from(
        wall.add(Duration(hours: hours)),
        location,
      ).timeZoneOffset.inMilliseconds,
    );
  }
  final matches = <DateTime>[];
  for (final offset in offsets) {
    final candidate = wall.subtract(Duration(milliseconds: offset));
    final local = tz.TZDateTime.from(candidate, location);
    if (local.year == date.year &&
        local.month == date.month &&
        local.day == date.day &&
        local.hour == hour &&
        local.minute == minute) {
      matches.add(candidate);
    }
  }
  if (matches.length != 1) {
    throw const FormatException(
      'This local time is skipped or repeated by a clock change. Choose another time or enter the instant in UTC.',
    );
  }
  return matches.single;
}

/// Unsaved text survives record switches/resizes; SQLite remains authoritative.
class TaskEditBuffer {
  TaskEditBuffer(Task row, String planningZone)
    : title = row.title,
      description = row.description,
      nextAction = row.nextAction ?? '',
      courseId = row.courseId,
      priority = row.priority,
      kind = row.deadlineKind,
      date = row.deadlineDate?.toString() ?? '',
      time = '',
      zone = row.deadlineZone ?? planningZone,
      targetDate = '',
      targetTime = '',
      targetZone = planningZone,
      estimate = row.remainingMinutes?.toString() ?? '' {
    if (row.deadlineUtc != null) {
      final parts = localInput(row.deadlineUtc!, zone).split(' ');
      date = parts[0];
      time = parts[1];
    }
    if (row.targetUtc != null) {
      final parts = localInput(row.targetUtc!, targetZone).split(' ');
      targetDate = parts[0];
      targetTime = parts[1];
    }
    original = row;
    originalDate = date;
    originalTime = time;
    originalZone = zone;
    originalTargetDate = targetDate;
    originalTargetTime = targetTime;
    originalTargetZone = targetZone;
  }
  late Task original;
  late String originalDate, originalTime, originalZone;
  late String originalTargetDate, originalTargetTime, originalTargetZone;
  String title, description, nextAction, date, time, zone;
  String targetDate, targetTime, targetZone, estimate;
  String? courseId;
  TaskPriority priority;
  DeadlineKind kind;
  bool dirty = false;
  bool advanced = false;

  TaskDraft toDraft(TaskStatus status) {
    validateTaskTitle(title);
    final minutes = estimate.trim().isEmpty
        ? null
        : int.tryParse(estimate.trim());
    if (estimate.trim().isNotEmpty && (minutes == null || minutes < 0)) {
      throw const FormatException(
        'Remaining estimate must be a whole number of minutes, zero or more.',
      );
    }
    final sameDeadline =
        kind == original.deadlineKind &&
        date == originalDate &&
        time == originalTime &&
        zone == originalZone;
    final deadline = switch (kind) {
      DeadlineKind.none => const Deadline.none(),
      DeadlineKind.dateOnly => Deadline.dateOnly(
        CalendarDate.parse(date.trim()),
        zone.trim(),
      ),
      DeadlineKind.timed => Deadline.timed(
        sameDeadline ? original.deadlineUtc! : parseWallTime(date, time, zone),
        zone.trim(),
      ),
    };
    final hasTarget =
        targetDate.trim().isNotEmpty || targetTime.trim().isNotEmpty;
    final sameTarget =
        targetDate == originalTargetDate &&
        targetTime == originalTargetTime &&
        targetZone == originalTargetZone;
    final target = !hasTarget
        ? null
        : sameTarget && original.targetUtc != null
        ? original.targetUtc
        : parseWallTime(targetDate, targetTime, targetZone);
    final boundary = deadline.boundary;
    if (target != null &&
        boundary != null &&
        (target.isAfter(boundary) ||
            (kind == DeadlineKind.dateOnly &&
                target.isAtSameMomentAs(boundary)))) {
      throw const FormatException(
        'Choose an internal target before the official deadline ends.',
      );
    }
    return TaskDraft(
      title: title,
      description: description,
      nextAction: nextAction.trim().isEmpty ? null : nextAction.trim(),
      courseId: courseId,
      priority: priority,
      status: status,
      deadline: deadline,
      targetUtc: target,
      remainingMinutes: minutes,
    );
  }
}
