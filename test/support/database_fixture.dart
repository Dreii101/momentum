import 'dart:io';

import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:path/path.dart' as p;

class DatabaseFixture {
  DatabaseFixture._(this.directory, this.file);
  final Directory directory;
  final File file;
  final List<AppDatabase> _connections = [];
  static Future<DatabaseFixture> create() async {
    final directory = await Directory.systemTemp.createTemp('momentum-data-');
    return DatabaseFixture._(
      directory,
      File(p.join(directory.path, 'fixture.sqlite')),
    );
  }

  AppDatabase open() {
    final db = AppDatabase.file(file);
    _connections.add(db);
    return db;
  }

  Future<void> dispose() async {
    for (final db in _connections) {
      await db.close();
    }
    final target = await directory.resolveSymbolicLinks();
    final root = await Directory.systemTemp.resolveSymbolicLinks();
    if (!p.isWithin(root, target) ||
        !p.basename(target).startsWith('momentum-data-')) {
      throw StateError('Refusing to remove a non-fixture directory.');
    }
    await directory.delete(recursive: true);
  }
}

class SeededRecords {
  const SeededRecords(
    this.course,
    this.task,
    this.subtask,
    this.note,
    this.link,
  );
  final Course course;
  final Task task;
  final Subtask subtask;
  final Note note;
  final NoteTaskLink link;
}

Future<SeededRecords> seedRecords(
  MomentumRepository repository,
) => repository.transaction(() async {
  await repository.initialize();
  final course = await repository.createCourse(
    CourseDraft(
      name: 'Biology – 生物',
      termStart: CalendarDate(2026, 10, 1),
      termEnd: CalendarDate(2027, 2, 28),
    ),
  );
  final task = await repository.createTask(
    TaskDraft(
      title: 'Read chapter 🧬',
      courseId: course.id,
      description: 'First page\nSecond page',
      nextAction: 'Open the book',
      remainingMinutes: 40,
      deadline: Deadline.dateOnly(
        CalendarDate(2026, 11, 1),
        'America/New_York',
      ),
      targetUtc: DateTime.utc(2026, 10, 31, 17, 30),
    ),
  );
  final subtask = await repository.createSubtask(task.id, 'Read introduction');
  final note = await repository.createNote(
    NoteDraft(
      title: 'Lecture notes',
      body: 'Preserve accents: café\n日本語 🧬',
      courseId: course.id,
      pinned: true,
    ),
  );
  final link = await repository.linkNote(note.id, task.id);
  await repository.setDailyPriorities(CalendarDate(2026, 10, 20), [task.id]);
  await repository.updateSettings(
    theme: ThemePreference.dark,
    planningZone: 'Asia/Manila',
  );
  await repository.archiveCourse(course.id);
  return SeededRecords(course, task, subtask, note, link);
});
