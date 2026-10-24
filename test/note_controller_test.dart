import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/notes/note_controller.dart';

Note fixtureNote([String id = '00000000-0000-4000-8000-000000000001']) => Note(
  id: id,
  createdAt: DateTime.utc(2026, 10, 21),
  updatedAt: DateTime.utc(2026, 10, 21),
  title: '',
  body: '',
  pinned: false,
);

class RecordingNotesRepository extends MomentumRepository {
  RecordingNotesRepository() : super(AppDatabase(NativeDatabase.memory()));
  final writes = <NoteDraft>[];
  Completer<void>? gate;
  bool fail = false;
  int active = 0, maxActive = 0;
  Note saved = fixtureNote();
  @override
  Future<Note> updateNote(String id, NoteDraft draft) async {
    active++;
    if (active > maxActive) maxActive = active;
    writes.add(draft);
    try {
      await gate?.future;
      if (fail) throw const FileSystemException('Disk is temporarily full');
      return saved = saved.copyWith(
        id: id,
        title: draft.title,
        body: draft.body,
        pinned: draft.pinned,
        courseId: Value(draft.courseId),
      );
    } finally {
      active--;
    }
  }
}

void main() {
  late RecordingNotesRepository repo;
  late NoteController controller;
  setUp(() {
    repo = RecordingNotesRepository();
    controller = NoteController(fixtureNote(), () async => repo);
  });
  tearDown(() async {
    controller.dispose();
    await repo.database.close();
  });

  testWidgets(
    '500ms debounce coalesces rapid Unicode text; selection alone is not an edit',
    (tester) async {
      controller.body.text = 'First';
      await tester.pump(const Duration(milliseconds: 499));
      expect(repo.writes, isEmpty);
      controller.body.text = '日本語 café 🧬\nSecond line';
      await tester.pump(const Duration(milliseconds: 499));
      expect(repo.writes, isEmpty);
      expect(controller.state, NoteSaveState.unsaved);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(repo.writes, hasLength(1));
      expect(repo.saved.body, controller.body.text);
      expect(controller.state, NoteSaveState.saved);
      controller.body.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 3,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(repo.writes, hasLength(1));
    },
  );

  testWidgets(
    'edits during a delayed save drain sequentially without an older Saved state',
    (tester) async {
      repo.gate = Completer<void>();
      controller.body.text = 'Older text';
      final first = controller.flush();
      await tester.pump();
      expect(controller.state, NoteSaveState.saving);
      controller.body.text = 'Latest text 🧬';
      final joined = controller.flush();
      expect(identical(first, joined), isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(repo.writes, hasLength(1));
      expect(controller.state, NoteSaveState.saving);
      repo.gate!.complete();
      await tester.pump();
      await tester.pump();
      expect(await first, isTrue);
      expect(repo.writes.map((d) => d.body), ['Older text', 'Latest text 🧬']);
      expect(repo.maxActive, 1);
      expect(repo.saved.body, controller.body.text);
      expect(controller.state, NoteSaveState.saved);
      controller.body.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 5,
      );
      controller.observe(fixtureNote().copyWith(body: 'Older text'));
      expect(controller.body.text, 'Latest text 🧬');
      expect(
        controller.body.selection,
        const TextSelection(baseOffset: 1, extentOffset: 5),
      );
    },
  );

  testWidgets('failed save preserves exact text and selection; retry commits', (
    tester,
  ) async {
    repo.fail = true;
    controller.title.text = 'My note';
    controller.body.text = 'Keep this\n日本語 🧬';
    controller.body.selection = const TextSelection.collapsed(offset: 4);
    final failed = controller.flush();
    await tester.pump();
    expect(await failed, isFalse);
    expect(controller.state, NoteSaveState.failed);
    expect(controller.copyText, 'My note\n\nKeep this\n日本語 🧬');
    expect(controller.body.selection.baseOffset, 4);
    repo.fail = false;
    final retry = controller.flush();
    await tester.pump();
    expect(await retry, isTrue);
    expect(repo.saved.body, 'Keep this\n日本語 🧬');
    expect(controller.state, NoteSaveState.saved);
  });

  testWidgets(
    'limits count Unicode characters and never truncate a failed draft',
    (tester) async {
      controller.body.text = '🧬' * 100001;
      final invalid = controller.flush();
      await tester.pump();
      expect(await invalid, isFalse);
      expect(repo.writes, isEmpty);
      expect(controller.body.text.runes.length, 100001);
      controller.body.text = '🧬' * 100000;
      final valid = controller.flush();
      await tester.pump();
      expect(await valid, isTrue);
      expect(repo.saved.body.runes.length, 100000);
      controller.title.text = 'x' * 201;
      final titleFailure = controller.flush();
      await tester.pump();
      expect(await titleFailure, isFalse);
      expect(controller.title.text.length, 201);
    },
  );

  testWidgets(
    'metadata joins text in one commit; empty title and body are valid',
    (tester) async {
      controller.body.text = 'Draft';
      controller.setPinned(true);
      controller.setCourse('00000000-0000-4000-8000-000000000002');
      final save = controller.flush();
      await tester.pump();
      expect(await save, isTrue);
      expect(repo.saved.pinned, isTrue);
      expect(repo.saved.courseId, '00000000-0000-4000-8000-000000000002');
      controller.title.clear();
      controller.body.clear();
      final empty = controller.flush();
      await tester.pump();
      expect(await empty, isTrue);
      expect(repo.saved.body, '');
      expect(repo.saved.title, '');
    },
  );

  testWidgets(
    'registry retains buffers and selections across record switches and flushes them',
    (tester) async {
      final drafts = NoteDrafts(() async => repo);
      final a = drafts.open(fixtureNote());
      final b = drafts.open(
        fixtureNote('00000000-0000-4000-8000-000000000002'),
      );
      a.body.text = 'First note';
      a.body.selection = const TextSelection.collapsed(offset: 3);
      b.body.text = 'Second note';
      expect(identical(drafts.open(fixtureNote()), a), isTrue);
      expect(a.body.selection.baseOffset, 3);
      final flushed = drafts.flushAll();
      await tester.pump();
      await flushed;
      expect(drafts.unsaved, isEmpty);
      expect(
        repo.writes.map((d) => d.body),
        containsAll(['First note', 'Second note']),
      );
      drafts.dispose();
    },
  );

  testWidgets('a trashed note keeps a blocked draft until restore', (
    tester,
  ) async {
    controller.body.text = 'Keep a failed draft';
    controller.setTrashed(true);
    final blocked = controller.flush();
    await tester.pump();
    expect(await blocked, isFalse);
    expect(repo.writes, isEmpty);
    controller.setTrashed(false);
    final restored = controller.flush();
    await tester.pump();
    expect(await restored, isTrue);
    expect(repo.saved.body, 'Keep a failed draft');
  });
}
