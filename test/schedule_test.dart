import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';

ActivityDraft weekly({
  String title = 'Class',
  String? courseId,
  CalendarDate? start,
  CalendarDate? end,
  String zone = 'Asia/Manila',
  int weekdays = 5,
  int startMinute = 540,
  int endMinute = 600,
  int offset = 0,
  bool busy = true,
}) => ActivityDraft(
  title: title,
  courseId: courseId,
  startDate: start ?? CalendarDate(2026, 10, 19),
  endDate: end ?? CalendarDate(2026, 11, 30),
  zone: zone,
  weekdays: weekdays,
  startMinute: startMinute,
  endMinute: endMinute,
  endDayOffset: offset,
  busy: busy,
);

class FailedScheduleUpgrade extends AppDatabase {
  FailedScheduleUpgrade(File file)
    : super(NativeDatabase.createInBackground(file));
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE notes SET body = 'Must roll back'");
    throw StateError('Injected after additive schedule migration');
  }
}

void main() {
  late DatabaseFixture fixture;
  late AppDatabase db;
  late MomentumRepository repo;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    db = fixture.open();
    repo = MomentumRepository(db, clock: () => DateTime.utc(2026, 10, 20));
    await repo.initialize();
  });
  tearDown(() => fixture.dispose());

  test('weekly weekdays, inclusive bounds, overnight, requested ranges and deterministic order', () async {
    final s = await repo.createActivity(
      weekly(
        start: CalendarDate(2026, 10, 20),
        end: CalendarDate(2026, 10, 28),
      ),
    );
    final data = await repo.scheduleSnapshot();
    final rows = generateOccurrences(
      data,
      DateTime.utc(2026, 10, 19),
      DateTime.utc(2026, 11),
    );
    expect(rows.map((o) => o.originalDate.toString()), [
      '2026-10-21',
      '2026-10-26',
      '2026-10-28',
    ]);
    expect(rows.every((o) => o.series.id == s.id && o.start.hour == 1), isTrue);
    expect(
      generateOccurrences(
        data,
        DateTime.utc(2026, 10, 22),
        DateTime.utc(2026, 10, 23),
      ),
      isEmpty,
    );
    final night = await repo.createActivity(
      ActivityDraft(
        title: 'Night',
        recurrence: 'once',
        weekdays: 0,
        startDate: CalendarDate(2026, 10, 21),
        endDate: CalendarDate(2026, 10, 21),
        startMinute: 23 * 60,
        endMinute: 60,
        endDayOffset: 1,
        zone: 'UTC',
      ),
    );
    final overnight = await repo.occurrence(night.id, night.startDate);
    expect(overnight.end, DateTime.utc(2026, 10, 22, 1));
    final nextDay = generateOccurrences(
      await repo.scheduleSnapshot(),
      DateTime.utc(2026, 10, 22),
      DateTime.utc(2026, 10, 23),
    );
    expect(nextDay.single.identity, overnight.identity);
    expect(
      () => generateOccurrences(data, DateTime.utc(2026), DateTime.utc(2028)),
      throwsArgumentError,
    );
  });

  test('DST gap moves the meeting by the exact gap; fold chooses first instant; non-hour/date skips', () {
    final gap = resolveInterval(
      CalendarDate(2026, 3, 8),
      150,
      180,
      0,
      'America/New_York',
    );
    expect(gap.start, DateTime.utc(2026, 3, 8, 7, 30));
    expect(gap.end, DateTime.utc(2026, 3, 8, 8));
    expect(gap.adjustments.single, contains('60 minutes'));
    final fold = resolveInterval(
      CalendarDate(2026, 11, 1),
      90,
      105,
      0,
      'America/New_York',
    );
    expect(fold.start, DateTime.utc(2026, 11, 1, 5, 30));
    expect(fold.end, DateTime.utc(2026, 11, 1, 5, 45));
    expect(fold.adjustments.single, contains('first occurrence'));
    final half = resolveInterval(
      CalendarDate(2026, 10, 4),
      135,
      180,
      0,
      'Australia/Lord_Howe',
    );
    expect(half.adjustments.single, contains('30 minutes'));
    expect(half.end.difference(half.start), const Duration(minutes: 45));
    final skipped = resolveInterval(
      CalendarDate(2011, 12, 30),
      540,
      600,
      0,
      'Pacific/Apia',
    );
    expect(skipped.adjustments.single, contains('1440 minutes'));
    expect(skipped.end.difference(skipped.start), const Duration(hours: 1));
  });

  test('move in/out of requested range keeps original identity, cancellation and notes', () async {
    final s = await repo.createActivity(weekly());
    final original = CalendarDate(2026, 10, 21);
    final note = await repo.createNote(
      const NoteDraft(body: 'Same original 🧬'),
    );
    await repo.setActivityLink(note.id, s.id, original, linked: true);
    await repo.changeOccurrence(
      s.id,
      original,
      move: OccurrenceMove(
        date: CalendarDate(2027, 1, 2),
        startMinute: 600,
        endMinute: 660,
        zone: 'UTC',
        location: 'Moved room',
      ),
    );
    final moved = await repo.occurrence(s.id, original);
    expect(moved.originalDate, original);
    expect(moved.location, 'Moved room');
    final data = await repo.scheduleSnapshot();
    expect(
      generateOccurrences(
        data,
        DateTime.utc(2026, 10, 21),
        DateTime.utc(2026, 10, 22),
      ),
      isEmpty,
    );
    expect(
      generateOccurrences(
        data,
        DateTime.utc(2027, 1, 2),
        DateTime.utc(2027, 1, 3),
      ).single.identity,
      moved.identity,
    );
    await repo.changeOccurrence(s.id, original, cancelled: true);
    expect((await repo.occurrence(s.id, original)).cancelled, isTrue);
    await repo.changeOccurrence(s.id, original, cancelled: false);
    expect((await repo.occurrence(s.id, original)).start, moved.start);
    expect(
      (await repo.watchActivityLinks(noteId: note.id).first)
          .single
          .originalDate,
      original,
    );
    await repo.changeOccurrence(s.id, original, reset: true);
    expect((await repo.occurrence(s.id, original)).moved, isFalse);
    expect((await repo.note(note.id)).body, 'Same original 🧬');
  });

  test('split previews links and exceptions, preserves history and retained original access across reopen', () async {
    final s = await repo.createActivity(weekly());
    final past = await repo.occurrence(s.id, CalendarDate(2026, 10, 19));
    final day = CalendarDate(2026, 10, 26);
    final note = await repo.createNote(const NoteDraft(body: 'Retain'));
    await repo.setActivityLink(note.id, s.id, day, linked: true);
    await repo.setActivityLink(note.id, s.id, null, linked: true);
    await repo.changeOccurrence(s.id, day, cancelled: true);
    final preview = await repo.previewSplit(s.id, day);
    expect(preview.links, hasLength(2));
    expect(preview.exceptions, hasLength(1));
    final next = await repo.replaceFuture(
      preview,
      weekly(title: 'New time', start: day, startMinute: 600, endMinute: 660),
    );
    expect((await repo.occurrence(s.id, past.originalDate)).start, past.start);
    expect((await repo.occurrence(s.id, day)).superseded, isTrue);
    expect((await repo.occurrence(s.id, day)).cancelled, isTrue);
    expect(await repo.watchActivityLinks(seriesId: next.id).first, isEmpty);
    expect(await repo.watchActivityLinks(seriesId: s.id).first, hasLength(2));
    final rows = generateOccurrences(
      await repo.scheduleSnapshot(),
      DateTime.utc(2026, 10, 26),
      DateTime.utc(2026, 10, 27),
    );
    expect(rows.single.series.id, next.id);
    await expectLater(
      repo.changeOccurrence(s.id, day, cancelled: false),
      throwsStateError,
    );
    await db.close();
    final reopened = MomentumRepository(fixture.open());
    expect((await reopened.occurrence(s.id, day)).cancelled, isTrue);
    expect((await reopened.activity(s.id)).replacedBy, next.id);
    expect((await reopened.note(note.id)).body, 'Retain');
  });

  test(
    'stale preview and past rescheduled occurrence refuse split atomically',
    () async {
      final s = await repo.createActivity(weekly());
      final day = CalendarDate(2026, 10, 26);
      final preview = await repo.previewSplit(s.id, day);
      final note = await repo.createNote(const NoteDraft());
      await repo.setActivityLink(note.id, s.id, day, linked: true);
      await expectLater(
        repo.replaceFuture(preview, weekly(start: day)),
        throwsStateError,
      );
      expect((await repo.scheduleSnapshot()).series, hasLength(1));
      await repo.changeOccurrence(
        s.id,
        day,
        move: OccurrenceMove(
          date: CalendarDate(2026, 10, 18),
          startMinute: 600,
          endMinute: 660,
          zone: 'UTC',
        ),
      );
      final fresh = await repo.previewSplit(s.id, day);
      await expectLater(
        repo.replaceFuture(fresh, weekly(start: day)),
        throwsStateError,
      );
      expect((await repo.activity(s.id)).supersededFrom, isNull);
      await expectLater(
        repo.previewSplit(s.id, CalendarDate(2026, 10, 19)),
        throwsStateError,
      );
    },
  );

  test('course archive retains schedule/task/note relationships; dates and positive duration validate', () async {
    final c = await repo.createCourse(
      CourseDraft(
        name: 'Course',
        termStart: CalendarDate(2026, 10, 1),
        termEnd: CalendarDate(2026, 12, 1),
      ),
    );
    final task = await repo.createTask(
      TaskDraft(title: 'Assignment', courseId: c.id),
    );
    final note = await repo.createNote(NoteDraft(courseId: c.id));
    final s = await repo.createActivity(weekly(courseId: c.id));
    await repo.archiveCourse(c.id);
    expect((await repo.scheduleSnapshot()).series.single.courseId, c.id);
    expect((await repo.task(task.id)).courseId, c.id);
    expect((await repo.note(note.id)).courseId, c.id);
    await expectLater(
      repo.createActivity(
        weekly(courseId: c.id, end: CalendarDate(2027, 1, 1)),
      ),
      throwsFormatException,
    );
    await expectLater(
      repo.updateCourse(
        c.id,
        CourseDraft(name: 'Course', termEnd: CalendarDate(2026, 10, 22)),
      ),
      throwsFormatException,
    );
    await expectLater(
      repo.createActivity(weekly(weekdays: 0)),
      throwsFormatException,
    );
    await expectLater(
      repo.createActivity(weekly(startMinute: 600, endMinute: 600)),
      throwsFormatException,
    );
    await expectLater(
      repo.changeOccurrence(s.id, CalendarDate(2026, 10, 22), cancelled: true),
      throwsFormatException,
    );
  });

  test('SQL unique series and occurrence links, foreign keys, checks and outer rollback', () async {
    final s = await repo.createActivity(weekly());
    final n = await repo.createNote(const NoteDraft());
    await repo.setActivityLink(n.id, s.id, null, linked: true);
    await repo.setActivityLink(n.id, s.id, null, linked: true);
    await repo.setActivityLink(n.id, s.id, s.startDate, linked: true);
    for (final original in [null, s.startDate.toString()]) {
      await expectLater(
        db.customStatement(
          'INSERT INTO note_activity_links (id,note_id,series_id,original_date,created_at) VALUES (?,?,?,?,?)',
          [newUuid(), n.id, s.id, original, 1],
        ),
        throwsException,
      );
    }
    await expectLater(
      db.customStatement('UPDATE activity_series SET weekdays=0 WHERE id=?', [
        s.id,
      ]),
      throwsException,
    );
    await expectLater(
      db.customStatement('UPDATE activity_series SET course_id=? WHERE id=?', [
        newUuid(),
        s.id,
      ]),
      throwsException,
    );
    await expectLater(
      repo.transaction(() async {
        await repo.changeOccurrence(s.id, s.startDate, cancelled: true);
        await repo.setActivityLink(n.id, s.id, null, linked: false);
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await repo.activityException(s.id, s.startDate), isNull);
    expect(await repo.watchActivityLinks(noteId: n.id).first, hasLength(2));
  });

  test(
    'overlap is exclusive at edges, ignores free/cancelled, includes overnight',
    () async {
      final a = await repo.createActivity(weekly(zone: 'UTC'));
      final b = await repo.createActivity(
        weekly(zone: 'UTC', startMinute: 570, endMinute: 630),
      );
      final free = await repo.createActivity(weekly(zone: 'UTC', busy: false));
      final edge = await repo.createActivity(
        weekly(zone: 'UTC', startMinute: 600, endMinute: 660),
      );
      final day = a.startDate;
      expect(
        overlaps(
          await repo.occurrence(a.id, day),
          await repo.occurrence(b.id, day),
        ),
        isTrue,
      );
      expect(
        overlaps(
          await repo.occurrence(a.id, day),
          await repo.occurrence(free.id, day),
        ),
        isFalse,
      );
      expect(
        overlaps(
          await repo.occurrence(a.id, day),
          await repo.occurrence(edge.id, day),
        ),
        isFalse,
      );
      await repo.changeOccurrence(b.id, day, cancelled: true);
      expect(
        overlaps(
          await repo.occurrence(a.id, day),
          await repo.occurrence(b.id, day),
        ),
        isFalse,
      );
    },
  );

  test('populated schema4 migration preserves every field, rollback and current frozen schema6', () async {
    final old = File('${fixture.directory.path}/schema4.sqlite');
    createSchemaFixture(old, version: 4);
    seedSchemaV1(old);
    final before = readAllFixtureData(old), oldSchema = readSchema(old);
    final failing = FailedScheduleUpgrade(old);
    await expectLater(failing.ensureOpen(), throwsA(isA<Object>()));
    await failing.close();
    expect(readAllFixtureData(old), before);
    expect(readSchema(old), oldSchema);
    final raw = sql.sqlite3.open(old.path);
    expect(raw.select('PRAGMA user_version').single.values.single, 4);
    raw.close();
    final upgraded = AppDatabase.file(old);
    await upgraded.ensureOpen();
    expect(await upgraded.select(upgraded.activitySeriesRows).get(), isEmpty);
    await upgraded.close();
    expect(readAllFixtureData(old), before);
    final expected = File('${fixture.directory.path}/schema5.sqlite');
    createSchemaFixture(expected, version: 10);
    expect(readSchema(old), readSchema(expected));
  });
}
