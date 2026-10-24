import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/recovery_snapshots.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/backup/backup_codec.dart';
import 'package:momentum/features/backup/backup_data.dart';
import 'package:momentum/features/backup/backup_service.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:momentum/features/reminders/reminder_coordinator.dart';
import 'package:momentum/features/reminders/reminder_store.dart';
import 'package:momentum/features/reminders/reminder_types.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/backup_fixture.dart';
import 'support/database_fixture.dart';
import 'support/progress_fixture.dart';
import 'support/schema_fixture.dart';
import 'support/fake_notifications.dart';
import 'calendar_test.dart' show readEveryRow;
import 'timer_engine_test.dart' show FakeTimerClock;

class NoSnapshotSpace extends RecoverySnapshots {
  NoSnapshotSpace(super.directory);
  @override
  Future<File> create(File source) async =>
      throw const FileSystemException('No space for recovery snapshot');
}

class GatedSnapshots extends RecoverySnapshots {
  GatedSnapshots(super.directory);
  final entered = Completer<void>(), proceed = Completer<void>();
  @override
  Future<File> create(File source) async {
    entered.complete();
    await proceed.future;
    return RecoverySnapshots(directory).create(source);
  }
}

class FailedUpgradeAfterSnapshot extends AppDatabase {
  FailedUpgradeAfterSnapshot(super.file) : super.file();
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement("UPDATE notes SET body='must roll back'");
    throw StateError('Injected migration failure after snapshot');
  }
}

Uint8List changedBackup(
  Uint8List original,
  void Function(Map<String, dynamic>) edit, {
  bool sign = true,
}) {
  final root = jsonDecode(utf8.decode(original)) as Map<String, dynamic>;
  edit(root);
  if (sign) {
    final payload = {
      for (final entry in (root['payload'] as Map).entries)
        entry.key as String: [
          for (final row in entry.value as List)
            Map<String, Object?>.from(row as Map),
        ],
    };
    root['payloadSha256'] = payloadDigest(payload);
  }
  return Uint8List.fromList(utf8.encode(jsonEncode(root)));
}

void main() {
  late DatabaseFixture sourceFixture, targetFixture;
  late MomentumRepository source, target;
  late BackupService exporter, importer;
  late MemoryBackupFiles files;
  setUp(() async {
    sourceFixture = await DatabaseFixture.create();
    targetFixture = await DatabaseFixture.create();
    source = MomentumRepository(
      sourceFixture.open(),
      clock: () => DateTime.utc(2026, 10, 22, 8),
    );
    target = MomentumRepository(
      targetFixture.open(),
      clock: () => DateTime.utc(2026, 10, 22, 8),
    );
    await seedBackup(source);
    await initializeBackupStore(target);
    files = MemoryBackupFiles();
    exporter = BackupService(
      source,
      sourceFixture.file,
      RecoverySnapshots.forDatabase(sourceFixture.file),
      files,
    );
    importer = BackupService(
      target,
      targetFixture.file,
      RecoverySnapshots.forDatabase(targetFixture.file),
      files,
    );
  });
  tearDown(() async {
    await sourceFixture.dispose();
    await targetFixture.dispose();
  });

  test('all portable sections validate; exclude installation, registration, receipt/cache data and global opt-in', () async {
    final identity = await source.installation(),
        bytes = await exporter.exportBytes();
    final preview = await BackupCodec.decode(bytes);
    expect(preview.payload.keys, unorderedEquals(backupTables));
    expect(preview.counts.values.every((n) => n > 0), isTrue);
    expect(preview.unfinished, 1);
    expect(utf8.decode(bytes), isNot(contains(identity.id)));
    expect(utf8.decode(bytes), isNot(contains('clock_epoch')));
    expect(utf8.decode(bytes), isNot(contains('notification_cleanup_rows')));
    expect(
      preview.payload['reminder_preferences_rows']!.single.containsKey(
        'enabled',
      ),
      isFalse,
    );
    expect(
      () => preview.payload['tasks']!.first['title'] = 'Mutated after preview',
      throwsUnsupportedError,
    );
  });

  test('portable back-and-forth preserves relationships, dates, totals and both installation identities through reopen', () async {
    await ReminderStore(source)
        .preferences(enabled: true, quietEnabled: false, start: 1320, end: 420);
    await target.createNote(
      const NoteDraft(title: 'Remove only on explicit replace'),
    );
    final identity = await target.installation(),
        settingsId = (await target.settings()).id;
    final expected = await readBackupData(source);
    final before = await source.progressSnapshot(fixtureWeek, 'Asia/Manila');
    final preview = await BackupCodec.decode(await exporter.exportBytes());
    final snapshot = await importer.replace(preview);
    expect(await snapshot.exists(), isTrue);
    expect((await target.installation()).id, identity.id);
    expect((await target.settings()).id, settingsId);
    final actual = await readBackupData(target);
    for (final table in backupTables.where((t) => t != 'focus_sessions')) {
      expect(actual[table], expected[table], reason: table);
    }
    final restored = await target.database
        .select(target.database.focusSessions)
        .get();
    expect(
      restored.where((s) => s.state != SessionState.finalized).single.state,
      SessionState.awaitingReview,
    );
    expect(
      restored.where((s) => s.state != SessionState.finalized).single.outcome,
      SessionOutcome.interrupted,
    );
    expect(restored.every((s) => s.installationId == identity.id), isTrue);
    final after = await target.progressSnapshot(fixtureWeek, 'Asia/Manila');
    expect(after.reportedMs, before.reportedMs);
    expect(after.tasks.length, before.tasks.length);
    expect(after.steps.length, before.steps.length);
    expect(
      (await target.database
              .select(target.database.reminderPreferencesRows)
              .getSingle())
          .enabled,
      isFalse,
    );
    final sourceIdentity = await source.installation();
    final originalSession = (await TimerStore(source).unfinished())!;
    await TimerStore(source).apply(
      originalSession.id,
      TimerAction.finalize,
      FakeTimerClock().sample(),
      commandId: source.ids(),
      reportedMs: 0,
      confirmed: true,
    );
    await exporter.replace(
      await BackupCodec.decode(await importer.exportBytes()),
    );
    expect((await source.installation()).id, sourceIdentity.id);
    expect(await readBackupData(source), actual);
    expect(
      (await source.database
              .select(source.database.reminderPreferencesRows)
              .getSingle())
          .enabled,
      isTrue,
    );
    await source.database.close();
    source = MomentumRepository(sourceFixture.open());
    expect(
      (await source.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
      before.reportedMs,
    );
    await target.database.close();
    target = MomentumRepository(targetFixture.open());
    expect(
      (await target.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
      before.reportedMs,
    );
    expect(
      (await target.progressSnapshot(
        fixtureWeek,
        'Asia/Manila',
      )).reflection!.helped,
      'Small starts 日本語',
    );
  });
  test('frozen JSON written by the real Windows picker restores the same records and credit', () async {
    final native = await BackupCodec.decode(
      await File('test/fixtures/momentum_backup_v1.json').readAsBytes(),
    );
    expect(native.total, 30);
    await importer.replace(native);
    expect(
      (await target.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
      390000,
    );
    expect(
      (await target.progressSnapshot(
        fixtureWeek,
        'Asia/Manila',
      )).reflection!.helped,
      'Small starts 日本語',
    );
  });

  test('corrupt, truncated, checksum and compatibility failures do not write current data', () async {
    final bytes = await exporter.exportBytes(),
        before = await readBackupData(target);
    for (final invalid in [
      Uint8List.fromList([255]),
      Uint8List.fromList(bytes.take(30).toList()),
      changedBackup(bytes, (r) => r['version'] = 2),
      changedBackup(bytes, (r) => r['schema'] = 999),
      changedBackup(bytes, (r) => r['version'] = 1.0),
      changedBackup(bytes, (r) => r['exportedAt'] = '2026-02-30T12:00:00Z'),
      changedBackup(
        bytes,
        (r) => r['payload']['notes'][0]['body'] = 'Checksum mismatch',
        sign: false,
      ),
      changedBackup(bytes, (r) => r['counts']['notes'] = 100),
    ]) {
      await expectLater(BackupCodec.decode(invalid), throwsFormatException);
    }
    expect(await readBackupData(target), before);
  });

  test('validators reject IDs, enums, text limits, dates, relationships, type coercion, durations and semantic mismatches', () async {
    final bytes = await exporter.exportBytes();
    final mutations = <void Function(Map<String, dynamic>)>[
      (r) => r['payload']['notes'][0]['id'] = 'invalid',
      (r) => r['payload']['tasks'][0]['status'] = 'invented',
      (r) => r['payload']['notes'][0]['body'] = 'x' * 100001,
      (r) => r['payload']['tasks'][0]['title'] = 'x' * 201,
      (r) => r['payload']['courses'][0]['term_start'] = '2026-02-30',
      (r) => r['payload']['note_task_links'][0]['note_id'] = newUuid(),
      (r) => r['payload']['subtasks'][0]['position'] = 0.5,
      (r) => r['payload']['planned_work_blocks'][0]['end_utc'] =
          r['payload']['planned_work_blocks'][0]['start_utc'],
      (r) => r['payload']['focus_sessions'][0]['planned_ms'] = 0,
      (r) => r['payload']['app_settings'][0]['planning_zone'] = 'Not/AZone',
      (r) => r['payload']['tasks'][0]['completed_at'] = null,
      (r) => r['payload']['activity_exceptions'][0]['original_date'] =
          '2026-10-20',
      (r) => r['payload']['focus_sessions'][0]['installation_id'] = newUuid(),
      (r) => r['payload']['app_settings'][0]['updated_at'] = 999999999999999999,
    ];
    // Select a completed task explicitly; row ordering is by UUID.
    mutations[10] = (r) {
      final row = (r['payload']['tasks'] as List).firstWhere(
        (t) => t['status'] == 'done',
      );
      row['completed_at'] = null;
    };
    for (var i = 0; i < mutations.length; i++) {
      await expectLater(
        BackupCodec.decode(changedBackup(bytes, mutations[i])),
        throwsFormatException,
        reason: 'mutation $i',
      );
    }
  });

  test(
    'last supported date-only deadline retains its exclusive next-day boundary',
    () async {
      final bytes = await exporter.exportBytes();
      final lastDate = changedBackup(bytes, (r) {
        final row = (r['payload']['tasks'] as List).firstWhere(
          (t) => t['deadline_kind'] == 'dateOnly',
        );
        row['deadline_date'] = '9999-12-31';
        row['deadline_zone'] = 'UTC';
        row['deadline_boundary_utc'] = DateTime.utc(10000)
            .millisecondsSinceEpoch;
      });
      final decoded = await BackupCodec.decode(lastDate);
      expect(
        decoded.payload['tasks']!.firstWhere(
          (t) => t['deadline_date'] == '9999-12-31',
        )['deadline_boundary_utc'],
        DateTime.utc(10000).millisecondsSinceEpoch,
      );
    },
  );

  test(
    '50 MiB streaming limit and 200,000-record limit; no read past cap',
    () async {
      var chunks = 0;
      Stream<List<int>> oversized() async* {
        for (var i = 0; i < 900; i++) {
          chunks++;
          yield Uint8List(65536);
        }
      }

      await expectLater(
        boundedBackupRead(BackupInput('large.json', oversized())),
        throwsFormatException,
      );
      expect(chunks, 801);
      await expectLater(
        boundedBackupRead(
          BackupInput(
            'reported-large.json',
            const Stream.empty(),
            length: maxBackupBytes + 1,
          ),
        ),
        throwsFormatException,
      );
      final bytes = await exporter.exportBytes();
      final tooMany = changedBackup(bytes, (r) {
        r['payload']['tasks'] = List.filled(
          maxBackupRecords + 1,
          <String, Object?>{},
        );
        r['counts']['tasks'] = maxBackupRecords + 1;
      });
      await expectLater(BackupCodec.decode(tooMany), throwsFormatException);
    },
  );

  test('picker cancellation is neutral; content URI and full storage never give false export success', () async {
    files.cancelPick = true;
    expect(await importer.inspect(), isNull);
    files.savedUri = null;
    expect(await exporter.export(), isNull);
    files.savedUri = Uri.parse('content://documents/backup.json');
    expect((await exporter.export())!.scheme, 'content');
    files.failSave = true;
    await expectLater(exporter.export(), throwsStateError);
    expect(
      (await target.database.select(target.database.notes).get()),
      isEmpty,
    );
  });

  test('failed replacement rolls back every original table; verified snapshots retain exactly three and can preview recovery', () async {
    await target.createNote(
      const NoteDraft(title: 'Original', body: 'Keep this 日本語'),
    );
    final before = readEveryRow(targetFixture.file),
        preview = await BackupCodec.decode(await exporter.exportBytes());
    await target.database.customStatement(
      "CREATE TRIGGER refuse_note BEFORE INSERT ON notes BEGIN SELECT RAISE(ABORT,'full disk fixture'); END",
    );
    await expectLater(importer.replace(preview), throwsA(anything));
    expect(readEveryRow(targetFixture.file), before);
    await target.database.customStatement('DROP TRIGGER refuse_note');
    for (var i = 0; i < 4; i++) {
      await importer.snapshots.create(targetFixture.file);
    }
    final snapshots = importer.snapshots.listSync();
    expect(snapshots, hasLength(3));
    final prior = await importer.inspectRecovery(snapshots.first);
    expect(prior.payload['notes']!.single['body'], 'Keep this 日本語');
    expect(readEveryRow(targetFixture.file), before);
    expect(importer.snapshots.listSync(), hasLength(3));
    // A wall-clock rollback must not prune the snapshot just created.
    snapshots.first.copySync(
      '${importer.snapshots.directory.path}/recovery-9999999999999999-abcdef.sqlite',
    );
    final newest = await importer.snapshots.create(targetFixture.file);
    expect(await newest.exists(), isTrue);
    expect(importer.snapshots.listSync().first.path, newest.path);
    expect(importer.snapshots.listSync(), hasLength(3));
  });

  test(
    'historical activities remain exportable after their course term changes',
    () async {
      final activity =
          (await source.database
                  .select(source.database.activitySeriesRows)
                  .get())
              .single;
      await (source.database.update(source.database.courses)
            ..where((c) => c.id.equals(activity.courseId!)))
          .write(CoursesCompanion(termEnd: Value(CalendarDate(2026, 10, 20))));
      expect(
        (await BackupCodec.decode(await exporter.exportBytes()))
            .counts['activity_series'],
        1,
      );
    },
  );

  test('snapshot storage failure blocks migration before any DDL or version change', () async {
    final directory = Directory(
      '${targetFixture.directory.path}/blocked-upgrade',
    )..createSync();
    final old = File('${directory.path}/old.sqlite');
    createSchemaFixture(old, version: 9);
    seedSchemaV1(old);
    final before = readEveryRow(old);
    File('${directory.path}/recovery')
        .writeAsStringSync('Cannot create snapshot directory');
    final db = AppDatabase.file(old);
    await expectLater(db.ensureOpen(), throwsA(anything));
    await db.close();
    expect(readEveryRow(old), before);
    final check = sql.sqlite3.open(old.path, mode: sql.OpenMode.readOnly);
    expect(check.userVersion, 9);
    check.close();
  });

  test('snapshot and replacement hold one writer reservation against another database connection', () async {
    final other = targetFixture.open();
    await other.ensureOpen();
    await other.customStatement('PRAGMA busy_timeout=0');
    final gate = GatedSnapshots(importer.snapshots.directory);
    final guarded = BackupService(target, targetFixture.file, gate, files);
    final replacing = guarded.replace(
      await BackupCodec.decode(await exporter.exportBytes()),
    );
    await gate.entered.future;
    try {
      await expectLater(
        MomentumRepository(
          other,
        ).createTask(const TaskDraft(title: 'Cannot enter the snapshot gap')),
        throwsA(predicate((e) => e.toString().contains('locked'))),
      );
    } finally {
      gate.proceed.complete();
    }
    expect(await (await replacing).exists(), isTrue);
    expect(
      (await target.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
      390000,
    );
  });

  test('snapshot failure aborts replacement before any deletion', () async {
    await target.createTask(const TaskDraft(title: 'Untouched'));
    final before = readEveryRow(targetFixture.file);
    final unavailable = BackupService(
      target,
      targetFixture.file,
      NoSnapshotSpace(importer.snapshots.directory),
      files,
    );
    await expectLater(
      unavailable.replace(
        await BackupCodec.decode(await exporter.exportBytes()),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(readEveryRow(targetFixture.file), before);
  });

  test('running and unreviewed current sessions block replacement; explicit finalization permits engine reload', () async {
    final clock = FakeTimerClock(),
        owner = TimerCoordinator(TimerStore(target), clock, period: null);
    await owner.initialize();
    await owner.start(SessionKind.focus);
    final preview = await BackupCodec.decode(await exporter.exportBytes());
    await expectLater(importer.replace(preview), throwsStateError);
    expect(importer.snapshots.listSync(), isEmpty);
    await owner.command(TimerAction.end);
    await expectLater(importer.replace(preview), throwsStateError);
    await owner.command(TimerAction.finalize, reportedMs: 0, confirmed: true);
    await owner.withDataReplacement(() => importer.replace(preview));
    expect(owner.view.session!.state, SessionState.awaitingReview);
    expect(owner.view.session!.outcome, SessionOutcome.interrupted);
    expect(owner.view.session!.reportedMs, isNull);
    await owner.close();
  });

  test('obsolete reminder cancellations survive restart/failure; retry follows commit without rolling back restored credit', () async {
    final ruleTask = await target.createTask(
      TaskDraft(
        title: 'Old reminder task',
        deadline: Deadline.timed(DateTime.utc(2026, 10, 23), 'UTC'),
      ),
    );
    final rule = await ReminderStore(target)
        .setRule(ReminderKind.deadline, ruleTask.id);
    await target.database
        .into(target.database.reminderRegistrations)
        .insert(
          ReminderRegistrationsCompanion.insert(
            id: newUuid(),
            ruleId: rule.id,
            identityKey: 'old',
            notificationId: 1000042,
            sourceUtc: DateTime.utc(2026, 10, 23),
            dueUtc: DateTime.utc(2026, 10, 23),
            fingerprint: 'old',
            state: RegistrationState.scheduled,
          ),
        );
    await importer.replace(
      await BackupCodec.decode(await exporter.exportBytes()),
    );
    await target.database.close();
    target = MomentumRepository(targetFixture.open());
    final native = FakeNotifications()..failCancel = true;
    final owner = ReminderCoordinator(
      ReminderStore(target),
      native,
      FakeTimerClock(),
      onResponse: (_) async {},
    );
    await owner.initialize();
    expect(owner.view.error, isNotNull);
    expect(owner.view.inputs, isNotNull);
    expect(
      await target.database
          .select(target.database.notificationCleanupRows)
          .get(),
      hasLength(1),
    );
    expect(
      (await target.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
      390000,
    );
    native.failCancel = false;
    await owner.reconcile();
    expect(
      await target.database
          .select(target.database.notificationCleanupRows)
          .get(),
      isEmpty,
    );
    expect(native.cancellations, 1);
    expect(native.permissions, 0);
    await owner.close();
    await native.callbacks.close();
  });

  test('migration snapshot is made before DDL, and failed migration preserves original records and version', () async {
    final old = File('${targetFixture.directory.path}/old-v9.sqlite');
    createSchemaFixture(old, version: 9);
    seedSchemaV1(old);
    final before = readEveryRow(old), failing = FailedUpgradeAfterSnapshot(old);
    await expectLater(
      failing.ensureOpen(),
      throwsA(
        predicate((e) => e.toString().contains('Injected migration failure')),
      ),
    );
    await failing.close();
    expect(readEveryRow(old), before);
    final snapshots = RecoverySnapshots.forDatabase(old).listSync();
    expect(snapshots, hasLength(1));
    final raw = sql.sqlite3.open(
      snapshots.single.path,
      mode: sql.OpenMode.readOnly,
    );
    expect(raw.userVersion, 9);
    raw.close();
    expect(readEveryRow(snapshots.single), before);
    final upgraded = AppDatabase.file(old);
    await upgraded.ensureOpen();
    await upgraded.close();
    expect(RecoverySnapshots.forDatabase(old).listSync(), hasLength(2));
    final actual = sql.sqlite3.open(old.path, mode: sql.OpenMode.readOnly);
    expect(actual.userVersion, 10);
    actual.close();
    expect(currentSchemaVersion, 10);
  });
}
