// Explicit isolated acceptance entry; ordinary builds never import it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/migrations.dart'
    show scheduleV5Sql, planningV6Sql;
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../test/support/schema_fixture.dart'
    show seedSchemaV1, fixtureTaskId, fixtureSubtaskId;
import 'task_schema_fixture.dart';
import 'planning_restart_app.dart' show planningRows;
import 'notes_restart_app.dart' show sameRecords;

Future<Map<String, Object?>> timerRows(AppDatabase db) async => {
  ...await planningRows(db),
  for (final name in [
    'focus_sessions',
    'focus_segments',
    'timer_command_receipts',
  ])
    name: [
      for (final r
          in await db.customSelect('SELECT * FROM $name ORDER BY id').get())
        r.data,
    ],
};
Future<void> main() async {
  await launchTimerFixture();
}

Future<TimerCoordinator> launchTimerFixture({
  String name = 'phase8_timer_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final folder = Directory(p.join(support.path, name));
  await folder.create(recursive: true);
  final file = File(p.join(folder.path, 'timer.sqlite'));
  final existed = await file.exists();
  if (!existed) {
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute('BEGIN');
      for (final statement in schemaV3Statements()) {
        raw.execute(statement);
      }
      raw.execute('ALTER TABLE tasks ADD COLUMN "archived_at" INTEGER NULL');
      raw.execute(
        'CREATE INDEX tasks_visibility ON tasks (deleted_at, archived_at)',
      );
      for (final statement in [...scheduleV5Sql, ...planningV6Sql]) {
        raw.execute(statement);
      }
      raw.execute('PRAGMA user_version=6');
      raw.execute('COMMIT');
    } finally {
      raw.close();
    }
    seedSchemaV1(file);
  }
  final baseline = File(p.join(folder.path, 'baseline.json'));
  final checkpoint = File(p.join(folder.path, 'checkpoint.json'));
  Map<String, Object?>? oldRows;
  if (!existed) {
    final raw = sql.sqlite3.open(file.path);
    try {
      oldRows = {
        for (final t in raw.select(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
        ))
          t['name'] as String: raw
              .select('SELECT * FROM "${t['name']}" ORDER BY id')
              .map((r) => Map<String, Object?>.from(r))
              .toList(),
      };
    } finally {
      raw.close();
    }
  }
  final db = AppDatabase.file(file);
  final repo = MomentumRepository(db);
  final coordinator = TimerCoordinator(
    TimerStore(repo),
    SystemTimerClock(wallClock: utcNow, epoch: newUuid()),
    period: null,
  );
  try {
    await db.ensureOpen();
    if (!existed) {
      final migrated = await planningRows(db);
      if (!sameRecords(oldRows, migrated)) {
        throw StateError('Previous records changed in timer migration.');
      }
      await File(p.join(folder.path, 'migration.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'from': 6,
          'to': 7,
          'before': oldRows,
          'after': migrated,
        }),
        flush: true,
      );
      await baseline.writeAsString(jsonEncode(migrated), flush: true);
    } else if (!sameRecords(
      await planningRows(db),
      jsonDecode(await baseline.readAsString()),
    )) {
      throw StateError('Earlier task/note/schedule data changed.');
    }
    final beforeRecovery = existed ? await timerRows(db) : null;
    await coordinator.initialize();
    Map<String, Object?>? recovered;
    if (!existed) {
      await coordinator.start(SessionKind.rest, minutes: 1);
      await coordinator.command(TimerAction.end);
      await coordinator.command(
        TimerAction.finalize,
        reportedMs: 0,
        confirmed: true,
      );
      await coordinator.start(
        SessionKind.focus,
        minutes: 1,
        taskId: fixtureTaskId,
        subtaskId: fixtureSubtaskId,
      );
      await Future<void>.delayed(const Duration(milliseconds: 5200));
      await coordinator.checkpoint();
      await checkpoint.writeAsString(
        jsonEncode(await timerRows(db)),
        flush: true,
      );
    } else {
      final current = coordinator.view.session!;
      if (current.state != SessionState.awaitingReview ||
          current.outcome != SessionOutcome.interrupted ||
          current.reportedMs != null) {
        throw StateError('Interrupted timer was not recovered for review.');
      }
      final saved =
          jsonDecode(await checkpoint.readAsString()) as Map<String, dynamic>;
      final previous = (beforeRecovery!['focus_sessions'] as List)
          .cast<Map>()
          .singleWhere((r) => r['id'] == current.id);
      final firstCheckpoint = (saved['focus_sessions'] as List)
          .cast<Map>()
          .singleWhere((r) => r['id'] == current.id);
      if (current.eligibleMs != previous['eligible_ms'] ||
          current.eligibleMs < (firstCheckpoint['eligible_ms'] as int) ||
          current.elapsedMs < previous['elapsed_ms'] ||
          current.elapsedMs > current.plannedMs ||
          !current.hasUncertainty) {
        throw StateError(
          'Recovery changed eligible time or exceeded the endpoint.',
        );
      }
      final now = await timerRows(db);
      for (final row
          in (beforeRecovery['focus_sessions'] as List).cast<Map>().where(
            (r) => r['id'] != current.id,
          )) {
        final retained = (now['focus_sessions'] as List)
            .cast<Map>()
            .singleWhere((r) => r['id'] == row['id']);
        if (!sameRecords(row, retained)) {
          throw StateError('Finalized history changed.');
        }
      }
      for (final table in ['focus_segments', 'timer_command_receipts']) {
        for (final old in (beforeRecovery[table] as List).cast<Map>()) {
          final retained = (now[table] as List).cast<Map>().singleWhere(
            (r) => r['id'] == old['id'],
          );
          if (!sameRecords(old, retained)) {
            throw StateError('Saved timer ledger or command was lost.');
          }
        }
      }
      recovered = {
        'state': current.state.name,
        'outcome': current.outcome!.name,
        'eligibleMs': current.eligibleMs,
        'uncertainMs': current.uncertainMs,
        'reportedMs': current.reportedMs,
      };
    }
    await File(p.join(folder.path, 'last-run.json')).writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed
            ? 'recovered-after-process-restart'
            : 'checkpoint-saved-running',
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schemaVersion': db.schemaVersion,
        'beforeRecovery': beforeRecovery,
        'recovered': recovered,
        'records': await timerRows(db),
      }),
      flush: true,
    );
  } catch (e) {
    await File(p.join(folder.path, 'last-run.json')).writeAsString(
      jsonEncode({'status': 'FAILED', 'pid': pid, 'error': e.toString()}),
      flush: true,
    );
    await coordinator.close();
    await db.close();
    rethrow;
  }
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWith((ref) {
          ref.onDispose(() => db.close());
          return repo;
        }),
        timerCoordinatorProvider.overrideWith((ref) {
          ref.onDispose(coordinator.dispose);
          return coordinator;
        }),
      ],
      child: const MomentumApp(),
    ),
  );
  return coordinator;
}
