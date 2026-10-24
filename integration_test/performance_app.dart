// Explicit isolated measurement entry; never imported by the product entry.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/tasks/task_workflow.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  final dartStart = DateTime.now().toUtc();
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(p.join(support.path, 'phase13_performance'));
  await directory.create(recursive: true);
  final reports = Platform.isAndroid
      ? Directory(
          p.join(
            (await getExternalStorageDirectory())!.path,
            'phase13_performance',
          ),
        )
      : directory;
  await reports.create(recursive: true);
  final file = File(p.join(directory.path, 'reference.sqlite'));
  final container = ProviderContainer(
    overrides: [databaseFileProvider.overrideWithValue(() async => file)],
  );
  final repo = await container.read(repositoryProvider.future);
  final db = repo.database;
  final seeded = (await db.select(db.tasks).get()).isEmpty;
  if (seeded) {
    final now = DateTime.now().toUtc();
    await db.batch((b) {
      b.insertAll(db.tasks, [
        for (var i = 0; i < 1000; i++)
          TasksCompanion.insert(
            id: newUuid(),
            createdAt: now,
            updatedAt: now,
            title: 'Reference assignment $i',
            status: TaskStatus.todo,
            priority: TaskPriority.normal,
            deadlineKind: DeadlineKind.none,
          ),
      ]);
      b.insertAll(db.notes, [
        for (var i = 0; i < 250; i++)
          NotesCompanion.insert(
            id: newUuid(),
            createdAt: now,
            updatedAt: now,
            title: 'Reference lecture $i',
            body:
                '${'Class material. ' * 256}${i % 25 == 0 ? 'mitochondria' : ''}',
          ),
      ]);
    });
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MomentumApp(showDevelopment: false),
    ),
  );
  final settings = await container.read(settingsProvider.future);
  await container.read(timerCoordinatorProvider.future);
  final day = localDay(DateTime.now().toUtc(), settings.planningZone);
  await container.read(dailyTasksProvider(day).future);
  await container.read(upcomingTasksProvider.future);
  WidgetsBinding.instance.scheduleFrame();
  await WidgetsBinding.instance.endOfFrame;
  await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
  final readyAt = DateTime.now().toUtc();
  final dataset = await db
      .customSelect(
        'SELECT (SELECT count(*) FROM tasks) AS tasks, count(*) AS notes, sum(length(CAST(body AS BLOB))) AS body_bytes FROM notes',
      )
      .getSingle();
  final report = <String, Object?>{
    'pid': pid,
    'platform': Platform.operatingSystem,
    'osVersion': Platform.operatingSystemVersion,
    'buildMode': kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug',
    'schema': db.schemaVersion,
    'seededThisRun': seeded,
    'tasks': dataset.read<int>('tasks'),
    'notes': dataset.read<int>('notes'),
    'noteBodyUtf8Bytes': dataset.read<int>('body_bytes'),
    'dartStartUtc': dartStart.toIso8601String(),
    'readyUtc': readyAt.toIso8601String(),
    'dartToUsableFrameMs': readyAt.difference(dartStart).inMicroseconds / 1000,
    'scope': 'Process cold; OS file caches retained. Today data and timer opened, frame completed. Search includes background SQLite transport and row decoding, excludes UI painting.',
  };
  await File(p.join(reports.path, 'ready-$pid.json'))
      .writeAsString(jsonEncode(report), flush: true);
  final times = <double>[];
  final queries = <String>[];
  for (var i = 0; i < 21; i++) {
    final query = i == 0 ? 'mitochondria' : 'Reference lecture ${i + 100}';
    queries.add(query);
    final watch = Stopwatch()..start();
    final rows = await repo.watchNotes(search: query).first;
    if (rows.length != (i == 0 ? 10 : 1)) {
      throw StateError('Search fixture is inconsistent.');
    }
    times.add(watch.elapsedMicroseconds / 1000);
  }
  report['searchFirstMs'] = times.first;
  final warm = times.skip(1).toList()..sort();
  report['searchWarmMedianMs'] = (warm[9] + warm[10]) / 2;
  report['searchWarmP95Ms'] = warm[18];
  report['searchWarmMaxMs'] = warm.last;
  report['searchSamplesMs'] = times;
  report['searchQueries'] = queries;
  report['databaseBytes'] = await file.length();
  await File(p.join(reports.path, 'result-$pid.json')).writeAsString(
    const JsonEncoder.withIndent('  ').convert(report),
    flush: true,
  );
}
