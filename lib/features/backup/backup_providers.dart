import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/database/providers.dart';
import '../../core/database/recovery_snapshots.dart';
import '../focus/timer_providers.dart';
import '../focus/timer_engine.dart';
import '../notes/note_providers.dart';
import '../reminders/reminder_providers.dart';
import 'backup_codec.dart';
import 'backup_service.dart';

final backupFilesProvider = Provider<BackupFiles>((ref) => BackupFiles());
final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  final file = await ref.watch(databaseFileProvider)();
  return BackupService(
    repo,
    file,
    RecoverySnapshots.forDatabase(file),
    ref.watch(backupFilesProvider),
  );
}, retry: (count, error) => null);

final recoveryFilesProvider = FutureProvider.autoDispose<List<File>>(
  (ref) async =>
      (await ref.watch(backupServiceProvider.future)).snapshots.listSync(),
  retry: (count, error) => null,
);

class BackupView {
  const BackupView({
    this.busy = false,
    this.preview,
    this.message,
    this.error,
    this.warning,
  });
  final bool busy;
  final ValidatedBackup? preview;
  final String? message, warning;
  final Object? error;
}

final backupControllerProvider = NotifierProvider<BackupController, BackupView>(
  BackupController.new,
);

class BackupController extends Notifier<BackupView> {
  @override
  BackupView build() => const BackupView();

  Future<void> _run(
    Future<void> Function() action, {
    bool keepPreview = true,
  }) async {
    if (state.busy) return;
    state = BackupView(busy: true, preview: keepPreview ? state.preview : null);
    try {
      await action();
    } catch (e) {
      state = BackupView(busy: true, preview: state.preview, error: e);
    } finally {
      state = BackupView(
        preview: state.preview,
        message: state.message,
        error: state.error,
        warning: state.warning,
      );
      ref.invalidate(recoveryFilesProvider);
    }
  }

  Future<void> _flushNotes() async {
    final notes = ref.read(noteDraftsProvider);
    await notes.flushAll();
    if (notes.unsaved.isNotEmpty) {
      throw StateError(
        'Some note edits could not save. Retry or copy them before continuing.',
      );
    }
  }

  Future<void> export() => _run(() async {
    await _flushNotes();
    final timer = await ref.read(timerCoordinatorProvider.future);
    if (timer.view.session?.state == SessionState.running ||
        timer.view.session?.state == SessionState.paused) {
      await timer.checkpoint();
    }
    final uri = await (await ref.read(backupServiceProvider.future)).export();
    state = BackupView(
      busy: true,
      preview: state.preview,
      message: uri == null ? 'Export cancelled. No backup was saved.' : 'Backup file saved successfully. Keep a copy away from this device.',
    );
  });

  Future<void> inspect([File? recovery]) => _run(() async {
    final service = await ref.read(backupServiceProvider.future);
    final preview = recovery == null
        ? await service.inspect()
        : await service.inspectRecovery(recovery);
    state = BackupView(
      busy: true,
      preview: preview,
      message: preview == null
          ? 'Selection cancelled. No data changed.'
          : 'Validation passed. Your current data has not changed.',
    );
  }, keepPreview: false);

  Future<void> replace({required bool confirmed}) => _run(() async {
    final preview = state.preview;
    if (!confirmed || preview == null) {
      throw StateError(
        'Validate a backup and explicitly confirm replacement first.',
      );
    }
    await _flushNotes();
    final timer = await ref.read(timerCoordinatorProvider.future);
    final reminders = await ref.read(reminderCoordinatorProvider.future);
    final service = await ref.read(backupServiceProvider.future);
    await timer.withDataReplacement(
      () => reminders.withDataReplacement(() => service.replace(preview)),
    );
    state = const BackupView(
      busy: true,
      message: 'Replacement saved. A recovery snapshot of the previous data is kept on this device.',
    );
    ref.invalidate(noteDraftsProvider);
    ref.read(shellNavigationProvider.notifier).resetAfterReplacement();
    // OS reconciliation follows the commit and must never undo restored data.
    try {
      await reminders.reconcile(refreshStatus: true);
      final view = reminders.view;
      if (view.error != null ||
          view.registrations.any((r) => r.error != null)) {
        throw StateError(
          'Reminder cleanup or scheduling needs attention. Open Reminders to retry.',
        );
      }
      if (timer.view.error != null) {
        throw StateError(
          'The timer view could not reload. Reopen Momentum before using a session.',
        );
      }
    } catch (e) {
      state = BackupView(
        busy: true,
        message: state.message,
        warning: 'Replacement succeeded. $e',
      );
    }
  });
}
