import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/focus/focus_workflow.dart';

import 'adaptive_shell_test.dart' show pumpShell, ShellHarness;
import 'task_widgets_test.dart' show perform, tapVisible, enter, open, go;
import 'timer_engine_test.dart' show FakeTimerClock;

void route(ShellHarness h, String value) => h.container
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.today, value);
Future<void> review(WidgetTester tester, {String seconds = '0'}) async {
  await enter(tester, 'focus-reported', seconds);
  await tapVisible(tester, find.byKey(const Key('focus-confirm')));
  await tapVisible(tester, find.byKey(const Key('focus-save-review')));
}

Future<void> tick(
  WidgetTester tester,
  TimerCoordinator owner,
  FakeTimerClock clock,
  int count,
) async {
  for (var i = 0; i < count; i++) {
    clock.advance(5000);
    await perform(tester, owner.checkpoint);
  }
}

void main() {
  test('reported seconds are bounded before conversion to milliseconds', () {
    expect(reportedWorkMilliseconds('0', 5999), 0);
    expect(reportedWorkMilliseconds(' 5 ', 5999), 5000);
    for (final input in [
      '6',
      '-1',
      '1.5',
      'no',
      '2305843009213693956',
      '999999999999999999999999999',
    ]) {
      expect(
        () => reportedWorkMilliseconds(input, 5999),
        throwsFormatException,
      );
    }
  });
  testWidgets(
    'all-steps completion resolves the timer; recovery opens honest review',
    (tester) async {
      final clock = FakeTimerClock();
      final h = await pumpShell(
        tester,
        realSessions: true,
        timerClock: clock,
        diagnostics: false,
      );
      final task = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Whole task')),
      );
      final step = await perform(
        tester,
        () => h.repository.createSubtask(task.id, 'Only step'),
      );
      await perform(
        tester,
        () => h.repository.updateSubtask(
          step.id,
          title: step.title,
          position: step.position,
          completed: true,
        ),
      );
      route(h, 'focus/${task.id}');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      var owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      await tick(tester, owner, clock, 1);
      clock.advance(30000);
      clock.epoch = 'restarted-process';
      clock.elapsed = 0;
      h.container.invalidate(timerCoordinatorProvider);
      await tester.pumpAndSettle();
      owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      expect(find.text('Welcome back. Review this session.'), findsOneWidget);
      expect(owner.view.session!.state, SessionState.awaitingReview);
      expect(owner.view.session!.reportedMs, isNull);
      await review(tester);
      route(h, 'focus/${task.id}');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      await tapVisible(tester, find.byKey(const Key('focus-open-task')));
      await tapVisible(tester, find.byKey(const Key('offer-complete-task')));
      expect(owner.view.session!.state, SessionState.awaitingReview);
      expect(
        (await perform(tester, () => h.repository.task(task.id))).status,
        TaskStatus.done,
      );
      await review(tester);
    },
  );
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'task → starter → continue → pause → review → history on $platform',
      (tester) async {
        final clock = FakeTimerClock();
        final h = await pumpShell(
          tester,
          realSessions: true,
          timerClock: clock,
          diagnostics: false,
          platform: platform,
          size: platform == TargetPlatform.android
              ? const Size(390, 1100)
              : const Size(1440, 1100),
        );
        final task = await perform(
          tester,
          () => h.repository.createTask(
            const TaskDraft(
              title: 'One question',
              nextAction: 'Open the worksheet',
            ),
          ),
        );
        final step = await perform(
          tester,
          () => h.repository.createSubtask(task.id, 'Read question one'),
        );
        final note = await perform(
          tester,
          () => h.repository.createNote(
            const NoteDraft(title: 'Class notes', body: 'Original text'),
          ),
        );
        await perform(
          tester,
          () => h.repository.setNoteTaskLink(note.id, task.id, linked: true),
        );
        open(h, task.id);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('task-open-starter')));
        final owner = await perform(
          tester,
          () => h.container.read(timerCoordinatorProvider.future),
        );
        expect(owner.view.session, isNull);
        final choice = find.byKey(ValueKey('starter-action-${task.id}'));
        await tapVisible(tester, choice);
        await tapVisible(tester, find.text('Read question one').last);
        await tapVisible(tester, find.byKey(const Key('focus-start')));
        final starter = owner.view.session!;
        expect(starter.kind, SessionKind.starter);
        expect(starter.subtaskId, step.id);
        await tick(tester, owner, clock, 24);
        expect(owner.view.session!.state, SessionState.awaitingReview);
        expect(
          (await perform(
            tester,
            () => h.repository.subtask(step.id),
          )).completedAt,
          isNull,
        );
        await review(tester, seconds: '120');
        await tapVisible(tester, find.byKey(const Key('focus-mark-step')));
        expect(
          (await perform(tester, () => h.repository.task(task.id))).status,
          TaskStatus.todo,
        );
        await tapVisible(tester, find.byKey(const Key('continue-10')));
        final focus = owner.view.session!;
        expect(focus.id, isNot(starter.id));
        expect(focus.plannedMs, 600000);
        expect(
          focus.subtaskId,
          isNull,
        ); // A completed step is not carried into new work.
        await tick(tester, owner, clock, 1);
        await tapVisible(tester, find.byKey(const Key('focus-pause-resume')));
        clock.advance(60000);
        await tapVisible(tester, find.byKey(ValueKey('focus-note-${note.id}')));
        expect(
          h.container
              .read(shellNavigationProvider)
              .selectedRecords[Destination.notes],
          note.id,
        );
        await tapVisible(tester, find.byKey(const Key('return-to-session')));
        await tapVisible(tester, find.byKey(const Key('focus-pause-resume')));
        await tapVisible(tester, find.byKey(const Key('focus-extend')));
        expect(owner.view.session!.plannedMs, 900000);
        await tick(tester, owner, clock, 1);
        await tapVisible(tester, find.byKey(const Key('focus-end')));
        expect(owner.view.session!.eligibleMs, 10000);
        await review(tester, seconds: '10');
        await tapVisible(tester, find.byKey(const Key('focus-history')));
        expect(find.byKey(ValueKey('history-${starter.id}')), findsOneWidget);
        expect(find.byKey(ValueKey('history-${focus.id}')), findsOneWidget);
        expect(
          (await perform(tester, () => h.repository.task(task.id))).status,
          TaskStatus.todo,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'no steps, explicit stop, failed save, repeated Finish, optional break and custom keyboard start',
    (tester) async {
      final clock = FakeTimerClock();
      final h = await pumpShell(
        tester,
        realSessions: true,
        timerClock: clock,
        diagnostics: false,
      );
      final task = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Without steps')),
      );
      route(h, 'starter/${task.id}');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      final owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      await tick(tester, owner, clock, 1);
      await tapVisible(tester, find.byKey(const Key('focus-end')));
      await review(tester, seconds: '6');
      expect(find.text('This change was not confirmed saved'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('focus-reported')))
            .controller!
            .text,
        '6',
      );
      await enter(tester, 'focus-reported', '2305843009213693956');
      await tapVisible(tester, find.byKey(const Key('focus-save-review')));
      expect(owner.view.session!.state, SessionState.awaitingReview);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('focus-reported')))
            .controller!
            .text,
        '2305843009213693956',
      );
      await enter(tester, 'focus-reported', '4');
      await perform(
        tester,
        () => h.repository.database.customStatement(
          "CREATE TRIGGER reject_review BEFORE UPDATE ON focus_sessions WHEN NEW.state='finalized' BEGIN SELECT RAISE(ABORT,'disk rejection'); END",
        ),
      );
      await tapVisible(tester, find.byKey(const Key('focus-save-review')));
      expect(owner.view.session!.state, SessionState.awaitingReview);
      await perform(
        tester,
        () =>
            h.repository.database.customStatement('DROP TRIGGER reject_review'),
      );
      await tapVisible(tester, find.byKey(const Key('focus-save-review')));
      await perform(
        tester,
        () => owner.command(
          TimerAction.finalize,
          reportedMs: 4000,
          confirmed: true,
        ),
      );
      final history = await perform(
        tester,
        () => h.repository.database
            .select(h.repository.database.focusSessions)
            .get(),
      );
      expect(history.length, 1);
      await tapVisible(tester, find.byKey(const Key('focus-break')));
      expect(owner.view.session!.state, SessionState.finalized);
      await enter(tester, 'focus-duration', '1');
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      expect(owner.view.session!.kind, SessionKind.rest);
      await tick(tester, owner, clock, 1);
      await tapVisible(tester, find.byKey(const Key('focus-end')));
      expect(owner.view.session!.eligibleMs, 0);
      await review(tester);
      await tapVisible(tester, find.byKey(const Key('focus-another')));
      await enter(tester, 'focus-duration', '7');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(owner.view.session!.plannedMs, 420000);
      await tapVisible(tester, find.byKey(const Key('focus-end')));
      await review(tester);
    },
  );

  testWidgets(
    'completion routes to review; deleted link retained; unfinished session cannot be replaced',
    (tester) async {
      final clock = FakeTimerClock();
      final h = await pumpShell(
        tester,
        realSessions: true,
        timerClock: clock,
        diagnostics: false,
      );
      final task = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Linked work')),
      );
      route(h, 'focus/${task.id}');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      final owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      final id = owner.view.session!.id;
      route(h, 'focus');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('focus-start')))
            .onPressed,
        isNull,
      );
      expect(owner.view.session!.id, id);
      await tapVisible(tester, find.byKey(const Key('setup-return-session')));
      await tick(tester, owner, clock, 1);
      await tapVisible(tester, find.byKey(const Key('focus-open-task')));
      await tapVisible(tester, find.byKey(const Key('complete-task')));
      expect(owner.view.session!.state, SessionState.awaitingReview);
      expect(owner.view.session!.reportedMs, isNull);
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.today],
        'session/$id',
      );
      await perform(tester, () => h.repository.deleteTask(task.id));
      expect(
        find.text(
          'The linked task is in Trash. Your session and notes are retained.',
        ),
        findsOneWidget,
      );
      await review(tester);
      expect(owner.view.session!.titleSnapshot, task.title);
      expect(
        (await perform(tester, () => h.repository.task(task.id))).status,
        TaskStatus.done,
      );
    },
  );

  testWidgets(
    'resize, enlarged text, leaving and background return preserve the session and review input',
    (tester) async {
      final clock = FakeTimerClock();
      final h = await pumpShell(
        tester,
        realSessions: true,
        timerClock: clock,
        diagnostics: false,
        textScale: 2,
        size: const Size(1440, 1100),
      );
      route(h, 'focus');
      await tester.pumpAndSettle();
      await enter(tester, 'focus-duration', '1');
      await tapVisible(tester, find.byKey(const Key('focus-start')));
      final owner = await perform(
        tester,
        () => h.container.read(timerCoordinatorProvider.future),
      );
      final id = owner.view.session!.id;
      await tick(tester, owner, clock, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      clock.advance(30000);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(owner.view.session!.eligibleMs, 5000);
      expect(owner.view.session!.uncertainMs, 30000);
      for (final width in [390.0, 600.0, 999.0, 1000.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1100);
        await tester.pumpAndSettle();
        expect(owner.view.session!.id, id);
        expect(tester.takeException(), isNull);
      }
      await tapVisible(tester, find.byKey(const Key('focus-end')));
      await enter(tester, 'focus-reported', '3');
      final controller = tester
          .widget<TextField>(find.byKey(const Key('focus-reported')))
          .controller;
      go(h, Destination.tasks);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('return-to-session')));
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('focus-reported')))
            .controller,
        same(controller),
      );
      expect(controller!.text, '3');
      await tapVisible(tester, find.byKey(const Key('focus-confirm')));
      await tapVisible(tester, find.byKey(const Key('focus-save-review')));
    },
  );
}
