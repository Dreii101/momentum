import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/tasks/task_workflow.dart';

import 'support/database_fixture.dart';

void main() {
  late DatabaseFixture fixture;
  late AppDatabase db;
  late MomentumRepository repo;
  var now = DateTime.utc(2026, 10, 21, 15, 59, 59);
  setUp(() async {
    fixture = await DatabaseFixture.create();
    db = fixture.open();
    repo = MomentumRepository(db, clock: () => now);
    await repo.initialize();
  });
  tearDown(() => fixture.dispose());

  test('capture, edit, complete, reopen and restart preserve exact fields and projections', () async {
    final day = CalendarDate(2026, 10, 21);
    final task = await repo.createTask(
      const TaskDraft(title: '  Read one page  '),
    );
    expect(task.title, 'Read one page');
    expect(task.deadlineKind, DeadlineKind.none);
    final edited = await repo.updateTaskDetails(
      task.id,
      TaskDraft(
        title: 'Read chapter',
        description: '日本語 🧬',
        nextAction: 'Open page 1',
        priority: TaskPriority.high,
        remainingMinutes: 40,
        deadline: Deadline.dateOnly(CalendarDate(2026, 10, 22), 'Asia/Manila'),
        targetUtc: DateTime.utc(2026, 10, 22, 10),
      ),
    );
    await repo.toggleDailyPriority(day, task.id);
    expect((await repo.watchDailyTasks(day).first).single.id, task.id);
    expect((await repo.watchUpcomingTasks().first).single.id, task.id);
    now = now.add(const Duration(minutes: 1));
    await repo.setTaskStatus(task.id, TaskStatus.done);
    expect(await repo.watchUpcomingTasks().first, isEmpty);
    expect(
      (await repo.watchDailyTasks(day).first).single.status,
      TaskStatus.done,
    );
    // A stale editor cannot silently reopen a completed task.
    final stale = await repo.updateTaskDetails(
      task.id,
      const TaskDraft(title: 'Updated after completion'),
    );
    expect(stale.status, TaskStatus.done);
    expect(stale.completedAt, now);
    await repo.updateTaskDetails(
      task.id,
      TaskEditBuffer(edited, 'Asia/Manila').toDraft(TaskStatus.todo),
    );
    await repo.setTaskStatus(task.id, TaskStatus.todo);
    final reopened = await repo.task(task.id);
    expect(reopened.completedAt, isNull);
    expect(reopened.remainingMinutes, 40);
    expect((await repo.watchUpcomingTasks().first).single, reopened);
    await db.close();
    repo = MomentumRepository(fixture.open());
    expect(await repo.task(task.id), reopened);
    expect((await repo.watchDailyTasks(day).first).single, reopened);
  });

  test(
    'title validation counts Unicode characters and failure retains old values',
    () async {
      final task = await repo.createTask(TaskDraft(title: '🧬' * 200));
      for (final title in ['', ' \t\n ', 'a' * 201]) {
        await expectLater(
          repo.updateTaskDetails(task.id, TaskDraft(title: title)),
          throwsArgumentError,
        );
      }
      expect((await repo.task(task.id)).title, task.title);
      await expectLater(
        repo.createTask(
          const TaskDraft(title: 'Estimate', remainingMinutes: -1),
        ),
        throwsArgumentError,
      );
    },
  );

  test('priority toggles are atomic at three and archive/trash remove only selections', () async {
    final day = CalendarDate(2026, 10, 21);
    final tasks = [
      for (var i = 0; i < 4; i++)
        await repo.createTask(TaskDraft(title: 'Task $i')),
    ];
    for (final task in tasks.take(3)) {
      await repo.toggleDailyPriority(day, task.id);
    }
    final before = await repo.watchPriorities(day).first;
    await expectLater(
      repo.toggleDailyPriority(day, tasks.last.id),
      throwsArgumentError,
    );
    expect(await repo.watchPriorities(day).first, before);
    await repo.archiveTask(tasks.first.id);
    expect(await repo.watchDailyTasks(day).first, hasLength(2));
    await expectLater(
      repo.toggleDailyPriority(day, tasks.first.id),
      throwsStateError,
    );
    await repo.archiveTask(tasks.first.id, archived: false);
    expect(await repo.watchDailyTasks(day).first, hasLength(2));
    await repo.toggleDailyPriority(day, tasks.last.id);
    await repo.deleteTask(tasks.last.id);
    await repo.deleteTask(tasks.last.id, deleted: false);
    expect(await repo.watchDailyTasks(day).first, hasLength(2));
  });

  test('archive and trash preserve linked notes, archived courses and ordered steps on restart', () async {
    final course = await repo.createCourse(const CourseDraft(name: 'Biology'));
    final task = await repo.createTask(
      TaskDraft(title: 'Report', courseId: course.id),
    );
    final note = await repo.createNote(const NoteDraft(body: 'Keep my notes'));
    await repo.linkNote(note.id, task.id);
    final step = await repo.appendSubtask(task.id, 'Read first page');
    await repo.archiveCourse(course.id);
    await repo.archiveTask(task.id);
    await repo.deleteTask(task.id);
    await db.close();
    repo = MomentumRepository(fixture.open());
    expect((await repo.task(task.id)).archivedAt, isNotNull);
    expect((await repo.task(task.id)).deletedAt, isNotNull);
    await repo.deleteTask(task.id, deleted: false);
    expect(await repo.watchTasks().first, isEmpty); // still archived
    await repo.archiveTask(task.id, archived: false);
    expect((await repo.watchTasks().first).single.courseId, course.id);
    expect(await repo.note(note.id), note);
    expect(
      (await repo.watchLinksForTask(task.id).first).single.noteId,
      note.id,
    );
    expect((await repo.watchSubtasks(task.id).first).single, step);
  });

  test('subtask reorder validates whole permutation, rolls back and never completes parent', () async {
    final task = await repo.createTask(const TaskDraft(title: 'Break down'));
    final a = await repo.appendSubtask(task.id, 'First');
    final b = await repo.appendSubtask(task.id, 'Second');
    final c = await repo.appendSubtask(task.id, 'Third');
    await repo.reorderSubtasks(task.id, [c.id, a.id, b.id]);
    expect((await repo.watchSubtasks(task.id).first).map((r) => r.id), [
      c.id,
      a.id,
      b.id,
    ]);
    for (final invalid in [
      [a.id, a.id, b.id],
      [a.id],
      [a.id, b.id, task.id],
    ]) {
      await expectLater(
        repo.reorderSubtasks(task.id, invalid),
        throwsArgumentError,
      );
    }
    expect((await repo.watchSubtasks(task.id).first).map((r) => r.id), [
      c.id,
      a.id,
      b.id,
    ]);
    for (final row in await repo.watchSubtasks(task.id).first) {
      await repo.updateSubtask(
        row.id,
        title: row.title,
        position: row.position,
        completed: true,
      );
    }
    expect((await repo.task(task.id)).status, TaskStatus.todo);
    await expectLater(
      repo.transaction(() async {
        await repo.reorderSubtasks(task.id, [a.id, b.id, c.id]);
        throw StateError('fail later');
      }),
      throwsStateError,
    );
    expect((await repo.watchSubtasks(task.id).first).map((r) => r.id), [
      c.id,
      a.id,
      b.id,
    ]);
    await repo.deleteSubtask(a.id);
    await repo.deleteSubtask(a.id, deleted: false);
    expect((await repo.watchSubtasks(task.id).first).map((r) => r.id), [
      c.id,
      a.id,
      b.id,
    ]);
  });

  test('date-only deadlines cross local midnight correctly, including DST and zone preference changes', () async {
    for (final zone in [
      'Asia/Manila',
      'America/New_York',
      'Pacific/Kiritimati',
    ]) {
      final task = await repo.createTask(
        TaskDraft(
          title: zone,
          deadline: Deadline.dateOnly(CalendarDate(2026, 11, 1), zone),
        ),
      );
      final boundary = task.deadlineBoundaryUtc!;
      expect(
        isTaskOverdue(task, boundary.subtract(const Duration(milliseconds: 1))),
        isFalse,
      );
      expect(isTaskOverdue(task, boundary), isTrue);
      expect(
        localDay(boundary.subtract(const Duration(milliseconds: 1)), zone),
        CalendarDate(2026, 11, 1),
      );
      expect(localDay(boundary, zone), CalendarDate(2026, 11, 2));
      await repo.updateSettings(
        theme: ThemePreference.system,
        planningZone: 'UTC',
      );
      expect((await repo.task(task.id)).deadlineBoundaryUtc, boundary);
    }
    final deadline = DateTime.utc(2026, 10, 21, 12);
    final timed = await repo.createTask(
      TaskDraft(title: 'Exact', deadline: Deadline.timed(deadline, 'UTC')),
    );
    expect(isTaskOverdue(timed, deadline), isFalse);
    expect(
      isTaskOverdue(timed, deadline.add(const Duration(milliseconds: 1))),
      isTrue,
    );
    final done = await repo.updateTask(
      timed.id,
      TaskDraft(
        title: 'Done',
        status: TaskStatus.done,
        deadline: Deadline.timed(deadline, 'UTC'),
      ),
    );
    expect(isTaskOverdue(done, deadline.add(const Duration(days: 1))), isFalse);
  });

  test('wall times reject nonexistent/ambiguous hours and invalid dates; exact original instants survive editing', () async {
    for (final date in ['2026-02-29', '2026-04-31']) {
      expect(() => parseWallTime(date, '10:00', 'UTC'), throwsArgumentError);
    }
    expect(
      () => parseWallTime('2026-03-08', '02:30', 'America/New_York'),
      throwsFormatException,
    );
    expect(
      () => parseWallTime('2026-11-01', '01:30', 'America/New_York'),
      throwsFormatException,
    );
    expect(
      parseWallTime('2026-11-01', '06:30', 'UTC'),
      DateTime.utc(2026, 11, 1, 6, 30),
    );
    final instant = DateTime.utc(2026, 11, 1, 6, 30, 42, 123);
    final task = await repo.createTask(
      TaskDraft(
        title: 'DST',
        deadline: Deadline.timed(instant, 'America/New_York'),
        targetUtc: instant,
      ),
    );
    final buffer = TaskEditBuffer(task, 'UTC')
      ..description = 'Only text changed';
    final saved = await repo.updateTaskDetails(
      task.id,
      buffer.toDraft(TaskStatus.todo),
    );
    expect(saved.deadlineUtc, instant);
    expect(saved.targetUtc, instant);
    buffer.targetDate = '2026-11-02';
    expect(() => buffer.toDraft(TaskStatus.todo), throwsFormatException);
    expect((await repo.task(task.id)).targetUtc, instant);
  });
}
