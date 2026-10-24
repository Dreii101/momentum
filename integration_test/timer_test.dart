import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'timer_restart_app.dart' as fixture;
import 'schedule_test.dart' show capture;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native timer development review, explicit credit and task preservation',
    (tester) async {
      final owner = await fixture.launchTimerFixture(
        name: 'phase8_ui_${DateTime.now().microsecondsSinceEpoch}',
      );
      await tester.pumpAndSettle();
      final taskId = owner.view.session!.taskId!;
      final before = await owner.store.repository.task(taskId);
      await tester.tap(find.byKey(const Key('open-development')));
      await tester.pumpAndSettle();
      final end = find.byKey(const Key('timer-end'));
      await tester.ensureVisible(end);
      await tester.tap(end);
      await tester.pumpAndSettle();
      expect(owner.view.session!.state, SessionState.awaitingReview);
      expect(owner.view.session!.reportedMs, isNull);
      await capture(tester, 'phase8-timer-review.png');
      final amount = find.byKey(const Key('timer-reported'));
      await tester.ensureVisible(amount);
      await tester.enterText(amount, '0');
      final confirmation = find.byKey(const Key('timer-confirm'));
      await tester.ensureVisible(confirmation);
      await tester.tap(confirmation);
      final finalize = find.byKey(const Key('timer-finalize'));
      await tester.ensureVisible(finalize);
      await tester.tap(finalize);
      await tester.pumpAndSettle();
      expect(owner.view.session!.state, SessionState.finalized);
      expect(owner.view.session!.reportedMs, 0);
      expect(await owner.store.repository.task(taskId), before);
      final support = await getApplicationSupportDirectory();
      await File(p.join(support.path, 'phase8-ui-result.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'platform': Platform.operatingSystem,
          'sessionId': owner.view.session!.id,
          'explicitZeroConfirmation': true,
          'taskUnchanged': true,
        }),
        flush: true,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
