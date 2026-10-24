import '../../core/database/app_database.dart';
import '../../core/database/planning_repository.dart';
import '../../core/database/value_types.dart';
import '../schedule/recurrence.dart';
import '../tasks/task_workflow.dart' show localDay;

enum CalendarKind { deadline, target, activity, work }

enum CalendarView { agenda, day, week }

class CalendarFilters {
  const CalendarFilters({
    this.kinds = const {
      CalendarKind.deadline,
      CalendarKind.target,
      CalendarKind.activity,
      CalendarKind.work,
    },
    this.cancelled = false,
    this.completed = false,
    this.courseId,
  });
  final Set<CalendarKind> kinds;
  final bool cancelled, completed;
  final String? courseId;
}

class CalendarEntry {
  const CalendarEntry({
    required this.identity,
    required this.kind,
    required this.title,
    required this.start,
    required this.end,
    this.day,
    this.task,
    this.block,
    this.occurrence,
  });
  final String identity, title;
  final CalendarKind kind;
  final DateTime start, end;

  /// All-day deadlines retain their written calendar date in every display zone.
  final CalendarDate? day;
  final Task? task;
  final PlannedWorkBlock? block;
  final Occurrence? occurrence;
  bool get cancelled =>
      occurrence?.cancelled == true ||
      block?.status == WorkBlockStatus.cancelled;
  bool get busy =>
      !cancelled &&
      (kind == CalendarKind.activity
          ? occurrence!.series.busy
          : kind == CalendarKind.work &&
                block!.status == WorkBlockStatus.planned);
}

List<CalendarEntry> projectCalendar(
  PlanningSnapshot data,
  CalendarDate from,
  CalendarDate until,
  String zone, {
  CalendarFilters filters = const CalendarFilters(),
}) {
  requireTimeZone(zone);
  final start = resolveWall(dateValue(from), zone).instant;
  final end = resolveWall(dateValue(until), zone).instant;
  if (until.compareTo(from) <= 0 ||
      dateValue(until).difference(dateValue(from)).inDays > 366) {
    throw ArgumentError('Choose a calendar range of 1–366 days.');
  }
  bool inRange(DateTime t) => !t.isBefore(start) && t.isBefore(end);
  bool visibleTask(Task t) =>
      t.deletedAt == null &&
      t.archivedAt == null &&
      (filters.completed || t.status != TaskStatus.done) &&
      (filters.courseId == null || t.courseId == filters.courseId);
  final tasks = {for (final t in data.tasks.where(visibleTask)) t.id: t};
  final output = <CalendarEntry>[];
  for (final t in tasks.values) {
    if (filters.kinds.contains(CalendarKind.deadline)) {
      final day = t.deadlineDate;
      if (t.deadlineKind == DeadlineKind.dateOnly &&
          day != null &&
          day.compareTo(from) >= 0 &&
          day.compareTo(until) < 0) {
        output.add(
          CalendarEntry(
            identity: 'deadline/${t.id}',
            kind: CalendarKind.deadline,
            title: t.title,
            start: resolveWall(dateValue(day), zone).instant,
            end: resolveWall(dateValue(addDays(day, 1)), zone).instant,
            day: day,
            task: t,
          ),
        );
      } else if (t.deadlineKind == DeadlineKind.timed &&
          inRange(t.deadlineUtc!)) {
        output.add(
          CalendarEntry(
            identity: 'deadline/${t.id}',
            kind: CalendarKind.deadline,
            title: t.title,
            start: t.deadlineUtc!,
            end: t.deadlineUtc!,
            task: t,
          ),
        );
      }
    }
    if (filters.kinds.contains(CalendarKind.target) &&
        t.targetUtc != null &&
        inRange(t.targetUtc!)) {
      output.add(
        CalendarEntry(
          identity: 'target/${t.id}',
          kind: CalendarKind.target,
          title: t.title,
          start: t.targetUtc!,
          end: t.targetUtc!,
          task: t,
        ),
      );
    }
  }
  if (filters.kinds.contains(CalendarKind.work)) {
    for (final b in data.blocks) {
      final t = tasks[b.taskId];
      if (t == null ||
          b.deletedAt != null ||
          (!filters.cancelled && b.status == WorkBlockStatus.cancelled) ||
          (!filters.completed && b.status == WorkBlockStatus.completed) ||
          !b.endUtc.isAfter(start) ||
          !b.startUtc.isBefore(end)) {
        continue;
      }
      output.add(
        CalendarEntry(
          identity: 'work/${b.id}',
          kind: CalendarKind.work,
          title: t.title,
          start: b.startUtc,
          end: b.endUtc,
          task: t,
          block: b,
        ),
      );
    }
  }
  if (filters.kinds.contains(CalendarKind.activity)) {
    for (final o in generateOccurrences(data.schedule, start, end)) {
      if ((!filters.cancelled && o.cancelled) ||
          (filters.courseId != null && o.series.courseId != filters.courseId)) {
        continue;
      }
      output.add(
        CalendarEntry(
          identity: 'activity/${o.identity}',
          kind: CalendarKind.activity,
          title: o.series.title,
          start: o.start,
          end: o.end,
          occurrence: o,
        ),
      );
    }
  }
  output.sort((a, b) {
    final byTime = a.start.compareTo(b.start);
    if (byTime != 0) return byTime;
    return a.identity.compareTo(b.identity);
  });
  return output;
}

bool entryOnDay(CalendarEntry e, CalendarDate day, String zone) {
  if (e.day != null) return e.day == day;
  if (e.start == e.end) return localDay(e.start, zone) == day;
  final start = resolveWall(dateValue(day), zone).instant;
  final end = resolveWall(dateValue(addDays(day, 1)), zone).instant;
  return e.end.isAfter(start) && e.start.isBefore(end);
}

List<CalendarEntry> workConflicts(
  PlanningSnapshot data,
  DateTime start,
  DateTime end,
  String zone, {
  String? excluding,
}) {
  final rows = projectCalendar(
    data,
    addDays(localDay(start, zone), -1),
    addDays(localDay(end, zone), 2),
    zone,
    filters: const CalendarFilters(completed: true),
  );
  return rows
      .where(
        (e) =>
            e.busy &&
            e.identity != 'work/$excluding' &&
            e.start.isBefore(end) &&
            e.end.isAfter(start),
      )
      .toList();
}
