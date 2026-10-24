import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import 'task_controls.dart';
import 'task_editor.dart';
import 'task_workflow.dart';

enum TaskView { active, completed, archived, trash }

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key, required this.split});
  final bool split;
  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final capture = TextEditingController(), search = TextEditingController();
  final drafts = <String, TaskEditBuffer>{};
  TaskView view = TaskView.active;
  bool busy = false;
  Object? error;
  @override
  void dispose() {
    capture.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> create() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final task = await (await ref.read(repositoryProvider.future))
          .createTask(TaskDraft(title: capture.text));
      if (!mounted) return;
      capture.clear();
      setState(() => view = TaskView.active);
      openTask(ref, task.id);
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool matches(Task task) {
    final visible = switch (view) {
      TaskView.active =>
        task.deletedAt == null &&
            task.archivedAt == null &&
            task.status != TaskStatus.done,
      TaskView.completed =>
        task.deletedAt == null &&
            task.archivedAt == null &&
            task.status == TaskStatus.done,
      TaskView.archived => task.deletedAt == null && task.archivedAt != null,
      TaskView.trash => task.deletedAt != null,
    };
    return visible &&
        ('${task.title} ${task.description} ${task.nextAction ?? ''}')
            .toLowerCase()
            .contains(search.text.toLowerCase().trim());
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.tasks];
    final rows = ref.watch(taskRecordsProvider);
    final now = ref.watch(workflowInstantProvider);
    void back() => ref
        .read(shellNavigationProvider.notifier)
        .clearRecord(Destination.tasks);
    final list = WorkspaceScroll(
      storageKey: 'task-list-scroll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Space.lg),
          TextField(
            key: const Key('quick-capture'),
            enabled: !busy,
            controller: capture,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'What needs doing?',
              helperText: 'A title is enough. Up to 200 characters.',
            ),
            onSubmitted: (_) => create(),
          ),
          const SizedBox(height: Space.sm),
          FilledButton(
            key: const Key('capture-task'),
            onPressed: busy ? null : create,
            child: Text(busy ? 'Saving…' : 'Add task'),
          ),
          if (error != null) ...[
            const SizedBox(height: Space.md),
            ActionError(
              title: 'Task was not saved',
              message:
                  'Your title is still here. ${error is ArgumentError ? 'Enter a title of 1–200 characters.' : 'Check storage access and retry.'}',
              details: error.toString(),
              onRetry: create,
            ),
          ],
          const SizedBox(height: Space.xl),
          TextField(
            key: const Key('task-search'),
            controller: search,
            decoration: const InputDecoration(
              labelText: 'Search tasks',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Space.lg),
          KeyedSubtree(
            key: const Key('task-view'),
            child: DropdownButtonFormField<TaskView>(
              key: ValueKey(view),
              initialValue: view,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Show'),
              items: [
                for (final value in TaskView.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(switch (value) {
                      TaskView.active => 'To do and Doing',
                      TaskView.completed => 'Completed',
                      TaskView.archived => 'Archived',
                      TaskView.trash => 'Trash',
                    }),
                  ),
              ],
              onChanged: (value) => setState(() => view = value!),
            ),
          ),
          const SizedBox(height: Space.lg),
          rows.when(
            loading: () => const LoadingState(message: 'Loading tasks…'),
            error: (e, _) => ActionError(
              title: 'Could not load tasks',
              message: 'Your records are preserved. Retry to load them.',
              details: e.toString(),
              onRetry: () => ref.invalidate(taskRecordsProvider),
            ),
            data: (all) {
              final filtered = all.where(matches).toList();
              return filtered.isEmpty
                  ? Text(
                      view == TaskView.trash
                          ? 'Trash is empty. Deleted tasks can be restored here.'
                          : 'No tasks in this view. Capture a small next step above.',
                    )
                  : Column(
                      children: [
                        for (final task in filtered)
                          TaskSummary(
                            key: ValueKey('task-row-${task.id}'),
                            task: task,
                            now: now,
                            onOpen: () => openTask(ref, task.id),
                          ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
    final detail = selected == null
        ? const WorkspaceScroll(
            child: EmptyState(
              icon: Icons.check_circle_outline,
              title: 'One manageable next step',
              message: 'Choose a task to edit its details, break it down, or select it for Today.',
            ),
          )
        : TaskEditor(
            key: ValueKey(selected),
            taskId: selected,
            onBack: back,
            bufferFor: (row, zone) =>
                drafts.putIfAbsent(row.id, () => TaskEditBuffer(row, zone)),
          );
    return PopScope(
      canPop: widget.split || selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: LayoutBuilder(
        builder: (context, size) => Row(
          children: [
            if (widget.split || selected == null)
              SizedBox(
                width: widget.split
                    ? (size.maxWidth * .38).clamp(260, 360)
                    : size.maxWidth,
                child: list,
              ),
            if (widget.split) const VerticalDivider(width: 1),
            if (widget.split || selected != null) Expanded(child: detail),
          ],
        ),
      ),
    );
  }
}
