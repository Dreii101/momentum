// Explicit native acceptance entry; never imported by the production entry.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/notes/note_controller.dart';
import 'package:momentum/features/notes/note_providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Map<String, Object?>> noteSnapshot(AppDatabase db) async => {
  for (final table in [
    'courses',
    'tasks',
    'subtasks',
    'notes',
    'note_task_links',
    'daily_priorities',
    'app_settings',
    'installations',
  ])
    table: [
      for (final row
          in await db.customSelect('SELECT * FROM $table ORDER BY id').get())
        row.data,
    ],
};
bool sameRecords(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((k) => b.containsKey(k) && sameRecords(a[k], b[k]));
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        List.generate(a.length, (i) => i).every((i) => sameRecords(a[i], b[i]));
  }
  return a == b;
}

Future<void> main() => launchNotesFixture();

Future<void> launchNotesFixture({String name = 'phase5_notes_checks'}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final directory = Directory(p.join(support.path, name));
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'notes.sqlite'));
  final expected = File(p.join(directory.path, 'expected.json'));
  final report = File(p.join(directory.path, 'last-run.json'));
  final existed = await file.exists();
  final db = AppDatabase.file(file);
  String? failure, noteId;
  try {
    await db.ensureOpen();
    final repo = MomentumRepository(db);
    if (!existed) {
      await repo.initialize();
      final course = await repo.createCourse(
        const CourseDraft(name: 'Native course'),
      );
      final note = await repo.createNote(const NoteDraft());
      await repo.createNote(
        const NoteDraft(),
      ); // Empty/untitled is a valid record.
      final a = await repo.createTask(const TaskDraft(title: 'Earlier task'));
      final b = await repo.createTask(const TaskDraft(title: 'Use this note'));
      await repo.setNoteTaskLink(note.id, a.id, linked: true);
      await repo.setNoteTaskLink(note.id, b.id, linked: true);
      await repo.setNoteTaskLink(note.id, b.id, linked: true);
      final editor = NoteController(note, () async => repo);
      try {
        editor.title.text = 'Native class note 🧬';
        editor.body.text = 'First draft';
        editor.body.text = '日本語 café 🧬\nSecond line\n\nOne reusable original.';
        editor.setPinned(true);
        editor.setCourse(course.id);
        for (
          var attempt = 0;
          attempt < 120 && editor.state != NoteSaveState.saved;
          attempt++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (editor.state != NoteSaveState.saved || editor.dirty) {
          throw StateError(
            'Native 500ms autosave did not commit: ${editor.error}',
          );
        }
      } finally {
        editor.dispose();
      }
      await repo.archiveCourse(course.id);
      await repo.deleteTask(a.id);
      await repo.deleteNote(note.id);
      await repo.deleteNote(note.id, deleted: false);
      await File(p.join(directory.path, 'note-id.txt'))
          .writeAsString(note.id, flush: true);
      await expected.writeAsString(
        jsonEncode(await noteSnapshot(db)),
        flush: true,
      );
      noteId = note.id;
    } else {
      if (!await expected.exists() ||
          !sameRecords(
            await noteSnapshot(db),
            jsonDecode(await expected.readAsString()),
          )) {
        throw StateError(
          'Saved notes, links or other records changed across process restart.',
        );
      }
      noteId = await File(p.join(directory.path, 'note-id.txt')).readAsString();
    }
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'status': existed
            ? 'verified-after-process-restart'
            : 'saved-by-native-autosave',
        'pid': pid,
        'platform': Platform.operatingSystem,
        'schemaVersion': db.schemaVersion,
        'checkedAt': DateTime.now().toUtc().toIso8601String(),
        'databasePath': file.path,
        'noteId': noteId,
        'records': await noteSnapshot(db),
      }),
      flush: true,
    );
  } catch (error) {
    failure = error.toString();
    await report.writeAsString(
      jsonEncode({'status': 'FAILED', 'pid': pid, 'error': failure}),
      flush: true,
    );
  } finally {
    await db.close();
  }
  if (failure != null) {
    runApp(MaterialApp(home: Scaffold(body: SelectableText(failure))));
    return;
  }
  runApp(
    ProviderScope(
      overrides: [
        databaseFileProvider.overrideWithValue(() async => file),
        shellNavigationProvider.overrideWith(
          () => NotesCheckNavigation(noteId!),
        ),
      ],
      child: NotesCheckApp(directory: directory, noteId: noteId!),
    ),
  );
}

class NotesCheckNavigation extends ShellNavigation {
  NotesCheckNavigation(this.noteId);
  final String noteId;
  @override
  ShellRoute build() => ShellRoute(
    destination: Destination.notes,
    selectedRecords: {Destination.notes: noteId},
  );
}

class NotesCheckApp extends ConsumerStatefulWidget {
  const NotesCheckApp({
    super.key,
    required this.directory,
    required this.noteId,
  });
  final Directory directory;
  final String noteId;
  @override
  ConsumerState<NotesCheckApp> createState() => _NotesCheckAppState();
}

class _NotesCheckAppState extends ConsumerState<NotesCheckApp> {
  late final NoteDrafts drafts;
  NoteSaveState? previousSave;
  Future<void> receipts = Future.value();
  @override
  void initState() {
    super.initState();
    drafts = ref.read(noteDraftsProvider);
    drafts.addListener(onDraftChanged);
  }

  void onDraftChanged() {
    final controller = drafts.existing(widget.noteId);
    if (controller == null) return;
    final before = previousSave;
    previousSave = controller.state;
    if (before == NoteSaveState.saving &&
        controller.state == NoteSaveState.saved) {
      final saved = controller.lastPersisted;
      receipts = receipts.then((_) => recordSave(saved));
    }
  }

  Future<void> recordSave(Note saved) async {
    try {
      if (!mounted) return;
      final repo = await ref.read(repositoryProvider.future);
      final actual = await repo.note(saved.id);
      if (actual.title != saved.title || actual.body != saved.body) return;
      // A UI edit updates the independent expected fixture only after commit.
      await File(p.join(widget.directory.path, 'expected.json')).writeAsString(
        jsonEncode(await noteSnapshot(repo.database)),
        flush: true,
      );
      await File(p.join(widget.directory.path, 'ui-save.json')).writeAsString(
        jsonEncode({
          'pid': pid,
          'platform': Platform.operatingSystem,
          'noteId': saved.id,
          'title': saved.title,
          'body': saved.body,
          'savedAfterCommit': true,
        }),
        flush: true,
      );
    } catch (error) {
      await File(p.join(widget.directory.path, 'ui-save-error.txt'))
          .writeAsString(error.toString());
    }
  }

  @override
  void dispose() {
    drafts.removeListener(onDraftChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shellNavigationProvider, (previous, next) {
      if (previous == null || previous.destination == next.destination) return;
      File(p.join(widget.directory.path, 'navigation.json')).writeAsString(
        jsonEncode({
          'pid': pid,
          'platform': Platform.operatingSystem,
          'from': previous.destination.name,
          'to': next.destination.name,
          'noteId': next.selectedRecords[Destination.notes],
          'taskId': next.selectedRecords[Destination.tasks],
        }),
        flush: true,
      );
    });
    return const MomentumApp();
  }
}
