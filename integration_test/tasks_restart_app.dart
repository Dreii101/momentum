// Explicit native acceptance fixture, excluded from the production entry point.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/tasks/task_workflow.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../test/support/schema_fixture.dart' show seedSchemaV1, fixtureTaskId;
import 'task_schema_fixture.dart';

Future<Map<String, Object?>> snapshot(AppDatabase db) async => {
  for (final table in [
    'courses',
    'tasks',
    'subtasks',
    'notes',
    'note_task_links',
    'daily_priorities',
    'app_settings',
    'installations',
  ])
    table: [
      for (final row
          in await db.customSelect('SELECT * FROM $table ORDER BY id').get())
        row.data,
    ],
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(p.join(support.path, 'phase4_task_checks'));
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'tasks.sqlite'));
  final expected = File(p.join(directory.path, 'expected.json'));
  final report = File(p.join(directory.path, 'last-run.json'));
  final existed = await file.exists();
  Map<String, Object?>? before;
  if (!existed) {
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute('PRAGMA foreign_keys = ON');
      raw.execute('BEGIN');
      for (final statement in schemaV3Statements()) {
        raw.execute(statement);
      }
      raw.execute('PRAGMA user_version = 3');
      raw.execute('COMMIT');
    } finally {
      raw.close();
    }
    seedSchemaV1(file);
    final old = sql.sqlite3.open(file.path);
    try {
      old.execute(
        'UPDATE app_settings SET focus_minutes = 41, break_minutes = 9, reduced_motion = 1',
      );
      before = {
        for (final table in [
          'courses',
          'tasks',
          'subtasks',
          'notes',
          'note_task_links',
          'daily_priorities',
          'app_settings',
          'installations',
        ])
          table: old
              .select('SELECT * FROM $table ORDER BY id')
              .map((r) => Map<String, Object?>.from(r))
              .toList(),
      };
    } finally {
      old.close();
    }
  }
  final db = AppDatabase.file(file);
  String? failure;
  try {
    await db.ensureOpen();
    final repo = MomentumRepository(db);
    if (!existed) {
      final migrated = await snapshot(db);
      final expectedMigration = Map<String, Object?>.from(before!);
      for (final task in expectedMigration['tasks']! as List) {
        (task as Map)['archived_at'] = null;
      }
      // Map key order may differ after ALTER; compare structured values.
      if (!_same(migrated, expectedMigration)) {
        throw StateError('Migration changed historical data.');
      }
      await File(p.join(directory.path, 'migration.json')).writeAsString(
        jsonEncode({
          'from': 3,
          'to': db.schemaVersion,
          'allEightTablesPreserved': true,
          'expectedAfterMigration': expectedMigration,
          'after': migrated,
        }),
        flush: true,
      );
      final row = await repo.createTask(
        TaskDraft(
          title: 'Phase 4 persisted task',
          description: '日本語 café 🧬',
          nextAction: 'Open the first question',
          deadline: Deadline.dateOnly(
            CalendarDate(2026, 11, 1),
            'America/New_York',
          ),
          targetUtc: DateTime.utc(2026, 10, 31, 10),
          remainingMinutes: 37,
          priority: TaskPriority.high,
        ),
      );
      final a = await repo.appendSubtask(row.id, 'Read the question');
      final b = await repo.appendSubtask(row.id, 'Write a first sentence');
      await repo.reorderSubtasks(row.id, [b.id, a.id]);
      await repo.updateSubtask(
        b.id,
        title: b.title,
        position: 0,
        completed: true,
      );
      await repo.setTaskStatus(row.id, TaskStatus.done);
      await repo.setTaskStatus(row.id, TaskStatus.todo);
      await repo.archiveTask(row.id);
      await repo.archiveTask(row.id, archived: false);
      await repo.deleteTask(row.id);
      await repo.deleteTask(row.id, deleted: false);
      final day = localDay(utcNow(), (await repo.settings()).planningZone);
      await repo.setDailyPriorities(day, [fixtureTaskId, row.id]);
      await expected.writeAsString(jsonEncode(await snapshot(db)), flush: true);
    } else {
      if (!await expected.exists() ||
          !_same(
            await snapshot(db),
            jsonDecode(await expected.readAsString()),
          )) {
        throw StateError(
          'Saved tasks, order, links, priorities or preferences changed across process restart.',
        );
      }
    }
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed
            ? 'verified-after-process-restart'
            : 'saved-after-migration',
        'platform': Platform.operatingSystem,
        'pid': pid,
        'checkedAt': utcNow().toIso8601String(),
        'schemaVersion': db.schemaVersion,
        'databasePath': file.path,
        'records': await snapshot(db),
      }),
      flush: true,
    );
  } catch (error) {
    failure = error.toString();
    await report.writeAsString(
      jsonEncode({'status': 'FAILED', 'pid': pid, 'error': failure}),
      flush: true,
    );
  } finally {
    await db.close();
  }
  if (failure != null) {
    runApp(MaterialApp(home: Scaffold(body: SelectableText(failure))));
    return;
  }
  runApp(
    ProviderScope(
      overrides: [databaseFileProvider.overrideWithValue(() async => file)],
      child: TaskCheckApp(directory: directory),
    ),
  );
}

bool _same(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((k) => b.containsKey(k) && _same(a[k], b[k]));
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        List.generate(a.length, (i) => i).every((i) => _same(a[i], b[i]));
  }
  return a == b;
}

class TaskCheckApp extends ConsumerWidget {
  const TaskCheckApp({super.key, required this.directory});
  final Directory directory;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(shellNavigationProvider, (previous, next) {
      final id = next.selectedRecords[Destination.tasks];
      if (previous?.destination == Destination.today &&
          next.destination == Destination.tasks &&
          id != null) {
        File(p.join(directory.path, 'navigation.json')).writeAsString(
          jsonEncode({
            'pid': pid,
            'platform': Platform.operatingSystem,
            'from': 'Today',
            'to': 'Tasks',
            'taskId': id,
            'checkedAt': utcNow().toIso8601String(),
          }),
          flush: true,
        );
      }
    });
    return const MomentumApp();
  }
}
