import '../../core/database/app_database.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import '../reminders/reminder_store.dart';
import '../schedule/recurrence.dart';

typedef BackupPayload = Map<String, List<Map<String, Object?>>>;

const backupTables = [
  'courses',
  'tasks',
  'subtasks',
  'notes',
  'note_task_links',
  'daily_priorities',
  'app_settings',
  'activity_series',
  'activity_exceptions',
  'note_activity_links',
  'planned_work_blocks',
  'focus_sessions',
  'focus_segments',
  'reminder_preferences_rows',
  'reminder_rules',
  'weekly_reflections',
];

const excludedColumns = <String, Set<String>>{
  'app_settings': {'id', 'singleton'},
  'reminder_preferences_rows': {'id', 'singleton', 'enabled'},
  'focus_sessions': {
    'installation_id',
    'clock_epoch',
    'elapsed_mark_ms',
    'background',
  },
  'reminder_rules': {'installation_id'},
};

Future<BackupPayload> readBackupData(MomentumRepository repo) =>
    repo.transaction(() async {
      final result = <String, List<Map<String, Object?>>>{};
      for (final name in backupTables) {
        final rows = await repo.database
            .customSelect('SELECT * FROM "$name" ORDER BY id')
            .get();
        result[name] = [
          for (final row in rows)
            Map.of(row.data)..removeWhere(
              (key, _) => excludedColumns[name]?.contains(key) ?? false,
            ),
        ];
      }
      return result;
    });

/// All identifiers come from generated schema or the fixed table allowlist.
Future<void> writeBackupData(
  MomentumRepository repo,
  BackupPayload data, {
  required bool normalizeSessions,
}) async {
  final db = repo.database;
  final installation = await repo.installation();
  for (final name in backupTables) {
    await db.batch((batch) {
      for (final original in data[name]!) {
        final row = Map<String, Object?>.of(original);
        if (name == 'focus_sessions') {
          row.addAll({
            'installation_id': installation.id,
            'clock_epoch': 'restored',
            'elapsed_mark_ms': 0,
            'background': 0,
          });
          if (normalizeSessions && row['state'] != 'finalized') {
            row.addAll({
              'state': 'awaitingReview',
              'outcome': 'interrupted',
              'has_uncertainty': 1,
            });
          }
        }
        if (name == 'reminder_rules') {
          row['installation_id'] = row['kind'] == 'timer'
              ? installation.id
              : null;
        }
        final columns = row.keys.map((k) => '"$k"').join(',');
        if (name == 'app_settings' || name == 'reminder_preferences_rows') {
          batch.customStatement(
            'UPDATE "$name" SET ${row.keys.map((k) => '"$k"=?').join(',')} WHERE singleton=1',
            row.values.toList(),
          );
        } else {
          batch.customStatement(
            'INSERT INTO "$name" ($columns) VALUES (${List.filled(row.length, '?').join(',')})',
            row.values.toList(),
          );
        }
      }
    });
  }
}

Future<void> initializeBackupStore(MomentumRepository repo) async {
  await repo.initialize();
  await ReminderStore(repo).initialize();
}

/// Checks invariants not represented by SQL foreign keys/check constraints.
Future<void> validateBackupSemantics(AppDatabase db) async {
  final tasks = await db.select(db.tasks).get();
  for (final task in tasks) {
    if ((task.status == TaskStatus.done) != (task.completedAt != null)) {
      throw const FormatException('Task state and completion time disagree.');
    }
    if (task.deadlineZone != null) requireTimeZone(task.deadlineZone!);
    if (task.deadlineKind == DeadlineKind.dateOnly &&
        task.deadlineBoundaryUtc !=
            endOfDateExclusive(task.deadlineDate!, task.deadlineZone!)) {
      throw const FormatException(
        'Date-only deadline boundary disagrees with its date and zone.',
      );
    }
  }
  final steps = {for (final s in await db.select(db.subtasks).get()) s.id: s};
  for (final session in await db.select(db.focusSessions).get()) {
    requireTimeZone(session.zone);
    if (session.subtaskId != null &&
        steps[session.subtaskId]?.taskId != session.taskId) {
      throw const FormatException('Session step does not belong to its task.');
    }
    // The stored local start date stays authoritative after later zone changes.
  }
  for (final block in await db.select(db.plannedWorkBlocks).get()) {
    requireTimeZone(block.planningZone);
  }
  final series = await db.select(db.activitySeriesRows).get();
  final exceptions = await db.select(db.activityExceptions).get();
  final seriesById = {for (final s in series) s.id: s};
  final checkedChains = <String>{};
  for (final s in series) {
    // Course term edits do not invalidate retained historical meetings.
    validateActivity(ActivityDraft.from(s));
    final seen = <String>{};
    var current = s;
    while (current.replacedBy != null && !checkedChains.contains(current.id)) {
      if (!seen.add(current.id)) {
        throw const FormatException('Activity replacement cycle.');
      }
      current = seriesById[current.replacedBy]!;
    }
    checkedChains.addAll(seen);
  }
  for (final e in exceptions) {
    if (!isOriginalDate(seriesById[e.seriesId]!, e.originalDate)) {
      throw const FormatException('Invalid original activity date.');
    }
    if (e.zone != null) {
      validateInterval(e.startMinute!, e.endMinute!, e.endDayOffset!, e.zone!);
    }
  }
  for (final link in await db.select(db.noteActivityLinks).get()) {
    if (link.originalDate != null &&
        !isOriginalDate(seriesById[link.seriesId]!, link.originalDate!)) {
      throw const FormatException('Invalid linked activity date.');
    }
  }
  requireTimeZone((await db.select(db.appSettings).getSingle()).planningZone);
}
