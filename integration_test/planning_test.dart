import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'planning_restart_app.dart' as fixture;
import 'schedule_test.dart' show capture;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native manual work edit, cross-view projection and unchanged task deadline',
    (tester) async {
      await fixture.launchPlanningFixture(
        name: 'phase7_ui_${DateTime.now().microsecondsSinceEpoch}',
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repo = await container.read(repositoryProvider.future);
      final data = await repo.planningSnapshot();
      final t = data.tasks.singleWhere((t) => t.title == 'Calendar essay 🧬');
      final b = data.blocks.singleWhere((b) => b.locked);
      await capture(tester, 'phase7-calendar-week.png');
      final agenda = find.byKey(const Key('calendar-view-agenda'));
      await tester.ensureVisible(agenda);
      await tester.tap(agenda);
      await tester.pumpAndSettle();
      final block = find.byKey(ValueKey('calendar-work/${b.id}'));
      await tester.ensureVisible(block);
      await tester.tap(block);
      await tester.pumpAndSettle();
      final length = find.byKey(const Key('work-length'));
      await tester.ensureVisible(length);
      await tester.enterText(length, '75');
      final save = find.byKey(const Key('save-work'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        (await repo.workBlock(b.id)).endUtc.difference(b.startUtc).inMinutes,
        75,
      );
      expect(await repo.task(t.id), t);
      final back = find.byKey(const Key('calendar-back'));
      await tester.ensureVisible(back);
      await tester.tap(back);
      await tester.pumpAndSettle();
      final day = find.byKey(const Key('calendar-view-day'));
      await tester.ensureVisible(day);
      await tester.tap(day);
      await tester.pumpAndSettle();
      await tester.ensureVisible(block);
      await tester.tap(block);
      await tester.pumpAndSettle();
      await capture(tester, 'phase7-work-panel.png');
      final open = find.byKey(const Key('work-open-task'));
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(
        container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.tasks],
        t.id,
      );
      final support = await getApplicationSupportDirectory();
      await File(p.join(support.path, 'phase7-ui-result.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'platform': Platform.operatingSystem,
          'taskId': t.id,
          'blockId': b.id,
          'minutes': 75,
          'deadlineUnchanged': true,
          'sourceNavigation': true,
        }),
        flush: true,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
