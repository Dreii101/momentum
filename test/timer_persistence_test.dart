import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';
import 'calendar_test.dart' show readEveryRow, seedScheduleV5;
import 'timer_engine_test.dart' show FakeTimerClock;

import 'package:momentum/core/database/migrations.dart' show planningV6Sql;

class LostStartAcknowledgement extends TimerStore {
  LostStartAcknowledgement(super.repository);
  bool fail = true;
  @override
  Future<FocusSession> start({
    required String commandId,
    required String sessionId,
    required SessionKind kind,
    required int minutes,
    required String zone,
    required TimeSample now,
    String? taskId,
    String? subtaskId,
  }) async {
    final result = await super.start(
      commandId: commandId,
      sessionId: sessionId,
      kind: kind,
      minutes: minutes,
      zone: zone,
      now: now,
      taskId: taskId,
      subtaskId: subtaskId,
    );
    if (fail) {
      fail = false;
      throw const FileSystemException('Commit succeeded; acknowledgement lost');
    }
    return result;
  }
}

class FailedTimerUpgrade extends AppDatabase {
  FailedTimerUpgrade(File file)
    : super(NativeDatabase.createInBackground(file));
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE tasks SET title='must roll back'");
    throw StateError('Injected timer migration failure');
  }
}

void main() {
  late DatabaseFixture fixture;
  late MomentumRepository repo;
  late TimerStore store;
  late FakeTimerClock clock;
  late TimerCoordinator coordinator;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    repo = MomentumRepository(fixture.open());
    await repo.initialize();
    clock = FakeTimerClock();
    store = TimerStore(repo);
    coordinator = TimerCoordinator(store, clock, period: null);
    await coordinator.initialize();
  });
  tearDown(() async {
    await coordinator.close();
    await fixture.dispose();
  });

  test('task completion is guarded until timer review; completed task/step cannot start', () async {
    final task = await repo.createTask(const TaskDraft(title: 'Guarded task'));
    final step = await repo.createSubtask(task.id, 'Already done');
    await repo.updateSubtask(
      step.id,
      title: step.title,
      position: step.position,
      completed: true,
    );
    await expectLater(
      coordinator.start(
        SessionKind.starter,
        taskId: task.id,
        subtaskId: step.id,
      ),
      throwsStateError,
    );
    await coordinator.start(SessionKind.focus, taskId: task.id);
    await expectLater(
      repo.setTaskStatus(task.id, TaskStatus.done),
      throwsStateError,
    );
    await expectLater(
      repo.updateTask(
        task.id,
        const TaskDraft(title: 'Guarded task', status: TaskStatus.done),
      ),
      throwsStateError,
    );
    expect((await repo.task(task.id)).status, TaskStatus.todo);
    await coordinator.command(TimerAction.end);
    await repo.setTaskStatus(task.id, TaskStatus.done);
    expect(coordinator.view.session!.reportedMs, isNull);
    await coordinator.command(
      TimerAction.finalize,
      reportedMs: 0,
      confirmed: true,
    );
    await expectLater(
      coordinator.start(SessionKind.focus, taskId: task.id),
      throwsStateError,
    );
  });

  test('task/subtask/title/date snapshots survive editing, deletion and finalization without completion', () async {
    final t = await repo.createTask(
      const TaskDraft(title: 'Original 🧬', remainingMinutes: 40),
    );
    final step = await repo.createSubtask(t.id, 'Step');
    final s = (await coordinator.start(
      SessionKind.focus,
      minutes: 1,
      taskId: t.id,
      subtaskId: step.id,
    ))!;
    expect(s.titleSnapshot, t.title);
    expect(s.localStartDate, CalendarDate(2026, 10, 21));
    clock.advance(5000);
    await coordinator.checkpoint();
    await repo.updateTaskDetails(
      t.id,
      const TaskDraft(title: 'Renamed', remainingMinutes: 40),
    );
    await repo.deleteTask(t.id);
    final before = await repo.task(t.id),
        beforeStep = await repo.subtask(step.id);
    clock.advance(5000);
    await coordinator.command(TimerAction.end);
    await coordinator.command(
      TimerAction.finalize,
      reportedMs: 10000,
      confirmed: true,
    );
    expect(await repo.task(t.id), before);
    expect(await repo.subtask(step.id), beforeStep);
    expect((await store.session(s.id)).titleSnapshot, 'Original 🧬');
    expect((await repo.task(t.id)).status, TaskStatus.todo);
  });
  test('only one unfinished session; duplicate start ID returns original even after finalization', () async {
    final id = repo.ids();
    final first = (await coordinator.start(
      SessionKind.focus,
      minutes: 1,
      commandId: id,
    ))!;
    final again = await coordinator.start(
      SessionKind.focus,
      minutes: 1,
      commandId: id,
    );
    expect(again!.id, first.id);
    await expectLater(coordinator.start(SessionKind.starter), throwsStateError);
    await coordinator.command(TimerAction.end);
    await expectLater(
      coordinator.start(SessionKind.rest, minutes: 5),
      throwsStateError,
    );
    await coordinator.command(
      TimerAction.finalize,
      reportedMs: 0,
      confirmed: true,
    );
    expect(
      (await coordinator.start(
        SessionKind.focus,
        minutes: 1,
        commandId: id,
      ))!.id,
      first.id,
    );
    final next = await coordinator.start(SessionKind.starter);
    expect(next!.id, isNot(first.id));
    expect(
      await repo.database.select(repo.database.focusSessions).get(),
      hasLength(2),
    );
  });
  test('extension receipt and repeated finalization are durable and cannot double credit', () async {
    final s = (await coordinator.start(SessionKind.focus, minutes: 1))!;
    final extendId = repo.ids();
    await coordinator.command(
      TimerAction.extend,
      minutes: 1,
      commandId: extendId,
    );
    await coordinator.command(
      TimerAction.extend,
      minutes: 1,
      commandId: extendId,
    );
    expect(coordinator.view.session!.plannedMs, 120000);
    await expectLater(
      coordinator.command(TimerAction.extend, minutes: 2, commandId: extendId),
      throwsStateError,
    );
    clock.advance(5000);
    await coordinator.command(TimerAction.end);
    final first = (await coordinator.command(
      TimerAction.finalize,
      reportedMs: 4000,
      confirmed: true,
    ))!;
    final second = (await coordinator.command(
      TimerAction.finalize,
      reportedMs: 4000,
      confirmed: true,
    ))!;
    expect(second, first);
    expect((await store.session(s.id)).reportedMs, 4000);
    await expectLater(
      coordinator.command(
        TimerAction.finalize,
        reportedMs: 3000,
        confirmed: true,
      ),
      throwsStateError,
    );
  });
  test('SQL rejects duplicate unfinished state and invalid aggregate/credit/foreign keys', () async {
    final s = (await coordinator.start(SessionKind.focus, minutes: 1))!;
    for (final statement in [
      "UPDATE focus_sessions SET elapsed_ms=planned_ms+1",
      "UPDATE focus_sessions SET eligible_ms=1",
      "UPDATE focus_sessions SET planned_ms=0",
      "UPDATE focus_sessions SET state='finalized'",
      "UPDATE focus_sessions SET kind='invalid'",
      "UPDATE focus_sessions SET task_id='00000000-0000-4000-8000-000000000099'",
    ]) {
      await expectLater(
        repo.database.customStatement(statement),
        throwsA(isA<Exception>()),
      );
    }
    final columns = await repo.database
        .customSelect('PRAGMA table_info(focus_sessions)')
        .get();
    final names = columns.map((r) => r.read<String>('name')).join(',');
    final projection = columns
        .map(
          (r) => r.read<String>('name') == 'id'
              ? "'${repo.ids()}'"
              : r.read<String>('name'),
        )
        .join(',');
    await expectLater(
      repo.database.customStatement(
        'INSERT INTO focus_sessions ($names) SELECT $projection FROM focus_sessions',
      ),
      throwsA(isA<Exception>()),
    );
    expect(await store.session(s.id), s);
  });
  test('failed transaction retains confirmed state, ledger and receipt; Retry captures time once', () async {
    final s = (await coordinator.start(SessionKind.focus, minutes: 1))!;
    await repo.database.customStatement(
      "CREATE TRIGGER reject_timer BEFORE UPDATE ON focus_sessions BEGIN SELECT RAISE(ABORT,'Injected timer write failure'); END",
    );
    clock.advance(5000);
    await expectLater(
      coordinator.command(TimerAction.pause),
      throwsA(isA<Exception>()),
    );
    expect(coordinator.view.session, s);
    expect(coordinator.view.error, isNotNull);
    expect(await store.segments(s.id), isEmpty);
    await repo.database.customStatement('DROP TRIGGER reject_timer');
    await coordinator.retry();
    expect(coordinator.view.session!.state, SessionState.paused);
    expect(coordinator.view.session!.elapsedMs, 5000);
    expect((await store.segments(s.id)).single.eligibleMs, 5000);
    expect(coordinator.view.error, isNull);
  });
  test('commit acknowledgement loss retries the same start instead of creating a second session', () async {
    final other = TimerCoordinator(
      LostStartAcknowledgement(repo),
      clock,
      period: null,
    );
    try {
      await other.initialize();
      await expectLater(
        other.start(SessionKind.starter),
        throwsA(isA<FileSystemException>()),
      );
      expect(other.view.session, isNull);
      expect(await store.unfinished(), isNotNull);
      await other.retry();
      expect(other.view.session!.kind, SessionKind.starter);
      expect(
        await repo.database.select(repo.database.focusSessions).get(),
        hasLength(1),
      );
    } finally {
      await other.close();
    }
  });
  test('abrupt termination recovers last checkpoint plus bounded uncertainty, never resumes', () async {
    final s = (await coordinator.start(SessionKind.focus, minutes: 1))!;
    clock.advance(5000);
    await coordinator.checkpoint();
    await coordinator.close();
    await repo.database.close();
    clock.advance(3600000);
    clock.epoch = 'after-reboot';
    clock.elapsed = 0;
    final reopened = MomentumRepository(fixture.open());
    final recovered = TimerCoordinator(
      TimerStore(reopened),
      clock,
      period: null,
    );
    try {
      await recovered.initialize();
      final row = recovered.view.session!;
      expect(row.id, s.id);
      expect(row.state, SessionState.awaitingReview);
      expect(row.outcome, SessionOutcome.interrupted);
      expect(row.elapsedMs, 60000);
      expect(row.eligibleMs, 5000);
      expect(row.uncertainMs, 55000);
      expect(row.reportedMs, isNull);
      await expectLater(
        recovered.command(TimerAction.resume),
        throwsStateError,
      );
      await recovered.command(
        TimerAction.finalize,
        reportedMs: 5000,
        confirmed: true,
      );
      final finalized = recovered.view.session!;
      await recovered.command(
        TimerAction.finalize,
        reportedMs: 5000,
        confirmed: true,
      );
      expect(recovered.view.session, finalized);
    } finally {
      await recovered.close();
    }
  });
  test('background segments and pauses are recorded separately and no work is automatically reported', () async {
    final s = (await coordinator.start(SessionKind.focus, minutes: 1))!;
    clock.advance(5000);
    await coordinator.lifecycle(true);
    clock.advance(5000);
    await coordinator.checkpoint();
    clock.advance(5000);
    await coordinator.lifecycle(false);
    await coordinator.command(TimerAction.pause);
    clock.advance(10000);
    await coordinator.command(TimerAction.resume);
    clock.advance(5000);
    await coordinator.command(TimerAction.end);
    final row = coordinator.view.session!;
    expect(row.elapsedMs, 20000);
    expect(row.eligibleMs, 10000);
    expect(row.uncertainMs, 10000);
    expect(row.reportedMs, isNull);
    final segments = await store.segments(s.id);
    expect(segments.where((s) => s.kind == SegmentKind.pause), isNotEmpty);
    expect(segments.fold(0, (int n, s) => n + s.eligibleMs), row.eligibleMs);
    expect(segments.fold(0, (int n, s) => n + s.elapsedMs), row.elapsedMs);
  });
  test('wrong subtask and trashed task refuse start atomically', () async {
    final a = await repo.createTask(const TaskDraft(title: 'A')),
        b = await repo.createTask(const TaskDraft(title: 'B'));
    final step = await repo.createSubtask(a.id, 'A step');
    await expectLater(
      coordinator.start(SessionKind.focus, taskId: b.id, subtaskId: step.id),
      throwsStateError,
    );
    await repo.deleteTask(a.id);
    await expectLater(
      coordinator.start(SessionKind.focus, taskId: a.id),
      throwsStateError,
    );
    expect(await store.unfinished(), isNull);
    expect(
      await repo.database.select(repo.database.timerCommandReceipts).get(),
      isEmpty,
    );
  });
  test('populated schema6 upgrade preserves all prior fields; failure rolls back schema, data and version', () async {
    final old = File('${fixture.directory.path}/old6.sqlite');
    seedScheduleV5(old);
    final raw = sql.sqlite3.open(old.path);
    try {
      for (final statement in planningV6Sql) {
        raw.execute(statement);
      }
      raw.execute('PRAGMA user_version=6');
      raw.execute(
        "INSERT INTO planned_work_blocks(id,created_at,updated_at,task_id,start_utc,end_utc,planning_zone,status,locked) VALUES ('00000000-0000-4000-8000-000000000071',1,1,?,1000,61000,'UTC','planned',1)",
        [fixtureTaskId],
      );
    } finally {
      raw.close();
    }
    final before = readEveryRow(old);
    final failed = FailedTimerUpgrade(old);
    try {
      await expectLater(
        failed.ensureOpen(),
        throwsA(
          predicate<Object>(
            (e) => e.toString().contains('Injected timer migration failure'),
          ),
        ),
      );
    } finally {
      await failed.close();
    }
    expect(readEveryRow(old), before);
    final version = sql.sqlite3.open(old.path);
    expect(version.select('PRAGMA user_version').single.values.single, 6);
    version.close();
    final upgraded = AppDatabase.file(old);
    await upgraded.ensureOpen();
    await upgraded.close();
    final after = readEveryRow(old);
    expect(after.keys, hasLength(20));
    for (final key in before.keys) {
      expect(after[key], before[key], reason: key);
    }
    final expected = File('${fixture.directory.path}/expected7.sqlite');
    createSchemaFixture(expected, version: 10);
    expect(readSchema(old), readSchema(expected));
  });
}
