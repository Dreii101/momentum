// Explicit native verification entry point. Never included by lib/main.dart.
// Run twice as separate OS processes, preserving the directory between runs.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/database_fixture.dart' show seedRecords;

const fixtureTables = [
  'courses',
  'tasks',
  'subtasks',
  'notes',
  'note_task_links',
  'daily_priorities',
  'app_settings',
  'installations',
];

Future<Map<String, Object>> readRecords(AppDatabase db) async => {
  for (final table in fixtureTables)
    table: (await db.customSelect('SELECT * FROM $table ORDER BY id').get())
        .map((row) => row.data)
        .toList(),
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = Directory(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'phase2_storage_checks',
    ),
  );
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'restart.sqlite'));
  final expected = File(p.join(directory.path, 'expected.json'));
  final report = File(p.join(directory.path, 'last-run.json'));
  final existed = await file.exists();
  final db = AppDatabase.file(file);
  String status;
  try {
    final repository = MomentumRepository(db);
    await db.ensureOpen();
    if (!existed) {
      await seedRecords(repository);
      await expected.writeAsString(
        jsonEncode(await readRecords(db)),
        flush: true,
      );
      status = 'seeded';
    } else {
      // Reopen is read-only: never reseed, repair or overwrite the expected data.
      if (!await expected.exists()) {
        throw StateError('Missing external fixture reference.');
      }
      final saved = await expected.readAsString();
      if (jsonEncode(await readRecords(db)) != saved) {
        throw StateError(
          'Reopened records differ from the original committed fixture.',
        );
      }
      status = 'verified-after-process-restart';
    }
    final records = await readRecords(db);
    final result = {
      'status': status,
      'platform': Platform.operatingSystem,
      'pid': pid,
      'checkedAt': DateTime.now().toUtc().toIso8601String(),
      'databasePath': file.path,
      'schemaVersion': db.schemaVersion,
      'counts': {
        for (final entry in records.entries)
          entry.key: (entry.value as List).length,
      },
      'records': records,
    };
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result),
      flush: true,
    );
    debugPrint('PHASE2_STORAGE: $status; report=${report.path}');
  } catch (error, stack) {
    status = 'FAILED: $error';
    await report.writeAsString(
      jsonEncode({'status': status, 'pid': pid, 'stack': stack.toString()}),
      flush: true,
    );
  } finally {
    await db.close();
  }
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Phase 2 native storage check\n$status\n${report.path}',
            ),
          ),
        ),
      ),
    ),
  );
}
