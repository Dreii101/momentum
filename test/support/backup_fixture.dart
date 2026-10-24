import 'dart:typed_data';

import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/features/backup/backup_service.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:momentum/features/reminders/reminder_store.dart';
import 'package:momentum/features/reminders/reminder_types.dart';
import 'package:momentum/features/schedule/recurrence.dart';

import 'database_fixture.dart';
import 'progress_fixture.dart';

class MemoryBackupFiles extends BackupFiles {
  Uint8List? bytes;
  Uri? savedUri = Uri.parse('content://documents/momentum.json');
  bool cancelPick = false, failSave = false;
  @override
  Future<BackupInput?> pick() async => cancelPick
      ? null
      : BackupInput(
          'momentum.json',
          Stream.value(bytes!),
          length: bytes!.length,
        );
  @override
  Future<Uri?> save(Uint8List data, String name) async {
    if (failSave) throw StateError('No storage space');
    if (savedUri != null) bytes = Uint8List.fromList(data);
    return savedUri;
  }
}

Future<void> seedBackup(MomentumRepository repo) async {
  final basics = await seedRecords(repo);
  await seedProgress(repo);
  final course = await repo.createCourse(
    const CourseDraft(name: 'Active course'),
  );
  final series = await repo.createActivity(
    ActivityDraft(
      title: 'Class 日本語',
      courseId: course.id,
      recurrence: 'weekly',
      weekdays: 5,
      startDate: CalendarDate(2026, 10, 19),
      endDate: CalendarDate(2026, 11, 1),
      startMinute: 540,
      endMinute: 600,
      zone: 'Asia/Manila',
    ),
  );
  await repo.changeOccurrence(
    series.id,
    CalendarDate(2026, 10, 21),
    cancelled: true,
  );
  await repo.setActivityLink(basics.note.id, series.id, null, linked: true);
  await repo.setActivityLink(
    basics.note.id,
    series.id,
    CalendarDate(2026, 10, 21),
    linked: true,
  );
  final block = await repo.saveWorkBlock(
    WorkBlockDraft(
      taskId: basics.task.id,
      startUtc: DateTime.utc(2026, 10, 23, 2),
      endUtc: DateTime.utc(2026, 10, 23, 3),
      planningZone: 'Asia/Manila',
      locked: true,
    ),
  );
  final reminders = ReminderStore(repo);
  await reminders.initialize();
  await reminders.setRule(ReminderKind.deadline, basics.task.id);
  await reminders.setRule(ReminderKind.activity, series.id);
  await reminders.setRule(ReminderKind.work, block.id);
  await reminders.setRule(ReminderKind.timer, (await repo.installation()).id);
  await repo.saveReflection(
    fixtureWeek,
    helped: 'Small starts 日本語',
    obstacles: 'Interruptions',
    adjustment: 'Open one page',
  );
}
