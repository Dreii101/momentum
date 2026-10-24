import 'dart:math';

import 'package:drift/drift.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum TaskStatus { todo, doing, done }

enum TaskPriority { low, normal, high }

enum DeadlineKind { none, dateOnly, timed }

enum ThemePreference { system, light, dark }

enum WorkBlockStatus { planned, completed, cancelled }

/// A calendar date, never a midnight instant in the device's timezone.
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (year < 1 ||
        year > 9999 ||
        normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
  }
  factory CalendarDate.parse(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw FormatException('Expected YYYY-MM-DD', value);
    }
    return CalendarDate(
      int.parse(value.substring(0, 4)),
      int.parse(value.substring(5, 7)),
      int.parse(value.substring(8, 10)),
    );
  }
  final int year;
  final int month;
  final int day;
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  @override
  int compareTo(CalendarDate other) => toString().compareTo(other.toString());
  @override
  bool operator ==(Object other) =>
      other is CalendarDate && compareTo(other) == 0;
  @override
  int get hashCode => Object.hash(year, month, day);
}

class CalendarDateConverter extends TypeConverter<CalendarDate, String> {
  const CalendarDateConverter();
  @override
  CalendarDate fromSql(String fromDb) => CalendarDate.parse(fromDb);
  @override
  String toSql(CalendarDate value) => value.toString();
}

/// Integer milliseconds, with UTC guaranteed on every read.
class UtcInstantConverter extends TypeConverter<DateTime, int> {
  const UtcInstantConverter();
  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);
  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}

typedef Clock = DateTime Function();
typedef IdGenerator = String Function();

DateTime utcNow() => DateTime.now().toUtc();

/// RFC 9562 UUID v4, using the operating system's secure random source.
String newUuid() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

bool _zonesLoaded = false;
tz.Location requireTimeZone(String name) {
  if (name == 'UTC') return tz.UTC;
  if (!_zonesLoaded) {
    tz_data.initializeTimeZones();
    _zonesLoaded = true;
  }
  return tz.getLocation(name);
}

/// The first instant after a date-only deadline, in its stored IANA zone.
DateTime endOfDateExclusive(CalendarDate date, String zone) => tz.TZDateTime(
  requireTimeZone(zone),
  date.year,
  date.month,
  date.day + 1,
).toUtc();
