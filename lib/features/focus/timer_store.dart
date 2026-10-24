import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import 'timer_engine.dart';

TimerRecord timerRecord(FocusSession row) => TimerRecord(
  id: row.id,
  kind: row.kind,
  state: row.state,
  plannedMs: row.plannedMs,
  elapsedMs: row.elapsedMs,
  eligibleMs: row.eligibleMs,
  uncertainMs: row.uncertainMs,
  hasUncertainty: row.hasUncertainty,
  background: row.background,
  checkpoint: TimeSample(row.checkpointUtc, row.elapsedMarkMs, row.clockEpoch),
  outcome: row.outcome,
  reportedMs: row.reportedMs,
  finalizedUtc: row.finalizedUtc,
);

class TimerStore {
  TimerStore(this.repository);
  final MomentumRepository repository;
  AppDatabase get db => repository.database;
  Future<FocusSession?> unfinished() async {
    final installation = await repository.installation();
    return (db.select(db.focusSessions)..where(
          (t) =>
              t.installationId.equals(installation.id) &
              t.state.isNotValue(SessionState.finalized.name),
        ))
        .getSingleOrNull();
  }

  Future<FocusSession> session(String id) =>
      (db.select(db.focusSessions)..where((t) => t.id.equals(id))).getSingle();
  Future<List<FocusSegment>> segments(String id) =>
      (db.select(db.focusSegments)
            ..where((t) => t.sessionId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
          .get();

  Future<FocusSession?> _receipt(
    String commandId,
    String action,
    String payload,
  ) async {
    final previous = await (db.select(
      db.timerCommandReceipts,
    )..where((t) => t.id.equals(commandId))).getSingleOrNull();
    if (previous == null) return null;
    if (previous.action != action || previous.payload != payload) {
      throw StateError(
        'This command ID was already used with different arguments.',
      );
    }
    return session(previous.sessionId);
  }

  Future<void> _remember(
    String commandId,
    String sessionId,
    String action,
    String payload,
    TimeSample now,
  ) => db
      .into(db.timerCommandReceipts)
      .insert(
        TimerCommandReceiptsCompanion.insert(
          id: commandId,
          sessionId: sessionId,
          action: action,
          payload: payload,
          committedUtc: now.wallUtc,
        ),
      );

  Future<FocusSession> start({
    required String commandId,
    required String sessionId,
    required SessionKind kind,
    required int minutes,
    required String zone,
    required TimeSample now,
    String? taskId,
    String? subtaskId,
  }) => db.transaction(() async {
    final planned = TimerMachine.duration(kind, minutes);
    final location = requireTimeZone(zone);
    final payload = jsonEncode([kind.name, planned, zone, taskId, subtaskId]);
    final receipt = await _receipt(commandId, 'start', payload);
    if (receipt != null) return receipt;
    if (await unfinished() != null) {
      throw StateError(
        'Review and finalize the unfinished session before starting another.',
      );
    }
    Task? task;
    if (taskId != null) {
      task = await repository.task(taskId);
      if (task.deletedAt != null ||
          task.archivedAt != null ||
          task.status == TaskStatus.done) {
        throw StateError(
          'Restore or reopen the task before starting a session.',
        );
      }
    }
    if (subtaskId != null) {
      final subtask = await repository.subtask(subtaskId);
      if (taskId == null ||
          subtask.taskId != taskId ||
          subtask.deletedAt != null ||
          subtask.completedAt != null) {
        throw StateError('Choose a current subtask of the selected task.');
      }
    }
    final installation = await repository.installation();
    final local = tz.TZDateTime.from(now.wallUtc, location);
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            id: sessionId,
            installationId: installation.id,
            taskId: Value(taskId),
            subtaskId: Value(subtaskId),
            titleSnapshot: task?.title ?? 'General session',
            zone: zone,
            localStartDate: CalendarDate(local.year, local.month, local.day),
            startedUtc: now.wallUtc,
            kind: kind,
            state: SessionState.running,
            plannedMs: planned,
            elapsedMs: 0,
            eligibleMs: 0,
            uncertainMs: 0,
            hasUncertainty: false,
            background: false,
            checkpointUtc: now.wallUtc,
            elapsedMarkMs: now.elapsedMs,
            clockEpoch: now.epoch,
            revision: 0,
          ),
        );
    await _remember(commandId, sessionId, 'start', payload, now);
    return session(sessionId);
  });

  Future<FocusSession> apply(
    String id,
    TimerAction action,
    TimeSample now, {
    String? commandId,
    int minutes = 0,
    int? reportedMs,
    bool confirmed = false,
  }) => db.transaction(() async {
    final payload = jsonEncode([id, minutes, reportedMs, confirmed]);
    if (action != TimerAction.checkpoint && commandId == null) {
      throw ArgumentError('A durable command ID is required.');
    }
    if (commandId != null) {
      final receipt = await _receipt(commandId, action.name, payload);
      if (receipt != null) return receipt;
    }
    final old = await session(id);
    final installation = await repository.installation();
    if (old.installationId != installation.id) {
      throw StateError('This session belongs to another installation.');
    }
    final record = timerRecord(old);
    final step = TimerMachine.command(
      record,
      now,
      action,
      minutes: minutes,
      reportedMs: reportedMs,
      confirmed: confirmed,
    );
    if (!identical(step.record, record)) {
      final next = step.record;
      final written =
          await (db.update(db.focusSessions)..where(
                (t) => t.id.equals(id) & t.revision.equals(old.revision),
              ))
              .write(
                FocusSessionsCompanion(
                  state: Value(next.state),
                  outcome: Value(next.outcome),
                  plannedMs: Value(next.plannedMs),
                  elapsedMs: Value(next.elapsedMs),
                  eligibleMs: Value(next.eligibleMs),
                  uncertainMs: Value(next.uncertainMs),
                  hasUncertainty: Value(next.hasUncertainty),
                  background: Value(next.background),
                  checkpointUtc: Value(next.checkpoint.wallUtc),
                  elapsedMarkMs: Value(next.checkpoint.elapsedMs),
                  clockEpoch: Value(next.checkpoint.epoch),
                  reportedMs: Value(next.reportedMs),
                  finalizedUtc: Value(next.finalizedUtc),
                  revision: Value(old.revision + 1),
                ),
              );
      if (written != 1) {
        throw StateError(
          'The timer changed. Reload and retry the same command.',
        );
      }
      final last =
          await (db.select(db.focusSegments)
                ..where((t) => t.sessionId.equals(id))
                ..orderBy([(t) => OrderingTerm.desc(t.sequence)])
                ..limit(1))
              .getSingleOrNull();
      var sequence = last?.sequence ?? 0;
      for (final s in step.segments) {
        await db
            .into(db.focusSegments)
            .insert(
              FocusSegmentsCompanion.insert(
                id: repository.ids(),
                sessionId: id,
                sequence: ++sequence,
                kind: s.kind,
                fromUtc: s.from,
                toUtc: s.to,
                spanMs: s.spanMs,
                elapsedMs: s.elapsedMs,
                eligibleMs: s.eligibleMs,
                reason: Value(s.reason),
              ),
            );
      }
    }
    if (commandId != null) {
      await _remember(commandId, id, action.name, payload, now);
    }
    return session(id);
  });
}
