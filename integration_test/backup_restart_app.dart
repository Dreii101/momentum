// Isolated native acceptance entry; ordinary builds never import this file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/recovery_snapshots.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/backup/backup_service.dart';
import 'package:momentum/features/backup/backup_data.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/backup_fixture.dart' show seedBackup;
import '../test/support/progress_fixture.dart' show fixtureWeek;

class _DataNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(
    destination: Destination.settings,
    selectedRecords: {Destination.settings: 'data'},
  );
}

Future<void> main() async {
  await launchBackupFixture();
}

Future<Directory> launchBackupFixture({
  String name = 'phase12_backup_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = Directory(
    p.join((await getApplicationSupportDirectory()).path, name),
  );
  await directory.create(recursive: true);
  final sourceFile = File(p.join(directory.path, 'source.sqlite'));
  final sourceExisted = await sourceFile.exists();
  final sourceDb = AppDatabase.file(sourceFile);
  final source = MomentumRepository(
    sourceDb,
    clock: () => DateTime.utc(2026, 10, 22, 8),
  );
  await initializeBackupStore(source);
  if (!sourceExisted) await seedBackup(source);
  final exporter = BackupService(
    source,
    sourceFile,
    RecoverySnapshots.forDatabase(sourceFile),
    BackupFiles(),
  );
  final transfer = File(p.join(directory.path, 'source-backup.json'));
  await transfer.writeAsBytes(await exporter.exportBytes(), flush: true);
  await sourceDb.close();

  final file = File(p.join(directory.path, 'destination.sqlite'));
  final existed = await file.exists();
  final db = AppDatabase.file(file),
      repo = MomentumRepository(db, clock: () => DateTime.utc(2026, 10, 22, 8));
  await initializeBackupStore(repo);
  if (!existed) {
    await repo.createNote(
      const NoteDraft(
        title: 'Original native fixture',
        body: 'Replacement is tested only in this isolated workspace.',
      ),
    );
  }
  Future<void> report() async {
    final s = await repo.progressSnapshot(fixtureWeek, 'Asia/Manila');
    await File(p.join(directory.path, 'last-run.json')).writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schema': db.schemaVersion,
        'installation': (await repo.installation()).id,
        'counts': {
          for (final e in (await readBackupData(repo)).entries)
            e.key: e.value.length,
        },
        'reportedMs': s.reportedMs,
        'reflection': s.reflection?.helped,
        'unfinished': s.sessions
            .where((r) => r.reportedMs == null)
            .map(
              (r) => {
                'id': r.id,
                'state': r.state.name,
                'outcome': r.outcome?.name,
              },
            )
            .toList(),
        'snapshots': RecoverySnapshots.forDatabase(file)
            .listSync()
            .map((f) => p.basename(f.path))
            .toList(),
      }),
      flush: true,
    );
  }

  await report();
  final subscription = db
      .customSelect(
        'SELECT 1 AS backup_fixture_changed',
        readsFrom: db.allTables.toSet(),
      )
      .watch()
      .asyncMap((_) => report())
      .listen(
        null,
        onError: (Object e) =>
            File(p.join(directory.path, 'report-error.txt'))
                .writeAsString('$e', flush: true),
      );
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWith((ref) {
          ref.onDispose(() {
            unawaited(subscription.cancel());
            unawaited(db.close());
          });
          return repo;
        }),
        databaseFileProvider.overrideWithValue(() async => file),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 22, 8)),
        shellNavigationProvider.overrideWith(_DataNavigation.new),
      ],
      child: const MomentumApp(showDevelopment: false),
    ),
  );
  return directory;
}
