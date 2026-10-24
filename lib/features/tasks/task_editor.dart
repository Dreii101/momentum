import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import 'subtasks_editor.dart';
import 'task_controls.dart';
import 'task_workflow.dart';
import '../notes/note_relationships.dart';
import '../focus/focus_workflow.dart';

class TaskEditor extends ConsumerStatefulWidget {
  const TaskEditor({
    super.key,
    required this.taskId,
    required this.bufferFor,
    required this.onBack,
  });
  final String taskId;
  final TaskEditBuffer Function(Task, String) bufferFor;
  final VoidCallback onBack;
  @override
  ConsumerState<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<TaskEditor> {
  TaskEditBuffer? buffer;
  final controllers = <String, TextEditingController>{};
  bool busy = false;
  Object? error;
  String? feedback;
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget field(
    String key,
    String label,
    String value,
    ValueChanged<String> update, {
    String? helper,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: Space.lg),
    child: TextFormField(
      enabled: !busy,
      key: Key(key),
      controller: controllers.putIfAbsent(
        key,
        () => TextEditingController(text: value),
      ),
      minLines: lines,
      maxLines: lines == 1 ? 1 : 6,
      decoration: InputDecoration(labelText: label, helperText: helper),
      onChanged: (text) {
        update(text);
        setState(() {
          buffer!.dirty = true;
          feedback = null;
        });
      },
    ),
  );
  Future<void> save(Task row) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      feedback = null;
    });
    try {
      final draft = buffer!.toDraft(row.status);
      final saved = await (await ref.read(repositoryProvider.future))
          .updateTaskDetails(row.id, draft);
      buffer!.original = saved;
      buffer!.originalDate = buffer!.date;
      buffer!.originalTime = buffer!.time;
      buffer!.originalZone = buffer!.zone;
      buffer!.originalTargetDate = buffer!.targetDate;
      buffer!.originalTargetTime = buffer!.targetTime;
      buffer!.originalTargetZone = buffer!.targetZone;
      buffer!.dirty = false;
      if (mounted) setState(() => feedback = 'Saved on this device.');
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(taskRecordProvider(widget.taskId));
    final preferences = ref.watch(settingsProvider);
    if (preferences.hasError) {
      return WorkspaceScroll(
        child: ActionError(
          title: 'Could not load task preferences',
          message: 'Retry before editing time-zone-dependent fields. Your draft is preserved.',
          details: preferences.error.toString(),
          onRetry: () => ref.invalidate(settingsProvider),
        ),
      );
    }
    if (!preferences.hasValue) {
      return const WorkspaceScroll(
        child: LoadingState(message: 'Loading task preferences…'),
      );
    }
    final zone = preferences.requireValue.planningZone;
    return record.when(
      loading: () =>
          const WorkspaceScroll(child: LoadingState(message: 'Loading task…')),
      error: (e, _) => WorkspaceScroll(
        child: ActionError(
          title: 'Could not load task',
          message: 'Your changes have not been discarded.',
          details: e.toString(),
          onRetry: () => ref.invalidate(taskRecordProvider(widget.taskId)),
        ),
      ),
      data: (row) {
        if (row == null) {
          return WorkspaceScroll(
            child: Column(
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Back to tasks'),
                ),
                const Text(
                  'This task could not be found. Choose another saved task.',
                ),
              ],
            ),
          );
        }
        final draft = buffer ??= widget.bufferFor(row, zone);
        final available = row.deletedAt == null && row.archivedAt == null;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
              if (available) save(row);
            },
          },
          child: WorkspaceScroll(
            storageKey: 'task-detail-${row.id}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('back-to-tasks'),
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Task list'),
                  ),
                ),
                Text(
                  row.title,
                  key: const Key('task-detail-title'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Space.md),
                TaskActions(key: ValueKey('actions-${row.id}'), task: row),
                if (!available) ...[
                  const SizedBox(height: Space.lg),
                  const Text(
                    'Restore this task to edit it. Its notes and steps are preserved.',
                  ),
                  Text(row.description),
                  Text(deadlineLabel(row)),
                ] else ...[
                  const SizedBox(height: Space.lg),
                  DailyPriorityButton(task: row),
                  const SizedBox(height: Space.xl),
                  SectionCard(
                    title: 'Begin with something small',
                    description: 'Choose a small next action, then decide when to start.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          row.nextAction?.isNotEmpty == true ? row.nextAction! : 'What is the smallest useful action? Add it below, or begin with the first step.',
                        ),
                        const SizedBox(height: Space.lg),
                        FilledButton(
                          key: const Key('task-open-starter'),
                          onPressed: row.status == TaskStatus.done
                              ? null
                              : () => openStarter(ref, row.id),
                          child: const Text('Prepare a two-minute start'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  field(
                    'task-title',
                    'Title',
                    draft.title,
                    (v) => draft.title = v,
                    helper: 'Required · 1–200 characters',
                  ),
                  field(
                    'task-next-action',
                    'Next action (optional)',
                    draft.nextAction,
                    (v) => draft.nextAction = v,
                    helper: 'For example: open the assignment and read the first question.',
                  ),
                  field(
                    'task-description',
                    'Description (optional)',
                    draft.description,
                    (v) => draft.description = v,
                    lines: 3,
                  ),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: draft.priority,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: [
                      for (final p in TaskPriority.values)
                        DropdownMenuItem(value: p, child: Text(p.name)),
                    ],
                    onChanged: busy
                        ? null
                        : (p) => setState(() {
                            draft.priority = p!;
                            draft.dirty = true;
                          }),
                  ),
                  const SizedBox(height: Space.lg),
                  OutlinedButton(
                    key: const Key('task-advanced'),
                    onPressed: () =>
                        setState(() => draft.advanced = !draft.advanced),
                    child: Text(
                      draft.advanced
                          ? 'Hide optional planning fields'
                          : 'Course, deadline and estimate',
                    ),
                  ),
                  if (draft.advanced) ...[
                    const SizedBox(height: Space.lg),
                    ref
                        .watch(taskCoursesProvider)
                        .when(
                          loading: () => const Text('Loading courses…'),
                          error: (e, _) => ActionError(
                            title: 'Could not load courses',
                            message: 'The task’s current course is preserved.',
                            details: e.toString(),
                            onRetry: () => ref.invalidate(taskCoursesProvider),
                          ),
                          data: (courses) => DropdownButtonFormField<String>(
                            initialValue: draft.courseId ?? '',
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Course (optional)',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('No course'),
                              ),
                              for (final c in courses.where(
                                (c) =>
                                    (c.deletedAt == null &&
                                        c.archivedAt == null) ||
                                    c.id == draft.courseId,
                              ))
                                DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name +
                                        (c.deletedAt != null
                                            ? ' (deleted)'
                                            : c.archivedAt != null
                                            ? ' (archived)'
                                            : ''),
                                  ),
                                ),
                            ],
                            onChanged: busy
                                ? null
                                : (v) => setState(() {
                                    draft.courseId = v == '' ? null : v;
                                    draft.dirty = true;
                                  }),
                          ),
                        ),
                    const SizedBox(height: Space.lg),
                    DropdownButtonFormField<DeadlineKind>(
                      key: const Key('deadline-kind'),
                      initialValue: draft.kind,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Official deadline',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DeadlineKind.none,
                          child: Text('No deadline'),
                        ),
                        DropdownMenuItem(
                          value: DeadlineKind.dateOnly,
                          child: Text('Date only (all day)'),
                        ),
                        DropdownMenuItem(
                          value: DeadlineKind.timed,
                          child: Text('Date and time'),
                        ),
                      ],
                      onChanged: busy
                          ? null
                          : (v) => setState(() {
                              draft.kind = v!;
                              draft.dirty = true;
                            }),
                    ),
                    const SizedBox(height: Space.lg),
                    if (draft.kind != DeadlineKind.none) ...[
                      field(
                        'deadline-date',
                        'Deadline date',
                        draft.date,
                        (v) => draft.date = v,
                        helper: 'YYYY-MM-DD',
                      ),
                      if (draft.kind == DeadlineKind.timed)
                        field(
                          'deadline-time',
                          'Deadline time',
                          draft.time,
                          (v) => draft.time = v,
                          helper: 'HH:MM · 24-hour',
                        ),
                      field(
                        'deadline-zone',
                        'Deadline time zone',
                        draft.zone,
                        (v) => draft.zone = v,
                        helper: 'IANA name, for example Asia/Manila or UTC',
                      ),
                      if (draft.kind == DeadlineKind.dateOnly)
                        const Text(
                          'Due through the end of this date in the deadline’s time zone.',
                        ),
                    ],
                    const SizedBox(height: Space.lg),
                    field(
                      'target-date',
                      'Internal target date (optional)',
                      draft.targetDate,
                      (v) => draft.targetDate = v,
                      helper: 'YYYY-MM-DD · clear both target fields to remove',
                    ),
                    field(
                      'target-time',
                      'Internal target time',
                      draft.targetTime,
                      (v) => draft.targetTime = v,
                      helper: 'HH:MM · 24-hour',
                    ),
                    field(
                      'target-zone',
                      'Internal target time zone',
                      draft.targetZone,
                      (v) => draft.targetZone = v,
                    ),
                    field(
                      'remaining-estimate',
                      'Remaining estimate (minutes)',
                      draft.estimate,
                      (v) => draft.estimate = v,
                      helper: 'Optional whole minutes. Kept separate from your target and deadline.',
                    ),
                  ],
                  const SizedBox(height: Space.lg),
                  if (error != null)
                    ActionError(
                      title: 'Task changes were not saved',
                      message:
                          (error is FormatException || error is ArgumentError)
                          ? error.toString()
                          : 'Your input is still here. Check storage access and retry.',
                      details: error.toString(),
                      onRetry: () => save(row),
                    ),
                  FilledButton(
                    key: const Key('save-task'),
                    onPressed: busy ? null : () => save(row),
                    child: Text(busy ? 'Saving…' : 'Save task'),
                  ),
                  if (feedback != null)
                    Text(feedback!, semanticsLabel: feedback),
                  if (draft.dirty)
                    const Text(
                      'Unsaved changes · kept while you switch tasks. Save before closing the app.',
                    ),
                  const SizedBox(height: Space.xl),
                  SubtasksEditor(task: row),
                ],
                const SizedBox(height: Space.xl),
                TaskNotesPanel(taskId: row.id, allowLink: available),
              ],
            ),
          ),
        );
      },
    );
  }
}
