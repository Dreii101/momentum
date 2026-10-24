import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';
import 'support/progress_fixture.dart';
import 'calendar_test.dart' show readEveryRow;

class FailedProgressUpgrade extends AppDatabase {
  FailedProgressUpgrade(File file)
    : super(NativeDatabase.createInBackground(file));
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE tasks SET title='must roll back'");
    throw StateError('Injected progress migration failure');
  }
}

void main() {
  late DatabaseFixture fixture;
  late MomentumRepository repo;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    repo = MomentumRepository(
      fixture.open(),
      clock: () => DateTime.utc(2026, 10, 22, 8),
    );
    await repo.initialize();
  });
  tearDown(() => fixture.dispose());
  Future<ProgressSnapshot> snapshot([String zone = 'Asia/Manila']) =>
      repo.progressSnapshot(fixtureWeek, zone);

  test('known totals exclude pauses, breaks, zero-credit work and unresolved time; count each interval once', () async {
    await seedProgress(repo);
    final s = await snapshot();
    expect(s.tasks, hasLength(2));
    expect(s.steps, hasLength(1));
    expect(s.sessions, hasLength(6));
    expect(s.reportedMs, 390000);
    expect(s.count(SessionKind.starter), 1);
    expect(s.count(SessionKind.focus), 3);
    expect(s.unresolved, 1);
    expect(
      s.sessions.where((r) => r.uncertainMs > 0).single.reportedMs,
      180000,
    );
  });

  test(
    'paused work remains unresolved and cannot be corrected into credit',
    () async {
      final rows = await seedProgress(repo), row = rows[5];
      await (repo.database.update(
        repo.database.focusSessions,
      )..where((s) => s.id.equals(row.id))).write(
        const FocusSessionsCompanion(
          state: Value(SessionState.paused),
          outcome: Value(null),
        ),
      );
      expect((await snapshot()).reportedMs, 390000);
      expect((await snapshot()).unresolved, 1);
      await expectLater(
        repo.correctReportedWork(
          row.id,
          reportedMs: 60000,
          expectedRevision: row.revision,
          confirmed: true,
        ),
        throwsFormatException,
      );
    },
  );

  test('stored date controls cross-midnight sessions and survives zone changes; completion boundaries use selected zone', () async {
    final rows = await seedProgress(repo);
    expect(rows[2].finalizedUtc!.day, 25);
    expect(
      rows[2].finalizedUtc!.hour,
      16,
    ); // Monday locally, still Sunday start.
    expect((await snapshot('America/New_York')).reportedMs, 390000);
    expect(
      (await snapshot('UTC')).tasks,
      hasLength(1),
    ); // Midnight Manila was Sunday UTC.
    final next = await repo.progressSnapshot(
      CalendarDate(2026, 10, 26),
      'Asia/Manila',
    );
    expect(next.reportedMs, 1000);
    expect(next.count(SessionKind.focus), 1);
    expect(progressWeek(CalendarDate(2027, 1, 3)), CalendarDate(2026, 12, 28));
    expect(progressWeek(CalendarDate(2027, 1, 4)), CalendarDate(2027, 1, 4));
  });

  test('reopening, trash/restore and archived relationships consistently update completion streams', () async {
    await seedProgress(repo);
    final first = await snapshot();
    final task = first.tasks.firstWhere((t) => t.archivedAt == null);
    final stream = repo.watchProgress(fixtureWeek, 'Asia/Manila');
    final changed = stream.firstWhere((s) => s.tasks.length == 1);
    await repo.setTaskStatus(task.id, TaskStatus.todo);
    expect((await changed).steps, hasLength(1));
    await repo.deleteTask(task.id);
    expect((await snapshot()).steps, isEmpty);
    await repo.deleteTask(task.id, deleted: false);
    final step = (await snapshot()).steps.single.step;
    await repo.updateSubtask(
      step.id,
      title: step.title,
      position: step.position,
      completed: false,
    );
    expect((await snapshot()).steps, isEmpty);
    await repo.setTaskStatus(task.id, TaskStatus.done);
    expect((await snapshot()).tasks, hasLength(2));
    expect((await snapshot()).reportedMs, 390000);
  });

  test('correction is confirmed, bounded, revision guarded, idempotent and reactive without changing elapsed evidence', () async {
    final rows = await seedProgress(repo), row = rows[1];
    Future<FocusSession> correct(
      int ms, {
      bool confirmed = true,
      int? revision,
    }) => repo.correctReportedWork(
      row.id,
      reportedMs: ms,
      expectedRevision: revision ?? row.revision,
      confirmed: confirmed,
    );
    for (final amount in [-1, row.eligibleMs + 1]) {
      await expectLater(correct(amount), throwsFormatException);
    }
    await expectLater(correct(1000, confirmed: false), throwsFormatException);
    final emission = repo
        .watchProgress(fixtureWeek, 'Asia/Manila')
        .firstWhere((s) => s.reportedMs == 270000);
    final updated = await correct(60000);
    expect((await emission).reportedMs, 270000);
    expect(updated.eligibleMs, row.eligibleMs);
    expect(updated.elapsedMs, row.elapsedMs);
    expect(updated.finalizedUtc, row.finalizedUtc);
    expect(updated.localStartDate, row.localStartDate);
    expect((await correct(60000)).revision, updated.revision);
    await expectLater(correct(50000), throwsStateError);
    await correct(0, revision: updated.revision);
    expect((await snapshot()).reportedMs, 210000);
    for (final invalid in [rows[4], rows[5]]) {
      await expectLater(
        repo.correctReportedWork(
          invalid.id,
          reportedMs: 0,
          expectedRevision: invalid.revision,
          confirmed: true,
        ),
        throwsFormatException,
      );
    }
    expect((await repo.task(row.taskId!)).status, TaskStatus.done);
  });

  test('failed credit writes roll back and reflection/corrected credit survive real close and reopen', () async {
    final rows = await seedProgress(repo), row = rows.first;
    await repo.database.customStatement(
      "CREATE TRIGGER refuse_credit BEFORE UPDATE ON focus_sessions BEGIN SELECT RAISE(ABORT,'disk failure fixture'); END",
    );
    await expectLater(
      repo.correctReportedWork(
        row.id,
        reportedMs: 50000,
        expectedRevision: row.revision,
        confirmed: true,
      ),
      throwsA(anything),
    );
    expect((await snapshot()).reportedMs, 390000);
    await repo.database.customStatement('DROP TRIGGER refuse_credit');
    await repo.correctReportedWork(
      row.id,
      reportedMs: 50000,
      expectedRevision: row.revision,
      confirmed: true,
    );
    final saved = await repo.saveReflection(
      fixtureWeek,
      helped: 'Small starts 🧬',
      obstacles: '日本語\nInterruptions',
      adjustment: 'Open one page',
    );
    final edited = await repo.saveReflection(
      fixtureWeek,
      helped: 'Small starts 🧬',
      obstacles: '日本語\nInterruptions',
      adjustment: 'Two minutes',
    );
    expect(edited.id, saved.id);
    await repo.database.close();
    repo = MomentumRepository(fixture.open());
    final reopened = await snapshot();
    expect(reopened.reportedMs, 350000);
    expect(reopened.reflection!.adjustment, 'Two minutes');
    expect(reopened.reflection!.obstacles, '日本語\nInterruptions');
    expect(
      await repo.database.select(repo.database.weeklyReflections).get(),
      hasLength(1),
    );
  });

  test('reflection week uniqueness, Monday/calendar/text constraints and failed writes preserve saved answers', () async {
    final saved = await repo.saveReflection(
      fixtureWeek,
      helped: '',
      obstacles: '',
      adjustment: 'Keep',
    );
    await expectLater(
      repo.saveReflection(
        CalendarDate(2026, 10, 20),
        helped: '',
        obstacles: '',
        adjustment: '',
      ),
      throwsArgumentError,
    );
    await expectLater(
      repo.saveReflection(
        fixtureWeek,
        helped: 'x' * 5001,
        obstacles: '',
        adjustment: '',
      ),
      throwsFormatException,
    );
    await repo.saveReflection(
      fixtureWeek,
      helped: '🧬' * 5000,
      obstacles: '',
      adjustment: 'Keep',
    );
    await expectLater(
      repo.database.customStatement(
        'UPDATE weekly_reflections SET week_start=?',
        ['2026-02-30'],
      ),
      throwsA(anything),
    );
    await expectLater(
      repo.database.customStatement(
        'UPDATE weekly_reflections SET week_start=?',
        ['2026-10-20'],
      ),
      throwsA(anything),
    );
    await expectLater(
      repo.database.customStatement(
        'INSERT INTO weekly_reflections SELECT ?,week_start,helped,obstacles,adjustment,created_at,updated_at FROM weekly_reflections',
        [repo.ids()],
      ),
      throwsA(anything),
    );
    await repo.database.customStatement(
      "CREATE TRIGGER refuse_reflection BEFORE UPDATE ON weekly_reflections BEGIN SELECT RAISE(ABORT,'disk failure fixture'); END",
    );
    await expectLater(
      repo.saveReflection(
        fixtureWeek,
        helped: 'Changed',
        obstacles: '',
        adjustment: '',
      ),
      throwsA(anything),
    );
    expect((await snapshot()).reflection!.id, saved.id);
    expect((await snapshot()).reflection!.adjustment, 'Keep');
  });

  test('populated schema 8 migrates additively; interruption rolls back data, DDL and version', () async {
    final oldFile = File('${fixture.directory.path}/v8.sqlite');
    createSchemaFixture(oldFile, version: 8);
    seedSchemaV1(oldFile);
    final before = readEveryRow(oldFile);
    final failing = FailedProgressUpgrade(oldFile);
    await expectLater(
      failing.ensureOpen(),
      throwsA(
        predicate(
          (e) => e.toString().contains('Injected progress migration failure'),
        ),
      ),
    );
    await failing.close();
    expect(readEveryRow(oldFile), before);
    final raw = sql.sqlite3.open(oldFile.path);
    expect(raw.select('PRAGMA user_version').single.values.single, 8);
    raw.close();
    final upgraded = AppDatabase.file(oldFile);
    await upgraded.ensureOpen();
    await upgraded.close();
    final after = readEveryRow(oldFile);
    for (final entry in before.entries) {
      expect(after[entry.key], entry.value, reason: entry.key);
    }
    expect(after.keys, hasLength(20));
    final expected = File('${fixture.directory.path}/v10.sqlite');
    createSchemaFixture(expected, version: 10);
    expect(readSchema(oldFile), readSchema(expected));
  });
}
