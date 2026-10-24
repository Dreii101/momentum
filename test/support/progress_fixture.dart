import 'package:drift/drift.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_engine.dart';

final fixtureWeek = CalendarDate(2026, 10, 19);

/// Independent known records: 2 tasks, 1 step, 390s, 1 starter + 3 focus reviews.
Future<List<FocusSession>> seedProgress(MomentumRepository repo) =>
    repo.transaction(() async {
      final db = repo.database;
      await repo.initialize();
      final task = await repo.createTask(
        const TaskDraft(title: 'Boundary task 日本語', status: TaskStatus.done),
      );
      await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(completedAt: Value(DateTime.utc(2026, 10, 18, 16))),
      );
      final archived = await repo.createTask(
        const TaskDraft(title: 'Archived completion', status: TaskStatus.done),
      );
      await repo.archiveTask(archived.id);
      final step = await repo.createSubtask(task.id, 'Read introduction');
      await repo.updateSubtask(
        step.id,
        title: step.title,
        position: 0,
        completed: true,
      );
      final installation = await repo.installation();
      final result = <FocusSession>[];
      for (var i = 0; i < 7; i++) {
        final id = repo.ids();
        final kind = i == 0
            ? SessionKind.starter
            : i == 4
            ? SessionKind.rest
            : SessionKind.focus;
        final start = i == 2
            ? DateTime.utc(2026, 10, 25, 15, 59)
            : DateTime.utc(2026, 10, i == 6 ? 26 : 20, 2, i);
        final eligible = [120000, 240000, 300000, 60000, 0, 60000, 1000][i];
        final uncertain = i == 1 ? 60000 : 0;
        final elapsed = kind == SessionKind.rest ? 60000 : eligible + uncertain;
        await db
            .into(db.focusSessions)
            .insert(
              FocusSessionsCompanion.insert(
                id: id,
                installationId: installation.id,
                taskId: Value(task.id),
                titleSnapshot: 'Fixture interval $i',
                zone: 'Asia/Manila',
                localStartDate: CalendarDate(
                  2026,
                  10,
                  i == 2
                      ? 25
                      : i == 6
                      ? 26
                      : 20,
                ),
                startedUtc: start,
                kind: kind,
                state: i == 5
                    ? SessionState.awaitingReview
                    : SessionState.finalized,
                outcome: Value(
                  i == 5
                      ? SessionOutcome.interrupted
                      : SessionOutcome.stoppedEarly,
                ),
                plannedMs: i == 0 ? 120000 : 600000,
                elapsedMs: elapsed,
                eligibleMs: eligible,
                uncertainMs: uncertain,
                hasUncertainty: uncertain > 0,
                background: false,
                checkpointUtc: start.add(Duration(milliseconds: elapsed)),
                elapsedMarkMs: elapsed,
                clockEpoch: 'fixture',
                revision: 4,
                reportedMs: Value(
                  i == 5 ? null : [90000, 180000, 120000, 0, 0, 0, 1000][i],
                ),
                finalizedUtc: Value(
                  i == 5 ? null : start.add(Duration(milliseconds: elapsed)),
                ),
              ),
            );
        result.add(
          await (db.select(
            db.focusSessions,
          )..where((s) => s.id.equals(id))).getSingle(),
        );
      }
      // A pause is evidence, never a second credited interval.
      await db
          .into(db.focusSegments)
          .insert(
            FocusSegmentsCompanion.insert(
              id: repo.ids(),
              sessionId: result[1].id,
              sequence: 1,
              kind: SegmentKind.pause,
              fromUtc: result[1].startedUtc,
              toUtc: result[1].startedUtc.add(const Duration(minutes: 2)),
              spanMs: 120000,
              elapsedMs: 0,
              eligibleMs: 0,
            ),
          );
      return result;
    });
