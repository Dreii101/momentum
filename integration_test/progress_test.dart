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
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/progress_fixture.dart';
import 'progress_restart_app.dart' as acceptance;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native progress: fixture totals, correction and reflection', (
    tester,
  ) async {
    await acceptance.main();
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AdaptiveShell)),
    );
    final repo = await container.read(repositoryProvider.future);
    final before = await repo.progressSnapshot(fixtureWeek, 'Asia/Manila');
    expect(
      find.text(
        'Reported focus time: ${before.reportedMs ~/ 60000}:${((before.reportedMs ~/ 1000) % 60).toString().padLeft(2, '0')}',
      ),
      findsOneWidget,
    );
    final starter = before.sessions.firstWhere(
      (s) => s.kind == SessionKind.starter,
    );
    container
        .read(shellNavigationProvider.notifier)
        .selectRecord(Destination.progress, starter.id);
    await tester.pumpAndSettle();
    final correction = find.byKey(const Key('progress-correction'));
    await tester.ensureVisible(correction);
    await tester.enterText(correction, '60');
    await tester.ensureVisible(find.byKey(const Key('progress-confirm')));
    await tester.tap(find.byKey(const Key('progress-confirm')));
    await tester.ensureVisible(
      find.byKey(const Key('progress-save-correction')),
    );
    await tester.tap(find.byKey(const Key('progress-save-correction')));
    await tester.pumpAndSettle();
    expect(find.text('Correction saved'), findsOneWidget);
    final reflection = find.byKey(const Key('reflection-helped'));
    await tester.ensureVisible(reflection);
    await tester.enterText(reflection, 'Native saved reflection 日本語');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(find.byKey(const Key('reflection-save')));
    await tester.tap(find.byKey(const Key('reflection-save')));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    final after = await repo.progressSnapshot(fixtureWeek, 'Asia/Manila');
    expect(after.reportedMs, 360000);
    expect(after.reflection!.helped, 'Native saved reflection 日本語');
    if (Platform.isWindows) {
      await tester.ensureVisible(find.byKey(const Key('progress-task-total')));
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final support = await getApplicationSupportDirectory();
      await File(
        p.join(support.path, 'phase11_progress_checks', 'progress.png'),
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    }
    expect(tester.takeException(), isNull);
  });
}
