import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/notes/note_controller.dart';
import 'package:momentum/features/notes/note_providers.dart';

import 'adaptive_shell_test.dart' show ShellHarness, pumpShell;
import 'task_widgets_test.dart' show perform, tapVisible, enter, go;

void selectNote(ShellHarness harness, String id) => harness.container
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.notes, id);
NoteController buffer(ShellHarness harness, String id) =>
    harness.container.read(noteDraftsProvider).existing(id)!;

class FaultyNotesRepository extends MomentumRepository {
  FaultyNotesRepository(super.database);
  bool failWrites = false, failReads = false, failActions = false;
  Completer<void>? gate;
  @override
  Future<Note> updateNote(String id, NoteDraft draft) async {
    await gate?.future;
    if (failWrites) {
      throw const FileSystemException('Storage temporarily unavailable');
    }
    return super.updateNote(id, draft);
  }

  @override
  Stream<Note?> watchNote(String id) => failReads
      ? Stream.error(const FileSystemException('Could not read note'))
      : super.watchNote(id);

  @override
  Future<void> deleteNote(String id, {bool deleted = true}) {
    if (failActions) {
      throw const FileSystemException('Could not change note Trash state');
    }
    return super.deleteNote(id, deleted: deleted);
  }
}

void main() {
  testWidgets(
    'a storage-opening failure still exposes Copy and retains the note buffer after retry',
    (tester) async {
      var denyOpen = false;
      final h = await pumpShell(
        tester,
        repositoryFactory: (db) => FaultyNotesRepository(db),
        openingFailure: () => denyOpen
            ? const FileSystemException('Folder temporarily unavailable')
            : null,
      );
      final repo = h.repository as FaultyNotesRepository;
      final note = await perform(
        tester,
        () => repo.createNote(const NoteDraft()),
      );
      selectNote(h, note.id);
      await tester.pumpAndSettle();
      repo.failWrites = true;
      await enter(
        tester,
        'note-body',
        'Recover while storage is unavailable 🧬',
      );
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      final original = buffer(h, note.id);
      denyOpen = true;
      h.container.invalidate(repositoryProvider);
      await tester.pumpAndSettle();
      expect(find.text('Your saved workspace could not open'), findsOneWidget);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tapVisible(tester, find.byKey(const Key('copy-hidden-note-draft')));
      expect(copied, 'Recover while storage is unavailable 🧬');
      denyOpen = false;
      repo.failWrites = false;
      await tapVisible(tester, find.byKey(const Key('retry-storage')));
      expect(identical(buffer(h, note.id), original), isTrue);
      await tapVisible(tester, find.byKey(const Key('save-note')));
      expect((await perform(tester, () => repo.note(note.id))).body, copied);
    },
  );
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets(
      'empty creation, rapid autosave and explicit save on $platform',
      (tester) async {
        final h = await pumpShell(
          tester,
          platform: platform,
          size: platform == TargetPlatform.android
              ? const Size(390, 950)
              : const Size(1440, 1000),
        );
        go(h, Destination.notes);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const Key('new-note')));
        final id = h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.notes]!;
        expect((await perform(tester, () => h.repository.note(id))).body, '');
        await enter(tester, 'note-body', 'First words');
        await tester.pump(const Duration(milliseconds: 200));
        await enter(tester, 'note-body', '日本語 café 🧬\nSecond line');
        expect(buffer(h, id).state, NoteSaveState.unsaved);
        await tester.pump(const Duration(milliseconds: 650));
        final saved = await perform(tester, () => h.repository.note(id));
        expect(saved.body, '日本語 café 🧬\nSecond line');
        expect(saved.title, '');
        expect(buffer(h, id).state, NoteSaveState.saved);
        await enter(tester, 'note-title', 'Explicit title');
        if (platform == TargetPlatform.windows) {
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pumpAndSettle();
        } else {
          await tapVisible(tester, find.byKey(const Key('save-note')));
        }
        expect(
          (await perform(tester, () => h.repository.note(id))).title,
          'Explicit title',
        );
        await tapVisible(tester, find.byKey(const Key('note-metadata')));
        await tapVisible(tester, find.byKey(const Key('pin-note')));
        await tester.pump(const Duration(milliseconds: 650));
        expect(
          (await perform(tester, () => h.repository.note(id))).pinned,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'writing selection survives resize, theme changes and 200% text on $platform',
      (tester) async {
        final h = await pumpShell(
          tester,
          platform: platform,
          size: const Size(1440, 1100),
          textScale: 2,
        );
        final note = await perform(
          tester,
          () => h.repository.createNote(
            const NoteDraft(
              title: 'Selection',
              body: 'Some Unicode 🧬\nA second line',
            ),
          ),
        );
        selectNote(h, note.id);
        await tester.pumpAndSettle();
        final controller = tester
            .widget<TextField>(find.byKey(const Key('note-body')))
            .controller!;
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 4,
        );
        for (final width in [360.0, 600.0, 999.0, 1000.0, 1440.0]) {
          tester.view.physicalSize = Size(width, 1100);
          await tester.pumpAndSettle();
          final current = tester
              .widget<TextField>(find.byKey(const Key('note-body')))
              .controller!;
          expect(identical(current, controller), isTrue);
          expect(
            current.selection,
            const TextSelection(baseOffset: 0, extentOffset: 4),
          );
          expect(current.text, note.body);
          expect(tester.takeException(), isNull);
        }
        await perform(
          tester,
          () => h.repository.updateSettings(
            theme: ThemePreference.dark,
            planningZone: 'Asia/Manila',
            reducedMotion: true,
          ),
        );
        expect(
          controller.selection,
          const TextSelection(baseOffset: 0, extentOffset: 4),
        );
        await tester.ensureVisible(find.byKey(const Key('save-note')));
        expect(
          tester.getSize(find.byKey(const Key('save-note'))).height,
          greaterThanOrEqualTo(48),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'failed writes and reads keep the draft; Copy, hidden recovery and Retry work',
    (tester) async {
      final h = await pumpShell(
        tester,
        repositoryFactory: (db) => FaultyNotesRepository(db),
      );
      final repo = h.repository as FaultyNotesRepository;
      final note = await perform(
        tester,
        () => repo.createNote(const NoteDraft()),
      );
      selectNote(h, note.id);
      await tester.pumpAndSettle();
      repo.failWrites = true;
      await enter(tester, 'note-body', 'Do not lose this\n日本語 🧬');
      final controller = buffer(h, note.id);
      controller.body.selection = const TextSelection.collapsed(offset: 3);
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(controller.state, NoteSaveState.failed);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tapVisible(tester, find.byKey(const Key('copy-note-draft')));
      expect(copied, 'Do not lose this\n日本語 🧬');
      await tapVisible(tester, find.byKey(const Key('trash-note')));
      expect(
        (await perform(tester, () => repo.note(note.id))).deletedAt,
        isNull,
      );
      expect(controller.body.text, copied);
      controller.body.selection = const TextSelection.collapsed(offset: 3);
      repo.failReads = true;
      h.container.invalidate(noteRecordProvider(note.id));
      await tester.pumpAndSettle();
      expect(find.text('Could not refresh this note'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('note-body')))
            .controller!
            .text,
        copied,
      );
      go(h, Destination.tasks);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('review-note-draft')), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('review-note-draft')));
      expect(identical(buffer(h, note.id), controller), isTrue);
      expect(controller.body.selection.baseOffset, 3);
      repo.failReads = false;
      repo.failWrites = false;
      h.container.invalidate(noteRecordProvider(note.id));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('save-note')));
      expect((await perform(tester, () => repo.note(note.id))).body, copied);
      expect(controller.state, NoteSaveState.saved);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'navigation during a delayed save keeps newer text and flushes both note buffers',
    (tester) async {
      final h = await pumpShell(
        tester,
        repositoryFactory: (db) => FaultyNotesRepository(db),
      );
      final repo = h.repository as FaultyNotesRepository;
      final a = await perform(
        tester,
        () => repo.createNote(const NoteDraft(title: 'A')),
      );
      final b = await perform(
        tester,
        () => repo.createNote(const NoteDraft(title: 'B')),
      );
      selectNote(h, a.id);
      await tester.pumpAndSettle();
      repo.gate = Completer<void>();
      await enter(tester, 'note-body', 'First version');
      await tapVisible(tester, find.byKey(const Key('save-note')));
      expect(buffer(h, a.id).state, NoteSaveState.saving);
      expect(
        tester.widget<TextField>(find.byKey(const Key('note-body'))).enabled,
        isTrue,
      );
      await enter(tester, 'note-body', 'Latest during the write');
      go(h, Destination.settings);
      await tester.pumpAndSettle();
      selectNote(h, b.id);
      await tester.pumpAndSettle();
      await enter(tester, 'note-body', 'B flushed on navigation');
      go(h, Destination.today);
      await tester.pumpAndSettle();
      repo.gate!.complete();
      await tester.pumpAndSettle();
      expect(
        (await perform(tester, () => repo.note(a.id))).body,
        'Latest during the write',
      );
      expect(
        (await perform(tester, () => repo.note(b.id))).body,
        'B flushed on navigation',
      );
      expect(buffer(h, a.id).state, NoteSaveState.saved);
      expect(buffer(h, b.id).state, NoteSaveState.saved);
      selectNote(h, a.id);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('note-body')))
            .controller!
            .text,
        'Latest during the write',
      );
    },
  );

  testWidgets(
    'relationship entry points reuse one note, including after task deletion',
    (tester) async {
      final h = await pumpShell(tester, size: const Size(1440, 1100));
      final note = await perform(
        tester,
        () => h.repository.createNote(
          const NoteDraft(title: 'Reusable note', body: 'One original body 🧬'),
        ),
      );
      final a = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Task A')),
      );
      final b = await perform(
        tester,
        () => h.repository.createTask(const TaskDraft(title: 'Task B')),
      );
      selectNote(h, note.id);
      await tester.pumpAndSettle();
      final writing = buffer(h, note.id);
      await tapVisible(tester, find.byKey(const Key('select-task-links')));
      await tapVisible(tester, find.byKey(ValueKey('link-task-${a.id}')));
      await tapVisible(tester, find.byKey(ValueKey('link-task-${b.id}')));
      await tapVisible(tester, find.byKey(const Key('select-task-links')));
      await tapVisible(tester, find.text('Task A'));
      expect(
        h.container.read(shellNavigationProvider).destination,
        Destination.tasks,
      );
      await tapVisible(
        tester,
        find.byKey(ValueKey('open-linked-note-${note.id}')),
      );
      expect(
        h.container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.notes],
        note.id,
      );
      expect(identical(buffer(h, note.id), writing), isTrue);
      expect(writing.body.text, 'One original body 🧬');
      await perform(tester, () => h.repository.deleteTask(a.id));
      expect(find.text('Task A (in Trash)'), findsOneWidget);
      await tapVisible(tester, find.text('Task A (in Trash)'));
      await tapVisible(
        tester,
        find.byKey(ValueKey('open-linked-note-${note.id}')),
      );
      expect(
        (await perform(tester, () => h.repository.note(note.id))).body,
        writing.body.text,
      );
      expect(
        await perform(tester, () => h.repository.watchNotes().first),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'Trash flushes pending text; search, pin order and restore retain the original record',
    (tester) async {
      final h = await pumpShell(
        tester,
        size: const Size(390, 1000),
        platform: TargetPlatform.android,
        repositoryFactory: (db) => FaultyNotesRepository(db),
      );
      final repo = h.repository as FaultyNotesRepository;
      final note = await perform(
        tester,
        () => h.repository.createNote(
          const NoteDraft(title: 'Library note', body: 'Find %_ 🧬'),
        ),
      );
      go(h, Destination.notes);
      await tester.pumpAndSettle();
      await enter(tester, 'note-search', '%_');
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('note-row-${note.id}')), findsOneWidget);
      await tapVisible(tester, find.byKey(ValueKey('note-row-${note.id}')));
      await enter(tester, 'note-body', 'Latest text before Trash');
      await tapVisible(tester, find.byKey(const Key('trash-note')));
      var saved = await perform(tester, () => h.repository.note(note.id));
      expect(saved.body, 'Latest text before Trash');
      expect(saved.deletedAt, isNotNull);
      await tapVisible(tester, find.byKey(const Key('back-to-notes')));
      await enter(tester, 'note-search', '');
      await tapVisible(tester, find.byKey(const Key('notes-trash-filter')));
      await tapVisible(tester, find.byKey(ValueKey('note-row-${note.id}')));
      repo.failActions = true;
      await tapVisible(tester, find.byKey(const Key('restore-note')));
      expect(find.text('Note action did not finish'), findsOneWidget);
      expect(
        (await perform(tester, () => repo.note(note.id))).deletedAt,
        isNotNull,
      );
      expect(buffer(h, note.id).body.text, 'Latest text before Trash');
      repo.failActions = false;
      await tapVisible(tester, find.text('Retry'));
      saved = await perform(tester, () => h.repository.note(note.id));
      expect(saved.deletedAt, isNull);
      expect(saved.body, 'Latest text before Trash');
      expect(saved.id, note.id);
    },
  );
}
