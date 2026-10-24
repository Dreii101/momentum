import 'package:drift/drift.dart';

import 'app_database.dart';
import 'value_types.dart';

final class Deadline {
  const Deadline.none()
    : kind = DeadlineKind.none,
      date = null,
      instant = null,
      zone = null;
  Deadline.dateOnly(CalendarDate value, String timeZone)
    : kind = DeadlineKind.dateOnly,
      date = value,
      instant = null,
      zone = timeZone {
    requireTimeZone(timeZone);
  }
  Deadline.timed(DateTime value, String timeZone)
    : kind = DeadlineKind.timed,
      date = null,
      instant = value.toUtc(),
      zone = timeZone {
    requireTimeZone(timeZone);
  }
  final DeadlineKind kind;
  final CalendarDate? date;
  final DateTime? instant;
  final String? zone;
  DateTime? get boundary => switch (kind) {
    DeadlineKind.none => null,
    DeadlineKind.timed => instant,
    DeadlineKind.dateOnly => endOfDateExclusive(date!, zone!),
  };
}

final class CourseDraft {
  const CourseDraft({
    required this.name,
    this.color,
    this.termStart,
    this.termEnd,
  });
  final String name;
  final String? color;
  final CalendarDate? termStart;
  final CalendarDate? termEnd;
}

final class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description = '',
    this.nextAction,
    this.courseId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.normal,
    this.deadline = const Deadline.none(),
    this.targetUtc,
    this.remainingMinutes,
  });
  final String title;
  final String description;
  final String? nextAction;
  final String? courseId;
  final TaskStatus status;
  final TaskPriority priority;
  final Deadline deadline;
  final DateTime? targetUtc;
  final int? remainingMinutes;
}

final class NoteDraft {
  const NoteDraft({
    this.title = '',
    this.body = '',
    this.courseId,
    this.pinned = false,
  });
  final String title;
  final String body;
  final String? courseId;
  final bool pinned;
}

/// Commands commit to SQLite before completing. Streams are SQLite projections,
/// not a second in-memory persistence system. Draft updates replace editable fields.
class MomentumRepository {
  MomentumRepository(this.database, {Clock? clock, IdGenerator? ids})
    : clock = clock ?? utcNow,
      ids = ids ?? newUuid;
  final AppDatabase database;
  final Clock clock;
  final IdGenerator ids;
  DateTime get _now => clock().toUtc();

  Future<void> initialize() => database.transaction(() async {
    final now = _now;
    await database
        .into(database.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            id: ids(),
            singleton: 1,
            theme: ThemePreference.system,
            planningZone: 'Asia/Manila',
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await database
        .into(database.installations)
        .insert(
          InstallationsCompanion.insert(
            id: ids(),
            singleton: 1,
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  });

  Future<T> transaction<T>(Future<T> Function() action) =>
      database.transaction(action);

  Future<Course> course(String id) => (database.select(
    database.courses,
  )..where((t) => t.id.equals(id))).getSingle();
  Future<Task> task(String id) => (database.select(
    database.tasks,
  )..where((t) => t.id.equals(id))).getSingle();
  Future<Subtask> subtask(String id) => (database.select(
    database.subtasks,
  )..where((t) => t.id.equals(id))).getSingle();
  Future<Note> note(String id) => (database.select(
    database.notes,
  )..where((t) => t.id.equals(id))).getSingle();

  Stream<List<Course>> watchCourses({
    bool includeArchived = false,
    bool includeDeleted = false,
  }) {
    final query = database.select(database.courses)
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (!includeDeleted) query.where((t) => t.deletedAt.isNull());
    if (!includeArchived) query.where((t) => t.archivedAt.isNull());
    return query.watch();
  }

  Stream<List<Task>> watchTasks({
    String? courseId,
    TaskStatus? status,
    bool includeDeleted = false,
    bool includeArchived = false,
  }) {
    final query = database.select(database.tasks)
      ..orderBy([
        (t) => OrderingTerm.desc(t.updatedAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (!includeDeleted) query.where((t) => t.deletedAt.isNull());
    if (!includeArchived) query.where((t) => t.archivedAt.isNull());
    if (courseId != null) query.where((t) => t.courseId.equals(courseId));
    if (status != null) query.where((t) => t.status.equalsValue(status));
    return query.watch();
  }

  Stream<List<Subtask>> watchSubtasks(
    String taskId, {
    bool includeDeleted = false,
  }) {
    final query = database.select(database.subtasks)
      ..where((t) => t.taskId.equals(taskId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.position),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (!includeDeleted) query.where((t) => t.deletedAt.isNull());
    return query.watch();
  }

  Stream<List<Note>> watchNotes({
    String? courseId,
    bool includeDeleted = false,
    bool onlyDeleted = false,
    String search = '',
  }) {
    final query = database.select(database.notes)
      ..orderBy([
        (t) => OrderingTerm.desc(t.pinned),
        (t) => OrderingTerm.desc(t.updatedAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (onlyDeleted) {
      query.where((t) => t.deletedAt.isNotNull());
    } else if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    if (search.isNotEmpty) {
      final needle = FunctionCallExpression<String>('LOWER', [
        Variable(search),
      ]);
      query.where(
        (t) =>
            FunctionCallExpression<int>('INSTR', [
              t.title.lower(),
              needle,
            ]).isBiggerThanValue(0) |
            FunctionCallExpression<int>('INSTR', [
              t.body.lower(),
              needle,
            ]).isBiggerThanValue(0),
      );
    }
    if (courseId != null) query.where((t) => t.courseId.equals(courseId));
    return query.watch();
  }

  Stream<Note?> watchNote(String id) => (database.select(
    database.notes,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Relationships always return the original records, including tombstones.
  Stream<List<Note>> watchLinkedNotes(String taskId) {
    final query =
        database.select(database.noteTaskLinks).join([
            innerJoin(
              database.notes,
              database.notes.id.equalsExp(database.noteTaskLinks.noteId),
            ),
          ])
          ..where(database.noteTaskLinks.taskId.equals(taskId))
          ..orderBy([
            OrderingTerm.desc(database.notes.pinned),
            OrderingTerm.asc(database.notes.id),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(database.notes)).toList(),
    );
  }

  Stream<List<Task>> watchLinkedTasks(String noteId) {
    final query =
        database.select(database.noteTaskLinks).join([
            innerJoin(
              database.tasks,
              database.tasks.id.equalsExp(database.noteTaskLinks.taskId),
            ),
          ])
          ..where(database.noteTaskLinks.noteId.equals(noteId))
          ..orderBy([
            OrderingTerm.asc(database.tasks.title),
            OrderingTerm.asc(database.tasks.id),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(database.tasks)).toList(),
    );
  }

  Stream<List<NoteTaskLink>> watchLinksForNote(String noteId) =>
      (database.select(database.noteTaskLinks)
            ..where((t) => t.noteId.equals(noteId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();
  Stream<List<NoteTaskLink>> watchLinksForTask(String taskId) =>
      (database.select(database.noteTaskLinks)
            ..where((t) => t.taskId.equals(taskId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();
  Stream<List<DailyPriority>> watchPriorities(CalendarDate day) =>
      (database.select(database.dailyPriorities)
            ..where((t) => t.day.equalsValue(day))
            ..orderBy([(t) => OrderingTerm.asc(t.slot)]))
          .watch();
  Stream<Settings> watchSettings() =>
      database.select(database.appSettings).watchSingle();
  Future<Settings> settings() =>
      database.select(database.appSettings).getSingle();
  Future<InstallationMetadata> installation() =>
      database.select(database.installations).getSingle();
  Stream<InstallationMetadata> watchInstallation() =>
      database.select(database.installations).watchSingle();

  Future<Course> createCourse(CourseDraft draft) async {
    validateCourseDraft(draft);
    final id = ids(), now = _now;
    await database
        .into(database.courses)
        .insert(
          CoursesCompanion.insert(
            id: id,
            name: draft.name.trim(),
            color: Value(draft.color),
            termStart: Value(draft.termStart),
            termEnd: Value(draft.termEnd),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return course(id);
  }

  Future<Course> updateCourse(String id, CourseDraft draft) =>
      database.transaction(() async {
        validateCourseDraft(draft);
        final activities = await (database.select(
          database.activitySeriesRows,
        )..where((t) => t.courseId.equals(id))).get();
        if (activities.any(
          (s) =>
              (draft.termStart != null &&
                  s.startDate.compareTo(draft.termStart!) < 0) ||
              (draft.termEnd != null &&
                  s.endDate.compareTo(draft.termEnd!) > 0),
        )) {
          throw const FormatException(
            'These term bounds exclude an existing activity or retained series. Keep its history within the term.',
          );
        }
        await (database.update(
          database.courses,
        )..where((t) => t.id.equals(id))).write(
          CoursesCompanion(
            name: Value(draft.name.trim()),
            color: Value(draft.color),
            termStart: Value(draft.termStart),
            termEnd: Value(draft.termEnd),
            updatedAt: Value(_now),
          ),
        );
        return course(id);
      });

  Future<void> archiveCourse(String id, {bool archived = true}) async {
    await course(id);
    await (database.update(
      database.courses,
    )..where((t) => t.id.equals(id))).write(
      CoursesCompanion(
        archivedAt: Value(archived ? _now : null),
        updatedAt: Value(_now),
      ),
    );
  }

  Future<void> deleteCourse(String id, {bool deleted = true}) async {
    await course(id);
    await (database.update(
      database.courses,
    )..where((t) => t.id.equals(id))).write(
      CoursesCompanion(
        deletedAt: Value(deleted ? _now : null),
        updatedAt: Value(_now),
      ),
    );
  }

  TasksCompanion _taskFields(TaskDraft draft, DateTime? previousCompletion) {
    validateTaskTitle(draft.title);
    if (draft.remainingMinutes != null && draft.remainingMinutes! < 0) {
      throw ArgumentError('Remaining estimate must be zero or more minutes.');
    }
    final boundary = draft.deadline.boundary;
    if (draft.targetUtc != null &&
        boundary != null &&
        (draft.targetUtc!.isAfter(boundary) ||
            (draft.deadline.kind == DeadlineKind.dateOnly &&
                draft.targetUtc!.isAtSameMomentAs(boundary)))) {
      throw ArgumentError(
        'Internal target must not follow the official deadline.',
      );
    }
    return TasksCompanion(
      title: Value(draft.title.trim()),
      description: Value(draft.description),
      nextAction: Value(draft.nextAction),
      courseId: Value(draft.courseId),
      status: Value(draft.status),
      priority: Value(draft.priority),
      deadlineKind: Value(draft.deadline.kind),
      deadlineDate: Value(draft.deadline.date),
      deadlineUtc: Value(draft.deadline.instant),
      deadlineZone: Value(draft.deadline.zone),
      deadlineBoundaryUtc: Value(boundary),
      targetUtc: Value(draft.targetUtc?.toUtc()),
      remainingMinutes: Value(draft.remainingMinutes),
      completedAt: Value(
        draft.status == TaskStatus.done ? previousCompletion ?? _now : null,
      ),
      updatedAt: Value(_now),
    );
  }

  Future<Task> createTask(TaskDraft draft) async {
    final id = ids();
    await database
        .into(database.tasks)
        .insert(
          _taskFields(
            draft,
            null,
          ).copyWith(id: Value(id), createdAt: Value(_now)),
        );
    return task(id);
  }

  Future<Task> updateTask(String id, TaskDraft draft) =>
      database.transaction(() async {
        final previous = await task(id);
        await _requireSessionReview(id, draft.status);
        await (database.update(database.tasks)..where((t) => t.id.equals(id)))
            .write(_taskFields(draft, previous.completedAt));
        return task(id);
      });

  /// Editing details must not overwrite completion changed by another control.
  Future<Task> updateTaskDetails(String id, TaskDraft draft) =>
      database.transaction(() async {
        final current = await task(id);
        if (current.deletedAt != null || current.archivedAt != null) {
          throw StateError('Restore this task before editing its details.');
        }
        await (database.update(
          database.tasks,
        )..where((t) => t.id.equals(id))).write(
          _taskFields(draft, current.completedAt).copyWith(
            status: Value(current.status),
            completedAt: Value(current.completedAt),
          ),
        );
        return task(id);
      });

  Future<void> setTaskStatus(String id, TaskStatus status) =>
      database.transaction(() async {
        final previous = await task(id);
        await _requireSessionReview(id, status);
        await (database.update(
          database.tasks,
        )..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            status: Value(status),
            completedAt: Value(
              status == TaskStatus.done ? previous.completedAt ?? _now : null,
            ),
            updatedAt: Value(_now),
          ),
        );
      });

  Future<void> _requireSessionReview(String taskId, TaskStatus status) async {
    if (status != TaskStatus.done) return;
    final running =
        await (database.select(database.focusSessions)
              ..where(
                (s) =>
                    s.taskId.equals(taskId) &
                    s.state.isIn(['running', 'paused']),
              )
              ..limit(1))
            .getSingleOrNull();
    if (running != null) {
      throw StateError(
        'End the linked session for review before completing this task.',
      );
    }
  }

  Future<void> archiveTask(String id, {bool archived = true}) =>
      database.transaction(() async {
        await task(id);
        await (database.update(
          database.tasks,
        )..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            archivedAt: Value(archived ? _now : null),
            updatedAt: Value(_now),
          ),
        );
        if (archived) {
          await (database.delete(
            database.dailyPriorities,
          )..where((t) => t.taskId.equals(id))).go();
        }
      });

  Stream<Task?> watchTask(String id) => (database.select(
    database.tasks,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Stream<List<Task>> watchDailyTasks(CalendarDate day) {
    final query =
        database.select(database.dailyPriorities).join([
            innerJoin(
              database.tasks,
              database.tasks.id.equalsExp(database.dailyPriorities.taskId),
            ),
          ])
          ..where(
            database.dailyPriorities.day.equalsValue(day) &
                database.tasks.deletedAt.isNull() &
                database.tasks.archivedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(database.dailyPriorities.slot)]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(database.tasks)).toList(),
    );
  }

  /// One source record for each commitment; internal targets stay distinct.
  Stream<List<Task>> watchUpcomingTasks() =>
      (database.select(database.tasks)
            ..where(
              (t) =>
                  t.deletedAt.isNull() &
                  t.archivedAt.isNull() &
                  t.status.equalsValue(TaskStatus.done).not() &
                  (t.deadlineBoundaryUtc.isNotNull() | t.targetUtc.isNotNull()),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(
                coalesce([t.targetUtc, t.deadlineBoundaryUtc]),
              ),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();
  Future<void> deleteTask(String id, {bool deleted = true}) =>
      database.transaction(() async {
        await task(id);
        await (database.update(
          database.tasks,
        )..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            deletedAt: Value(deleted ? _now : null),
            updatedAt: Value(_now),
          ),
        );
        if (deleted) {
          await (database.delete(
            database.dailyPriorities,
          )..where((t) => t.taskId.equals(id))).go();
        }
        // Retain notes, links and child records. Restore does not repopulate priorities.
      });

  Future<Subtask> createSubtask(
    String taskId,
    String title, {
    int position = 0,
  }) async {
    validateTaskTitle(title);
    final id = ids(), now = _now;
    await database
        .into(database.subtasks)
        .insert(
          SubtasksCompanion.insert(
            id: id,
            taskId: taskId,
            title: title.trim(),
            position: position,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return subtask(id);
  }

  Future<Subtask> updateSubtask(
    String id, {
    required String title,
    required int position,
    required bool completed,
  }) => database.transaction(() async {
    validateTaskTitle(title);
    final previous = await subtask(id);
    await (database.update(
      database.subtasks,
    )..where((t) => t.id.equals(id))).write(
      SubtasksCompanion(
        title: Value(title.trim()),
        position: Value(position),
        completedAt: Value(completed ? previous.completedAt ?? _now : null),
        updatedAt: Value(_now),
      ),
    );
    return subtask(id);
  });
  Future<void> deleteSubtask(String id, {bool deleted = true}) async {
    await subtask(id);
    await (database.update(
      database.subtasks,
    )..where((t) => t.id.equals(id))).write(
      SubtasksCompanion(
        deletedAt: Value(deleted ? _now : null),
        updatedAt: Value(_now),
      ),
    );
  }

  /// Validates a complete permutation before changing any positions.
  Future<void> reorderSubtasks(String taskId, List<String> orderedIds) =>
      database.transaction(() async {
        final rows = await (database.select(
          database.subtasks,
        )..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())).get();
        if (orderedIds.length != rows.length ||
            orderedIds.toSet().length != rows.length ||
            !rows.every((row) => orderedIds.contains(row.id))) {
          throw ArgumentError('Reorder the current steps of this task only.');
        }
        for (var index = 0; index < orderedIds.length; index++) {
          await (database.update(
            database.subtasks,
          )..where((t) => t.id.equals(orderedIds[index]))).write(
            SubtasksCompanion(position: Value(index), updatedAt: Value(_now)),
          );
        }
      });

  Future<Subtask> appendSubtask(String taskId, String title) =>
      database.transaction(() async {
        final rows = await (database.select(
          database.subtasks,
        )..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())).get();
        final position = rows.fold<int>(
          0,
          (next, row) => row.position >= next ? row.position + 1 : next,
        );
        return createSubtask(taskId, title, position: position);
      });

  Future<void> toggleDailyPriority(CalendarDate day, String taskId) =>
      database.transaction(() async {
        final rows =
            await (database.select(database.dailyPriorities)
                  ..where((t) => t.day.equalsValue(day))
                  ..orderBy([(t) => OrderingTerm.asc(t.slot)]))
                .get();
        final selection = rows.map((r) => r.taskId).toList();
        if (!selection.remove(taskId)) selection.add(taskId);
        await setDailyPriorities(day, selection);
      });

  Future<Note> createNote(NoteDraft draft) async {
    validateNoteDraft(draft);
    final id = ids(), now = _now;
    await database
        .into(database.notes)
        .insert(
          NotesCompanion.insert(
            id: id,
            title: draft.title,
            body: draft.body,
            courseId: Value(draft.courseId),
            pinned: Value(draft.pinned),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return note(id);
  }

  Future<Note> updateNote(String id, NoteDraft draft) => database.transaction(
    () async {
      validateNoteDraft(draft);
      if ((await note(id)).deletedAt != null) {
        throw StateError('Restore the note from Trash before saving changes.');
      }
      await (database.update(
        database.notes,
      )..where((t) => t.id.equals(id))).write(
        NotesCompanion(
          title: Value(draft.title),
          body: Value(draft.body),
          courseId: Value(draft.courseId),
          pinned: Value(draft.pinned),
          updatedAt: Value(_now),
        ),
      );
      return note(id);
    },
  );

  Future<void> deleteNote(String id, {bool deleted = true}) async {
    await note(id);
    await (database.update(
      database.notes,
    )..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        deletedAt: Value(deleted ? _now : null),
        updatedAt: Value(_now),
      ),
    );
  }

  Future<NoteTaskLink> linkNote(String noteId, String taskId) async {
    final id = ids();
    await database
        .into(database.noteTaskLinks)
        .insert(
          NoteTaskLinksCompanion.insert(
            id: id,
            noteId: noteId,
            taskId: taskId,
            createdAt: _now,
          ),
        );
    return (database.select(
      database.noteTaskLinks,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> unlinkNote(String noteId, String taskId) => (database.delete(
    database.noteTaskLinks,
  )..where((t) => t.noteId.equals(noteId) & t.taskId.equals(taskId))).go();

  /// UI relationship commands are idempotent; SQL still rejects raw duplicates.
  Future<void> setNoteTaskLink(
    String noteId,
    String taskId, {
    required bool linked,
  }) => database.transaction(() async {
    if (!linked) {
      await unlinkNote(noteId, taskId);
      return;
    }
    if ((await note(noteId)).deletedAt != null ||
        (await task(taskId)).deletedAt != null) {
      throw StateError('Restore both records before adding a link.');
    }
    final existing =
        await (database.select(database.noteTaskLinks)
              ..where((t) => t.noteId.equals(noteId) & t.taskId.equals(taskId)))
            .getSingleOrNull();
    if (existing == null) await linkNote(noteId, taskId);
  });

  /// Replaces a day's selection atomically, preserving IDs/timestamps on reordering.
  /// Unique (day, slot), slot 1..3 also enforce the cap for concurrent writers.
  Future<void> setDailyPriorities(CalendarDate day, List<String> taskIds) {
    if (taskIds.length > 3 || taskIds.toSet().length != taskIds.length) {
      throw ArgumentError('Choose up to three different tasks.');
    }
    return database.transaction(() async {
      for (final id in taskIds) {
        final selected = await task(id);
        if (selected.deletedAt != null || selected.archivedAt != null) {
          throw StateError(
            'Restore the task before adding it to daily priorities.',
          );
        }
      }
      final old = await (database.select(
        database.dailyPriorities,
      )..where((t) => t.day.equalsValue(day))).get();
      final byTask = {for (final row in old) row.taskId: row};
      await (database.delete(
        database.dailyPriorities,
      )..where((t) => t.day.equalsValue(day))).go();
      for (var index = 0; index < taskIds.length; index++) {
        final previous = byTask[taskIds[index]];
        await database
            .into(database.dailyPriorities)
            .insert(
              DailyPrioritiesCompanion.insert(
                id: previous?.id ?? ids(),
                day: day,
                taskId: taskIds[index],
                slot: index + 1,
                createdAt: previous?.createdAt ?? _now,
              ),
            );
      }
    });
  }

  Future<void> updateSettings({
    required ThemePreference theme,
    required String planningZone,
    int? focusMinutes,
    int? breakMinutes,
    bool? reducedMotion,
  }) async {
    requireTimeZone(planningZone);
    await (database.update(
      database.appSettings,
    )..where((t) => t.singleton.equals(1))).write(
      AppSettingsCompanion(
        theme: Value(theme),
        planningZone: Value(planningZone),
        focusMinutes: focusMinutes == null
            ? const Value.absent()
            : Value(focusMinutes),
        breakMinutes: breakMinutes == null
            ? const Value.absent()
            : Value(breakMinutes),
        reducedMotion: reducedMotion == null
            ? const Value.absent()
            : Value(reducedMotion),
        updatedAt: Value(_now),
      ),
    );
  }
}

void validateTaskTitle(String value) {
  final length = value.trim().runes.length;
  if (length < 1 || length > 200) {
    throw ArgumentError('Enter a title of 1–200 characters.');
  }
}

const noteBodyLimit = 100000;
void validateCourseDraft(CourseDraft draft) {
  if (draft.name.trim().isEmpty || draft.name.trim().runes.length > 200) {
    throw const FormatException('Enter a course name of 1–200 characters.');
  }
  if (draft.termStart != null &&
      draft.termEnd != null &&
      draft.termStart!.compareTo(draft.termEnd!) > 0) {
    throw const FormatException('Term end must be on or after term start.');
  }
}

void validateNoteDraft(NoteDraft draft) {
  if (draft.title.runes.length > 200) {
    throw const FormatException(
      'Use at most 200 characters for the note title.',
    );
  }
  if (draft.body.runes.length > noteBodyLimit) {
    throw const FormatException(
      'Use at most 100,000 characters in the note body. Copy your draft before shortening it.',
    );
  }
}
