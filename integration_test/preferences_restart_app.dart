// Explicit verification entry point; never imported by the production app.
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
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PreferencesCheckNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(destination: Destination.settings);
}

Future<Map<String, Object?>> savedPreferences(AppDatabase db) async => {
  'preferences':
      (await db.customSelect('SELECT * FROM app_settings').getSingle()).data,
  'installation':
      (await db.customSelect('SELECT * FROM installations').getSingle()).data,
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(
    p.join(support.path, 'phase3_preferences_checks'),
  );
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'preferences.sqlite'));
  final expected = File(p.join(directory.path, 'expected.json'));
  final report = File(p.join(directory.path, 'last-run.json'));
  final existed = await file.exists();
  final db = AppDatabase.file(file);
  String? failure;
  try {
    await db.ensureOpen();
    final repository = MomentumRepository(db);
    if (!existed) {
      await repository.initialize();
      await repository.updateSettings(
        theme: ThemePreference.dark,
        planningZone: 'Europe/London',
        focusMinutes: 40,
        breakMinutes: 7,
        reducedMotion: true,
      );
      await expected.writeAsString(
        jsonEncode(await savedPreferences(db)),
        flush: true,
      );
    } else {
      if (!await expected.exists() ||
          jsonEncode(await savedPreferences(db)) !=
              await expected.readAsString()) {
        throw StateError(
          'Reopened preferences differ from the original committed values.',
        );
      }
    }
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed ? 'verified-after-process-restart' : 'saved',
        'platform': Platform.operatingSystem,
        'pid': pid,
        'checkedAt': DateTime.now().toUtc().toIso8601String(),
        'schemaVersion': db.schemaVersion,
        'databasePath': file.path,
        ...await savedPreferences(db),
      }),
      flush: true,
    );
  } catch (error) {
    failure = error.toString();
    await report.writeAsString(
      jsonEncode({'status': 'FAILED', 'error': failure, 'pid': pid}),
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
        shellNavigationProvider.overrideWith(PreferencesCheckNavigation.new),
      ],
      child: const MomentumApp(),
    ),
  );
}
