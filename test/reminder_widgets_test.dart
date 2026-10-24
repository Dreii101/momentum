import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_widgets_test.dart' show perform;

import 'package:momentum/app/navigation.dart';
import 'package:momentum/app/design_system.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/reminders/reminder_providers.dart';
import 'package:momentum/features/reminders/reminder_store.dart';
import 'package:momentum/features/reminders/reminder_coordinator.dart';
import 'package:momentum/features/reminders/reminder_page.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/reminders/reminder_types.dart';

import 'support/fake_notifications.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'reminder permission context, denial, quiet validation, resizing and retry on $platform',
      (tester) async {
        tester.view.physicalSize = const Size(390, 850);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final db = AppDatabase(NativeDatabase.memory());
        final now = DateTime.utc(2026, 10, 22, 2);
        final repo = MomentumRepository(db, clock: () => now);
        await perform(tester, repo.initialize);
        final fake = FakeNotifications()..allowed = false;
        final store = ReminderStore(repo);
        final owner = ReminderCoordinator(
          store,
          fake,
          SystemTimerClock(wallClock: () => now, epoch: 'widgets'),
          onResponse: (_) async {},
        );
        await perform(tester, () async {
          await store.initialize();
          await owner.reconcile();
        });
        final container = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWith((ref) => repo),
            reminderCoordinatorProvider.overrideWith((ref) => owner),
          ],
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          owner.dispose();
          await tester.pump();
          await perform(tester, db.close);
          await fake.callbacks.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: momentumTheme(
                platform == TargetPlatform.windows
                    ? Brightness.dark
                    : Brightness.light,
                platform: platform,
              ),
              home: const Scaffold(body: ReminderPage()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(fake.permissions, 0);
        expect(fake.capabilityReads, 0);
        container
            .read(shellNavigationProvider.notifier)
            .selectRecord(Destination.settings, 'reminders');
        await tester.pumpAndSettle();
        final toggle = find.descendant(
          of: find.widgetWithText(SwitchListTile, 'Enable reminders'),
          matching: find.byType(Switch),
        );
        await tester.ensureVisible(toggle);
        await tester.pumpAndSettle();
        await tester.tap(toggle);
        await perform(tester, () async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();
        expect(fake.permissions, 1);
        expect(find.text('Permission denied'), findsOneWidget);
        final task = await perform(
          tester,
          () => repo.createTask(
            TaskDraft(
              title: 'A long deadline title for enlarged text and a narrow phone screen that must remain readable without overflowing the reminder selection control',
              deadline: Deadline.timed(
                now.add(const Duration(hours: 4)),
                'Asia/Manila',
              ),
            ),
          ),
        );
        await perform(tester, () async {
          await owner.store.setRule(ReminderKind.deadline, task.id);
          await owner.reconcile();
        });
        await tester.pumpAndSettle();
        expect(
          (await perform(tester, owner.store.registrations)).single.state,
          RegistrationState.scheduleFailed,
        );
        fake.allowed = true;
        await perform(tester, () => owner.reconcile(refreshStatus: true));
        await tester.pumpAndSettle();
        expect(fake.items, hasLength(1));
        final sourcePicker = find.byWidgetPredicate(
          (w) => w is DropdownButtonFormField<String>,
        );
        await tester.ensureVisible(sourcePicker);
        await tester.pumpAndSettle();
        await tester.tap(sourcePicker);
        await tester.pumpAndSettle();
        await tester.tap(find.text(task.title).last);
        await tester.pumpAndSettle();
        final saveRule = find.text('Save reminder rule');
        await tester.ensureVisible(saveRule);
        await tester.pumpAndSettle();
        await tester.tap(saveRule);
        await perform(tester, () => owner.reconcile());
        expect(tester.takeException(), isNull);
        final quietStart = find.widgetWithText(
          TextField,
          'Quiet start (HH:MM)',
        );
        await tester.ensureVisible(quietStart);
        await tester.pumpAndSettle();
        await tester.enterText(quietStart, '25:99');
        tester.view.physicalSize = const Size(1280, 900);
        await tester.pumpAndSettle();
        final save = find.text('Save quiet hours');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.text('25:99'), findsOneWidget);
        expect(find.text('Reminder action needs attention'), findsOneWidget);
        expect(tester.takeException(), isNull);
        final quietEnd = find.widgetWithText(TextField, 'Quiet end (HH:MM)');
        await tester.ensureVisible(quietEnd);
        await tester.enterText(quietEnd, '08:30');
        tester.view.physicalSize = const Size(700, 900);
        await tester.pumpAndSettle();
        expect(find.text('08:30'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          (await perform(tester, () => repo.task(task.id))).title,
          task.title,
        );
        owner.dispose();
      },
    );
  }
}
