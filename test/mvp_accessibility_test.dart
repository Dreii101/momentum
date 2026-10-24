import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';

import 'adaptive_shell_test.dart' show pumpShell;

void main() {
  testWidgets('MVP destinations at 200% text expose labelled touch controls', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = await pumpShell(tester, textScale: 2, diagnostics: false);
    for (final brightness in [Brightness.light, Brightness.dark]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      for (final width in [320.0, 700.0, 1280.0]) {
        tester.view.physicalSize = Size(width, 1100);
        for (final destination in Destination.values) {
          h.container.read(shellNavigationProvider.notifier).go(destination);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$destination/$width/$brightness',
          );
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        }
      }
    }
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
    h.container.read(shellNavigationProvider.notifier).go(Destination.tasks);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNotNull);
    expect(FocusManager.instance.primaryFocus!.context, isNotNull);
    semantics.dispose();
  });
}
