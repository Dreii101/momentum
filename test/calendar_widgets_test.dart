import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/migrations.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/calendar/calendar_providers.dart';
import 'package:momentum/features/schedule/recurrence.dart';

import 'adaptive_shell_test.dart' show ShellHarness, pumpShell;
import 'task_widgets_test.dart' show perform, tapVisible, enter, go;
import 'calendar_test.dart' show workDraft;
import 'schedule_test.dart' show weekly;

void planRoute(ShellHarness h, String id) => h.container
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.plan, id);
void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'manual work create/edit/remove/restore through calendar forms on $platform',
      (tester) async {
        final h = await pumpShell(
          tester,
          platform: platform,
          size: platform == TargetPlatform.windows
              ? const Size(1440, 1100)
              : const Size(390, 1100),
          clock: () => DateTime.utc(2026, 10, 21),
        );
        final t = await perform(
          tester,
          () => h.repository.createTask(
            TaskDraft(
              title: 'Essay',
              deadline: Deadline.dateOnly(
                CalendarDate(2026, 10, 23),
                'Asia/Manila',
              ),
              remainingMinutes: 90,
            ),
          ),
        );
        go(h, Destination.plan);
        await tester.pumpAndSettle();
        expect(
          find.text(
            platform == TargetPlatform.windows
                ? 'Week calendar'
                : 'Agenda calendar',
          ),
          findsOneWidget,
        );
        await tapVisible(tester, find.byKey(const Key('new-work')));
        await enter(tester, 'work-length', '50');
        await tapVisible(tester, find.byKey(const Key('save-work')));
        var b = (await perform(
          tester,
          h.repository.planningSnapshot,
        )).blocks.single;
        expect(b.endUtc.difference(b.startUtc).inMinutes, 50);
        await enter(tester, 'work-time', '13:00');
        await tapVisible(tester, find.byKey(const Key('save-work')));
        b = (await perform(
          tester,
          h.repository.planningSnapshot,
        )).blocks.single;
        expect(b.startUtc, DateTime.utc(2026, 10, 21, 5));
        expect(await perform(tester, () => h.repository.task(t.id)), t);
        await tapVisible(tester, find.byKey(const Key('delete-work')));
        expect(find.text('Restore work block'), findsOneWidget);
        await tapVisible(tester, find.byKey(const Key('delete-work')));
        expect(
          (await perform(tester, () => h.repository.workBlock(b.id))).deletedAt,
          isNull,
        );
        await tapVisible(tester, find.byKey(const Key('calendar-back')));
        await tapVisible(tester, find.byKey(const Key('calendar-view-day')));
        await tapVisible(tester, find.byKey(ValueKey('calendar-work/${b.id}')));
        await tapVisible(tester, find.byKey(const Key('work-open-task')));
        expect(
          h.container
              .read(shellNavigationProvider)
              .selectedRecords[Destination.tasks],
          t.id,
        );
        await enter(tester, 'task-title', 'Essay revised');
        if (find.byKey(const Key('remaining-estimate')).evaluate().isEmpty) {
          await tapVisible(tester, find.byKey(const Key('task-advanced')));
        }
        await enter(tester, 'remaining-estimate', '75');
        await enter(tester, 'target-date', '2026-10-22');
        await enter(tester, 'target-time', '12:00');
        await enter(tester, 'target-zone', 'Asia/Manila');
        await tapVisible(tester, find.byKey(const Key('save-task')));
        final updated = await perform(tester, () => h.repository.task(t.id));
        expect(updated.deadlineDate, t.deadlineDate);
        expect(updated.remainingMinutes, 75);
        expect(updated.targetUtc, DateTime.utc(2026, 10, 22, 4));
        go(h, Destination.plan);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('calendar-back')));
        await tapVisible(tester, find.byKey(const Key('calendar-view-agenda')));
        expect(find.text('Work · Essay revised'), findsOneWidget);
        expect(find.text('Internal target · Essay revised'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'cross-view source opening, filters, moved class once and cancellation opt-in',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(1440, 1100),
        clock: () => DateTime.utc(2026, 10, 21),
      );
      final t = await perform(
        tester,
        () => h.repository.createTask(
          TaskDraft(
            title: 'Deadline source',
            deadline: Deadline.dateOnly(CalendarDate(2026, 10, 21), 'UTC'),
          ),
        ),
      );
      final s = await perform(
        tester,
        () => h.repository.createActivity(weekly()),
      );
      await perform(
        tester,
        () => h.repository.changeOccurrence(
          s.id,
          CalendarDate(2026, 10, 21),
          move: OccurrenceMove(
            date: CalendarDate(2026, 10, 22),
            startMinute: 540,
            endMinute: 600,
            zone: 'Asia/Manila',
          ),
        ),
      );
      go(h, Destination.plan);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('calendar-view-agenda')));
      expect(
        find.byKey(ValueKey('calendar-activity/${s.id}/2026-10-21')),
        findsOneWidget,
      );
      await tapVisible(
        tester,
        find.byKey(ValueKey('calendar-deadline/${t.id}')),
      );
      await tapVisible(tester, find.byKey(const Key('calendar-open-task')));
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.tasks],
        t.id,
      );
      go(h, Destination.plan);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('calendar-back')));
      await tapVisible(
        tester,
        find.byKey(ValueKey('calendar-activity/${s.id}/2026-10-21')),
      );
      await tapVisible(tester, find.byKey(const Key('calendar-open-activity')));
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.plan],
        'occurrence/${s.id}/2026-10-21',
      );
      await perform(
        tester,
        () => h.repository.changeOccurrence(
          s.id,
          CalendarDate(2026, 10, 21),
          cancelled: true,
        ),
      );
      await tapVisible(tester, find.byKey(const Key('plan-calendar')));
      expect(
        find.byKey(ValueKey('calendar-activity/${s.id}/2026-10-21')),
        findsNothing,
      );
      await tapVisible(tester, find.text('Calendar filters'));
      await tapVisible(tester, find.byKey(const Key('calendar-cancelled')));
      expect(
        find.byKey(ValueKey('calendar-activity/${s.id}/2026-10-21')),
        findsOneWidget,
      );
      await tapVisible(tester, find.byKey(const Key('filter-activity')));
      expect(
        find.byKey(ValueKey('calendar-activity/${s.id}/2026-10-21')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'overlap acknowledgement and SQLite failure preserve work input; explicit retry',
    (tester) async {
      final h = await pumpShell(
        tester,
        platform: TargetPlatform.android,
        size: const Size(390, 1100),
        clock: () => DateTime.utc(2026, 10, 21),
      );
      final t = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Plan')),
      );
      await perform(tester, () => h.repository.saveWorkBlock(workDraft(t.id)));
      planRoute(h, 'new-work');
      await tester.pumpAndSettle();
      await enter(tester, 'work-length', '0');
      await tapVisible(tester, find.byKey(const Key('save-work')));
      expect(find.text('Work was not saved'), findsOneWidget);
      await enter(tester, 'work-length', '45');
      await tapVisible(tester, find.byKey(const Key('save-work')));
      expect(find.textContaining('Overlap warning:'), findsOneWidget);
      expect(
        (await perform(tester, h.repository.planningSnapshot)).blocks,
        hasLength(1),
      );
      await tapVisible(tester, find.byKey(const Key('work-accept-overlap')));
      await perform(
        tester,
        () => h.repository.database.customStatement(
          "CREATE TRIGGER reject_work BEFORE INSERT ON planned_work_blocks BEGIN SELECT RAISE(ABORT,'Injected write failure'); END",
        ),
      );
      await tapVisible(tester, find.byKey(const Key('save-work')));
      expect(find.text('Work was not saved'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('work-length')))
            .controller!
            .text,
        '45',
      );
      await perform(
        tester,
        () => h.repository.database.customStatement('DROP TRIGGER reject_work'),
      );
      await tapVisible(tester, find.text('Retry'));
      expect(
        (await perform(tester, h.repository.planningSnapshot)).blocks,
        hasLength(2),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'work draft and selection survive resize, theme, 200 percent and keyboard save',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(1440, 1100),
        clock: () => DateTime.utc(2026, 10, 21),
      );
      await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Keep draft')),
      );
      planRoute(h, 'new-work');
      await tester.pumpAndSettle();
      await enter(tester, 'work-time', '12:34');
      final controller = tester
          .widget<TextField>(find.byKey(const Key('work-time')))
          .controller!;
      controller.selection = const TextSelection.collapsed(offset: 3);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      for (final width in [360.0, 600.0, 999.0, 1000.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1300);
        await tester.pumpAndSettle();
        expect(
          identical(
            tester
                .widget<TextField>(find.byKey(const Key('work-time')))
                .controller,
            controller,
          ),
          isTrue,
        );
        expect(controller.selection.baseOffset, 3);
        expect(controller.text, '12:34');
        expect(tester.takeException(), isNull);
      }
      await perform(tester, () async {
        final old = await h.repository.settings();
        await h.repository.updateSettings(
          theme: ThemePreference.dark,
          planningZone: old.planningZone,
        );
      });
      expect(controller.text, '12:34');
      await tester.ensureVisible(find.byKey(const Key('work-time')));
      await tester.tap(find.byKey(const Key('work-time')));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(
        (await perform(tester, h.repository.planningSnapshot)).blocks,
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('calendar read failure is explicit and retry restores its view', (
    tester,
  ) async {
    final h = await pumpShell(tester, clock: () => DateTime.utc(2026, 10, 21));
    go(h, Destination.plan);
    await tester.pumpAndSettle();
    await perform(
      tester,
      () => h.repository.database.customStatement(
        'DROP TABLE planned_work_blocks',
      ),
    );
    h.container.invalidate(planningProvider);
    await tester.pumpAndSettle();
    expect(find.text('Could not load calendar'), findsOneWidget);
    await perform(tester, () async {
      for (final statement in planningV6Sql) {
        await h.repository.database.customStatement(statement);
      }
    });
    await tapVisible(tester, find.text('Retry'));
    expect(find.text('Week calendar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
