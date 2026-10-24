import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import '../focus/focus_workflow.dart';

class SubtasksEditor extends ConsumerStatefulWidget {
  const SubtasksEditor({super.key, required this.task});
  final Task task;
  @override
  ConsumerState<SubtasksEditor> createState() => _SubtasksEditorState();
}

class _SubtasksEditorState extends ConsumerState<SubtasksEditor> {
  final title = TextEditingController();
  bool busy = false, showDeleted = false;
  Object? error;
  Future<void> Function(MomentumRepository)? retry;
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function(MomentumRepository) command) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retry = command;
    });
    try {
      await command(await ref.read(repositoryProvider.future));
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> add() => run((repo) async {
    await repo.appendSubtask(widget.task.id, title.text);
    if (mounted) title.clear();
  });
  void move(List<Subtask> rows, int index, int delta) {
    final ids = rows.map((r) => r.id).toList();
    final id = ids.removeAt(index);
    ids.insert(index + delta, id);
    run((r) => r.reorderSubtasks(widget.task.id, ids));
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(subtasksProvider(widget.task.id));
    return SectionCard(
      title: 'Small steps',
      description: 'One level is enough. Finishing steps never completes the whole task automatically.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          rows.when(
            loading: () => const LoadingState(message: 'Loading steps…'),
            error: (e, _) => ActionError(
              title: 'Could not load steps',
              message: 'Your saved steps are preserved.',
              details: e.toString(),
              onRetry: () => ref.invalidate(subtasksProvider(widget.task.id)),
            ),
            data: (steps) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (steps.isEmpty)
                  const Text('Add a small first action, if it helps.'),
                for (var index = 0; index < steps.length; index++) ...[
                  SubtaskRow(
                    key: ValueKey(steps[index].id),
                    row: steps[index],
                    busy: busy,
                    onSave: (value, completed) => run((r) async {
                      // Read current position so saving text cannot undo a reorder.
                      final fresh = await r.subtask(steps[index].id);
                      await r.updateSubtask(
                        fresh.id,
                        title: value,
                        position: fresh.position,
                        completed: completed,
                      );
                    }),
                    onDelete: () =>
                        run((r) => r.deleteSubtask(steps[index].id)),
                    onUp: index == 0 ? null : () => move(steps, index, -1),
                    onDown: index == steps.length - 1
                        ? null
                        : () => move(steps, index, 1),
                  ),
                  const SizedBox(height: Space.lg),
                ],
                if (steps.isNotEmpty &&
                    steps.every((s) => s.completedAt != null) &&
                    widget.task.status != TaskStatus.done) ...[
                  const Text(
                    'All steps are done. Would you like to complete the task too?',
                  ),
                  OutlinedButton(
                    key: const Key('offer-complete-task'),
                    onPressed: busy
                        ? null
                        : () => run(
                            (r) =>
                                completeTaskWithReview(ref, r, widget.task.id),
                          ),
                    child: const Text('Complete whole task'),
                  ),
                ],
              ],
            ),
          ),
          TextField(
            key: const Key('new-subtask'),
            enabled: !busy,
            controller: title,
            decoration: const InputDecoration(
              labelText: 'New step',
              helperText: '1–200 characters',
            ),
            onSubmitted: (_) => add(),
          ),
          const SizedBox(height: Space.sm),
          OutlinedButton(
            key: const Key('add-subtask'),
            onPressed: busy ? null : add,
            child: const Text('Add step'),
          ),
          if (error != null)
            ActionError(
              title: 'Step change was not saved',
              message: error.toString(),
              onRetry: () => run(retry!),
            ),
          const SizedBox(height: Space.md),
          TextButton(
            onPressed: () => setState(() => showDeleted = !showDeleted),
            child: Text(
              showDeleted ? 'Hide removed steps' : 'Restore removed steps',
            ),
          ),
          if (showDeleted)
            ref
                .watch(removedSubtasksProvider(widget.task.id))
                .when(
                  loading: () => const Text('Loading removed steps…'),
                  error: (e, _) => ActionError(
                    title: 'Could not load removed steps',
                    message: e.toString(),
                    onRetry: () =>
                        ref.invalidate(removedSubtasksProvider(widget.task.id)),
                  ),
                  data: (removed) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (removed.isEmpty) const Text('No removed steps.'),
                      for (final step in removed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Space.sm),
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => run(
                                    (r) => r.deleteSubtask(
                                      step.id,
                                      deleted: false,
                                    ),
                                  ),
                            child: Text('Restore: ${step.title}'),
                          ),
                        ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

final removedSubtasksProvider = StreamProvider.family<List<Subtask>, String>(
  (ref, taskId) => repositoryStream(
    ref,
    (r) => r
        .watchSubtasks(taskId, includeDeleted: true)
        .map((rows) => rows.where((r) => r.deletedAt != null).toList()),
  ),
);

class SubtaskRow extends StatefulWidget {
  const SubtaskRow({
    super.key,
    required this.row,
    required this.busy,
    required this.onSave,
    required this.onDelete,
    this.onUp,
    this.onDown,
  });
  final Subtask row;
  final bool busy;
  final void Function(String, bool) onSave;
  final VoidCallback onDelete;
  final VoidCallback? onUp, onDown;
  @override
  State<SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<SubtaskRow> {
  late final controller = TextEditingController(text: widget.row.title);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Checkbox(
              semanticLabel: 'Complete step ${widget.row.title}',
              value: widget.row.completedAt != null,
              onChanged: widget.busy
                  ? null
                  : (v) => widget.onSave(controller.text, v!),
            ),
          ),
          Expanded(
            child: TextFormField(
              enabled: !widget.busy,
              controller: controller,
              decoration: const InputDecoration(labelText: 'Step title'),
            ),
          ),
        ],
      ),
      Wrap(
        spacing: Space.sm,
        children: [
          TextButton(
            onPressed: widget.busy
                ? null
                : () => widget.onSave(
                    controller.text,
                    widget.row.completedAt != null,
                  ),
            child: const Text('Save step'),
          ),
          IconButton(
            tooltip: 'Move step up',
            onPressed: widget.busy ? null : widget.onUp,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            tooltip: 'Move step down',
            onPressed: widget.busy ? null : widget.onDown,
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: 'Remove step',
            onPressed: widget.busy ? null : widget.onDelete,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    ],
  );
}
