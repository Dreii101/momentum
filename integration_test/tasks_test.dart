import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tasks_restart_app.dart' as acceptance;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native Today Start opens saved task details without changing stored data',
    (tester) async {
      await acceptance.main();
      await tester.pumpAndSettle();
      expect(find.text('2 of 3 selected'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repo = await container.read(repositoryProvider.future);
      final before = await acceptance.snapshot(repo.database);
      await tester.tap(find.text('Start').first);
      await tester.pumpAndSettle();
      expect(
        container.read(shellNavigationProvider).destination,
        Destination.tasks,
      );
      expect(find.byKey(const Key('task-detail-title')), findsOneWidget);
      expect(find.text('Begin with something small'), findsOneWidget);
      final title = find.byKey(const Key('task-title'));
      await tester.ensureVisible(title);
      await tester.enterText(title, 'Native unsaved draft');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(title).controller!.text,
        'Native unsaved draft',
      );
      expect(await acceptance.snapshot(repo.database), before);
      if (Platform.isWindows) {
        await tester.ensureVisible(find.byKey(const Key('task-detail-title')));
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final support = await getApplicationSupportDirectory();
        await File(
          p.join(support.path, 'phase4_task_checks', 'task-detail.png'),
        ).writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
        image.dispose();
      }
      debugPrint(
        'PHASE4_NATIVE_TASK: Today -> Start -> saved details; draft input retained; stored data unchanged.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
