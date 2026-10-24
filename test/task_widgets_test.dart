import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';

import 'adaptive_shell_test.dart' show ShellHarness, pumpShell;

/// Database writes can schedule Drift's query refresh in Flutter's fake clock.
/// Pump that clock while waiting instead of blocking it in tester.runAsync.
Future<T> perform<T>(WidgetTester tester, Future<T> Function() action) async {
  T? result;
  Object? error;
  var done = false;
  action().then(
    (value) {
      result = value;
      done = true;
    },
    onError: (Object failure, StackTrace stack) {
      error = failure;
      done = true;
    },
  );
  for (var attempt = 0; !done && attempt < 200; attempt++) {
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
  }
  if (!done) throw StateError('Database operation did not settle.');
  if (error != null) throw error!;
  await tester.pumpAndSettle();
  return result as T;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pump();
}

void go(ShellHarness harness, Destination destination) =>
    harness.container.read(shellNavigationProvider.notifier).go(destination);
void open(ShellHarness harness, String id) => harness.container
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.tasks, id);

class FailingTaskRepository extends MomentumRepository {
  FailingTaskRepository(super.database);
  bool failCreate = true, failSave = true;
  Completer<void>? saveGate;
  @override
  Future<Task> createTask(TaskDraft draft) async {
    if (failCreate) {
      throw const FileSystemException('Storage temporarily unavailable');
    }
    return super.createTask(draft);
  }

  @override
  Future<Task> updateTaskDetails(String id, TaskDraft draft) async {
    await saveGate?.future;
    if (failSave) {
      throw const FileSystemException('Storage temporarily unavailable');
    }
    return super.updateTaskDetails(id, draft);
  }
}

void main() {
  testWidgets(
    'pending save keeps one draft and reports success only after commit',
    (tester) async {
      final harness = await pumpShell(
        tester,
        repositoryFactory: (db) => FailingTaskRepository(db),
      );
      final repo = harness.repository as FailingTaskRepository;
      repo.failCreate = false;
      repo.failSave = false;
      final task = await perform(
        tester,
        () => repo.createTask(const TaskDraft(title: 'Before save')),
      );
      open(harness, task.id);
      await tester.pumpAndSettle();
      await enter(tester, 'task-title', 'Kept until commit');
      repo.saveGate = Completer<void>();
      await tapVisible(tester, find.byKey(const Key('save-task')));
      expect(find.text('Saved on this device.'), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .enabled,
        isFalse,
      );
      expect(
        (await perform(tester, () => repo.task(task.id))).title,
        'Before save',
      );
      repo.saveGate!.complete();
      await tester.pumpAndSettle();
      expect(
        (await perform(tester, () => repo.task(task.id))).title,
        'Kept until commit',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .enabled,
        isTrue,
      );
      expect(find.text('Saved on this device.'), findsOneWidget);
    },
  );
  testWidgets('Trash undo still works after returning to the task list', (
    tester,
  ) async {
    final harness = await pumpShell(
      tester,
      platform: TargetPlatform.android,
      size: const Size(390, 850),
    );
    final task = await perform(
      tester,
      () => harness.repository.createTask(
        const TaskDraft(title: 'Recover from list'),
      ),
    );
    open(harness, task.id);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('trash-task')));
    await tapVisible(tester, find.byKey(const Key('back-to-tasks')));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      (await perform(tester, () => harness.repository.task(task.id))).deletedAt,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'capture, choose Today, Start, complete and reopen on $platform',
      (tester) async {
        final harness = await pumpShell(
          tester,
          platform: platform,
          size: platform == TargetPlatform.android
              ? const Size(390, 850)
              : const Size(1440, 950),
        );
        go(harness, Destination.tasks);
        await tester.pumpAndSettle();
        await enter(tester, 'quick-capture', 'Read one question');
        await tapVisible(tester, find.byKey(const Key('capture-task')));
        expect(find.byKey(const Key('task-detail-title')), findsOneWidget);
        final row = (await perform(
          tester,
          () => harness.repository.watchTasks().first,
        )).single;
        await enter(tester, 'task-next-action', 'Open the assignment');
        if (platform == TargetPlatform.windows) {
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pumpAndSettle();
        } else {
          await tapVisible(tester, find.byKey(const Key('save-task')));
        }
        expect(
          (await perform(
            tester,
            () => harness.repository.task(row.id),
          )).nextAction,
          'Open the assignment',
        );
        await tapVisible(
          tester,
          find.byKey(const Key('toggle-daily-priority')),
        );
        go(harness, Destination.today);
        await tester.pumpAndSettle();
        expect(find.text('1 of 3 selected'), findsOneWidget);
        await tapVisible(tester, find.byKey(ValueKey('start-${row.id}')));
        expect(find.text('A small start is enough'), findsOneWidget);
        await tapVisible(tester, find.byKey(const Key('focus-back')));
        open(harness, row.id);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('complete-task')));
        expect(
          (await perform(tester, () => harness.repository.task(row.id))).status,
          TaskStatus.done,
        );
        go(harness, Destination.today);
        await tester.pumpAndSettle();
        expect(find.text('Completed'), findsOneWidget);
        open(harness, row.id);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('complete-task')));
        expect(
          (await perform(
            tester,
            () => harness.repository.task(row.id),
          )).completedAt,
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'failed capture/save retain input, retry commits and invalid target preserves record',
    (tester) async {
      final harness = await pumpShell(
        tester,
        repositoryFactory: (db) => FailingTaskRepository(db),
      );
      final repo = harness.repository as FailingTaskRepository;
      go(harness, Destination.tasks);
      await tester.pumpAndSettle();
      await enter(tester, 'quick-capture', 'Keep this title');
      await tapVisible(tester, find.byKey(const Key('capture-task')));
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('quick-capture')))
            .controller!
            .text,
        'Keep this title',
      );
      expect(await perform(tester, () => repo.watchTasks().first), isEmpty);
      repo.failCreate = false;
      await tapVisible(tester, find.byKey(const Key('capture-task')));
      final task = (await perform(
        tester,
        () => repo.watchTasks().first,
      )).single;
      await enter(tester, 'task-title', 'Edited title');
      await tapVisible(tester, find.byKey(const Key('save-task')));
      expect(find.text('Task changes were not saved'), findsOneWidget);
      expect(
        (await perform(tester, () => repo.task(task.id))).title,
        'Keep this title',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Edited title',
      );
      repo.failSave = false;
      await tapVisible(tester, find.byKey(const Key('save-task')));
      expect(
        (await perform(tester, () => repo.task(task.id))).title,
        'Edited title',
      );
      await tapVisible(tester, find.byKey(const Key('task-advanced')));
      await tapVisible(tester, find.byKey(const Key('deadline-kind')));
      await tester.tap(find.text('Date only (all day)').last);
      await tester.pumpAndSettle();
      await enter(tester, 'deadline-date', '2026-11-01');
      await enter(tester, 'deadline-zone', 'America/New_York');
      await enter(tester, 'target-date', '2026-11-03');
      await enter(tester, 'target-time', '10:00');
      await tapVisible(tester, find.byKey(const Key('save-task')));
      expect(
        find.textContaining('Choose an internal target before'),
        findsOneWidget,
      );
      expect(
        (await perform(tester, () => repo.task(task.id))).deadlineKind,
        DeadlineKind.none,
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('target-date')))
            .controller!
            .text,
        '2026-11-03',
      );
    },
  );

  testWidgets(
    'record switches and every layout boundary retain unsaved task drafts at 200% text',
    (tester) async {
      final harness = await pumpShell(
        tester,
        size: const Size(1440, 1000),
        textScale: 2,
      );
      final a = await perform(
        tester,
        () => harness.repository.createTask(const TaskDraft(title: 'First')),
      );
      final b = await perform(
        tester,
        () => harness.repository.createTask(const TaskDraft(title: 'Second')),
      );
      open(harness, a.id);
      await tester.pumpAndSettle();
      await enter(tester, 'task-description', 'Keep my draft');
      open(harness, b.id);
      await tester.pumpAndSettle();
      await enter(tester, 'task-next-action', 'Small step');
      open(harness, a.id);
      await tester.pumpAndSettle();
      for (final width in [360.0, 600.0, 999.0, 1000.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('task-description')))
              .controller!
              .text,
          'Keep my draft',
        );
        expect(tester.takeException(), isNull);
      }
      open(harness, b.id);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-next-action')))
            .controller!
            .text,
        'Small step',
      );
      expect(
        (await perform(
          tester,
          () => harness.repository.task(a.id),
        )).description,
        '',
      );
    },
  );

  testWidgets(
    'steps reorder and offer completion; task Trash restores notes and steps',
    (tester) async {
      final harness = await pumpShell(tester, size: const Size(1440, 1000));
      final task = (await perform(
        tester,
        () => harness.repository.createTask(const TaskDraft(title: 'Read')),
      ));
      final note = (await perform(
        tester,
        () => harness.repository.createNote(const NoteDraft(body: 'Keep')),
      ));
      await perform(
        tester,
        () => harness.repository.linkNote(note.id, task.id),
      );
      open(harness, task.id);
      await tester.pumpAndSettle();
      for (final title in ['First step', 'Second step']) {
        await enter(tester, 'new-subtask', title);
        await tapVisible(tester, find.byKey(const Key('add-subtask')));
      }
      await tapVisible(tester, find.byTooltip('Move step up').last);
      var steps = (await perform(
        tester,
        () => harness.repository.watchSubtasks(task.id).first,
      ));
      expect(steps.first.title, 'Second step');
      for (var index = 0; index < 2; index++) {
        await tapVisible(tester, find.byType(Checkbox).at(index));
      }
      expect(find.byKey(const Key('offer-complete-task')), findsOneWidget);
      expect(
        (await perform(tester, () => harness.repository.task(task.id))).status,
        TaskStatus.todo,
      );
      await tapVisible(tester, find.byKey(const Key('offer-complete-task')));
      expect(
        (await perform(tester, () => harness.repository.task(task.id))).status,
        TaskStatus.done,
      );
      await tapVisible(tester, find.byKey(const Key('trash-task')));
      expect(find.byKey(const Key('restore-task')), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('restore-task')));
      expect(
        (await perform(
          tester,
          () => harness.repository.task(task.id),
        )).deletedAt,
        isNull,
      );
      expect(
        await perform(tester, () => harness.repository.note(note.id)),
        note,
      );
      steps = (await perform(
        tester,
        () => harness.repository.watchSubtasks(task.id).first,
      ))!;
      expect(steps, hasLength(2));
      expect(steps.every((s) => s.completedAt != null), isTrue);
    },
  );

  testWidgets(
    'Today follows local midnight and planning-zone changes without rewriting deadlines',
    (tester) async {
      var now = DateTime.utc(2026, 10, 21, 15, 59, 59);
      final harness = await pumpShell(
        tester,
        clock: () => now,
        size: const Size(1440, 1000),
      );
      final task = (await perform(
        tester,
        () => harness.repository.createTask(
          TaskDraft(
            title: 'Due tonight',
            deadline: Deadline.dateOnly(
              CalendarDate(2026, 10, 21),
              'Asia/Manila',
            ),
          ),
        ),
      ));
      await perform(
        tester,
        () => harness.repository.setDailyPriorities(
          CalendarDate(2026, 10, 21),
          [task.id],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 selected'), findsOneWidget);
      expect(find.textContaining('Overdue ·'), findsNothing);
      now = DateTime.utc(2026, 10, 21, 16);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('0 of 3 selected'), findsOneWidget);
      expect(find.textContaining('Overdue ·'), findsOneWidget);
      await perform(
        tester,
        () => harness.repository.updateSettings(
          theme: ThemePreference.system,
          planningZone: 'UTC',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1 of 3 selected'),
        findsOneWidget,
      ); // same stored date, UTC still Oct 21
      expect(
        (await perform(
          tester,
          () => harness.repository.task(task.id),
        )).deadlineBoundaryUtc,
        task.deadlineBoundaryUtc,
      );
    },
  );

  testWidgets(
    'three-priority feedback and archive/trash filters on a narrow dark phone',
    (tester) async {
      final harness = await pumpShell(
        tester,
        platform: TargetPlatform.android,
        size: const Size(360, 1000),
        textScale: 2,
      );
      await perform(
        tester,
        () => harness.repository.updateSettings(
          theme: ThemePreference.dark,
          planningZone: 'UTC',
        ),
      );
      final tasks = <Task>[];
      for (var i = 0; i < 4; i++) {
        tasks.add(
          await perform(
            tester,
            () => harness.repository.createTask(TaskDraft(title: 'Choice $i')),
          ),
        );
      }
      for (final task in tasks) {
        open(harness, task.id);
        await tester.pumpAndSettle();
        await tapVisible(
          tester,
          find.byKey(const Key('toggle-daily-priority')),
        );
      }
      expect(
        find.textContaining('Choose at most three tasks.'),
        findsOneWidget,
      );
      await tapVisible(tester, find.byKey(const Key('task-advanced')));
      for (final key in [
        'deadline-kind',
        'target-zone',
        'remaining-estimate',
        'save-task',
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tapVisible(tester, find.byKey(const Key('archive-task')));
      expect(find.text('Archived'), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('back-to-tasks')));
      await tapVisible(tester, find.byKey(const Key('task-view')));
      await tester.tap(find.text('Archived').last);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('task-row-${tasks.last.id}')), findsOneWidget);
      await tapVisible(tester, find.text(tasks.last.title));
      await tapVisible(tester, find.text('Unarchive'));
      await tapVisible(tester, find.byKey(const Key('trash-task')));
      await tapVisible(tester, find.byKey(const Key('back-to-tasks')));
      await tapVisible(tester, find.byKey(const Key('task-view')));
      await tester.tap(find.text('Trash').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text(tasks.last.title));
      await tapVisible(tester, find.byKey(const Key('restore-task')));
      expect(
        (await perform(
          tester,
          () => harness.repository.task(tasks.last.id),
        )).deletedAt,
        isNull,
      );
      await tapVisible(tester, find.byKey(const Key('back-to-tasks')));
      await enter(tester, 'quick-capture', 'New task from Trash view');
      await tapVisible(tester, find.byKey(const Key('capture-task')));
      await tapVisible(tester, find.byKey(const Key('back-to-tasks')));
      expect(find.text('To do and Doing'), findsOneWidget);
      expect(find.text('New task from Trash view'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
