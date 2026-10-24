import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import '../focus/timer_engine.dart';
import '../schedule/recurrence.dart';

CalendarDate progressWeek(CalendarDate day) =>
    addDays(day, 1 - dateValue(day).weekday);

class CompletedStep {
  const CompletedStep(this.step, this.task);
  final Subtask step;
  final Task task;
}

class ProgressSnapshot {
  const ProgressSnapshot(
    this.tasks,
    this.steps,
    this.sessions,
    this.reflection,
  );
  final List<Task> tasks;
  final List<CompletedStep> steps;
  final List<FocusSession> sessions;
  final WeeklyReflection? reflection;

  Iterable<FocusSession> get credited => sessions.where(
    (s) => s.state == SessionState.finalized && s.kind != SessionKind.rest,
  );
  int get reportedMs => credited.fold(0, (sum, s) => sum + s.reportedMs!);
  int count(SessionKind kind) => credited.where((s) => s.kind == kind).length;
  int get unresolved =>
      sessions.where((s) => s.state != SessionState.finalized).length;
}

extension ProgressRepository on MomentumRepository {
  Future<ProgressSnapshot> progressSnapshot(CalendarDate week, String zone) =>
      database.transaction(() async {
        if (progressWeek(week) != week) {
          throw ArgumentError('Choose a Monday week start.');
        }
        final location = requireTimeZone(zone), end = addDays(week, 7);
        final fromUtc = tz.TZDateTime(
          location,
          week.year,
          week.month,
          week.day,
        ).toUtc();
        final toUtc = tz.TZDateTime(
          location,
          end.year,
          end.month,
          end.day,
        ).toUtc();
        final tasks =
            await (database.select(database.tasks)
                  ..where(
                    (t) =>
                        t.status.equalsValue(TaskStatus.done) &
                        t.deletedAt.isNull() &
                        t.completedAt.isBiggerOrEqualValue(
                          fromUtc.millisecondsSinceEpoch,
                        ) &
                        t.completedAt.isSmallerThanValue(
                          toUtc.millisecondsSinceEpoch,
                        ),
                  )
                  ..orderBy([
                    (t) => OrderingTerm.desc(t.completedAt),
                    (t) => OrderingTerm.asc(t.id),
                  ]))
                .get();
        final steps =
            await (database.select(database.subtasks).join([
                    innerJoin(
                      database.tasks,
                      database.tasks.id.equalsExp(database.subtasks.taskId),
                    ),
                  ])
                  ..where(
                    database.subtasks.deletedAt.isNull() &
                        database.tasks.deletedAt.isNull() &
                        database.subtasks.completedAt.isBiggerOrEqualValue(
                          fromUtc.millisecondsSinceEpoch,
                        ) &
                        database.subtasks.completedAt.isSmallerThanValue(
                          toUtc.millisecondsSinceEpoch,
                        ),
                  )
                  ..orderBy([
                    OrderingTerm.desc(database.subtasks.completedAt),
                    OrderingTerm.asc(database.subtasks.id),
                  ]))
                .get();
        final sessions =
            await (database.select(database.focusSessions)
                  ..where(
                    (s) =>
                        s.localStartDate.isBiggerOrEqualValue(week.toString()) &
                        s.localStartDate.isSmallerThanValue(end.toString()),
                  )
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.startedUtc),
                    (s) => OrderingTerm.asc(s.id),
                  ]))
                .get();
        final reflection = await (database.select(
          database.weeklyReflections,
        )..where((r) => r.weekStart.equalsValue(week))).getSingleOrNull();
        return ProgressSnapshot(
          tasks,
          [
            for (final row in steps)
              CompletedStep(
                row.readTable(database.subtasks),
                row.readTable(database.tasks),
              ),
          ],
          sessions,
          reflection,
        );
      });

  Stream<ProgressSnapshot> watchProgress(CalendarDate week, String zone) =>
      database
          .customSelect(
            // Drift caches streams by SQL/arguments, not readsFrom tables.
            'SELECT 1 AS progress_changed',
            readsFrom: {
              database.tasks,
              database.subtasks,
              database.focusSessions,
              database.weeklyReflections,
            },
          )
          .watch()
          .asyncMap((_) => progressSnapshot(week, zone));

  Future<WeeklyReflection> saveReflection(
    CalendarDate week, {
    required String helped,
    required String obstacles,
    required String adjustment,
  }) => database.transaction(() async {
    if (progressWeek(week) != week) {
      throw ArgumentError('Choose a Monday week start.');
    }
    for (final value in [helped, obstacles, adjustment]) {
      if (value.runes.length > 5000 || value.contains('\u0000')) {
        throw const FormatException(
          'Each reflection answer allows up to 5,000 characters, without null characters.',
        );
      }
    }
    final query = database.select(database.weeklyReflections)
      ..where((r) => r.weekStart.equalsValue(week));
    final previous = await query.getSingleOrNull(), now = clock().toUtc();
    await database
        .into(database.weeklyReflections)
        .insertOnConflictUpdate(
          WeeklyReflectionsCompanion.insert(
            id: previous?.id ?? ids(),
            weekStart: week,
            helped: helped,
            obstacles: obstacles,
            adjustment: adjustment,
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    return query.getSingle();
  });

  /// Correction is not a second timer finalization; receipts and elapsed evidence stay intact.
  Future<FocusSession> correctReportedWork(
    String id, {
    required int reportedMs,
    required int expectedRevision,
    required bool confirmed,
  }) => database.transaction(() async {
    final query = database.select(database.focusSessions)
      ..where((s) => s.id.equals(id));
    final saved = await query.getSingle();
    if (!confirmed ||
        saved.state != SessionState.finalized ||
        saved.kind == SessionKind.rest ||
        reportedMs < 0 ||
        reportedMs > saved.eligibleMs) {
      throw const FormatException(
        'Confirm an amount from zero to eligible work on a finalized work session.',
      );
    }
    if (reportedMs == saved.reportedMs) return saved;
    if (saved.revision != expectedRevision) {
      throw StateError(
        'This session changed. Reopen its details before correcting it.',
      );
    }
    await (database.update(
      database.focusSessions,
    )..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        reportedMs: Value(reportedMs),
        revision: Value(saved.revision + 1),
      ),
    );
    return query.getSingle();
  });
}
