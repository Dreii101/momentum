// Isolated native acceptance entry; normal builds never import this file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:momentum/features/tasks/task_workflow.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'timer_restart_app.dart' show timerRows;

Future<void> main() async {
  await launchFocusFixture();
}

Future<TimerCoordinator> launchFocusFixture({
  String name = 'phase9_focus_checks',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(p.join(support.path, name));
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'focus.sqlite'));
  final existed = await file.exists();
  final db = AppDatabase.file(file);
  final repo = MomentumRepository(db);
  final owner = TimerCoordinator(
    TimerStore(repo),
    SystemTimerClock(wallClock: utcNow, epoch: newUuid()),
  );
  try {
    await repo.initialize();
    if (!existed) {
      final task = await repo.createTask(
        const TaskDraft(
          title: 'Make one small start',
          nextAction: 'Open the worksheet',
        ),
      );
      await repo.createSubtask(task.id, 'Read the first question');
      final note = await repo.createNote(
        const NoteDraft(
          title: 'Working notes',
          body: 'Writing stays separate from session credit.',
        ),
      );
      await repo.setNoteTaskLink(note.id, task.id, linked: true);
      await repo.setDailyPriorities(localDay(utcNow(), 'Asia/Manila'), [
        task.id,
      ]);
    }
    final before = await timerRows(db);
    await owner.initialize();
    await File(p.join(directory.path, 'last-run.json')).writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': owner.view.session?.outcome == SessionOutcome.interrupted
            ? 'recovered-for-review'
            : 'opened',
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schemaVersion': db.schemaVersion,
        'beforeRecovery': before,
        'records': await timerRows(db),
      }),
      flush: true,
    );
  } catch (e) {
    await File(p.join(directory.path, 'last-run.json')).writeAsString(
      jsonEncode({'status': 'FAILED', 'pid': pid, 'error': e.toString()}),
      flush: true,
    );
    await owner.close();
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
          ref.onDispose(owner.dispose);
          return owner;
        }),
      ],
      child: const MomentumApp(showDevelopment: false),
    ),
  );
  return owner;
}
