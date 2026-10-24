import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';

import 'support/database_fixture.dart';

void main() {
  late DatabaseFixture fixture;
  late AppDatabase db;
  late MomentumRepository repository;
  final now = DateTime.utc(2026, 10, 20, 10, 20, 30, 123);
  setUp(() async {
    fixture = await DatabaseFixture.create();
    db = fixture.open();
    repository = MomentumRepository(db, clock: () => now);
    await repository.initialize();
  });
  tearDown(() => fixture.dispose());

  test(
    'all preferences survive reopen and invalid timer values are rejected',
    () async {
      final identity = await repository.installation();
      await repository.updateSettings(
        theme: ThemePreference.dark,
        planningZone: 'Europe/London',
        focusMinutes: 45,
        breakMinutes: 8,
        reducedMotion: true,
      );
      final saved = await repository.settings();
      for (final assignment in [
        'focus_minutes = 0',
        'focus_minutes = 181',
        'focus_minutes = 1.5',
        'break_minutes = 0',
        'break_minutes = 61',
        'break_minutes = 2.5',
        'reduced_motion = 2',
      ]) {
        await expectLater(
          db.customStatement('UPDATE app_settings SET $assignment'),
          throwsException,
        );
      }
      expect(await repository.settings(), saved);
      await repository.updateSettings(
        theme: ThemePreference.light,
        planningZone: 'Asia/Manila',
      );
      final updated = await repository.settings();
      expect(updated.focusMinutes, 45);
      expect(updated.breakMinutes, 8);
      expect(updated.reducedMotion, isTrue);
      await db.close();
      final reopened = MomentumRepository(fixture.open());
      await reopened.initialize();
      expect(await reopened.settings(), updated);
      expect(await reopened.installation(), identity);
    },
  );

  test('all models persist, UTC milliseconds/date values and installation survive reopen', () async {
    final records = await seedRecords(repository);
    final installation = await repository.installation();
    final settings = await repository.settings();
    final priorities = await repository
        .watchPriorities(CalendarDate(2026, 10, 20))
        .first;
    await db.close();
    final reopened = MomentumRepository(fixture.open());
    await reopened.initialize();
    expect(await reopened.task(records.task.id), records.task);
    expect(await reopened.subtask(records.subtask.id), records.subtask);
    expect(await reopened.note(records.note.id), records.note);
    expect(await reopened.watchLinksForNote(records.note.id).first, [
      records.link,
    ]);
    expect(
      await reopened.watchPriorities(CalendarDate(2026, 10, 20)).first,
      priorities,
    );
    expect(await reopened.installation(), installation);
    expect(await reopened.settings(), settings);
    final course = await reopened.course(records.course.id);
    expect(course.archivedAt, now);
    expect(course.termEnd, CalendarDate(2027, 2, 28));
    expect(records.task.createdAt, now);
    expect(records.task.createdAt.isUtc, isTrue);
    expect(records.task.deadlineDate.toString(), '2026-11-01');
    // DST fall-back date lasts 25 hours in New York, and ends at 05:00 UTC.
    expect(records.task.deadlineBoundaryUtc, DateTime.utc(2026, 11, 2, 5));
  });

  test('CRUD, soft delete/restore and archived-course relations preserve linked content', () async {
    final records = await seedRecords(repository);
    expect(await repository.watchCourses().first, isEmpty);
    expect(
      (await repository.watchCourses(includeArchived: true).first).single.id,
      records.course.id,
    );
    expect(
      (await repository.watchTasks(courseId: records.course.id).first)
          .single
          .id,
      records.task.id,
    );
    await repository.updateCourse(
      records.course.id,
      const CourseDraft(name: 'Edited'),
    );
    await repository.archiveCourse(records.course.id, archived: false);
    await repository.deleteCourse(records.course.id);
    expect(await repository.watchCourses().first, isEmpty);
    expect(
      (await repository.task(records.task.id)).courseId,
      records.course.id,
    );
    expect(
      (await repository.note(records.note.id)).courseId,
      records.course.id,
    );
    await repository.deleteCourse(records.course.id, deleted: false);
    expect((await repository.watchCourses().first).single.name, 'Edited');
    await repository.updateTask(
      records.task.id,
      const TaskDraft(title: 'Finished', status: TaskStatus.done),
    );
    expect((await repository.task(records.task.id)).completedAt, now);
    await repository.updateTask(
      records.task.id,
      const TaskDraft(title: 'Reopened'),
    );
    expect((await repository.task(records.task.id)).completedAt, isNull);
    final step = await repository.updateSubtask(
      records.subtask.id,
      title: 'Step edited',
      position: 2,
      completed: true,
    );
    expect(step.completedAt, now);
    expect((await repository.task(records.task.id)).status, TaskStatus.todo);
    await repository.deleteSubtask(step.id);
    expect(await repository.watchSubtasks(records.task.id).first, isEmpty);
    await repository.deleteSubtask(step.id, deleted: false);
    await repository.updateNote(
      records.note.id,
      const NoteDraft(body: 'Updated'),
    );
    await repository.deleteNote(records.note.id);
    expect(await repository.watchNotes().first, isEmpty);
    await repository.deleteNote(records.note.id, deleted: false);
    await repository.deleteTask(records.task.id);
    expect(await repository.watchTasks().first, isEmpty);
    expect(
      await repository.watchPriorities(CalendarDate(2026, 10, 20)).first,
      isEmpty,
    );
    expect((await repository.note(records.note.id)).body, 'Updated');
    expect(await repository.watchLinksForTask(records.task.id).first, [
      records.link,
    ]);
    expect(
      (await repository.watchSubtasks(records.task.id).first).single.id,
      step.id,
    );
    await repository.deleteTask(records.task.id, deleted: false);
    expect((await repository.watchTasks().first).single.id, records.task.id);
    await repository.unlinkNote(records.note.id, records.task.id);
    expect(await repository.watchLinksForNote(records.note.id).first, isEmpty);
  });

  test('duplicate links and every foreign key reject invalid writes', () async {
    final records = await seedRecords(repository);
    await expectLater(
      repository.linkNote(records.note.id, records.task.id),
      throwsException,
    );
    await expectLater(
      repository.linkNote(newUuid(), records.task.id),
      throwsException,
    );
    await expectLater(
      repository.linkNote(records.note.id, newUuid()),
      throwsException,
    );
    await expectLater(
      repository.createTask(TaskDraft(title: 'Invalid', courseId: newUuid())),
      throwsException,
    );
    await expectLater(
      repository.createNote(NoteDraft(courseId: newUuid())),
      throwsException,
    );
    await expectLater(
      repository.createSubtask(newUuid(), 'Orphan'),
      throwsException,
    );
    await expectLater(
      db
          .into(db.dailyPriorities)
          .insert(
            DailyPrioritiesCompanion.insert(
              id: newUuid(),
              day: CalendarDate(2026, 10, 21),
              taskId: newUuid(),
              slot: 1,
              createdAt: now,
            ),
          ),
      throwsException,
    );
    await expectLater(
      (db.delete(
        db.courses,
      )..where((t) => t.id.equals(records.course.id))).go(),
      throwsException,
    );
    expect((await repository.note(records.note.id)).body, records.note.body);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test('priorities enforce three slots, distinct tasks, rollback and stable IDs on reorder', () async {
    final tasks = <Task>[];
    for (var i = 0; i < 4; i++) {
      tasks.add(await repository.createTask(TaskDraft(title: 'Task $i')));
    }
    final day = CalendarDate(2026, 10, 20);
    await repository.setDailyPriorities(
      day,
      tasks.take(3).map((t) => t.id).toList(),
    );
    final before = await repository.watchPriorities(day).first;
    expect(
      () => repository.setDailyPriorities(day, tasks.map((t) => t.id).toList()),
      throwsArgumentError,
    );
    expect(
      () =>
          repository.setDailyPriorities(day, [tasks.first.id, tasks.first.id]),
      throwsArgumentError,
    );
    await expectLater(
      repository.setDailyPriorities(day, [tasks.last.id, newUuid()]),
      throwsStateError,
    );
    expect(await repository.watchPriorities(day).first, before);
    await expectLater(
      db.customStatement(
        'INSERT INTO daily_priorities (id, day, task_id, slot, created_at) VALUES (?, ?, ?, ?, ?)',
        [
          newUuid(),
          day.toString(),
          tasks.last.id,
          1.5,
          now.millisecondsSinceEpoch,
        ],
      ),
      throwsException,
    );
    await expectLater(
      db
          .into(db.dailyPriorities)
          .insert(
            DailyPrioritiesCompanion.insert(
              id: newUuid(),
              day: day,
              taskId: tasks.last.id,
              slot: 4,
              createdAt: now,
            ),
          ),
      throwsException,
    );
    await expectLater(
      db
          .into(db.dailyPriorities)
          .insert(
            DailyPrioritiesCompanion.insert(
              id: newUuid(),
              day: day,
              taskId: tasks.last.id,
              slot: 1,
              createdAt: now,
            ),
          ),
      throwsException,
    );
    await repository.setDailyPriorities(
      day,
      tasks.take(3).map((t) => t.id).toList().reversed.toList(),
    );
    final after = await repository.watchPriorities(day).first;
    expect(after.map((p) => p.id), before.reversed.map((p) => p.id));
    await repository.deleteTask(tasks.first.id);
    await expectLater(
      repository.setDailyPriorities(day, [tasks.first.id]),
      throwsStateError,
    );
  });

  test(
    'concurrent priority commands on independent connections remain atomic',
    () async {
      final tasks = <Task>[];
      for (var i = 0; i < 6; i++) {
        tasks.add(await repository.createTask(TaskDraft(title: 'Task $i')));
      }
      final other = MomentumRepository(fixture.open());
      await other.database.ensureOpen();
      final day = CalendarDate(2026, 10, 20);
      final choices = [
        tasks.take(3).map((t) => t.id).toList(),
        tasks.skip(3).map((t) => t.id).toList(),
      ];
      // SQLite may reject a competing deferred write transaction as BUSY;
      // callers receive that error and can retry. It must never partially save.
      var successes = 0;
      void acceptOnlyContention(Object error) {
        final message = error.toString().toLowerCase();
        if (!message.contains('database is locked') &&
            !message.contains('sqlite_busy')) {
          throw error;
        }
      }

      await Future.wait([
        repository
            .setDailyPriorities(day, choices[0])
            .then((_) {
              successes++;
            })
            .catchError(acceptOnlyContention),
        other
            .setDailyPriorities(day, choices[1])
            .then((_) {
              successes++;
            })
            .catchError(acceptOnlyContention),
      ]);
      expect(successes, greaterThanOrEqualTo(1));
      final saved = (await repository.watchPriorities(day).first)
          .map((p) => p.taskId)
          .toList();
      expect(saved, anyOf(equals(choices[0]), equals(choices[1])));
    },
  );

  test('invalid enums, UUIDs, dates, lengths and deadline combinations are rejected by SQLite', () async {
    final task = await repository.createTask(const TaskDraft(title: 'Keep'));
    for (final assignment in [
      "status = 'surprise'",
      "priority = 'urgent'",
      "deadline_kind = 'maybe'",
      "id = 'bad-id'",
      "remaining_minutes = -1",
      "title = '   '",
      "deadline_kind = 'timed'",
      "deadline_utc = 1",
      "status = 'done'",
    ]) {
      await expectLater(
        db.customStatement('UPDATE tasks SET $assignment WHERE id = ?', [
          task.id,
        ]),
        throwsException,
      );
    }
    final dated = await repository.createTask(
      TaskDraft(
        title: 'Date',
        deadline: Deadline.dateOnly(CalendarDate(2028, 2, 29), 'Asia/Manila'),
      ),
    );
    for (final date in [
      '2027-02-29',
      '2026-13-01',
      '0000-01-01',
      '2026-01-32',
      '2026-1-1',
    ]) {
      await expectLater(
        db.customStatement('UPDATE tasks SET deadline_date = ? WHERE id = ?', [
          date,
          dated.id,
        ]),
        throwsException,
      );
    }
    await expectLater(
      db.customStatement('UPDATE tasks SET title = ? WHERE id = ?', [
        'x' * 201,
        task.id,
      ]),
      throwsException,
    );
    await expectLater(
      repository.createNote(NoteDraft(body: 'x' * 100001)),
      throwsException,
    );
    await expectLater(
      db.customStatement("UPDATE app_settings SET theme = 'unknown'"),
      throwsException,
    );
    expect((await repository.task(task.id)).title, 'Keep');
  });

  test('deadline/date-only/timed/target/estimate remain distinct and UTC is normalized', () async {
    final date = CalendarDate(2028, 2, 29);
    expect(CalendarDate.parse(date.toString()), date);
    expect(() => CalendarDate(2027, 2, 29), throwsArgumentError);
    expect(() => CalendarDate.parse('2026-1-01'), throwsFormatException);
    expect(() => Deadline.timed(now, 'Not/AZone'), throwsA(anything));
    final deadline = DateTime.parse('2026-10-21T18:00:00+08:00');
    final timed = await repository.createTask(
      TaskDraft(
        title: 'Timed',
        deadline: Deadline.timed(deadline, 'Asia/Manila'),
        targetUtc: deadline,
        remainingMinutes: 20,
      ),
    );
    expect(timed.deadlineUtc, DateTime.utc(2026, 10, 21, 10));
    expect(timed.deadlineUtc!.isUtc, isTrue);
    expect(timed.deadlineDate, isNull);
    await expectLater(
      repository.createTask(
        TaskDraft(
          title: 'Late target',
          deadline: Deadline.timed(deadline, 'Asia/Manila'),
          targetUtc: deadline.add(const Duration(milliseconds: 1)),
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.createTask(
        TaskDraft(
          title: 'Late date target',
          deadline: Deadline.dateOnly(date, 'Asia/Manila'),
          targetUtc: endOfDateExclusive(date, 'Asia/Manila'),
        ),
      ),
      throwsArgumentError,
    );
    await repository.updateTask(timed.id, const TaskDraft(title: 'Cleared'));
    final cleared = await repository.task(timed.id);
    expect(cleared.deadlineKind, DeadlineKind.none);
    expect(cleared.deadlineBoundaryUtc, isNull);
    expect(cleared.targetUtc, isNull);
    expect(cleared.remainingMinutes, isNull);
  });

  test('failed multi-record transaction rolls back committed-looking inner operations', () async {
    final records = await seedRecords(repository);
    await expectLater(
      repository.transaction(() async {
        await repository.updateNote(
          records.note.id,
          const NoteDraft(body: 'Must roll back'),
        );
        await repository.createTask(const TaskDraft(title: 'Must disappear'));
        await repository.linkNote(
          records.note.id,
          records.task.id,
        ); // Duplicate.
      }),
      throwsException,
    );
    expect(await repository.note(records.note.id), records.note);
    expect((await repository.watchTasks().first).length, 1);
  });

  test(
    'live query streams publish committed CRUD and never rolled-back records',
    () async {
      final snapshots = <List<Task>>[];
      final empty = Completer<void>();
      final created = Completer<void>();
      final removed = Completer<void>();
      final subscription = repository.watchTasks().listen((rows) {
        snapshots.add(rows);
        if (!empty.isCompleted) empty.complete();
        if (rows.isNotEmpty && !created.isCompleted) created.complete();
        if (created.isCompleted && rows.isEmpty && !removed.isCompleted) {
          removed.complete();
        }
      });
      addTearDown(subscription.cancel);
      await empty.future.timeout(const Duration(seconds: 5));
      final task = await repository.createTask(
        const TaskDraft(title: 'Stream value'),
      );
      await created.future.timeout(const Duration(seconds: 5));
      await expectLater(
        repository.transaction(() async {
          await repository.createTask(const TaskDraft(title: 'Never emit'));
          throw StateError('Rollback');
        }),
        throwsStateError,
      );
      await repository.deleteTask(task.id);
      await removed.future.timeout(const Duration(seconds: 5));
      expect(
        snapshots.expand((list) => list).any((t) => t.title == 'Never emit'),
        isFalse,
      );
    },
  );

  test(
    'injected UUIDs/clock and validated singleton settings persist',
    () async {
      const id = '12345678-1234-4234-8234-123456789abc';
      final injected = MomentumRepository(db, ids: () => id, clock: () => now);
      final task = await injected.createTask(
        const TaskDraft(title: 'Deterministic'),
      );
      expect(task.id, id);
      expect(task.createdAt, now);
      await repository.updateSettings(
        theme: ThemePreference.light,
        planningZone: 'Europe/London',
      );
      expect(
        (await repository.watchSettings().first).planningZone,
        'Europe/London',
      );
      await repository.initialize();
      expect((await repository.settings()).theme, ThemePreference.light);
      expect(await db.select(db.appSettings).get(), hasLength(1));
      expect(await db.select(db.installations).get(), hasLength(1));
      for (var i = 0; i < 20; i++) {
        expect(
          newUuid(),
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
      }
    },
  );
}
