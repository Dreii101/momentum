import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/calendar/calendar_projection.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';
import 'schedule_test.dart' show weekly;

WorkBlockDraft workDraft(
  String task, {
  int hour = 1,
  WorkBlockStatus status = WorkBlockStatus.planned,
  bool locked = false,
}) => WorkBlockDraft(
  taskId: task,
  startUtc: DateTime.utc(2026, 10, 21, hour),
  endUtc: DateTime.utc(2026, 10, 21, hour + 1),
  planningZone: 'Asia/Manila',
  status: status,
  locked: locked,
);

Map<String, Object?> readEveryRow(File file) {
  final raw = sql.sqlite3.open(file.path);
  try {
    return {
      for (final t in raw.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      ))
        t['name'] as String: raw
            .select('SELECT * FROM "${t['name']}" ORDER BY 1')
            .map((r) => Map<String, Object?>.from(r))
            .toList(),
    };
  } finally {
    raw.close();
  }
}

void seedScheduleV5(File file) {
  createSchemaFixture(file, version: 5);
  seedSchemaV1(file);
  final raw = sql.sqlite3.open(file.path);
  try {
    raw.execute('PRAGMA foreign_keys=ON');
    raw.execute(
      "INSERT INTO activity_series(id,created_at,updated_at,title,course_id,recurrence,weekdays,start_date,end_date,start_minute,end_minute,end_day_offset,zone,location,busy) VALUES (?,?,?,?,?,'weekly',5,'2026-10-19','2026-11-30',540,600,0,'Asia/Manila','Room 🧬',1)",
      [
        '00000000-0000-4000-8000-000000000021',
        fixtureInstant,
        fixtureInstant,
        'Existing class',
        fixtureCourseId,
      ],
    );
    raw.execute(
      "INSERT INTO activity_exceptions(id,series_id,original_date,cancelled,created_at,updated_at) VALUES (?,?, '2026-10-21',1,?,?)",
      [
        '00000000-0000-4000-8000-000000000022',
        '00000000-0000-4000-8000-000000000021',
        fixtureInstant,
        fixtureInstant,
      ],
    );
    raw.execute(
      "INSERT INTO note_activity_links(id,note_id,series_id,original_date,created_at) VALUES (?,?,?,NULL,?)",
      [
        '00000000-0000-4000-8000-000000000023',
        fixtureNoteId,
        '00000000-0000-4000-8000-000000000021',
        fixtureInstant,
      ],
    );
  } finally {
    raw.close();
  }
}

class FailedPlanningUpgrade extends AppDatabase {
  FailedPlanningUpgrade(File file)
    : super(NativeDatabase.createInBackground(file));
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE notes SET body='must roll back'");
    throw StateError('Injected planning migration failure');
  }
}

void main() {
  late DatabaseFixture fixture;
  late MomentumRepository repo;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    repo = MomentumRepository(
      fixture.open(),
      clock: () => DateTime.utc(2026, 10, 20),
    );
    await repo.initialize();
  });
  tearDown(() => fixture.dispose());
  List<CalendarEntry> project(
    PlanningSnapshot data, {
    String zone = 'Asia/Manila',
    CalendarFilters filters = const CalendarFilters(),
  }) => projectCalendar(
    data,
    CalendarDate(2026, 10, 21),
    CalendarDate(2026, 10, 22),
    zone,
    filters: filters,
  );

  test(
    'work CRUD and reopen keep every deadline/target/estimate field untouched',
    () async {
      final t = await repo.createTask(
        TaskDraft(
          title: 'Draft essay',
          deadline: Deadline.timed(
            DateTime.utc(2026, 10, 23, 1),
            'Asia/Manila',
          ),
          targetUtc: DateTime.utc(2026, 10, 22),
          remainingMinutes: 90,
        ),
      );
      final b = await repo.saveWorkBlock(workDraft(t.id, locked: true));
      final moved = await repo.saveWorkBlock(
        workDraft(t.id, hour: 5, status: WorkBlockStatus.completed),
        id: b.id,
      );
      expect(moved.id, b.id);
      expect(moved.createdAt, b.createdAt);
      expect(moved.startUtc, DateTime.utc(2026, 10, 21, 5));
      expect(await repo.task(t.id), t);
      await repo.deleteWorkBlock(b.id);
      expect((await repo.workBlock(b.id)).deletedAt, isNotNull);
      await repo.deleteWorkBlock(b.id, deleted: false);
      await repo.database.close();
      final reopened = MomentumRepository(fixture.open());
      expect(await reopened.task(t.id), t);
      expect(await reopened.workBlock(b.id), moved);
    },
  );

  test(
    'positive duration, FK, enum and integer constraints plus rollback',
    () async {
      final t = await repo.createTask(const TaskDraft(title: 'Work'));
      final start = DateTime.utc(2026, 10, 21);
      await expectLater(
        repo.saveWorkBlock(
          WorkBlockDraft(
            taskId: t.id,
            startUtc: start,
            endUtc: start,
            planningZone: 'UTC',
          ),
        ),
        throwsFormatException,
      );
      await expectLater(
        repo.saveWorkBlock(
          WorkBlockDraft(
            taskId: t.id,
            startUtc: start,
            endUtc: start.add(const Duration(hours: 1)),
            planningZone: 'No/Zone',
          ),
        ),
        throwsA(predicate<Object>((e) => e.toString().contains('No/Zone'))),
      );
      final b = await repo.saveWorkBlock(workDraft(t.id));
      for (final sqlText in [
        "UPDATE planned_work_blocks SET end_utc=start_utc",
        "UPDATE planned_work_blocks SET status='invalid'",
        "UPDATE planned_work_blocks SET start_utc=1.5",
        "UPDATE planned_work_blocks SET task_id='00000000-0000-4000-8000-000000000099'",
      ]) {
        await expectLater(
          repo.database.customStatement(sqlText),
          throwsA(isA<Exception>()),
        );
      }
      await expectLater(
        repo.transaction(() async {
          await repo.deleteWorkBlock(b.id);
          await repo.saveWorkBlock(workDraft(t.id, hour: 7));
          throw StateError('rollback');
        }),
        throwsStateError,
      );
      expect((await repo.planningSnapshot()).blocks, [b]);
    },
  );

  test('all-day date stays written; timed instants and targets use display zone and half-open midnight', () async {
    final all = await repo.createTask(
      TaskDraft(
        title: 'All day',
        deadline: Deadline.dateOnly(
          CalendarDate(2026, 10, 21),
          'America/Los_Angeles',
        ),
      ),
    );
    final midnight = await repo.createTask(
      TaskDraft(
        title: 'Midnight',
        deadline: Deadline.timed(DateTime.utc(2026, 10, 20, 16), 'UTC'),
        targetUtc: DateTime.utc(2026, 10, 20, 15),
      ),
    );
    await repo.createTask(
      TaskDraft(
        title: 'Next midnight',
        deadline: Deadline.timed(DateTime.utc(2026, 10, 21, 16), 'UTC'),
      ),
    );
    final data = await repo.planningSnapshot();
    final manila = project(data);
    expect(manila.map((e) => e.title), containsAll(['All day', 'Midnight']));
    expect(manila.map((e) => e.title), isNot(contains('Next midnight')));
    final deadline = manila.singleWhere((e) => e.task!.id == all.id);
    expect(deadline.day, CalendarDate(2026, 10, 21));
    final la = project(data, zone: 'America/Los_Angeles');
    expect(la.singleWhere((e) => e.task!.id == all.id).day, deadline.day);
    expect(manila.where((e) => e.task!.id == midnight.id), hasLength(1));
    final prior = projectCalendar(
      data,
      CalendarDate(2026, 10, 20),
      CalendarDate(2026, 10, 21),
      'Asia/Manila',
    );
    expect(prior.single.kind, CalendarKind.target);
  });

  test('moved activities appear once and cancellation is opt-in', () async {
    final s = await repo.createActivity(weekly());
    await repo.changeOccurrence(
      s.id,
      CalendarDate(2026, 10, 21),
      move: OccurrenceMove(
        date: CalendarDate(2026, 10, 22),
        startMinute: 540,
        endMinute: 600,
        zone: 'Asia/Manila',
      ),
    );
    var data = await repo.planningSnapshot();
    expect(project(data), isEmpty);
    final next = projectCalendar(
      data,
      CalendarDate(2026, 10, 19),
      CalendarDate(2026, 10, 26),
      'Asia/Manila',
    );
    expect(
      next.where(
        (e) => e.occurrence!.originalDate == CalendarDate(2026, 10, 21),
      ),
      hasLength(1),
    );
    await repo.changeOccurrence(
      s.id,
      CalendarDate(2026, 10, 21),
      cancelled: true,
    );
    data = await repo.planningSnapshot();
    expect(
      projectCalendar(
        data,
        CalendarDate(2026, 10, 22),
        CalendarDate(2026, 10, 23),
        'Asia/Manila',
      ),
      isEmpty,
    );
    expect(
      projectCalendar(
        data,
        CalendarDate(2026, 10, 22),
        CalendarDate(2026, 10, 23),
        'Asia/Manila',
        filters: const CalendarFilters(cancelled: true),
      ).single.cancelled,
      isTrue,
    );
  });

  test('overnight work intersects both days, exclusive edges and overlap ignores free/cancelled', () async {
    final t = await repo.createTask(const TaskDraft(title: 'Late work'));
    final b = await repo.saveWorkBlock(
      WorkBlockDraft(
        taskId: t.id,
        startUtc: DateTime.utc(2026, 10, 21, 15, 30),
        endUtc: DateTime.utc(2026, 10, 21, 16, 30),
        planningZone: 'Asia/Manila',
      ),
    );
    final s = await repo.createActivity(
      weekly(startMinute: 1410, endMinute: 60, offset: 1),
    );
    await repo.createActivity(
      weekly(
        title: 'Free',
        busy: false,
        startMinute: 1410,
        endMinute: 60,
        offset: 1,
      ),
    );
    final data = await repo.planningSnapshot();
    final entry = project(data).singleWhere((e) => e.block != null);
    expect(
      entryOnDay(entry, CalendarDate(2026, 10, 21), 'Asia/Manila'),
      isTrue,
    );
    expect(
      entryOnDay(entry, CalendarDate(2026, 10, 22), 'Asia/Manila'),
      isTrue,
    );
    expect(
      workConflicts(
        data,
        b.startUtc,
        b.endUtc,
        'Asia/Manila',
        excluding: b.id,
      ).map((e) => e.title),
      ['Class'],
    );
    expect(
      workConflicts(
        data,
        b.endUtc,
        b.endUtc.add(const Duration(minutes: 1)),
        'Asia/Manila',
      ).any((e) => e.block != null),
      isFalse,
    );
    await repo.changeOccurrence(
      s.id,
      CalendarDate(2026, 10, 21),
      cancelled: true,
    );
    expect(
      workConflicts(
        await repo.planningSnapshot(),
        b.startUtc,
        b.endUtc,
        'Asia/Manila',
        excluding: b.id,
      ),
      isEmpty,
    );
  });

  test('source Trash/archive hides projections, restore retains blocks; filters include completed/cancelled deliberately', () async {
    final c = await repo.createCourse(const CourseDraft(name: 'Course'));
    final t = await repo.createTask(TaskDraft(title: 'Plan', courseId: c.id));
    final b = await repo.saveWorkBlock(workDraft(t.id));
    await repo.archiveTask(t.id);
    expect(project(await repo.planningSnapshot()), isEmpty);
    await repo.archiveTask(t.id, archived: false);
    expect(project(await repo.planningSnapshot()).single.block!.id, b.id);
    await repo.deleteTask(t.id);
    expect(project(await repo.planningSnapshot()), isEmpty);
    expect((await repo.workBlock(b.id)).deletedAt, isNull);
    await repo.deleteTask(t.id, deleted: false);
    await repo.saveWorkBlock(
      workDraft(t.id, status: WorkBlockStatus.cancelled),
      id: b.id,
    );
    expect(project(await repo.planningSnapshot()), isEmpty);
    expect(
      project(
        await repo.planningSnapshot(),
        filters: CalendarFilters(courseId: c.id, cancelled: true),
      ),
      hasLength(1),
    );
    await repo.saveWorkBlock(
      workDraft(t.id, status: WorkBlockStatus.completed),
      id: b.id,
    );
    expect(
      project(
        await repo.planningSnapshot(),
        filters: const CalendarFilters(completed: true),
      ),
      hasLength(1),
    );
  });

  test('reminder reconciliation stream observes initial state and committed source changes', () async {
    final events = <PlanningSnapshot>[];
    final sub = repo.watchReminderReconciliationInputs().listen(events.add);
    Future<void> waitFor(bool Function() done) async {
      for (var i = 0; i < 200 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(done(), isTrue);
    }

    try {
      await waitFor(() => events.isNotEmpty);
      final t = await repo.createTask(const TaskDraft(title: 'Hook'));
      await waitFor(() => events.last.tasks.any((v) => v.id == t.id));
      final b = await repo.saveWorkBlock(workDraft(t.id));
      await waitFor(() => events.last.blocks.any((v) => v.id == b.id));
      await repo.deleteTask(t.id);
      await waitFor(() => events.last.tasks.single.deletedAt != null);
      expect(project(events.last), isEmpty);
      expect(events.last.blocks.single.id, b.id);
    } finally {
      await sub.cancel();
    }
  });

  test('populated v5 upgrade preserves all 11 tables; failed migration rolls back DDL and data', () async {
    final file = File('${fixture.directory.path}/old.sqlite');
    seedScheduleV5(file);
    final before = readEveryRow(file);
    final failed = FailedPlanningUpgrade(file);
    try {
      await expectLater(
        failed.ensureOpen(),
        throwsA(
          predicate<Object>(
            (e) => e.toString().contains('Injected planning migration failure'),
          ),
        ),
      );
    } finally {
      await failed.close();
    }
    expect(readEveryRow(file), before);
    final raw = sql.sqlite3.open(file.path);
    expect(raw.select('PRAGMA user_version').single.values.single, 5);
    raw.close();
    final upgraded = AppDatabase.file(file);
    await upgraded.ensureOpen();
    await upgraded.close();
    final after = readEveryRow(file);
    expect(after.keys, hasLength(20));
    for (final key in before.keys) {
      expect(after[key], before[key], reason: key);
    }
    final expected = File('${fixture.directory.path}/schema6.sqlite');
    createSchemaFixture(expected, version: 10);
    expect(readSchema(file), readSchema(expected));
  });
}
