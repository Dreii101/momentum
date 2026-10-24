import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:momentum/features/reminders/reminder_coordinator.dart';
import 'package:momentum/features/reminders/reminder_plan.dart';
import 'package:momentum/features/reminders/reminder_providers.dart';
import 'package:momentum/features/reminders/reminder_store.dart';
import 'package:momentum/features/reminders/reminder_types.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';
import 'support/fake_notifications.dart';
import 'timer_engine_test.dart' show FakeTimerClock;
import 'calendar_test.dart' show readEveryRow;

class FailedReminderUpgrade extends AppDatabase {
  FailedReminderUpgrade(File f) : super(NativeDatabase.createInBackground(f));
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE notes SET body='must roll back'");
    throw StateError('Injected migration interruption');
  }
}

class FailedRegistrationAck extends ReminderStore {
  FailedRegistrationAck(super.repository);
  bool fail = true;
  @override
  Future<void> state(
    String id,
    RegistrationState state, {
    String? error,
    bool registered = false,
  }) async {
    if (registered && fail) {
      fail = false;
      throw const FileSystemException('Injected registration write failure');
    }
    await super.state(id, state, error: error, registered: registered);
  }
}

void main() {
  late DatabaseFixture fixture;
  late MomentumRepository repo;
  late ReminderStore store;
  late FakeTimerClock clock;
  late FakeNotifications native;
  late ReminderCoordinator owner;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    clock = FakeTimerClock()..wall = DateTime.utc(2026, 10, 22);
    repo = MomentumRepository(fixture.open(), clock: () => clock.wall);
    await repo.initialize();
    store = ReminderStore(repo);
    await store.initialize();
    native = FakeNotifications();
    owner = ReminderCoordinator(store, native, clock, onResponse: (_) async {});
  });
  tearDown(() async {
    await owner.close();
    await native.callbacks.close();
    await fixture.dispose();
  });
  Future<Task> deadline({
    String title = 'Write café 日本語',
    int minutes = 60,
  }) async {
    final task = await repo.createTask(
      TaskDraft(
        title: title,
        deadline: Deadline.timed(
          clock.wall.add(Duration(minutes: minutes)),
          'Asia/Manila',
        ),
      ),
    );
    await store.setRule(ReminderKind.deadline, task.id);
    return task;
  }

  Future<void> enable() => store.preferences(
    enabled: true,
    quietEnabled: false,
    start: 1320,
    end: 420,
  );
  Future<ReminderPlan> plan() async =>
      planReminders(await store.read(), clock.sample());

  test('lost registration acknowledgement retries stable ID without undoing source save', () async {
    final task = await deadline();
    await enable();
    await owner.close();
    owner = ReminderCoordinator(
      FailedRegistrationAck(repo),
      native,
      clock,
      onResponse: (_) async {},
    );
    await owner.reconcile();
    expect(owner.view.error, isNotNull);
    expect(native.items, hasLength(1));
    final id = native.items.keys.single;
    await owner.reconcile();
    expect(native.items.keys.single, id);
    expect(
      (await store.registrations()).single.state,
      RegistrationState.scheduled,
    );
    expect((await repo.task(task.id)).title, task.title);
  });
  test(
    'quiet-hour DST gap moves forward and fold chooses earlier offset',
    () async {
      clock.wall = DateTime.utc(2026, 3, 8);
      await repo.updateSettings(
        theme: ThemePreference.system,
        planningZone: 'America/New_York',
      );
      final task = await repo.createTask(
        TaskDraft(
          title: 'Gap',
          deadline: Deadline.timed(DateTime.utc(2026, 3, 8, 11), 'UTC'),
        ),
      );
      await store.setRule(ReminderKind.deadline, task.id, leadMinutes: 300);
      await store.preferences(
        enabled: true,
        quietEnabled: true,
        start: 60,
        end: 150,
      );
      expect(
        (await plan()).targets.single.dueUtc,
        DateTime.utc(2026, 3, 8, 7, 30),
      );
      clock.wall = DateTime.utc(2026, 11, 1);
      await repo.updateTask(
        task.id,
        TaskDraft(
          title: 'Fold',
          deadline: Deadline.timed(DateTime.utc(2026, 11, 1, 6, 30), 'UTC'),
        ),
      );
      await store.setRule(ReminderKind.deadline, task.id, leadMinutes: 90);
      await store.preferences(
        enabled: true,
        quietEnabled: true,
        start: 60,
        end: 90,
      );
      expect(
        (await plan()).targets.single.dueUtc,
        DateTime.utc(2026, 11, 1, 5, 30),
      );
    },
  );
  test('default off does not initialize OS access or ask permission; deny and retry preserve opt-in', () async {
    await owner.initialize();
    expect(native.capabilityReads, 0);
    expect(native.permissions, 0);
    await deadline();
    native.allowed = false;
    await owner.enable(true);
    expect(native.permissions, 1);
    expect((await store.read()).preferences.enabled, isTrue);
    expect(
      (await store.registrations()).single.state,
      RegistrationState.scheduleFailed,
    );
    native.allowed = true;
    await owner.reconcile(refreshStatus: true);
    expect(native.items, hasLength(1));
    expect(native.permissions, 1);
    await owner.enable(false);
    await owner.reconcile();
    expect(owner.view.capability!.allowed, isTrue);
    expect(native.items, isEmpty);
  });
  test('duplicate reconciliation and reopen preserve registration IDs; scheduling is never seen', () async {
    await deadline();
    await enable();
    await owner.reconcile();
    final original = (await store.registrations()).single;
    await owner.reconcile();
    expect(native.schedules, 1);
    expect(native.cancellations, 0);
    expect(original.openedAtUtc, isNull);
    expect(original.registeredAtUtc, clock.wall);
    final reopened = AppDatabase.file(fixture.file);
    try {
      final again = ReminderStore(MomentumRepository(reopened));
      expect(
        (await again.registrations()).single.notificationId,
        original.notificationId,
      );
    } finally {
      await reopened.close();
    }
  });
  test('edit keeps stable ID; completed/deleted tasks cancel without altering task saves', () async {
    final task = await deadline();
    await enable();
    await owner.reconcile();
    final first = (await store.registrations()).single;
    await repo.updateTask(
      task.id,
      TaskDraft(
        title: 'Edited',
        deadline: Deadline.timed(
          clock.wall.add(const Duration(hours: 2)),
          'Asia/Manila',
        ),
      ),
    );
    await owner.reconcile();
    final edited = (await store.registrations()).single;
    expect(edited.notificationId, first.notificationId);
    expect(native.schedules, 2);
    expect(native.cancellations, 1);
    native.failCancel = true;
    await repo.setTaskStatus(task.id, TaskStatus.done);
    await owner.reconcile();
    expect((await repo.task(task.id)).status, TaskStatus.done);
    expect(
      (await store.registrations()).single.state,
      RegistrationState.cancelFailed,
    );
    native.failCancel = false;
    await owner.reconcile();
    expect(native.items, isEmpty);
    await repo.setTaskStatus(task.id, TaskStatus.todo);
    await owner.reconcile();
    expect(native.items, hasLength(1));
    await repo.deleteTask(task.id);
    await owner.reconcile();
    expect(native.items, isEmpty);
  });
  test('scheduling failure is durable and retryable; exact revocation falls back approximately', () async {
    final task = await deadline();
    await enable();
    native.failSchedule = true;
    await owner.reconcile();
    expect((await repo.task(task.id)).title, task.title);
    expect(owner.view.error, isNotNull);
    expect(
      (await store.registrations()).single.error,
      contains('scheduling failure'),
    );
    native.failSchedule = false;
    native.revokeExactOnSchedule = true;
    await owner.reconcile();
    expect(native.items, hasLength(1));
    expect(native.exactModes.last, isFalse);
    native.allowed = false;
    await owner.reconcile(refreshStatus: true);
    expect(native.items, isEmpty);
    expect(owner.view.capability!.allowed, isFalse);
  });
  test(
    'new process repairs cached future registrations once without changing IDs',
    () async {
      await deadline();
      await enable();
      await owner.reconcile();
      final id = native.items.keys.single;
      await owner.close();
      owner = ReminderCoordinator(
        store,
        native,
        clock,
        onResponse: (_) async {},
      );
      await owner.initialize();
      expect(native.schedules, 2);
      expect(native.items.keys.single, id);
      await owner.reconcile();
      expect(native.schedules, 2);
    },
  );
  test('lost OS registrations restore once; off-time past triggers are not replayed', () async {
    await deadline();
    await enable();
    await owner.reconcile();
    native.items.clear();
    await owner.reconcile();
    expect(native.schedules, 2);
    native.items.clear();
    clock.advance(7200000);
    await owner.reconcile();
    expect(native.items, isEmpty);
    expect(native.schedules, 2);
    expect(
      (await store.registrations()).single.state,
      RegistrationState.elapsed,
    );
    expect((await store.registrations()).single.openedAtUtc, isNull);
  });
  test('late approximate registration stays briefly; stale source cancels even after trigger passed', () async {
    final task = await deadline(minutes: 1);
    await enable();
    native.exact = false;
    await owner.reconcile();
    clock.advance(90000);
    await owner.reconcile();
    expect(native.items, hasLength(1));
    await repo.setTaskStatus(task.id, TaskStatus.done);
    await owner.reconcile();
    expect(native.items, isEmpty);
    expect((await store.registrations()).single.openedAtUtc, isNull);
  });
  test('completed source clears an already elapsed OS alert without inferring seen', () async {
    final task = await deadline(minutes: 1);
    await enable();
    await owner.reconcile();
    native.items.clear();
    clock.advance(90000);
    await owner.reconcile();
    expect(
      (await store.registrations()).single.state,
      RegistrationState.elapsed,
    );
    final before = native.cancellations;
    await repo.setTaskStatus(task.id, TaskStatus.done);
    await owner.reconcile();
    expect(native.cancellations, before + 1);
    expect(
      (await store.registrations()).single.state,
      RegistrationState.cancelled,
    );
    expect((await store.registrations()).single.openedAtUtc, isNull);
  });
  test('date-only 09:00 uses saved zone through DST and midnight, independently of display zone', () async {
    final t = await repo.createTask(
      TaskDraft(
        title: 'Date only',
        deadline: Deadline.dateOnly(
          CalendarDate(2026, 11, 1),
          'America/New_York',
        ),
      ),
    );
    await store.setRule(ReminderKind.deadline, t.id);
    await enable();
    expect((await plan()).targets.single.dueUtc, DateTime.utc(2026, 11, 1, 14));
    await store.setRule(ReminderKind.deadline, t.id, leadMinutes: 1440);
    final early = (await plan()).targets.single;
    expect(early.dueUtc, DateTime.utc(2026, 10, 31, 14));
    expect(early.title, contains('2026-11-01'));
    await store.setRule(ReminderKind.deadline, t.id);
    await repo.updateSettings(
      theme: ThemePreference.system,
      planningZone: 'Pacific/Auckland',
    );
    expect((await plan()).targets.single.dueUtc, DateTime.utc(2026, 11, 1, 14));
    clock.wall = DateTime.utc(2026, 11, 2, 5);
    expect((await plan()).targets, isEmpty);
  });
  test('quiet hours defer only before source, suppress endpoint and validate bounds', () async {
    clock.wall = DateTime.utc(2026, 10, 21, 13); // 21:00 Manila
    final t = await deadline(minutes: 660); // 08:00 tomorrow, reminder at 23:00
    await store.setRule(ReminderKind.deadline, t.id, leadMinutes: 540);
    await store.preferences(
      enabled: true,
      quietEnabled: true,
      start: 1320,
      end: 420,
    );
    expect(
      (await plan()).targets.single.dueUtc,
      DateTime.utc(2026, 10, 21, 23),
    ); //07:00
    await store.setRule(ReminderKind.deadline, t.id, leadMinutes: 0);
    final early = await deadline(
      minutes: 120,
    ); //23:00 source, quiet end too late
    expect((await plan()).quietSuppressed, 1);
    expect(
      (await plan()).targets.any((r) => r.title.contains(early.title)),
      isTrue,
    ); // other same-title deadline remains
    expect(
      () => store.preferences(
        enabled: true,
        quietEnabled: true,
        start: 420,
        end: 420,
      ),
      throwsFormatException,
    );
    expect(
      () => store.setRule(ReminderKind.deadline, t.id, leadMinutes: 10081),
      throwsFormatException,
    );
  });
  test('moved and cancelled occurrences reconcile original identity; course archive preserves opt-in', () async {
    final course = await repo.createCourse(const CourseDraft(name: 'Biology'));
    final series = await repo.createActivity(
      ActivityDraft(
        title: 'Class',
        courseId: course.id,
        startDate: CalendarDate(2026, 10, 22),
        endDate: CalendarDate(2026, 11, 20),
        startMinute: 600,
        endMinute: 660,
        zone: 'Asia/Manila',
        weekdays: 127,
      ),
    );
    await store.setRule(ReminderKind.activity, series.id);
    await enable();
    await owner.reconcile();
    final old = (await store.registrations()).first;
    await repo.changeOccurrence(
      series.id,
      CalendarDate(2026, 10, 22),
      move: OccurrenceMove(
        date: CalendarDate(2026, 10, 23),
        startMinute: 720,
        endMinute: 780,
        zone: 'Asia/Manila',
      ),
    );
    await owner.reconcile();
    final moved = (await store.registrations()).firstWhere(
      (r) => r.id == old.id,
    );
    expect(moved.notificationId, old.notificationId);
    expect(moved.dueUtc, DateTime.utc(2026, 10, 23, 4));
    final route = await resolveReminder(store, 'momentum:${old.id}');
    expect(route!.record, 'occurrence/${series.id}/2026-10-22');
    await repo.archiveCourse(course.id);
    await owner.reconcile();
    expect(native.items.containsKey(old.notificationId), isTrue);
    await repo.changeOccurrence(
      series.id,
      CalendarDate(2026, 10, 22),
      cancelled: true,
    );
    await owner.reconcile();
    expect(native.items.containsKey(old.notificationId), isFalse);
    expect(await resolveReminder(store, 'momentum:${old.id}'), isNull);
  });
  test('selected series expand independently without reminders for unrelated series', () async {
    for (final title in ['Selected A', 'Selected B', 'Unselected']) {
      final s = await repo.createActivity(
        ActivityDraft(
          title: title,
          startDate: CalendarDate(2026, 10, 22),
          endDate: CalendarDate(2026, 10, 22),
          startMinute: 600,
          endMinute: 660,
          zone: 'Asia/Manila',
          recurrence: 'once',
          weekdays: 0,
        ),
      );
      if (title != 'Unselected') {
        await store.setRule(ReminderKind.activity, s.id);
      }
    }
    await enable();
    final targets = (await plan()).targets;
    expect(targets, hasLength(2));
    expect(targets.map((t) => t.key).toSet(), hasLength(2));
    expect(targets.every((t) => t.title.contains('Selected')), isTrue);
  });
  test('planned work edit/cancel changes alert but never deadline; callback re-reads task', () async {
    final task = await deadline();
    final b = await repo.saveWorkBlock(
      WorkBlockDraft(
        taskId: task.id,
        startUtc: clock.wall.add(const Duration(minutes: 20)),
        endUtc: clock.wall.add(const Duration(minutes: 40)),
        planningZone: 'Asia/Manila',
      ),
    );
    await store.setRule(ReminderKind.work, b.id);
    await enable();
    await owner.reconcile();
    final row = (await store.registrations()).firstWhere(
      (r) => r.identityKey.endsWith('/work'),
    );
    expect(
      (await resolveReminder(store, 'momentum:${row.id}'))!.destination,
      Destination.plan,
    );
    expect(
      (await store.registrations())
          .firstWhere((r) => r.id == row.id)
          .openedAtUtc,
      clock.wall,
    );
    await repo.deleteWorkBlock(b.id);
    await owner.reconcile();
    expect(await resolveReminder(store, 'momentum:${row.id}'), isNull);
    expect((await repo.task(task.id)).deadlineUtc, task.deadlineUtc);
    await repo.deleteTask(task.id);
    expect(await resolveReminder(store, 'momentum:garbage'), isNull);
  });
  test('128 cap reserves timer slot, includes late pending, and reports actual coverage', () async {
    await repo.transaction(() async {
      for (var i = 0; i < 130; i++) {
        await deadline(title: 'Task $i', minutes: i + 1);
      }
    });
    final session = await TimerStore(repo).start(
      commandId: repo.ids(),
      sessionId: repo.ids(),
      kind: SessionKind.starter,
      minutes: 2,
      zone: 'Asia/Manila',
      now: clock.sample(),
    );
    await store.setRule(ReminderKind.timer, (await repo.installation()).id);
    await enable();
    await owner.reconcile();
    expect(native.items, hasLength(128));
    expect(
      native.items.values.where((t) => t.sessionId == session.id),
      hasLength(1),
    );
    expect(owner.view.plan!.truncated, 3);
    expect(owner.view.scheduledThrough, isNotNull);
    expect(
      owner.view.coverageThrough!.isBefore(owner.view.plan!.horizon),
      isTrue,
    );
    clock.advance(90000);
    await owner.reconcile();
    expect(native.items.length, lessThanOrEqualTo(128));
    expect((await TimerStore(repo).session(session.id)).reportedMs, isNull);
  });
  test('timer pause/end cancels alert; quiet timer suppression never credits or completes task', () async {
    final timerStore = TimerStore(repo);
    final s = await timerStore.start(
      commandId: repo.ids(),
      sessionId: repo.ids(),
      kind: SessionKind.focus,
      minutes: 25,
      zone: 'Asia/Manila',
      now: clock.sample(),
    );
    await store.setRule(ReminderKind.timer, (await repo.installation()).id);
    await enable();
    await owner.reconcile();
    expect(native.items, hasLength(1));
    await timerStore.apply(
      s.id,
      TimerAction.pause,
      clock.sample(),
      commandId: repo.ids(),
    );
    await owner.reconcile();
    expect(native.items, isEmpty);
    expect(
      await resolveReminder(
        store,
        'momentum:${(await store.registrations()).single.id}',
      ),
      isNull,
    );
    await timerStore.apply(
      s.id,
      TimerAction.resume,
      clock.sample(),
      commandId: repo.ids(),
    );
    await store.preferences(
      enabled: true,
      quietEnabled: true,
      start: 0,
      end: 1439,
    );
    await owner.reconcile();
    expect(native.items, isEmpty);
    expect((await timerStore.session(s.id)).reportedMs, isNull);
  });
  test('rule uniqueness, FK and enum checks; reminder migration preserves populated v7 and rollback', () async {
    final t = await deadline();
    final rule = await store.setRule(
      ReminderKind.deadline,
      t.id,
      leadMinutes: 5,
    );
    expect((await store.read()).rules, hasLength(1));
    await expectLater(
      store.db.customStatement(
        "UPDATE reminder_rules SET kind='bad' WHERE id=?",
        [rule.id],
      ),
      throwsA(anything),
    );
    await expectLater(
      store.db.customStatement(
        "UPDATE reminder_rules SET task_id='missing' WHERE id=?",
        [rule.id],
      ),
      throwsA(anything),
    );
    final oldFile = File('${fixture.directory.path}/v7.sqlite');
    createSchemaFixture(oldFile, version: 7);
    seedSchemaV1(oldFile);
    final seed = sql.sqlite3.open(oldFile.path);
    try {
      seed.execute('PRAGMA foreign_keys=ON');
      seed.execute(
        "INSERT INTO activity_series(id,created_at,updated_at,title,course_id,recurrence,weekdays,start_date,end_date,start_minute,end_minute,end_day_offset,zone,location,busy) VALUES ('00000000-0000-4000-8000-000000000021',1,1,'Old class',?,'once',0,'2026-10-22','2026-10-22',540,600,0,'Asia/Manila','Room',1)",
        [fixtureCourseId],
      );
      seed.execute(
        "INSERT INTO activity_exceptions(id,series_id,original_date,cancelled,created_at,updated_at) VALUES ('00000000-0000-4000-8000-000000000022','00000000-0000-4000-8000-000000000021','2026-10-22',1,1,1)",
      );
      seed.execute(
        "INSERT INTO note_activity_links(id,note_id,series_id,original_date,created_at) VALUES ('00000000-0000-4000-8000-000000000023',?,'00000000-0000-4000-8000-000000000021','2026-10-22',1)",
        [fixtureNoteId],
      );
      seed.execute(
        "INSERT INTO planned_work_blocks(id,created_at,updated_at,task_id,start_utc,end_utc,planning_zone,status,locked) VALUES ('00000000-0000-4000-8000-000000000024',1,1,?,1000,61000,'UTC','planned',1)",
        [fixtureTaskId],
      );
      seed.execute(
        "INSERT INTO focus_sessions(id,installation_id,task_id,subtask_id,title_snapshot,zone,local_start_date,started_utc,kind,state,outcome,planned_ms,elapsed_ms,eligible_ms,uncertain_ms,has_uncertainty,background,checkpoint_utc,elapsed_mark_ms,clock_epoch,revision,reported_ms,finalized_utc) VALUES ('00000000-0000-4000-8000-000000000025',?,?,?,'Old timer 🧬','UTC','2026-10-20',1000,'focus','finalized','stoppedEarly',60000,5000,5000,0,0,0,6000,5000,'old-process',2,5000,6000)",
        [fixtureInstallationId, fixtureTaskId, fixtureSubtaskId],
      );
      seed.execute(
        "INSERT INTO focus_segments(id,session_id,sequence,kind,from_utc,to_utc,span_ms,elapsed_ms,eligible_ms) VALUES ('00000000-0000-4000-8000-000000000026','00000000-0000-4000-8000-000000000025',1,'active',1000,6000,5000,5000,5000)",
      );
      seed.execute(
        "INSERT INTO timer_command_receipts(id,session_id,action,payload,committed_utc) VALUES ('00000000-0000-4000-8000-000000000027','00000000-0000-4000-8000-000000000025','finalize','[]',6000)",
      );
    } finally {
      seed.close();
    }
    final before = readEveryRow(oldFile);
    expect(before.values.every((rows) => (rows as List).isNotEmpty), isTrue);
    final failing = FailedReminderUpgrade(oldFile);
    await expectLater(
      failing.ensureOpen(),
      throwsA(
        predicate(
          (e) => e.toString().contains('Injected migration interruption'),
        ),
      ),
    );
    await failing.close();
    expect(readEveryRow(oldFile), before);
    final raw = sql.sqlite3.open(oldFile.path);
    expect(raw.select('PRAGMA user_version').single.values.single, 7);
    raw.close();
    final upgraded = AppDatabase.file(oldFile);
    await upgraded.ensureOpen();
    await upgraded.close();
    final after = readEveryRow(oldFile);
    expect(after.keys, hasLength(20));
    for (final entry in before.entries) {
      expect(after[entry.key], entry.value, reason: entry.key);
    }
    final expected = File('${fixture.directory.path}/v10.sqlite');
    createSchemaFixture(expected, version: 10);
    expect(readSchema(oldFile), readSchema(expected));
  });
}
