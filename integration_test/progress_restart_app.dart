// Isolated acceptance entry. Ordinary builds never import this fixture.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/progress_fixture.dart';

class _ProgressNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(destination: Destination.progress);
}

Future<void> main() => launchProgressFixture();

Future<void> launchProgressFixture({
  String name = 'phase11_progress_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(p.join(support.path, name));
  await directory.create(recursive: true);
  final db = AppDatabase.file(File(p.join(directory.path, 'progress.sqlite')));
  final repo = MomentumRepository(
    db,
    clock: () => DateTime.utc(2026, 10, 22, 8),
  );
  await repo.initialize();
  if ((await db.select(db.tasks).get()).isEmpty) await seedProgress(repo);
  Future<void> report(ProgressSnapshot s) =>
      File(p.join(directory.path, 'last-run.json'))
          .writeAsString(
            const JsonEncoder.withIndent('  ').convert({
              'pid': pid,
              'platform': Platform.operatingSystem,
              'schema': db.schemaVersion,
              'week': '$fixtureWeek',
              'tasks': s.tasks.length,
              'steps': s.steps.length,
              'reportedMs': s.reportedMs,
              'sessionIds': s.sessions.map((r) => r.id).toList(),
              'reflection': s.reflection == null
                  ? null
                  : {
                      'id': s.reflection!.id,
                      'helped': s.reflection!.helped,
                      'obstacles': s.reflection!.obstacles,
                      'adjustment': s.reflection!.adjustment,
                    },
            }),
            flush: true,
          )
          .then((_) {});
  await report(await repo.progressSnapshot(fixtureWeek, 'Asia/Manila'));
  final subscription = repo
      .watchProgress(fixtureWeek, 'Asia/Manila')
      .asyncMap(report)
      .listen(
        null,
        onError: (Object error) =>
            File(p.join(directory.path, 'report-error.txt'))
                .writeAsString('$error', flush: true),
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
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 22, 8)),
        shellNavigationProvider.overrideWith(_ProgressNavigation.new),
      ],
      child: const MomentumApp(showDevelopment: false),
    ),
  );
}
