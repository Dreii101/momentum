import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/notes/note_controller.dart';

import 'support/database_fixture.dart';

void main() {
  late DatabaseFixture fixture;
  late AppDatabase db;
  late MomentumRepository repo;
  setUp(() async {
    fixture = await DatabaseFixture.create();
    db = fixture.open();
    repo = MomentumRepository(db);
    await repo.initialize();
  });
  tearDown(() => fixture.dispose());

  test(
    'empty notes, Unicode writing, pin and course survive real database reopen',
    () async {
      final note = await repo.createNote(const NoteDraft());
      final course = await repo.createCourse(
        const CourseDraft(name: 'Biology'),
      );
      final controller = NoteController(note, () async => repo);
      controller.title.text = 'Class 日本語';
      controller.body.text = 'café 🧬\nSecond line\n\nSame original note';
      controller.setPinned(true);
      controller.setCourse(course.id);
      expect(await controller.flush(), isTrue);
      controller.dispose();
      await repo.archiveCourse(course.id);
      final saved = await repo.note(note.id);
      await repo.createNote(const NoteDraft(title: 'Newer unpinned note'));
      expect((await repo.watchNotes().first).first.id, note.id);
      await db.close();
      final reopened = MomentumRepository(fixture.open());
      expect(await reopened.note(note.id), saved);
      expect(
        (await reopened.watchNotes(search: '日本語').first).single.id,
        note.id,
      );
    },
  );

  test('database search is literal, parameterized, in title/body and excludes Trash', () async {
    final a = await repo.createNote(
      const NoteDraft(title: 'BIOLOGY', body: "100% _wildcard_ 'quote' 日本語 🧬"),
    );
    await repo.createNote(
      const NoteDraft(title: 'Different', body: '100 percent'),
    );
    for (final query in [
      'biology',
      '%',
      '_wildcard_',
      "'quote'",
      '日本語',
      '🧬',
    ]) {
      expect((await repo.watchNotes(search: query).first).map((n) => n.id), [
        a.id,
      ]);
    }
    expect(await repo.watchNotes(search: "' OR 1=1 --").first, isEmpty);
    await repo.deleteNote(a.id);
    expect(await repo.watchNotes(search: '%').first, isEmpty);
    expect(
      (await repo.watchNotes(search: '%', onlyDeleted: true).first).single.id,
      a.id,
    );
    await repo.deleteNote(a.id, deleted: false);
    expect((await repo.watchNotes(search: '%').first).single.id, a.id);
  });

  test('one note links to several tasks; duplicates are rejected and UI commands are idempotent', () async {
    final note = await repo.createNote(const NoteDraft(body: 'Reusable'));
    final a = await repo.createTask(const TaskDraft(title: 'Task A'));
    final b = await repo.createTask(const TaskDraft(title: 'Task B'));
    await repo.setNoteTaskLink(note.id, a.id, linked: true);
    await repo.setNoteTaskLink(note.id, a.id, linked: true);
    await repo.setNoteTaskLink(note.id, b.id, linked: true);
    await expectLater(repo.linkNote(note.id, a.id), throwsException);
    expect(await repo.watchLinkedTasks(note.id).first, hasLength(2));
    expect((await repo.watchLinkedNotes(a.id).first).single, note);
    await repo.deleteTask(a.id);
    expect(await repo.note(note.id), note);
    expect(
      (await repo.watchLinkedTasks(note.id).first).first.deletedAt,
      isNotNull,
    );
    await repo.deleteNote(note.id);
    expect(
      (await repo.watchLinkedNotes(b.id).first).single.deletedAt,
      isNotNull,
    );
    await expectLater(
      repo.updateNote(note.id, const NoteDraft(body: 'Must not resurrect')),
      throwsStateError,
    );
    await repo.deleteNote(note.id, deleted: false);
    await repo.setNoteTaskLink(note.id, a.id, linked: false);
    expect(await repo.watchLinkedTasks(note.id).first, hasLength(1));
    expect((await repo.watchLinkedNotes(b.id).first).single.id, note.id);
    await db.close();
    final reopened = MomentumRepository(fixture.open());
    expect((await reopened.watchLinkedNotes(b.id).first).single.id, note.id);
    expect((await reopened.note(note.id)).body, 'Reusable');
  });

  test('real SQL and repository limits retain previous saved body on failed updates', () async {
    final note = await repo.createNote(NoteDraft(body: '🧬' * 100000));
    await expectLater(
      repo.updateNote(note.id, NoteDraft(body: '🧬' * 100001)),
      throwsFormatException,
    );
    await expectLater(
      db.customStatement('UPDATE notes SET body = ? WHERE id = ?', [
        'x' * 100001,
        note.id,
      ]),
      throwsException,
    );
    expect((await repo.note(note.id)).body.runes.length, 100000);
    await repo.deleteNote(note.id);
    await repo.deleteNote(note.id, deleted: false);
    expect((await repo.note(note.id)).body, note.body);
  });
}
