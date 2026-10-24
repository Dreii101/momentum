import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/backup/backup_providers.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/notes/note_providers.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:momentum/features/reminders/reminder_providers.dart';

import 'focus_flow_test.dart' show tick;
import 'support/backup_fixture.dart';
import 'support/database_fixture.dart';
import 'support/fake_notifications.dart';
import 'task_widgets_test.dart' show perform, enter;
import 'timer_engine_test.dart' show FakeTimerClock;

void main() {
  registerJourney(TargetPlatform.android, const Size(390, 1100));
  registerJourney(TargetPlatform.windows, const Size(1440, 1100));
}

/// Also run in the native integration runner; dialogs/notifications are adapters.
void registerJourney(TargetPlatform platform, Size size) {
  testWidgets('complete saved MVP journey on $platform', (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = (await tester.runAsync(DatabaseFixture.create))!;
    final repo = (await tester.runAsync(() async {
      final r = MomentumRepository(
        fixture.open(),
        clock: () => DateTime.utc(2026, 10, 23, 2),
      );
      await r.initialize();
      return r;
    }))!;
    final clock = FakeTimerClock()..wall = DateTime.utc(2026, 10, 23, 2);
    final files = MemoryBackupFiles(), notifications = FakeNotifications();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWith((ref) => repo),
        databaseFileProvider.overrideWithValue(() async => fixture.file),
        clockProvider.overrideWithValue(() => clock.wall),
        timerClockProvider.overrideWithValue(clock),
        backupFilesProvider.overrideWithValue(files),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    Future<void> settle() async {
      // Give the real background SQLite connection time to answer fake-clock UI frames.
      for (var i = 0; i < 1000; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
        if (i >= 30 && !tester.binding.hasScheduledFrame) return;
      }
      throw StateError('The journey UI did not settle.');
    }

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await settle();
    }

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      final timer = container.read(timerCoordinatorProvider).value;
      final reminders = container.read(reminderCoordinatorProvider).value;
      if (timer != null) await perform(tester, timer.close);
      if (reminders != null) await perform(tester, reminders.close);
      container.dispose();
      await tester.pump();
      await tester.runAsync(fixture.dispose);
      await notifications.callbacks.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MomentumApp(showDevelopment: false, platform: platform),
      ),
    );
    await settle();
    Future<void> route(Destination destination, String id) async {
      final navigation = container.read(shellNavigationProvider.notifier);
      if (id.isEmpty) {
        navigation.go(destination);
        navigation.clearRecord(destination);
      } else {
        navigation.selectRecord(destination, id);
      }
      await settle();
    }

    Future<void> tap(String id) => tapVisible(tester, find.byKey(Key(id)));
    Future<void> review({required String seconds}) async {
      await enter(tester, 'focus-reported', seconds);
      await tap('focus-confirm');
      await tap('focus-save-review');
    }

    await route(Destination.plan, 'new-course');
    await enter(tester, 'course-name', 'Biology 日本語');
    await tap('save-course');
    final course = (await perform(
      tester,
      () => repo.watchCourses().first,
    )).single;
    await route(Destination.plan, 'new-activity');
    await enter(tester, 'activity-title', 'Friday laboratory');
    await tapVisible(
      tester,
      find.byType(DropdownButtonFormField<String>).first,
    );
    await tapVisible(tester, find.text(course.name).last);
    await tap('preview-activity');
    await tap('save-activity');
    final series = (await perform(tester, repo.scheduleSnapshot)).series.single;
    expect(series.courseId, course.id);

    await route(Destination.notes, '');
    await tap('new-note');
    await enter(tester, 'note-title', 'Laboratory notes');
    await enter(
      tester,
      'note-body',
      'Read the slide. 🧬\nKeep the original material.',
    );
    await tap('save-note');
    final note = (await perform(tester, () => repo.watchNotes().first)).single;
    await route(Destination.plan, 'activity/${series.id}');
    await tapVisible(tester, find.text('Link an existing note'));
    await tap('schedule-link-note');
    await tapVisible(tester, find.text(note.title).last);
    await tap('save-schedule-link');
    expect(
      (await perform(
        tester,
        () => repo.watchActivityLinks(seriesId: series.id).first,
      )).single.noteId,
      note.id,
    );

    await route(Destination.tasks, '');
    await enter(tester, 'quick-capture', 'Explain the slide');
    await tap('capture-task');
    final task = (await perform(tester, () => repo.watchTasks().first)).single;
    await route(Destination.tasks, task.id);
    await enter(tester, 'task-next-action', 'Open the laboratory note');
    await tap('save-task');
    await tap('select-note-links');
    await tap('link-note-${note.id}');
    await tap('open-linked-note-${note.id}');
    expect(
      container
          .read(shellNavigationProvider)
          .selectedRecords[Destination.notes],
      note.id,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-body')))
          .controller!
          .text,
      note.body,
    );
    final editor = tester
        .widget<TextField>(find.byKey(const Key('note-body')))
        .controller!;
    editor.selection = const TextSelection.collapsed(offset: 4);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(700, 1100);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byKey(const Key('note-body'))).controller,
      same(editor),
    );
    expect(editor.selection.baseOffset, 4);
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    tester.view.physicalSize = size;
    await tester.pumpAndSettle();

    await route(Destination.tasks, task.id);
    await tap('task-open-starter');
    final timer = await perform(
      tester,
      () => container.read(timerCoordinatorProvider.future),
    );
    await tap('focus-start');
    await tick(tester, timer, clock, 24);
    await review(seconds: '120');
    await tap('continue-10');
    await tick(tester, timer, clock, 2);
    await tap('focus-end');
    await review(seconds: '10');
    await route(Destination.progress, '');
    expect(find.text('Reported focus time: 2:10'), findsOneWidget);
    expect(
      (await perform(tester, () => repo.task(task.id))).status,
      TaskStatus.todo,
    );

    await route(Destination.settings, 'data');
    await tap('backup-export');
    expect(files.bytes, isNotNull);
    expect(container.read(backupControllerProvider).error, isNull);
    // A subsequent edit proves replacement reads the validated export, not live data.
    final draft = container
        .read(noteDraftsProvider)
        .open(await perform(tester, () => repo.note(note.id)));
    draft.body.text = 'Later edit';
    await perform(tester, draft.flush);
    await tap('backup-inspect');
    expect(container.read(backupControllerProvider).preview, isNotNull);
    await tap('backup-confirm');
    await tap('backup-replace');
    expect(container.read(backupControllerProvider).error, isNull);
    expect((await perform(tester, () => repo.note(note.id))).body, note.body);
    final week = CalendarDate(2026, 10, 19);
    expect(
      (await perform(
        tester,
        () => repo.progressSnapshot(week, 'Asia/Manila'),
      )).reportedMs,
      130000,
    );
    expect(
      (await perform(
        tester,
        () => repo.watchLinksForNote(note.id).first,
      )).single.taskId,
      task.id,
    );
    // Independent file connection establishes reopen persistence without deleting data.
    final reopened = (await tester.runAsync(() async {
      final r = MomentumRepository(fixture.open());
      await r.initialize();
      return r;
    }))!;
    expect(
      (await perform(tester, () => reopened.note(note.id))).body,
      note.body,
    );
    expect(
      (await perform(
        tester,
        () => reopened.progressSnapshot(week, 'Asia/Manila'),
      )).reportedMs,
      130000,
    );
    expect(tester.takeException(), isNull);
  });
}
