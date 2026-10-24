import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import 'note_editor.dart';
import 'note_providers.dart';

void openNote(WidgetRef ref, String id) => ref
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.notes, id);

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key, required this.split});
  final bool split;
  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final search = TextEditingController();
  final editorKeys = <String, GlobalKey>{};
  bool trash = false, busy = false;
  Object? error;
  Future<void> Function()? retry;
  String? focusNewId;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retry = action;
    });
    try {
      await action();
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> create() => run(() async {
    final note = await (await ref.read(repositoryProvider.future))
        .createNote(const NoteDraft());
    if (!mounted) return;
    setState(() {
      trash = false;
      focusNewId = note.id;
    });
    openNote(ref, note.id);
  });
  Future<void> setTrash(Note note, bool deleted) => run(() async {
    final controller = ref.read(noteDraftsProvider).open(note);
    if (deleted && !await controller.flush()) {
      openNote(ref, note.id);
      return; // Preserve failed text and leave the note out of Trash.
    }
    await (await ref.read(repositoryProvider.future))
        .deleteNote(note.id, deleted: deleted);
    controller.setTrashed(deleted);
    if (!deleted && controller.dirty) await controller.flush();
  });
  @override
  Widget build(BuildContext context) {
    final selected = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.notes];
    final query = (search: search.text, trash: trash);
    final notes = ref.watch(noteLibraryProvider(query));
    void back() => ref
        .read(shellNavigationProvider.notifier)
        .clearRecord(Destination.notes);
    final library = WorkspaceScroll(
      storageKey: 'notes-library-scroll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Notes', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Space.md),
          const Text('Personal and class material, ready to reuse.'),
          const SizedBox(height: Space.lg),
          FilledButton.icon(
            key: const Key('new-note'),
            onPressed: busy ? null : create,
            icon: const Icon(Icons.add),
            label: const Text('New note'),
          ),
          const SizedBox(height: Space.lg),
          TextField(
            key: const Key('note-search'),
            controller: search,
            decoration: const InputDecoration(
              labelText: 'Search title and text',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Space.lg),
          CheckboxListTile(
            key: const Key('notes-trash-filter'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Trash'),
            value: trash,
            onChanged: (v) => setState(() => trash = v!),
          ),
          if (error != null)
            ActionError(
              title: 'Note action did not finish',
              message: 'Your notes and any open draft are preserved.',
              details: error.toString(),
              onRetry: () => run(retry!),
            ),
          const SizedBox(height: Space.md),
          notes.when(
            loading: () => const LoadingState(message: 'Loading notes…'),
            error: (e, _) => ActionError(
              title: 'Could not load notes',
              message: 'Retry to see your saved library.',
              details: e.toString(),
              onRetry: () => ref.invalidate(noteLibraryProvider(query)),
            ),
            data: (rows) => rows.isEmpty
                ? Text(
                    search.text.isNotEmpty
                        ? 'No matching notes.'
                        : trash
                        ? 'Trash is empty. Removed notes can be restored here.'
                        : 'No notes yet. A new note can be untitled or empty.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final note in rows)
                        Card(
                          elevation: 0,
                          child: ListTile(
                            key: ValueKey('note-row-${note.id}'),
                            selected: selected == note.id,
                            minVerticalPadding: Space.md,
                            title: Text(noteTitle(note)),
                            subtitle: Text(
                              note.body.isEmpty
                                  ? 'Empty note'
                                  : String.fromCharCodes(
                                      note.body.runes.take(180),
                                    ).replaceAll('\n', ' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: note.pinned
                                ? const Icon(Icons.push_pin)
                                : null,
                            onTap: () => openNote(ref, note.id),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
    final editor = selected == null
        ? const WorkspaceScroll(
            key: Key('notes-detail-slot'),
            child: EmptyState(
              icon: Icons.description_outlined,
              title: 'Room to think',
              message: 'Open a note or start an empty page. Your writing saves after a short pause.',
            ),
          )
        : NoteEditor(
            key: editorKeys.putIfAbsent(selected, () => GlobalKey()),
            noteId: selected,
            onBack: back,
            onTrash: setTrash,
            mutating: busy,
            focusBody: focusNewId == selected,
            actionError: error,
            onRetryAction: () => run(retry!),
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
                    ? (size.maxWidth * .35).clamp(260, 350)
                    : size.maxWidth,
                child: library,
              ),
            if (widget.split) const VerticalDivider(width: 1),
            if (widget.split || selected != null) Expanded(child: editor),
          ],
        ),
      ),
    );
  }
}
