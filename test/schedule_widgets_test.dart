import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';

import 'adaptive_shell_test.dart' show ShellHarness, pumpShell;
import 'task_widgets_test.dart' show perform, tapVisible, enter, go;
import 'schedule_test.dart' show weekly;

void route(ShellHarness h, String id) => h.container
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.plan, id);

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'course and activity creation, archived association, date view on $platform',
      (tester) async {
        final h = await pumpShell(
          tester,
          platform: platform,
          size: platform == TargetPlatform.windows
              ? const Size(1440, 1100)
              : const Size(390, 1000),
          clock: () => DateTime.utc(2026, 10, 21),
        );
        go(h, Destination.plan);
        route(h, 'timetable');
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('new-course')));
        await enter(tester, 'course-name', 'Biology 🧬');
        await enter(tester, 'course-start', '2026-10-01');
        await enter(tester, 'course-end', '2026-12-31');
        await tapVisible(tester, find.byKey(const Key('save-course')));
        final c = (await perform(
          tester,
          () => h.repository.watchCourses().first,
        )).single;
        expect(c.name, 'Biology 🧬');
        await tapVisible(tester, find.byKey(const Key('save-course')));
        expect(find.text('Course saved.'), findsOneWidget);
        await enter(tester, 'course-name', 'Biology edited');
        expect(find.text('Course saved.'), findsNothing);
        await tapVisible(tester, find.byKey(const Key('save-course')));
        await tapVisible(tester, find.byKey(const Key('archive-course')));
        expect(
          (await perform(tester, () => h.repository.course(c.id))).archivedAt,
          isNotNull,
        );
        await tapVisible(tester, find.byKey(const Key('new-activity')));
        await enter(tester, 'activity-title', 'Lab meeting');
        await enter(tester, 'activity-end', '2026-11-30');
        await tapVisible(tester, find.byKey(const Key('preview-activity')));
        await tapVisible(tester, find.byKey(const Key('save-activity')));
        final s = (await perform(
          tester,
          h.repository.scheduleSnapshot,
        )).series.single;
        expect(s.title, 'Lab meeting');
        expect(s.courseId, isNull);
        await tapVisible(tester, find.byKey(const Key('back-to-timetable')));
        expect(
          find.text(
            platform == TargetPlatform.windows
                ? 'Weekly timetable'
                : 'Daily timetable',
          ),
          findsOneWidget,
        );
        expect(find.text('Lab meeting'), findsWidgets);
        await enter(tester, 'timetable-date', '9999-12-31');
        await tapVisible(tester, find.byKey(const Key('view-timetable-date')));
        expect(find.textContaining('Choose a viewing year'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'draft survives phone/intermediate/desktop resizing, 200% text and keyboard preview',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(1440, 1100),
        clock: () => DateTime.utc(2026, 10, 21),
      );
      route(h, 'new-activity');
      await tester.pumpAndSettle();
      await enter(tester, 'activity-title', 'Keep draft');
      final original = tester
          .widget<TextField>(find.byKey(const Key('activity-title')))
          .controller!;
      original.selection = const TextSelection.collapsed(offset: 4);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      for (final width in [360.0, 600.0, 999.0, 1000.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1100);
        await tester.pumpAndSettle();
        final current = tester
            .widget<TextField>(find.byKey(const Key('activity-title')))
            .controller!;
        expect(identical(current, original), isTrue);
        expect(current.text, 'Keep draft');
        expect(current.selection.baseOffset, 4);
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.byKey(const Key('activity-title')));
      await tester.tap(find.byKey(const Key('activity-title')));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('save-activity')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel, reschedule, conflict acknowledgement and same-note links',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(390, 1100),
        platform: TargetPlatform.android,
        clock: () => DateTime.utc(2026, 10, 20),
      );
      final s = await perform(
        tester,
        () => h.repository.createActivity(weekly()),
      );
      await perform(
        tester,
        () => h.repository.createActivity(weekly(title: 'Other', weekdays: 8)),
      );
      final n = await perform(
        tester,
        () => h.repository.createNote(
          const NoteDraft(title: 'Reusable class note', body: 'Original'),
        ),
      );
      final day = CalendarDate(2026, 10, 21);
      await perform(
        tester,
        () => h.repository.setActivityLink(n.id, s.id, day, linked: true),
      );
      route(h, 'occurrence/${s.id}/$day');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('cancel-occurrence')));
      expect(
        (await perform(
          tester,
          () => h.repository.occurrence(s.id, day),
        )).cancelled,
        isTrue,
      );
      await tapVisible(tester, find.byKey(const Key('move-occurrence')));
      await enter(tester, 'move-date', '2026-10-22');
      await tapVisible(tester, find.byKey(const Key('save-occurrence-move')));
      expect(find.byKey(const Key('accept-move-overlap')), findsOneWidget);
      expect(
        (await perform(tester, () => h.repository.occurrence(s.id, day))).moved,
        isFalse,
      );
      await tapVisible(tester, find.byKey(const Key('accept-move-overlap')));
      await tapVisible(tester, find.byKey(const Key('save-occurrence-move')));
      final moved = await perform(
        tester,
        () => h.repository.occurrence(s.id, day),
      );
      expect(moved.moved, isTrue);
      expect(moved.cancelled, isFalse);
      await tapVisible(tester, find.text('Reusable class note'));
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.notes],
        n.id,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('note-body')))
            .controller!
            .text,
        'Original',
      );
      final link = (await perform(
        tester,
        () => h.repository.watchActivityLinks(noteId: n.id).first,
      )).single;
      await tapVisible(
        tester,
        find.byKey(ValueKey('note-activity-${link.id}')),
      );
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.plan],
        'occurrence/${s.id}/$day',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'replacement preview retains note and exception, linked original stays accessible',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(1440, 1100),
        clock: () => DateTime.utc(2026, 10, 20),
      );
      final s = await perform(
        tester,
        () => h.repository.createActivity(weekly()),
      );
      final n = await perform(
        tester,
        () => h.repository.createNote(const NoteDraft(title: 'Retained note')),
      );
      final day = CalendarDate(2026, 10, 26);
      await perform(
        tester,
        () => h.repository.setActivityLink(n.id, s.id, day, linked: true),
      );
      await perform(
        tester,
        () => h.repository.changeOccurrence(s.id, day, cancelled: true),
      );
      route(h, 'occurrence/${s.id}/$day');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('replace-future')));
      await enter(tester, 'activity-title', 'Replacement lab');
      await tapVisible(tester, find.byKey(const Key('preview-activity')));
      expect(
        find.textContaining('Retain 1 future exception(s) and 1 note link(s)'),
        findsOneWidget,
      );
      await tapVisible(tester, find.byKey(const Key('save-activity')));
      expect(
        (await perform(tester, h.repository.scheduleSnapshot)).series,
        hasLength(2),
      );
      route(h, 'occurrence/${s.id}/$day');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Retained superseded occurrence'),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Retained note'));
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.notes],
        n.id,
      );
    },
  );

  testWidgets(
    'validation and failed writes keep editor input and permit explicit retry',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(390, 1000),
        platform: TargetPlatform.android,
        clock: () => DateTime.utc(2026, 10, 21),
      );
      route(h, 'new-activity');
      await tester.pumpAndSettle();
      await enter(tester, 'activity-title', 'Keep on error');
      await enter(tester, 'activity-end-time', '08:00');
      await tapVisible(tester, find.byKey(const Key('preview-activity')));
      expect(find.text('Activity was not saved'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('activity-title')))
            .controller!
            .text,
        'Keep on error',
      );
      await enter(tester, 'activity-end-time', '10:00');
      await tapVisible(tester, find.byKey(const Key('preview-activity')));
      await perform(
        tester,
        () => h.repository.database.customStatement(
          "CREATE TRIGGER reject_schedule BEFORE INSERT ON activity_series BEGIN SELECT RAISE(ABORT, 'Injected write failure'); END",
        ),
      );
      await tapVisible(tester, find.byKey(const Key('save-activity')));
      expect(find.text('Activity was not saved'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('activity-title')))
            .controller!
            .text,
        'Keep on error',
      );
      await perform(
        tester,
        () => h.repository.database.customStatement(
          'DROP TRIGGER reject_schedule',
        ),
      );
      await tapVisible(tester, find.text('Retry'));
      await tapVisible(tester, find.byKey(const Key('save-activity')));
      expect(
        (await perform(
          tester,
          h.repository.scheduleSnapshot,
        )).series.single.title,
        'Keep on error',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
