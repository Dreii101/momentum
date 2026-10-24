import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/recovery_snapshots.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/backup/backup_providers.dart';
import 'package:momentum/features/backup/backup_service.dart';
import 'package:momentum/features/focus/timer_coordinator.dart';
import 'package:momentum/features/focus/timer_engine.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/focus/timer_store.dart';
import 'package:momentum/features/notes/note_providers.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:momentum/features/reminders/reminder_coordinator.dart';
import 'package:momentum/features/reminders/reminder_providers.dart';
import 'package:momentum/features/reminders/reminder_store.dart';

import 'support/backup_fixture.dart';
import 'support/database_fixture.dart';
import 'support/progress_fixture.dart';
import 'support/fake_notifications.dart';
import 'task_widgets_test.dart' show perform, tapVisible;
import 'timer_engine_test.dart' show FakeTimerClock;

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'backup cancellation, validation, confirmation, drafts, replacement and notification failure on $platform',
      (tester) async {
        tester.view.physicalSize = const Size(390, 950);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        tester.platformDispatcher.platformBrightnessTestValue =
            platform == TargetPlatform.windows
            ? Brightness.dark
            : Brightness.light;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final fixture = (await tester.runAsync(DatabaseFixture.create))!,
            origin = (await tester.runAsync(DatabaseFixture.create))!;
        addTearDown(() async {
          await tester.runAsync(fixture.dispose);
          await tester.runAsync(origin.dispose);
        });
        final stores = (await tester.runAsync(() async {
          final target = MomentumRepository(
            fixture.open(),
            clock: () => DateTime.utc(2026, 10, 22, 8),
          );
          final source = MomentumRepository(
            origin.open(),
            clock: () => DateTime.utc(2026, 10, 22, 8),
          );
          await seedBackup(source);
          await target.initialize();
          return (target, source);
        }))!;
        final repo = stores.$1, source = stores.$2;
        final files = MemoryBackupFiles();
        final service = BackupService(
          repo,
          fixture.file,
          RecoverySnapshots.forDatabase(fixture.file),
          files,
        );
        final exporter = BackupService(
          source,
          origin.file,
          RecoverySnapshots.forDatabase(origin.file),
          files,
        );
        files.bytes = await tester.runAsync(exporter.exportBytes);
        final validBytes = files.bytes!;
        final oldNote = await perform(
          tester,
          () => repo.createNote(const NoteDraft(title: 'Original draft')),
        );
        final clock = FakeTimerClock()..wall = DateTime.utc(2026, 10, 22, 8);
        final timer = TimerCoordinator(TimerStore(repo), clock, period: null);
        final native = FakeNotifications();
        final reminderStore = ReminderStore(repo);
        final reminders = ReminderCoordinator(
          reminderStore,
          native,
          clock,
          onResponse: (_) async {},
        );
        await perform(tester, timer.initialize);
        await perform(tester, reminders.initialize);
        await perform(
          tester,
          () => reminderStore.preferences(
            enabled: true,
            quietEnabled: false,
            start: 1320,
            end: 420,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWith((ref) => repo),
            backupServiceProvider.overrideWith((ref) => service),
            timerCoordinatorProvider.overrideWith((ref) => timer),
            reminderCoordinatorProvider.overrideWith((ref) => reminders),
            clockProvider.overrideWithValue(() => clock.wall),
          ],
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          await perform(tester, timer.close);
          await perform(tester, reminders.close);
          await native.callbacks.close();
          await tester.pump();
          await tester.pump();
        });
        container
            .read(shellNavigationProvider.notifier)
            .selectRecord(Destination.settings, 'data');
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MomentumApp(showDevelopment: false, platform: platform),
          ),
        );
        await tester.pumpAndSettle();
        files.cancelPick = true;
        await perform(
          tester,
          container.read(backupControllerProvider.notifier).inspect,
        );
        expect(
          find.text('Selection cancelled. No data changed.'),
          findsOneWidget,
        );
        expect(container.read(backupControllerProvider).preview, isNull);
        files.cancelPick = false;
        files.bytes = Uint8List.fromList([255]);
        await perform(
          tester,
          container.read(backupControllerProvider.notifier).inspect,
        );
        expect(find.text('Backup operation could not finish'), findsOneWidget);
        expect(find.byKey(const Key('backup-replace')), findsNothing);
        files.bytes = validBytes;
        await perform(
          tester,
          container.read(backupControllerProvider.notifier).inspect,
        );
        expect(find.text('Validated backup preview'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.byKey(const Key('backup-replace')))
              .onPressed,
          isNull,
        );
        for (final width in [700.0, 1280.0, 390.0]) {
          tester.view.physicalSize = Size(width, 950);
          await tester.pumpAndSettle();
          expect(find.text('Validated backup preview'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        files.failSave = true;
        await perform(
          tester,
          container.read(backupControllerProvider.notifier).export,
        );
        expect(container.read(backupControllerProvider).message, isNull);
        expect(container.read(backupControllerProvider).error, isNotNull);
        files.failSave = false;
        // A failed note autosave cannot silently lose its draft during replacement.
        await perform(
          tester,
          () => repo.database.customStatement(
            "CREATE TRIGGER refuse_draft BEFORE UPDATE ON notes BEGIN SELECT RAISE(ABORT,'draft save failed'); END",
          ),
        );
        final draft = container.read(noteDraftsProvider).open(oldNote);
        draft.body.text = 'Keep this if the write fails';
        await tapVisible(tester, find.byKey(const Key('backup-confirm')));
        await perform(
          tester,
          () => container
              .read(backupControllerProvider.notifier)
              .replace(confirmed: true),
        );
        expect(container.read(backupControllerProvider).error, isNotNull);
        expect(draft.body.text, 'Keep this if the write fails');
        expect(
          (await perform(tester, () => repo.note(oldNote.id))).title,
          'Original draft',
        );
        await perform(
          tester,
          () => repo.database.customStatement('DROP TRIGGER refuse_draft'),
        );
        native.failSchedule = true;
        await perform(
          tester,
          () => container
              .read(backupControllerProvider.notifier)
              .replace(confirmed: true),
        );
        expect(container.read(backupControllerProvider).error, isNull);
        expect(container.read(backupControllerProvider).warning, isNotNull);
        expect(
          container.read(backupControllerProvider).message,
          startsWith('Replacement saved.'),
        );
        expect(container.read(shellNavigationProvider).workspaceVersion, 1);
        expect(timer.view.session!.state, SessionState.awaitingReview);
        expect(
          (await perform(
            tester,
            () => repo.progressSnapshot(fixtureWeek, 'Asia/Manila'),
          )).reportedMs,
          390000,
        );
        expect(tester.takeException(), isNull);
        await perform(tester, timer.close);
        await perform(tester, reminders.close);
      },
    );
  }
}
