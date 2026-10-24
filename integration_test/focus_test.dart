import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'focus_restart_app.dart';
import 'schedule_test.dart' show capture;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native task starter continue pause review and recent history', (
    tester,
  ) async {
    final owner = await launchFocusFixture(
      name: 'phase9_ui_${DateTime.now().microsecondsSinceEpoch}',
    );
    await tester.pumpAndSettle();
    final task = (await owner.store.repository.watchTasks().first).single;
    final before = await owner.store.repository.task(task.id);
    Future<void> tap(String key) async {
      final target = find.byKey(Key(key));
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    Future<void> review() async {
      final field = find.byKey(const Key('focus-reported'));
      await tester.ensureVisible(field);
      await tester.enterText(field, '0');
      await tap('focus-confirm');
      await tap('focus-save-review');
    }

    await tap('start-${task.id}');
    expect(owner.view.session, isNull);
    await capture(tester, 'phase9-native-starter.png');
    await tap('focus-start');
    final starter = owner.view.session!;
    expect(starter.kind, SessionKind.starter);
    await Future<void>.delayed(const Duration(milliseconds: 5200));
    await owner.checkpoint();
    await tester.pumpAndSettle();
    await tap('focus-end');
    await review();
    await tap('continue-10');
    expect(owner.view.session!.kind, SessionKind.focus);
    final focus = owner.view.session!;
    await tap('focus-pause-resume');
    await capture(tester, 'phase9-native-paused.png');
    await tap('focus-open-task');
    await tap('return-to-session');
    expect(owner.view.session!.state, SessionState.paused);
    await tap('focus-pause-resume');
    await tap('focus-end');
    await capture(tester, 'phase9-native-review.png');
    await review();
    await tap('focus-history');
    expect(find.byKey(ValueKey('history-${starter.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('history-${focus.id}')), findsOneWidget);
    expect(await owner.store.repository.task(task.id), before);
    await capture(tester, 'phase9-native-history.png');
    final support = await getApplicationSupportDirectory();
    await File(p.join(support.path, 'phase9-ui-result.json')).writeAsString(
      jsonEncode({
        'status': 'PASS',
        'platform': Platform.operatingSystem,
        'clock': 'real Stopwatch and UTC',
        'starterId': starter.id,
        'focusId': focus.id,
        'explicitZeroCredit': true,
        'taskUnchanged': true,
        'historyCount': 2,
      }),
      flush: true,
    );
    expect(tester.takeException(), isNull);
  });
}
