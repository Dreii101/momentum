import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import 'note_controller.dart';

typedef NoteQuery = ({String search, bool trash});
final noteLibraryProvider = StreamProvider.autoDispose
    .family<List<Note>, NoteQuery>(
      (ref, query) => repositoryStream(
        ref,
        (r) => r.watchNotes(search: query.search, onlyDeleted: query.trash),
      ),
      retry: (count, error) => null,
    );
final noteRecordProvider = StreamProvider.autoDispose.family<Note?, String>(
  (ref, id) => repositoryStream(ref, (r) => r.watchNote(id)),
  retry: (count, error) => null,
);
final linkedNotesProvider = StreamProvider.autoDispose
    .family<List<Note>, String>(
      (ref, taskId) => repositoryStream(ref, (r) => r.watchLinkedNotes(taskId)),
      retry: (count, error) => null,
    );
final linkedTasksProvider = StreamProvider.autoDispose
    .family<List<Task>, String>(
      (ref, noteId) => repositoryStream(ref, (r) => r.watchLinkedTasks(noteId)),
      retry: (count, error) => null,
    );
final noteDraftsProvider = Provider<NoteDrafts>((ref) {
  final drafts = NoteDrafts(() => ref.read(repositoryProvider.future));
  ref.onDispose(drafts.dispose);
  return drafts;
});

String noteTitle(Note note) =>
    note.title.trim().isEmpty ? 'Untitled note' : note.title;
