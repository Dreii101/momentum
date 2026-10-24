import 'package:drift/drift.dart';

import '../../features/schedule/recurrence.dart';
import 'app_database.dart';
import 'repository.dart';
import 'value_types.dart';

class WorkBlockDraft {
  const WorkBlockDraft({
    required this.taskId,
    required this.startUtc,
    required this.endUtc,
    required this.planningZone,
    this.status = WorkBlockStatus.planned,
    this.locked = false,
  });
  final String taskId, planningZone;
  final DateTime startUtc, endUtc;
  final WorkBlockStatus status;
  final bool locked;
}

/// A consistent source snapshot, also the input boundary for future reminder
/// reconciliation. No calendar copies or notification side effects are stored.
class PlanningSnapshot {
  const PlanningSnapshot(this.tasks, this.blocks, this.schedule);
  final List<Task> tasks;
  final List<PlannedWorkBlock> blocks;
  final ScheduleSnapshot schedule;
}

extension PlanningRepository on MomentumRepository {
  Future<PlannedWorkBlock> workBlock(String id) => (database.select(
    database.plannedWorkBlocks,
  )..where((t) => t.id.equals(id))).getSingle();

  Future<PlannedWorkBlock> saveWorkBlock(WorkBlockDraft draft, {String? id}) =>
      database.transaction(() async {
        requireTimeZone(draft.planningZone);
        if (!draft.endUtc.isAfter(draft.startUtc)) {
          throw const FormatException('Work must end after it starts.');
        }
        final source = await task(draft.taskId);
        if (source.deletedAt != null || source.archivedAt != null) {
          throw StateError('Restore the task before planning work for it.');
        }
        final previous = id == null ? null : await workBlock(id);
        if (previous?.deletedAt != null) {
          throw StateError('Restore this work block before editing it.');
        }
        final recordId = id ?? ids(), now = clock().toUtc();
        await database
            .into(database.plannedWorkBlocks)
            .insertOnConflictUpdate(
              PlannedWorkBlocksCompanion.insert(
                id: recordId,
                taskId: draft.taskId,
                startUtc: draft.startUtc.toUtc(),
                endUtc: draft.endUtc.toUtc(),
                planningZone: draft.planningZone,
                status: draft.status,
                locked: Value(draft.locked),
                createdAt: previous?.createdAt ?? now,
                updatedAt: now,
              ),
            );
        return workBlock(recordId);
      });

  Future<void> deleteWorkBlock(String id, {bool deleted = true}) =>
      database.transaction(() async {
        await workBlock(id);
        final now = clock().toUtc();
        await (database.update(
          database.plannedWorkBlocks,
        )..where((t) => t.id.equals(id))).write(
          PlannedWorkBlocksCompanion(
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
          ),
        );
      });

  Future<PlanningSnapshot> planningSnapshot() => database.transaction(
    () async => PlanningSnapshot(
      await database.select(database.tasks).get(),
      await database.select(database.plannedWorkBlocks).get(),
      ScheduleSnapshot(
        await database.select(database.activitySeriesRows).get(),
        await database.select(database.activityExceptions).get(),
        await database.select(database.courses).get(),
      ),
    ),
  );

  Stream<PlanningSnapshot> watchPlanningInputs() => database
      .customSelect(
        'SELECT 1',
        readsFrom: {
          database.tasks,
          database.plannedWorkBlocks,
          database.activitySeriesRows,
          database.activityExceptions,
          database.courses,
        },
      )
      .watch()
      .asyncMap((_) => planningSnapshot());

  /// Initial full state plus committed source changes; consumers derive desired
  /// reminders idempotently, including removals. No unreliable UI-only events.
  Stream<PlanningSnapshot> watchReminderReconciliationInputs() =>
      watchPlanningInputs();
}
