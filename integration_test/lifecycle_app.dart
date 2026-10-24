// Explicit isolated OS lifecycle check. Ordinary builds never import this entry.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:momentum/features/focus/timer_engine.dart';

import 'focus_restart_app.dart';

Future<void> main() async {
  final owner = await launchFocusFixture(name: 'phase13_lifecycle');
  if ((await owner.store.repository.database
          .select(owner.store.repository.database.focusSessions)
          .get())
      .isEmpty) {
    final task = (await owner.store.repository.watchTasks().first).single;
    await owner.start(SessionKind.starter, taskId: task.id);
  }
  final directory = Directory(
    p.join((await getApplicationSupportDirectory()).path, 'phase13_lifecycle'),
  );
  Future<void> report() async {
    final session = owner.view.session;
    await File(p.join(directory.path, 'state.json')).writeAsString(
      jsonEncode({
        'pid': pid,
        'atUtc': DateTime.now().toUtc().toIso8601String(),
        'ready': owner.view.ready,
        'saving': owner.view.saving,
        'error': owner.view.error?.toString(),
        'id': session?.id,
        'state': session?.state.name,
        'outcome': session?.outcome?.name,
        'eligibleMs': session?.eligibleMs,
        'uncertainMs': session?.uncertainMs,
        'reportedMs': session?.reportedMs,
      }),
      flush: true,
    );
  }

  await report();
  // Serialize fixture reports so a slow write cannot replace a newer observation.
  owner.changes.asyncMap((_) => report()).listen(null);
}
