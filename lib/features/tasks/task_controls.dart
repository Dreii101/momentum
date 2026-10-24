import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import 'task_workflow.dart';
import '../focus/focus_workflow.dart';

void openTask(WidgetRef ref, String id) => ref
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.tasks, id);

/// Commit feedback belongs to the initiating control, not an optimistic cache.
class TaskActions extends ConsumerStatefulWidget {
  const TaskActions({super.key, required this.task});
  final Task task;
  @override
  ConsumerState<TaskActions> createState() => _TaskActionsState();
}

class _TaskActionsState extends ConsumerState<TaskActions> {
  bool busy = false;
  Object? error;
  Future<void> Function(MomentumRepository)? retry;
  Future<void> run(
    Future<void> Function(MomentumRepository) command, {
    String? undoLabel,
    Future<void> Function(MomentumRepository)? undo,
  }) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retry = command;
    });
    try {
      final repo = await ref.read(repositoryProvider.future);
      await command(repo);
      if (!mounted) return;
      if (undo != null) {
        final messenger = ScaffoldMessenger.of(context);
        Future<void> undoSavedChange() async {
          try {
            await undo(repo);
          } catch (_) {
            if (messenger.mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: const Text(
                    'Undo was not saved. Retry or restore the task from its list.',
                  ),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: undoSavedChange,
                  ),
                ),
              );
            }
          }
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(undoLabel!),
            action: SnackBarAction(label: 'Undo', onPressed: undoSavedChange),
          ),
        );
      }
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final deleted = task.deletedAt != null, archived = task.archivedAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          deleted
              ? 'In Trash'
              : archived
              ? 'Archived'
              : task.status == TaskStatus.done
              ? 'Done'
              : task.status == TaskStatus.doing
              ? 'Doing'
              : 'To do',
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            if (deleted)
              FilledButton(
                key: const Key('restore-task'),
                onPressed: busy
                    ? null
                    : () => run((r) => r.deleteTask(task.id, deleted: false)),
                child: const Text('Restore from Trash'),
              )
            else ...[
              if (archived)
                FilledButton(
                  onPressed: busy
                      ? null
                      : () =>
                            run((r) => r.archiveTask(task.id, archived: false)),
                  child: const Text('Unarchive'),
                )
              else ...[
                FilledButton(
                  key: const Key('complete-task'),
                  onPressed: busy
                      ? null
                      : () => run(
                          (r) => task.status == TaskStatus.done
                              ? r.setTaskStatus(task.id, TaskStatus.todo)
                              : completeTaskWithReview(ref, r, task.id),
                        ),
                  child: Text(
                    task.status == TaskStatus.done
                        ? 'Reopen task'
                        : 'Complete task',
                  ),
                ),
                if (task.status != TaskStatus.done)
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => run(
                            (r) => r.setTaskStatus(
                              task.id,
                              task.status == TaskStatus.doing
                                  ? TaskStatus.todo
                                  : TaskStatus.doing,
                            ),
                          ),
                    child: Text(
                      task.status == TaskStatus.doing
                          ? 'Move to To do'
                          : 'Mark Doing',
                    ),
                  ),
                OutlinedButton(
                  key: const Key('archive-task'),
                  onPressed: busy
                      ? null
                      : () => run(
                          (r) => r.archiveTask(task.id),
                          undoLabel: 'Task archived.',
                          undo: (r) => r.archiveTask(task.id, archived: false),
                        ),
                  child: const Text('Archive'),
                ),
              ],
              OutlinedButton(
                key: const Key('trash-task'),
                onPressed: busy
                    ? null
                    : () => run(
                        (r) => r.deleteTask(task.id),
                        undoLabel: 'Task moved to Trash.',
                        undo: (r) => r.deleteTask(task.id, deleted: false),
                      ),
                child: const Text('Move to Trash'),
              ),
            ],
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.md),
            child: ActionError(
              title: 'The change was not saved',
              message: 'Your task is preserved. Check available storage and try again.',
              details: error.toString(),
              onRetry: () => run(retry!),
            ),
          ),
      ],
    );
  }
}

class DailyPriorityButton extends ConsumerStatefulWidget {
  const DailyPriorityButton({super.key, required this.task});
  final Task task;
  @override
  ConsumerState<DailyPriorityButton> createState() =>
      _DailyPriorityButtonState();
}

class _DailyPriorityButtonState extends ConsumerState<DailyPriorityButton> {
  bool busy = false;
  Object? error;
  Future<void> toggle(CalendarDate day) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await (await ref.read(repositoryProvider.future))
          .toggleDailyPriority(day, widget.task.id);
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final day = localDay(
      ref.watch(workflowInstantProvider),
      settings.planningZone,
    );
    final priorities = ref.watch(dailyTasksProvider(day));
    return priorities.when(
      loading: () => const Text('Loading daily priorities…'),
      error: (e, _) => ActionError(
        title: 'Could not load priorities',
        message: 'Your selection has not been replaced.',
        details: e.toString(),
        onRetry: () => ref.invalidate(dailyTasksProvider(day)),
      ),
      data: (rows) {
        final selected = rows.any((r) => r.id == widget.task.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              key: const Key('toggle-daily-priority'),
              onPressed: busy ? null : () => toggle(day),
              icon: Icon(selected ? Icons.star : Icons.star_border),
              label: Text(
                selected ? 'Remove from Today’s three' : 'Choose for Today',
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const Text(
                'Choose at most three tasks. Remove one on Today to make room.',
              ),
            ],
          ],
        );
      },
    );
  }
}

class TaskSummary extends StatelessWidget {
  const TaskSummary({
    super.key,
    required this.task,
    required this.now,
    required this.onOpen,
    this.onStart,
  });
  final Task task;
  final DateTime now;
  final VoidCallback onOpen;
  final VoidCallback? onStart;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: onOpen,
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            task.status == TaskStatus.done
                ? 'Completed'
                : isTaskOverdue(task, now)
                ? 'Overdue · choose a manageable next step'
                : '${task.priority.name} priority',
          ),
          if (task.nextAction?.isNotEmpty ?? false)
            Text('Next: ${task.nextAction!}'),
          if (task.deadlineKind != DeadlineKind.none) Text(deadlineLabel(task)),
          if (task.targetUtc != null)
            Text(
              'Internal target: ${localInput(task.targetUtc!, task.deadlineZone ?? 'UTC')} · ${task.deadlineZone ?? 'UTC'}',
            ),
          if (onStart != null && task.status != TaskStatus.done)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: ValueKey('start-${task.id}'),
                onPressed: onStart,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Start'),
              ),
            ),
        ],
      ),
    ),
  );
}
