import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/features/progress/progress_providers.dart';
import 'package:momentum/features/progress/progress_repository.dart';

import 'adaptive_shell_test.dart' show pumpShell;
import 'task_widgets_test.dart' show perform, tapVisible, enter, go;
import 'support/progress_fixture.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    for (final width in [390.0, 700.0, 1280.0]) {
      testWidgets(
        'progress totals, reflection drafts and keyboard save at $width / $platform / 200%',
        (tester) async {
          tester.platformDispatcher.platformBrightnessTestValue = width == 700
              ? Brightness.dark
              : Brightness.light;
          addTearDown(
            tester.platformDispatcher.clearPlatformBrightnessTestValue,
          );
          final harness = await pumpShell(
            tester,
            size: Size(width, 950),
            platform: platform,
            textScale: 2,
            clock: () => DateTime.utc(2026, 10, 22, 8),
          );
          await perform(tester, () => seedProgress(harness.repository));
          go(harness, Destination.progress);
          await tester.pumpAndSettle();
          await perform(tester, () async {
            while (harness.container
                    .read(
                      progressProvider((
                        week: fixtureWeek,
                        zone: 'Asia/Manila',
                      )),
                    )
                    .value
                    ?.reportedMs !=
                390000) {
              await Future<void>.delayed(const Duration(milliseconds: 10));
            }
          });
          expect(find.text('Completed tasks: 2'), findsOneWidget);
          expect(find.text('Reported focus time: 6:30'), findsOneWidget);
          await enter(tester, 'reflection-helped', 'A small start 日本語 🧬');
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          tester.view.physicalSize = Size(width == 1280 ? 390 : 1280, 950);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('reflection-helped')))
                .controller!
                .text,
            'A small start 日本語 🧬',
          );
          await tapVisible(tester, find.byKey(const Key('progress-next')));
          expect(find.text('Completed tasks: 0'), findsOneWidget);
          await tapVisible(tester, find.byKey(const Key('progress-previous')));
          await tester.ensureVisible(
            find.byKey(const Key('reflection-helped')),
          );
          await tester.tap(find.byKey(const Key('reflection-helped')));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pumpAndSettle();
          expect(find.text('Saved'), findsOneWidget);
          expect(
            (await perform(
              tester,
              () => harness.repository.progressSnapshot(
                fixtureWeek,
                'Asia/Manila',
              ),
            )).reflection!.helped,
            'A small start 日本語 🧬',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'failed reflection/correction retain draft, explicit confirmation, retry and all projections update',
    (tester) async {
      final harness = await pumpShell(
        tester,
        clock: () => DateTime.utc(2026, 10, 22, 8),
      );
      final repo = harness.repository;
      final rows = await perform(tester, () => seedProgress(repo));
      go(harness, Destination.progress);
      await tester.pumpAndSettle();
      await perform(
        tester,
        () => repo.database.customStatement(
          "CREATE TRIGGER refuse_reflection BEFORE INSERT ON weekly_reflections BEGIN SELECT RAISE(ABORT,'storage unavailable'); END",
        ),
      );
      await enter(tester, 'reflection-helped', 'Keep this draft');
      await tapVisible(tester, find.byKey(const Key('reflection-save')));
      expect(find.text("Couldn't save"), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('reflection-helped')))
            .controller!
            .text,
        'Keep this draft',
      );
      await perform(
        tester,
        () => repo.database.customStatement('DROP TRIGGER refuse_reflection'),
      );
      await tapVisible(tester, find.byKey(const Key('reflection-save')));
      expect(find.text('Saved'), findsOneWidget);
      harness.container
          .read(shellNavigationProvider.notifier)
          .selectRecord(Destination.progress, rows.first.id);
      await tester.pumpAndSettle();
      await enter(tester, 'progress-correction', '9223372036854775807');
      await tapVisible(
        tester,
        find.byKey(const Key('progress-save-correction')),
      );
      expect(find.text('Could not save correction'), findsOneWidget);
      await enter(tester, 'progress-correction', '60');
      await tapVisible(
        tester,
        find.byKey(const Key('progress-save-correction')),
      );
      expect(find.text('Could not save correction'), findsOneWidget);
      await perform(
        tester,
        () => repo.database.customStatement(
          "CREATE TRIGGER refuse_credit BEFORE UPDATE ON focus_sessions BEGIN SELECT RAISE(ABORT,'storage unavailable'); END",
        ),
      );
      await tapVisible(tester, find.byKey(const Key('progress-confirm')));
      await tapVisible(
        tester,
        find.byKey(const Key('progress-save-correction')),
      );
      expect(find.text('Could not save correction'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('progress-correction')))
            .controller!
            .text,
        '60',
      );
      await perform(
        tester,
        () => repo.database.customStatement('DROP TRIGGER refuse_credit'),
      );
      await tapVisible(
        tester,
        find.byKey(const Key('progress-save-correction')),
      );
      expect(find.text('Correction saved'), findsOneWidget);
      await perform(tester, () async {
        while (harness.container
                .read(
                  progressProvider((week: fixtureWeek, zone: 'Asia/Manila')),
                )
                .value
                ?.reportedMs !=
            360000) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      expect(find.text('Reported focus time: 6:00'), findsOneWidget);
      expect(find.text('Saved confirmed work: 1:00'), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const Key('progress-save-correction')),
      ); // no second credit
      expect(
        (await perform(
          tester,
          () => repo.progressSnapshot(fixtureWeek, 'Asia/Manila'),
        )).reportedMs,
        360000,
      );
      harness.container
          .read(shellNavigationProvider.notifier)
          .selectRecord(Destination.today, 'session/${rows.first.id}');
      await tester.pumpAndSettle();
      expect(find.text('60 seconds explicitly confirmed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'loading failure displays unavailable totals rather than fabricated zeroes',
    (tester) async {
      final harness = await pumpShell(
        tester,
        clock: () => DateTime.utc(2026, 10, 22, 8),
      );
      go(harness, Destination.progress);
      await tester.pumpAndSettle();
      final range = (week: fixtureWeek, zone: 'Asia/Manila');
      await perform(
        tester,
        () => harness.repository.database.customStatement(
          'DROP TABLE weekly_reflections',
        ),
      );
      harness.container.invalidate(progressProvider(range));
      await tester.pumpAndSettle();
      expect(find.text('Could not load progress'), findsOneWidget);
      expect(find.byKey(const Key('progress-work-total')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
