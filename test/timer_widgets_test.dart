import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_providers.dart';

import 'adaptive_shell_test.dart' show pumpShell;
import 'task_widgets_test.dart' show perform, tapVisible, enter;
import 'timer_engine_test.dart' show FakeTimerClock;

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'development timer requires review/confirmation and keeps failed input on $platform',
      (tester) async {
        final clock = FakeTimerClock();
        final h = await pumpShell(
          tester,
          platform: platform,
          size: platform == TargetPlatform.android
              ? const Size(390, 1100)
              : const Size(1440, 1100),
          timerClock: clock,
        );
        final task = await perform(
          tester,
          () => h.repository.createTask(
            const TaskDraft(title: 'Do not auto-complete'),
          ),
        );
        await tapVisible(tester, find.byKey(const Key('open-development')));
        await enter(tester, 'timer-minutes', '1');
        await tapVisible(tester, find.byKey(const Key('timer-start-focus')));
        expect(find.text('Last committed state: running'), findsOneWidget);
        clock.advance(5000);
        await tapVisible(tester, find.byKey(const Key('timer-end')));
        expect(
          find.text('Last committed state: awaitingReview'),
          findsOneWidget,
        );
        await enter(tester, 'timer-reported', '6');
        await tapVisible(tester, find.byKey(const Key('timer-confirm')));
        await tapVisible(tester, find.byKey(const Key('timer-finalize')));
        expect(
          find.textContaining('Enter whole seconds from 0 to 5.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('timer-reported')))
              .controller!
              .text,
          '6',
        );
        await enter(tester, 'timer-reported', '2305843009213693956');
        await tapVisible(tester, find.byKey(const Key('timer-finalize')));
        expect(
          find.text('Last committed state: awaitingReview'),
          findsOneWidget,
        );
        await enter(tester, 'timer-reported', '4');
        await tapVisible(tester, find.byKey(const Key('timer-finalize')));
        expect(find.text('Last committed state: finalized'), findsOneWidget);
        final coordinator = await perform(
          tester,
          () => h.container.read(timerCoordinatorProvider.future),
        );
        expect(coordinator.view.session!.reportedMs, 4000);
        expect(
          (await perform(tester, () => h.repository.task(task.id))).status,
          TaskStatus.todo,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'checkpoint owner survives removal of screens and remains the same on return',
    (tester) async {
      final clock = FakeTimerClock();
      final h = await pumpShell(tester, timerClock: clock);
      final owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      await perform(tester, () => owner.start(SessionKind.starter));
      clock.advance(5000);
      await tester.pump(const Duration(seconds: 5));
      await perform(tester, () => Future.value());
      expect(owner.view.session!.elapsedMs, 5000);
      await tester.pumpWidget(const SizedBox.shrink());
      clock.advance(5000);
      await tester.pump(const Duration(seconds: 5));
      await perform(tester, () => Future.value());
      expect(owner.view.session!.elapsedMs, 10000);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const MomentumApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        identical(h.container.read(timerCoordinatorProvider).value, owner),
        isTrue,
      );
      expect(owner.view.session!.state, SessionState.running);
      await owner.close();
      expect(tester.takeException(), isNull);
    },
  );
}
