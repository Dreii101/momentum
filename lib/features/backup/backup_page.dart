import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../focus/focus_workflow.dart';
import '../focus/timer_engine.dart';
import '../focus/timer_providers.dart';
import 'backup_providers.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool confirmed = false;
  String? digest;
  @override
  Widget build(BuildContext context) {
    final view = ref.watch(backupControllerProvider);
    final controller = ref.read(backupControllerProvider.notifier);
    final preview = view.preview;
    if (preview?.digest != digest) {
      digest = preview?.digest;
      confirmed = false;
    }
    final active = ref.watch(timerViewProvider).value?.session;
    final unresolved = active != null && active.state != SessionState.finalized;
    void unfocus() => FocusManager.instance.primaryFocus?.unfocus();
    return WorkspaceScroll(
      storageKey: 'backup-scroll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref
                  .read(shellNavigationProvider.notifier)
                  .clearRecord(Destination.settings),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Settings'),
            ),
          ),
          Text(
            'Data and backups',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Space.lg),
          SectionCard(
            title: 'Keep a separate copy',
            description: 'Saved local data and recovery snapshots are not a separate-device backup. JSON backups are unencrypted and include your tasks, notes and history. Store and share them carefully.',
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                FilledButton.icon(
                  key: const Key('backup-export'),
                  onPressed: view.busy
                      ? null
                      : () {
                          unfocus();
                          controller.export();
                        },
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Export backup'),
                ),
                OutlinedButton.icon(
                  key: const Key('backup-inspect'),
                  onPressed: view.busy
                      ? null
                      : () {
                          unfocus();
                          confirmed = false;
                          controller.inspect();
                        },
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text('Choose and validate backup'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          if (view.message != null)
            Text(view.message!, key: const Key('backup-message')),
          if (view.error != null) ...[
            const SizedBox(height: Space.lg),
            ActionError(
              title: 'Backup operation could not finish',
              message: 'No partial replacement was saved. Review the details, then retry the operation. Unsaved note drafts are kept.',
              details: '${view.error}',
              retryLabel: 'Dismiss error',
              onRetry: () => ref.invalidate(backupControllerProvider),
            ),
          ],
          if (view.warning != null) ...[
            const SizedBox(height: Space.lg),
            Text(view.warning!, key: const Key('backup-warning')),
            TextButton(
              onPressed: () => ref
                  .read(shellNavigationProvider.notifier)
                  .selectRecord(Destination.settings, 'reminders'),
              child: const Text('Open reminders and retry'),
            ),
          ],
          if (preview != null) ...[
            const SizedBox(height: Space.xl),
            SectionCard(
              title: 'Validated backup preview',
              description:
                  'Exported ${preview.exportedAt.toIso8601String()} · ${preview.total} records. The checksum verifies payload integrity, not the identity of its creator.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in preview.counts.entries)
                    Text('${_label(entry.key)}: ${entry.value}'),
                  const SizedBox(height: Space.lg),
                  Text(
                    '${preview.unfinished} unfinished session(s) will return as interrupted reviews. Nothing will start or receive credit automatically.',
                  ),
                  const Text(
                    'Replace removes the current saved workspace and its links/history, then restores this dataset. It does not merge or synchronize. Other unsaved editor changes will be discarded. Note drafts must save successfully first. Installation identity and this device’s global reminder opt-in stay on this device.',
                  ),
                  const Text(
                    'Close other Momentum windows before replacing this workspace.',
                  ),
                  if (unresolved)
                    TextButton(
                      onPressed: () => openFocus(ref, 'session/${active.id}'),
                      child: const Text(
                        'Review the current session before replacing',
                      ),
                    ),
                  CheckboxListTile(
                    key: const Key('backup-confirm'),
                    contentPadding: EdgeInsets.zero,
                    value: confirmed,
                    onChanged: view.busy
                        ? null
                        : (value) => setState(() => confirmed = value!),
                    title: const Text(
                      'I understand that this unencrypted backup will replace my current saved workspace.',
                    ),
                  ),
                  FilledButton(
                    key: const Key('backup-replace'),
                    onPressed: view.busy || !confirmed || unresolved
                        ? null
                        : () {
                            unfocus();
                            controller.replace(confirmed: confirmed);
                          },
                    child: const Text('Replace saved workspace'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Space.xl),
          SectionCard(
            title: 'Local recovery snapshots',
            description: 'The latest three verified snapshots are kept before replacement or schema migration. They contain device-local SQLite data, are unencrypted, and stay in application-support storage. They do not protect against loss of this device. Choose one to validate a portable preview before replacing.',
            child: ref
                .watch(recoveryFilesProvider)
                .when(
                  loading: () => const LoadingState(
                    message: 'Reading recovery snapshots…',
                  ),
                  error: (e, _) => ActionError(
                    title: 'Could not read snapshots',
                    message: 'Retry to inspect local recovery files.',
                    details: '$e',
                    onRetry: () => ref.invalidate(recoveryFilesProvider),
                  ),
                  data: (files) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (files.isEmpty)
                        const Text(
                          'No recovery snapshots yet. One is required before a replacement or migration can proceed.',
                        ),
                      for (final file in files)
                        TextButton.icon(
                          onPressed: view.busy
                              ? null
                              : () {
                                  unfocus();
                                  confirmed = false;
                                  controller.inspect(file);
                                },
                          icon: const Icon(Icons.history),
                          label: Text(
                            'Validate recovery from ${file.lastModifiedSync().toLocal()}',
                          ),
                        ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

String _label(String key) => const {
  'courses': 'Courses',
  'tasks': 'Tasks',
  'subtasks': 'Subtasks',
  'notes': 'Notes',
  'note_task_links': 'Task–note links',
  'daily_priorities': 'Daily priorities',
  'app_settings': 'Preferences',
  'activity_series': 'Activity series',
  'activity_exceptions': 'Occurrence changes',
  'note_activity_links': 'Activity–note links',
  'planned_work_blocks': 'Planned work',
  'focus_sessions': 'Sessions',
  'focus_segments': 'Session evidence',
  'reminder_preferences_rows': 'Quiet hours',
  'reminder_rules': 'Reminder choices',
  'weekly_reflections': 'Weekly reflections',
}[key]!;
