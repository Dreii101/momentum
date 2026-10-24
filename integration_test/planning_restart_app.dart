// Explicit isolated native verification entry, never imported by lib/main.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/migrations.dart' show scheduleV5Sql;
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/calendar/calendar_projection.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../test/support/schema_fixture.dart' show seedSchemaV1;
import 'task_schema_fixture.dart';
import 'notes_restart_app.dart' show sameRecords;
import 'schedule_restart_app.dart' show scheduleSnapshot;

Future<Map<String, Object?>> planningRows(AppDatabase db) async => {
  ...await scheduleSnapshot(db),
  'planned_work_blocks': [
    for (final r
        in await db
            .customSelect('SELECT * FROM planned_work_blocks ORDER BY id')
            .get())
      r.data,
  ],
};
Future<void> main() => launchPlanningFixture();
Future<void> launchPlanningFixture({
  String name = 'phase7_planning_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final folder = Directory(p.join(support.path, name));
  await folder.create(recursive: true);
  final file = File(p.join(folder.path, 'planning.sqlite'));
  final existed = await file.exists();
  final expected = File(p.join(folder.path, 'expected.json'));
  final report = File(p.join(folder.path, 'last-run.json'));
  if (!existed) {
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute('PRAGMA foreign_keys=ON');
      raw.execute('BEGIN');
      for (final statement in schemaV3Statements()) {
        raw.execute(statement);
      }
      raw.execute('ALTER TABLE tasks ADD COLUMN "archived_at" INTEGER NULL');
      raw.execute(
        'CREATE INDEX tasks_visibility ON tasks (deleted_at, archived_at)',
      );
      for (final statement in scheduleV5Sql) {
        raw.execute(statement);
      }
      raw.execute('PRAGMA user_version=5');
      raw.execute('COMMIT');
    } finally {
      raw.close();
    }
    seedSchemaV1(file);
    final old = sql.sqlite3.open(file.path);
    try {
      old.execute(
        "INSERT INTO activity_series(id,created_at,updated_at,title,recurrence,weekdays,start_date,end_date,start_minute,end_minute,end_day_offset,zone,location,busy) VALUES ('00000000-0000-4000-8000-000000000051',1,1,'Retained native activity','once',0,'2026-10-21','2026-10-21',600,660,0,'Asia/Manila','Room A',1)",
      );
      old.execute(
        "INSERT INTO activity_exceptions(id,series_id,original_date,cancelled,created_at,updated_at) VALUES ('00000000-0000-4000-8000-000000000052','00000000-0000-4000-8000-000000000051','2026-10-21',0,1,1)",
      );
      old.execute(
        "INSERT INTO note_activity_links(id,note_id,series_id,created_at) VALUES ('00000000-0000-4000-8000-000000000053','00000000-0000-4000-8000-000000000004','00000000-0000-4000-8000-000000000051',1)",
      );
    } finally {
      old.close();
    }
  }
  Map<String, Object?> rawRows() {
    final raw = sql.sqlite3.open(file.path);
    try {
      return {
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

  final before = existed ? null : rawRows();
  final db = AppDatabase.file(file);
  String? failure;
  try {
    await db.ensureOpen();
    final repo = MomentumRepository(
      db,
      clock: () => DateTime.utc(2026, 10, 20),
    );
    if (!existed) {
      final after = await scheduleSnapshot(db);
      if (!sameRecords(before, after)) {
        throw StateError('Original schema-5 records changed.');
      }
      await File(p.join(folder.path, 'migration.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'from': 5,
          'to': 6,
          'before': before,
          'after': after,
        }),
        flush: true,
      );
      final t = await repo.createTask(
        TaskDraft(
          title: 'Calendar essay 🧬',
          deadline: Deadline.dateOnly(
            CalendarDate(2026, 10, 23),
            'Asia/Manila',
          ),
          targetUtc: DateTime.utc(2026, 10, 22, 1),
          remainingMinutes: 90,
        ),
      );
      await repo.createTask(
        TaskDraft(
          title: 'All-day commitment',
          deadline: Deadline.dateOnly(
            CalendarDate(2026, 10, 21),
            'America/New_York',
          ),
        ),
      );
      await repo.createTask(
        TaskDraft(
          title: 'Timed commitment',
          deadline: Deadline.timed(
            DateTime.utc(2026, 10, 21, 5),
            'Asia/Manila',
          ),
        ),
      );
      final b = await repo.saveWorkBlock(
        WorkBlockDraft(
          taskId: t.id,
          startUtc: DateTime.utc(2026, 10, 21, 1),
          endUtc: DateTime.utc(2026, 10, 21, 1, 25),
          planningZone: 'Asia/Manila',
        ),
      );
      await repo.saveWorkBlock(
        WorkBlockDraft(
          taskId: t.id,
          startUtc: DateTime.utc(2026, 10, 21, 3),
          endUtc: DateTime.utc(2026, 10, 21, 3, 50),
          planningZone: 'Asia/Manila',
          locked: true,
        ),
        id: b.id,
      );
      await repo.deleteWorkBlock(b.id);
      await repo.deleteWorkBlock(b.id, deleted: false);
      if (await repo.task(t.id) != t) {
        throw StateError('Planning changed the task or deadline.');
      }
      await repo.saveWorkBlock(
        WorkBlockDraft(
          taskId: t.id,
          startUtc: DateTime.utc(2026, 10, 21, 15, 30),
          endUtc: DateTime.utc(2026, 10, 21, 16, 30),
          planningZone: 'Asia/Manila',
        ),
      );
      await repo.changeOccurrence(
        '00000000-0000-4000-8000-000000000051',
        CalendarDate(2026, 10, 21),
        move: OccurrenceMove(
          date: CalendarDate(2026, 10, 22),
          startMinute: 600,
          endMinute: 660,
          zone: 'Asia/Manila',
          location: 'Room B',
        ),
      );
      await File(p.join(folder.path, 'ids.json')).writeAsString(
        jsonEncode({'taskId': t.id, 'blockId': b.id}),
        flush: true,
      );
      await expected.writeAsString(
        jsonEncode(await planningRows(db)),
        flush: true,
      );
    } else if (!await expected.exists() ||
        !sameRecords(
          await planningRows(db),
          jsonDecode(await expected.readAsString()),
        )) {
      throw StateError('Saved planning data changed across processes.');
    }
    final data = await repo.planningSnapshot();
    final entries = projectCalendar(
      data,
      CalendarDate(2026, 10, 19),
      CalendarDate(2026, 10, 26),
      'Asia/Manila',
    );
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed
            ? 'verified-after-process-restart'
            : 'migrated-and-saved',
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schemaVersion': db.schemaVersion,
        'records': await planningRows(db),
        'calendar': [
          for (final e in entries)
            {
              'identity': e.identity,
              'title': e.title,
              'kind': e.kind.name,
              'start': e.start.toIso8601String(),
              'end': e.end.toIso8601String(),
              'day': e.day?.toString(),
            },
        ],
      }),
      flush: true,
    );
  } catch (e) {
    failure = e.toString();
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
      overrides: [
        databaseFileProvider.overrideWithValue(() async => file),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 21)),
        shellNavigationProvider.overrideWith(PlanningCheckNavigation.new),
      ],
      child: PlanningCheckApp(folder: folder),
    ),
  );
}

class PlanningCheckNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(destination: Destination.plan);
}

class PlanningCheckApp extends ConsumerWidget {
  const PlanningCheckApp({super.key, required this.folder});
  final Directory folder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(shellNavigationProvider, (previous, next) {
      File(p.join(folder.path, 'navigation.json')).writeAsString(
        jsonEncode({
          'pid': pid,
          'from': previous?.destination.name,
          'to': next.destination.name,
          'selected': {
            for (final e in next.selectedRecords.entries) e.key.name: e.value,
          },
        }),
        flush: true,
      );
    });
    return const MomentumApp();
  }
}
