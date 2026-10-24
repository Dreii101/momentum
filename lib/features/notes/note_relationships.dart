import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../tasks/task_workflow.dart';
import 'note_providers.dart';

String taskLinkLabel(Task task) =>
    task.title +
    (task.deletedAt != null
        ? ' (in Trash)'
        : task.archivedAt != null
        ? ' (archived)'
        : task.status.name == 'done'
        ? ' (done)'
        : '');

/// The selector changes associations only; the editor keeps owning its text.
class NoteTaskRelationships extends ConsumerStatefulWidget {
  const NoteTaskRelationships({
    super.key,
    required this.noteId,
    required this.enabled,
  });
  final String noteId;
  final bool enabled;
  @override
  ConsumerState<NoteTaskRelationships> createState() =>
      _NoteTaskRelationshipsState();
}

class _NoteTaskRelationshipsState extends ConsumerState<NoteTaskRelationships> {
  bool selecting = false, busy = false;
  final search = TextEditingController();
  Object? error;
  String? retryTask;
  bool retryLinked = false;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> setLink(String taskId, bool linked) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retryTask = taskId;
      retryLinked = linked;
    });
    try {
      await (await ref.read(repositoryProvider.future))
          .setNoteTaskLink(widget.noteId, taskId, linked: linked);
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(linkedTasksProvider(widget.noteId));
    return SectionCard(
      title: 'Linked tasks',
      description: 'Open the original task. Linking keeps this note reusable.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          links.when(
            loading: () => const LoadingState(message: 'Loading linked tasks…'),
            error: (e, _) => ActionError(
              title: 'Could not load task links',
              message: 'Your writing is still available.',
              details: e.toString(),
              onRetry: () => ref.invalidate(linkedTasksProvider(widget.noteId)),
            ),
            data: (rows) => Column(
              children: [
                if (rows.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No tasks linked yet.'),
                  ),
                for (final task in rows)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(taskLinkLabel(task)),
                    onTap: () => ref
                        .read(shellNavigationProvider.notifier)
                        .selectRecord(Destination.tasks, task.id),
                    trailing: IconButton(
                      tooltip: 'Unlink task',
                      icon: const Icon(Icons.link_off),
                      onPressed: !widget.enabled || busy
                          ? null
                          : () => setLink(task.id, false),
                    ),
                  ),
              ],
            ),
          ),
          if (error != null)
            ActionError(
              title: 'Couldn’t update the task link',
              message: 'Your note text is preserved.',
              details: error.toString(),
              onRetry: () => setLink(retryTask!, retryLinked),
            ),
          if (widget.enabled) ...[
            OutlinedButton(
              key: const Key('select-task-links'),
              onPressed: () => setState(() => selecting = !selecting),
              child: Text(
                selecting ? 'Close task selector' : 'Choose linked tasks',
              ),
            ),
            if (selecting) ...[
              const SizedBox(height: Space.md),
              TextField(
                key: const Key('task-link-search'),
                controller: search,
                decoration: const InputDecoration(labelText: 'Find a task'),
                onChanged: (_) => setState(() {}),
              ),
              ref
                  .watch(taskRecordsProvider)
                  .when(
                    loading: () => const Text('Loading tasks…'),
                    error: (e, _) => ActionError(
                      title: 'Could not load tasks',
                      message: 'Retry to choose a relationship.',
                      details: e.toString(),
                      onRetry: () => ref.invalidate(taskRecordsProvider),
                    ),
                    data: (tasks) {
                      if (!links.hasValue) {
                        return const Text(
                          'Wait for the current links before changing the selection.',
                        );
                      }
                      final selected = links.requireValue
                          .map((t) => t.id)
                          .toSet();
                      final candidates = tasks
                          .where(
                            (t) =>
                                (t.deletedAt == null ||
                                    selected.contains(t.id)) &&
                                t.title.toLowerCase().contains(
                                  search.text.toLowerCase(),
                                ),
                          )
                          .toList();
                      return Column(
                        children: [
                          if (candidates.isEmpty)
                            const Text('No matching tasks.'),
                          for (final task in candidates)
                            CheckboxListTile(
                              key: ValueKey('link-task-${task.id}'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(taskLinkLabel(task)),
                              value: selected.contains(task.id),
                              onChanged: busy
                                  ? null
                                  : (v) => setLink(task.id, v!),
                            ),
                        ],
                      );
                    },
                  ),
            ],
          ],
        ],
      ),
    );
  }
}

class TaskNotesPanel extends ConsumerStatefulWidget {
  const TaskNotesPanel({
    super.key,
    required this.taskId,
    required this.allowLink,
  });
  final String taskId;
  final bool allowLink;
  @override
  ConsumerState<TaskNotesPanel> createState() => _TaskNotesPanelState();
}

class _TaskNotesPanelState extends ConsumerState<TaskNotesPanel> {
  bool selecting = false, busy = false;
  final search = TextEditingController();
  Object? error;
  String? retryNote;
  bool retryLinked = false;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> setLink(String noteId, bool linked) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retryNote = noteId;
      retryLinked = linked;
    });
    try {
      await (await ref.read(repositoryProvider.future))
          .setNoteTaskLink(noteId, widget.taskId, linked: linked);
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(linkedNotesProvider(widget.taskId));
    final query = (search: search.text, trash: false);
    return SectionCard(
      title: 'Linked notes',
      description: 'Reuse the same note across tasks.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          links.when(
            loading: () => const LoadingState(message: 'Loading linked notes…'),
            error: (e, _) => ActionError(
              title: 'Could not load linked notes',
              message: 'Retry to see the saved relationships.',
              details: e.toString(),
              onRetry: () => ref.invalidate(linkedNotesProvider(widget.taskId)),
            ),
            data: (rows) => Column(
              children: [
                if (rows.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No notes linked yet.'),
                  ),
                for (final note in rows)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    key: ValueKey('open-linked-note-${note.id}'),
                    title: Text(
                      noteTitle(note) +
                          (note.deletedAt != null ? ' (in Trash)' : ''),
                    ),
                    onTap: () => ref
                        .read(shellNavigationProvider.notifier)
                        .selectRecord(Destination.notes, note.id),
                    trailing: widget.allowLink
                        ? IconButton(
                            tooltip: 'Unlink note',
                            icon: const Icon(Icons.link_off),
                            onPressed: busy
                                ? null
                                : () => setLink(note.id, false),
                          )
                        : null,
                  ),
              ],
            ),
          ),
          if (error != null)
            ActionError(
              title: 'Couldn’t update the note link',
              message: 'The note itself is preserved.',
              details: error.toString(),
              onRetry: () => setLink(retryNote!, retryLinked),
            ),
          if (widget.allowLink) ...[
            OutlinedButton(
              key: const Key('select-note-links'),
              onPressed: () => setState(() => selecting = !selecting),
              child: Text(
                selecting ? 'Close note selector' : 'Choose linked notes',
              ),
            ),
            if (selecting) ...[
              const SizedBox(height: Space.md),
              TextField(
                key: const Key('note-link-search'),
                controller: search,
                decoration: const InputDecoration(labelText: 'Find a note'),
                onChanged: (_) => setState(() {}),
              ),
              ref
                  .watch(noteLibraryProvider(query))
                  .when(
                    loading: () => const Text('Loading notes…'),
                    error: (e, _) => ActionError(
                      title: 'Could not load notes',
                      message: 'Retry to choose a note.',
                      details: e.toString(),
                      onRetry: () => ref.invalidate(noteLibraryProvider(query)),
                    ),
                    data: (notes) {
                      if (!links.hasValue) {
                        return const Text(
                          'Wait for the current links before changing the selection.',
                        );
                      }
                      final selected = links.requireValue
                          .map((n) => n.id)
                          .toSet();
                      return Column(
                        children: [
                          if (notes.isEmpty)
                            const Text(
                              'No matching notes. Create one in Notes.',
                            ),
                          for (final note in notes)
                            CheckboxListTile(
                              key: ValueKey('link-note-${note.id}'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(noteTitle(note)),
                              value: selected.contains(note.id),
                              onChanged: busy
                                  ? null
                                  : (v) => setLink(note.id, v!),
                            ),
                        ],
                      );
                    },
                  ),
            ],
          ],
        ],
      ),
    );
  }
}
