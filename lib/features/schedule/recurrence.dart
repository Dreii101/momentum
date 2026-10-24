import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/database/value_types.dart';

DateTime dateValue(CalendarDate d) => DateTime.utc(d.year, d.month, d.day);
CalendarDate calendarOf(DateTime d) => CalendarDate(d.year, d.month, d.day);
CalendarDate addDays(CalendarDate d, int days) =>
    calendarOf(dateValue(d).add(Duration(days: days)));
String minuteLabel(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
int parseMinute(String text) {
  if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text.trim())) {
    throw const FormatException('Use HH:MM in 24-hour time.');
  }
  final parts = text.trim().split(':').map(int.parse).toList();
  return parts[0] * 60 + parts[1];
}

class ActivityDraft {
  const ActivityDraft({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.startMinute,
    required this.endMinute,
    required this.zone,
    this.recurrence = 'weekly',
    this.weekdays = 1,
    this.endDayOffset = 0,
    this.courseId,
    this.location = '',
    this.busy = true,
  });
  factory ActivityDraft.from(ActivitySeries s) => ActivityDraft(
    title: s.title,
    startDate: s.startDate,
    endDate: s.endDate,
    startMinute: s.startMinute,
    endMinute: s.endMinute,
    zone: s.zone,
    recurrence: s.recurrence,
    weekdays: s.weekdays,
    endDayOffset: s.endDayOffset,
    courseId: s.courseId,
    location: s.location,
    busy: s.busy,
  );
  final String title, recurrence, zone, location;
  final CalendarDate startDate, endDate;
  final int weekdays, startMinute, endMinute, endDayOffset;
  final String? courseId;
  final bool busy;
}

class OccurrenceMove {
  const OccurrenceMove({
    required this.date,
    required this.startMinute,
    required this.endMinute,
    required this.zone,
    this.endDayOffset = 0,
    this.location = '',
  });
  final CalendarDate date;
  final int startMinute, endMinute, endDayOffset;
  final String zone, location;
}

void validateInterval(int start, int end, int offset, String zone) {
  requireTimeZone(zone);
  if (start < 0 ||
      start > 1439 ||
      end < 0 ||
      end > 1439 ||
      offset < 0 ||
      offset > 1 ||
      end + offset * 1440 <= start) {
    throw const FormatException(
      'End must follow start. Select next-day ending for an overnight activity.',
    );
  }
}

void validateActivity(ActivityDraft d, {Course? course}) {
  if (d.title.trim().isEmpty || d.title.trim().runes.length > 200) {
    throw const FormatException('Enter an activity title of 1–200 characters.');
  }
  if (d.startDate.compareTo(d.endDate) > 0 ||
      (course?.termStart != null &&
          d.startDate.compareTo(course!.termStart!) < 0) ||
      (course?.termEnd != null && d.endDate.compareTo(course!.termEnd!) > 0)) {
    throw const FormatException(
      'Activity dates must be ordered and within the course term.',
    );
  }
  if ((d.recurrence != 'once' && d.recurrence != 'weekly') ||
      (d.recurrence == 'once' &&
          (d.startDate != d.endDate || d.weekdays != 0)) ||
      (d.recurrence == 'weekly' && (d.weekdays < 1 || d.weekdays > 127))) {
    throw const FormatException(
      'Choose one date, or at least one weekday for a weekly series.',
    );
  }
  validateInterval(d.startMinute, d.endMinute, d.endDayOffset, d.zone);
  if (d.recurrence == 'weekly' &&
      !List.generate(7, (i) => addDays(d.startDate, i)).any(
        (day) =>
            day.compareTo(d.endDate) <= 0 &&
            d.weekdays & (1 << (dateValue(day).weekday - 1)) != 0,
      )) {
    throw const FormatException(
      'No selected weekday occurs within these dates.',
    );
  }
}

class WallResolution {
  const WallResolution(this.instant, this.shift, this.ambiguous);
  final DateTime instant;
  final Duration shift;
  final bool ambiguous;
}

/// Match offsets around this wall date rather than relying on constructor
/// normalization. A fold chooses the first chronological instant. A gap shifts
/// by the actual offset change (including half-hour and whole-date gaps).
WallResolution resolveWall(DateTime wall, String zone) {
  final location = requireTimeZone(zone);
  final offsets = <int>{};
  for (var h = -72; h <= 72; h += 3) {
    offsets.add(
      tz.TZDateTime.from(
        wall.add(Duration(hours: h)),
        location,
      ).timeZoneOffset.inMilliseconds,
    );
  }
  final matches = <DateTime>[];
  final forward = <({DateTime instant, Duration shift})>[];
  for (final offset in offsets) {
    final candidate = wall.subtract(Duration(milliseconds: offset));
    final local = tz.TZDateTime.from(candidate, location);
    final actualWall = DateTime.utc(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
    );
    final difference = actualWall.difference(wall);
    if (difference == Duration.zero) matches.add(candidate);
    if (difference > Duration.zero) {
      forward.add((instant: candidate, shift: difference));
    }
  }
  matches.sort();
  if (matches.isNotEmpty) {
    return WallResolution(matches.first, Duration.zero, matches.length > 1);
  }
  forward.sort((a, b) => a.shift.compareTo(b.shift));
  if (forward.isEmpty) {
    throw StateError('Could not resolve local time in $zone');
  }
  return WallResolution(forward.first.instant, forward.first.shift, false);
}

class ResolvedInterval {
  const ResolvedInterval(this.start, this.end, this.adjustments);
  final DateTime start, end;
  final List<String> adjustments;
}

ResolvedInterval resolveInterval(
  CalendarDate date,
  int start,
  int end,
  int endDayOffset,
  String zone,
) {
  validateInterval(start, end, endDayOffset, zone);
  final begin = resolveWall(
    dateValue(date).add(Duration(minutes: start)),
    zone,
  );
  // Shift the whole meeting when its start is in a gap, preserving its intended
  // wall duration instead of allowing its adjusted start to overtake its end.
  final finish = resolveWall(
    dateValue(date)
        .add(Duration(days: endDayOffset, minutes: end) + begin.shift),
    zone,
  );
  if (!finish.instant.isAfter(begin.instant)) {
    throw const FormatException(
      'This clock change produces a non-positive duration. Choose another ending time.',
    );
  }
  return ResolvedInterval(begin.instant, finish.instant, [
    if (begin.shift > Duration.zero)
      'Clock gap: meeting moved forward ${begin.shift.inMinutes} minutes.',
    if (finish.shift > Duration.zero)
      'Clock gap: ending moved forward ${finish.shift.inMinutes} minutes.',
    if (begin.ambiguous || finish.ambiguous)
      'Repeated local time: first occurrence (earlier instant) selected.',
  ]);
}

bool isOriginalDate(ActivitySeries s, CalendarDate day) =>
    day.compareTo(s.startDate) >= 0 &&
    day.compareTo(s.endDate) <= 0 &&
    (s.recurrence == 'once' ||
        (s.weekdays & (1 << (dateValue(day).weekday - 1))) != 0);

class Occurrence {
  const Occurrence({
    required this.series,
    required this.originalDate,
    required this.start,
    required this.end,
    required this.zone,
    required this.location,
    required this.cancelled,
    required this.superseded,
    required this.moved,
    required this.adjustments,
  });
  final ActivitySeries series;
  final CalendarDate originalDate;
  final DateTime start, end;
  final String zone, location;
  final bool cancelled, superseded, moved;
  final List<String> adjustments;
  String get identity => '${series.id}/$originalDate';
}

Occurrence occurrenceFor(
  ActivitySeries s,
  CalendarDate original, [
  ActivityException? exception,
]) {
  if (!isOriginalDate(s, original)) {
    throw const FormatException(
      'That date is not an original occurrence of this series.',
    );
  }
  if (exception != null &&
      (exception.seriesId != s.id || exception.originalDate != original)) {
    throw ArgumentError('Wrong occurrence exception');
  }
  final interval = resolveInterval(
    exception?.movedDate ?? original,
    exception?.startMinute ?? s.startMinute,
    exception?.endMinute ?? s.endMinute,
    exception?.endDayOffset ?? s.endDayOffset,
    exception?.zone ?? s.zone,
  );
  return Occurrence(
    series: s,
    originalDate: original,
    start: interval.start,
    end: interval.end,
    zone: exception?.zone ?? s.zone,
    location: exception?.location ?? s.location,
    cancelled: exception?.cancelled ?? false,
    superseded:
        s.supersededFrom != null && original.compareTo(s.supersededFrom!) >= 0,
    moved: exception?.movedDate != null,
    adjustments: interval.adjustments,
  );
}

class ScheduleSnapshot {
  const ScheduleSnapshot(this.series, this.exceptions, this.courses);
  final List<ActivitySeries> series;
  final List<ActivityException> exceptions;
  final List<Course> courses;
  Occurrence occurrence(String id, CalendarDate day) => occurrenceFor(
    series.firstWhere((s) => s.id == id),
    day,
    exceptions
        .where((e) => e.seriesId == id && e.originalDate == day)
        .firstOrNull,
  );
}

/// Range is half-open in instants. Only nearby original dates are expanded;
/// moved exceptions are considered separately so moved-in records aren't lost.
List<Occurrence> generateOccurrences(
  ScheduleSnapshot data,
  DateTime from,
  DateTime until,
) {
  if (!until.isAfter(from) || until.difference(from).inDays > 366) {
    throw ArgumentError(
      'Request a positive timetable range of at most 366 days.',
    );
  }
  final output = <Occurrence>[];
  final exceptionMap = {
    for (final e in data.exceptions) '${e.seriesId}/${e.originalDate}': e,
  };
  for (final s in data.series.where((s) => s.deletedAt == null)) {
    final zone = requireTimeZone(s.zone);
    var first = addDays(calendarOf(tz.TZDateTime.from(from, zone)), -2);
    var last = addDays(calendarOf(tz.TZDateTime.from(until, zone)), 2);
    if (first.compareTo(s.startDate) < 0) first = s.startDate;
    if (last.compareTo(s.endDate) > 0) last = s.endDate;
    final dates = <CalendarDate>{};
    for (var day = first; day.compareTo(last) <= 0; day = addDays(day, 1)) {
      if (isOriginalDate(s, day)) dates.add(day);
    }
    dates.addAll(
      data.exceptions
          .where((e) {
            if (e.seriesId != s.id || e.movedDate == null) return false;
            final movedZone = requireTimeZone(e.zone!);
            final low = addDays(
              calendarOf(tz.TZDateTime.from(from, movedZone)),
              -2,
            );
            final high = addDays(
              calendarOf(tz.TZDateTime.from(until, movedZone)),
              2,
            );
            return e.movedDate!.compareTo(low) >= 0 &&
                e.movedDate!.compareTo(high) <= 0;
          })
          .map((e) => e.originalDate),
    );
    for (final day in dates) {
      final o = occurrenceFor(s, day, exceptionMap['${s.id}/$day']);
      if (!o.superseded && o.end.isAfter(from) && o.start.isBefore(until)) {
        output.add(o);
      }
    }
  }
  output.sort((a, b) {
    final byTime = a.start.compareTo(b.start);
    return byTime != 0 ? byTime : a.identity.compareTo(b.identity);
  });
  return output;
}

bool overlaps(Occurrence a, Occurrence b) =>
    a.identity != b.identity &&
    !a.cancelled &&
    !b.cancelled &&
    !a.superseded &&
    !b.superseded &&
    a.series.busy &&
    b.series.busy &&
    a.start.isBefore(b.end) &&
    b.start.isBefore(a.end);
