// Explicit diagnostic entry. Never imported by the production app.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../test/support/schema_fixture.dart'
    show seedSchemaV1, readAllFixtureData;
import 'task_schema_fixture.dart';
import 'notes_restart_app.dart' show sameRecords, noteSnapshot;

Future<Map<String, Object?>> scheduleSnapshot(AppDatabase db) async => {
  ...await noteSnapshot(db),
  for (final table in [
    'activity_series',
    'activity_exceptions',
    'note_activity_links',
  ])
    table: [
      for (final row
          in await db.customSelect('SELECT * FROM $table ORDER BY id').get())
        row.data,
    ],
};
Future<void> main() => launchScheduleFixture();
Future<void> launchScheduleFixture({
  String name = 'phase6_schedule_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final folder = Directory(p.join(support.path, name));
  await folder.create(recursive: true);
  final file = File(p.join(folder.path, 'schedule.sqlite'));
  final expected = File(p.join(folder.path, 'expected.json'));
  final report = File(p.join(folder.path, 'last-run.json'));
  final existed = await file.exists();
  Map<String, Object?>? before;
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
      raw.execute('PRAGMA user_version=4');
      raw.execute('COMMIT');
    } finally {
      raw.close();
    }
    seedSchemaV1(file);
    before = readAllFixtureData(file);
  }
  final db = AppDatabase.file(file);
  String? failure;
  try {
    await db.ensureOpen();
    final repo = MomentumRepository(
      db,
      clock: () => DateTime.utc(2026, 10, 20),
    );
    if (!existed) {
      final migrated = await noteSnapshot(db);
      if (!sameRecords(before, migrated)) {
        throw StateError('Schema4 records changed during upgrade.');
      }
      await File(p.join(folder.path, 'migration.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'from': 4,
          'to': 5,
          'before': before,
          'after': migrated,
        }),
        flush: true,
      );
      final c = await repo.createCourse(
        CourseDraft(
          name: 'Schedule course',
          termStart: CalendarDate(2026, 10, 1),
          termEnd: CalendarDate(2026, 12, 31),
        ),
      );
      final s = await repo.createActivity(
        ActivityDraft(
          title: 'Native class',
          courseId: c.id,
          startDate: CalendarDate(2026, 10, 19),
          endDate: CalendarDate(2026, 11, 30),
          weekdays: 5,
          startMinute: 540,
          endMinute: 600,
          zone: 'Asia/Manila',
          location: 'Room A',
        ),
      );
      final n = await repo.createNote(
        NoteDraft(
          title: 'Schedule note 🧬',
          body: 'Original class material 日本語',
          courseId: c.id,
        ),
      );
      final day = CalendarDate(2026, 10, 21),
          splitDay = CalendarDate(2026, 10, 26);
      await repo.setActivityLink(n.id, s.id, null, linked: true);
      await repo.setActivityLink(n.id, s.id, day, linked: true);
      await repo.setActivityLink(n.id, s.id, splitDay, linked: true);
      await repo.changeOccurrence(
        s.id,
        day,
        move: OccurrenceMove(
          date: CalendarDate(2026, 10, 22),
          startMinute: 540,
          endMinute: 600,
          zone: 'Asia/Manila',
          location: 'Room B',
        ),
      );
      await repo.changeOccurrence(s.id, splitDay, cancelled: true);
      final preview = await repo.previewSplit(s.id, splitDay);
      final next = await repo.replaceFuture(
        preview,
        ActivityDraft(
          title: 'Replacement class',
          courseId: c.id,
          startDate: splitDay,
          endDate: CalendarDate(2026, 11, 30),
          weekdays: 5,
          startMinute: 600,
          endMinute: 660,
          zone: 'Asia/Manila',
          location: 'Room C',
        ),
      );
      await repo.archiveCourse(c.id);
      await File(p.join(folder.path, 'ids.json')).writeAsString(
        jsonEncode({
          'courseId': c.id,
          'seriesId': s.id,
          'noteId': n.id,
          'replacementId': next.id,
        }),
        flush: true,
      );
      await expected.writeAsString(
        jsonEncode(await scheduleSnapshot(db)),
        flush: true,
      );
    } else if (!await expected.exists() ||
        !sameRecords(
          await scheduleSnapshot(db),
          jsonDecode(await expected.readAsString()),
        )) {
      throw StateError(
        'Schedule, note links or original data changed across process restart.',
      );
    }
    final data = await repo.scheduleSnapshot();
    final occurrences = generateOccurrences(
      data,
      DateTime.utc(2026, 10, 18),
      DateTime.utc(2026, 11, 1),
    );
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed
            ? 'verified-after-process-restart'
            : 'migrated-and-saved',
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schemaVersion': db.schemaVersion,
        'records': await scheduleSnapshot(db),
        'occurrences': [
          for (final o in occurrences)
            {
              'identity': o.identity,
              'start': o.start.toIso8601String(),
              'end': o.end.toIso8601String(),
              'cancelled': o.cancelled,
              'moved': o.moved,
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
        shellNavigationProvider.overrideWith(ScheduleCheckNavigation.new),
      ],
      child: ScheduleCheckApp(folder: folder),
    ),
  );
}

class ScheduleCheckNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(
    destination: Destination.plan,
    selectedRecords: {Destination.plan: 'timetable'},
  );
}

class ScheduleCheckApp extends ConsumerWidget {
  const ScheduleCheckApp({super.key, required this.folder});
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
