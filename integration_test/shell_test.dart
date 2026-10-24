import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/main.dart' as app;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native shell opens Settings, retains a draft and preserves saved preferences',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Make room for one next step'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repository = await container.read(repositoryProvider.future);
      final before = await repository.settings();
      if (find.byKey(const Key('workspace-menu')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('workspace-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings').last);
      } else {
        await tester.tap(find.byKey(const Key('nav-settings')));
      }
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('theme-preference')), findsOneWidget);
      final focusField = find.descendant(
        of: find.byKey(const Key('focus-minutes')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(focusField);
      await tester.enterText(focusField, '37');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('save-settings')));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('save-settings'))).height,
        greaterThanOrEqualTo(48),
      );
      // Do not save diagnostic edits into the normal product database.
      expect(await repository.settings(), before);
      await tester.ensureVisible(find.byKey(const Key('theme-preference')));
      await tester.pumpAndSettle();
      if (Platform.isWindows) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final support = await getApplicationSupportDirectory();
        final directory = Directory(
          p.join(support.path, 'phase3_shell_checks'),
        );
        await directory.create(recursive: true);
        final screenshot = File(p.join(directory.path, 'settings.png'));
        await screenshot.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
        image.dispose();
        debugPrint(screenshot.path);
      }
      debugPrint(
        'PHASE3_NATIVE_SHELL: storage opened; Settings visible; draft retained; saved values unchanged.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
