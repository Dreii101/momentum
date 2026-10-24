import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../core/database/app_database.dart';
import '../tasks/task_workflow.dart';
import '../schedule/schedule_links.dart';
import 'note_controller.dart';
import 'note_providers.dart';
import 'note_relationships.dart';

class NoteEditor extends ConsumerStatefulWidget {
  const NoteEditor({
    super.key,
    required this.noteId,
    required this.onBack,
    required this.onTrash,
    required this.mutating,
    this.focusBody = false,
    this.actionError,
    this.onRetryAction,
  });
  final String noteId;
  final VoidCallback onBack;
  final Future<void> Function(Note, bool) onTrash;
  final bool mutating, focusBody;
  final Object? actionError;
  final VoidCallback? onRetryAction;
  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  bool metadata = false;
  String? copyFeedback;
  Future<void> copy(NoteController controller) async {
    try {
      await Clipboard.setData(ClipboardData(text: controller.copyText));
      if (mounted) setState(() => copyFeedback = 'Draft copied.');
    } catch (_) {
      if (mounted) {
        setState(
          () => copyFeedback =
              'Couldn’t copy. Select your text and use the system Copy action.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(noteRecordProvider(widget.noteId));
    final drafts = ref.read(noteDraftsProvider);
    final existing = drafts.existing(widget.noteId);
    ref.listen(noteRecordProvider(widget.noteId), (previous, next) {
      final row = next.value;
      if (row != null) drafts.existing(row.id)?.observe(row);
    });
    return record.when(
      loading: () => existing != null
          ? editor(existing.lastPersisted)
          : const WorkspaceScroll(
              child: LoadingState(message: 'Opening note…'),
            ),
      error: (e, _) => existing != null
          ? editor(existing.lastPersisted, readError: e)
          : WorkspaceScroll(
              child: ActionError(
                title: 'Could not open note',
                message:
                    'Any existing draft is still available in this session.',
                details: e.toString(),
                onRetry: () =>
                    ref.invalidate(noteRecordProvider(widget.noteId)),
              ),
            ),
      data: (row) => editor(row),
    );
  }

  Widget editor(Note? row, {Object? readError}) {
    if (row == null) {
      return WorkspaceScroll(
        child: Column(
          children: [
            TextButton(
              onPressed: widget.onBack,
              child: const Text('Note library'),
            ),
            const Text(
              'This note could not be found. Choose another note from the library.',
            ),
          ],
        ),
      );
    }
    final controller = ref.read(noteDraftsProvider).open(row);
    final deleted = row.deletedAt != null;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            if (!deleted && !widget.mutating) controller.flush();
          },
        },
        child: WorkspaceScroll(
          storageKey: 'note-editor-${row.id}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.actionError != null)
                ActionError(
                  title: 'Note action did not finish',
                  message: 'Your saved note and current draft are preserved.',
                  details: widget.actionError.toString(),
                  onRetry: widget.onRetryAction!,
                ),
              if (readError != null)
                ActionError(
                  title: 'Could not refresh this note',
                  message: 'Your draft is available below. Retry or copy it before closing.',
                  details: readError.toString(),
                  onRetry: () =>
                      ref.invalidate(noteRecordProvider(widget.noteId)),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('back-to-notes'),
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Note library'),
                ),
              ),
              Text(
                deleted ? 'Note in Trash' : 'Your note',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Space.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  controller.label,
                  key: const Key('note-save-state'),
                ),
              ),
              const SizedBox(height: Space.md),
              if (controller.error != null)
                ActionError(
                  title: 'Couldn’t save',
                  message: controller.error is FormatException
                      ? (controller.error as FormatException).message
                      : 'Your draft is still here. Retry or copy it before closing the app.',
                  details: controller.error.toString(),
                  onRetry: () => controller.flush(),
                ),
              if (controller.error != null ||
                  readError != null ||
                  (deleted && controller.dirty)) ...[
                TextButton.icon(
                  key: const Key('copy-note-draft'),
                  onPressed: () => copy(controller),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy draft'),
                ),
                if (copyFeedback != null) Text(copyFeedback!),
              ],
              TextField(
                key: const Key('note-title'),
                controller: controller.title,
                enabled: !deleted && !widget.mutating,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  helperText:
                      'An untitled note is welcome. Up to 200 characters.',
                ),
              ),
              const SizedBox(height: Space.lg),
              TextField(
                key: const Key('note-body'),
                controller: controller.body,
                enabled: !deleted && !widget.mutating,
                autofocus: widget.focusBody,
                minLines: 12,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Plain-text note',
                  alignLabelWithHint: true,
                  helperText:
                      'Up to 100,000 characters · saves after a short pause',
                ),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  FilledButton(
                    key: const Key('save-note'),
                    onPressed: deleted || widget.mutating
                        ? null
                        : () => controller.flush(),
                    child: const Text('Save note'),
                  ),
                  if (deleted)
                    OutlinedButton(
                      key: const Key('restore-note'),
                      onPressed: widget.mutating
                          ? null
                          : () => widget.onTrash(row, false),
                      child: const Text('Restore note'),
                    )
                  else
                    OutlinedButton(
                      key: const Key('trash-note'),
                      onPressed: widget.mutating
                          ? null
                          : () => widget.onTrash(row, true),
                      child: const Text('Move note to Trash'),
                    ),
                ],
              ),
              if (deleted)
                const Padding(
                  padding: EdgeInsets.only(top: Space.md),
                  child: Text(
                    'Restore this note to continue writing. Its task links are retained.',
                  ),
                ),
              const SizedBox(height: Space.xl),
              OutlinedButton(
                key: const Key('note-metadata'),
                onPressed: () => setState(() => metadata = !metadata),
                child: Text(
                  metadata
                      ? 'Hide organization options'
                      : 'Pin and course (optional)',
                ),
              ),
              if (metadata) ...[
                CheckboxListTile(
                  key: const Key('pin-note'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pin this note'),
                  value: controller.pinned,
                  onChanged: deleted || widget.mutating
                      ? null
                      : (v) => controller.setPinned(v!),
                ),
                ref
                    .watch(taskCoursesProvider)
                    .when(
                      loading: () => const Text('Loading courses…'),
                      error: (e, _) => ActionError(
                        title: 'Could not load courses',
                        message: 'The current association is preserved.',
                        details: e.toString(),
                        onRetry: () => ref.invalidate(taskCoursesProvider),
                      ),
                      data: (courses) => DropdownButtonFormField<String>(
                        key: ValueKey(controller.courseId),
                        initialValue: controller.courseId ?? '',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Course (optional)',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('No course'),
                          ),
                          for (final course in courses.where(
                            (c) =>
                                (c.deletedAt == null && c.archivedAt == null) ||
                                c.id == controller.courseId,
                          ))
                            DropdownMenuItem(
                              value: course.id,
                              child: Text(
                                course.name +
                                    (course.deletedAt != null
                                        ? ' (deleted)'
                                        : course.archivedAt != null
                                        ? ' (archived)'
                                        : ''),
                              ),
                            ),
                        ],
                        onChanged: deleted || widget.mutating
                            ? null
                            : (v) => controller.setCourse(v == '' ? null : v),
                      ),
                    ),
                const SizedBox(height: Space.md),
                const Text(
                  'Course assignment can stay empty until courses are configured.',
                ),
              ],
              const SizedBox(height: Space.xl),
              NoteTaskRelationships(noteId: row.id, enabled: !deleted),
              const SizedBox(height: Space.xl),
              NoteScheduleLinks(noteId: row.id),
            ],
          ),
        ),
      ),
    );
  }
}
