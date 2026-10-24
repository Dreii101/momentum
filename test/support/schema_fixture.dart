import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Creates the OLD schema from the committed SQL, without consulting live models.
/// Test fixtures stay reproducible when the production tables change later.
void createSchemaFixture(File file, {int version = 1}) {
  final snapshot = jsonDecode(
    File('drift_schemas/momentum/drift_schema_v$version.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  final db = sqlite3.open(file.path);
  try {
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('BEGIN');
    for (final entity in snapshot['fixed_sql'] as List) {
      final sql =
          (entity['sql'] as List).singleWhere(
                (entry) => entry['dialect'] == 'sqlite',
              )['sql']
              as String;
      db.execute(sql);
    }
    db.execute('PRAGMA user_version = $version');
    db.execute('COMMIT');
  } finally {
    db.close();
  }
}

const fixtureCourseId = '00000000-0000-4000-8000-000000000001';
const fixtureTaskId = '00000000-0000-4000-8000-000000000002';
const fixtureSubtaskId = '00000000-0000-4000-8000-000000000003';
const fixtureNoteId = '00000000-0000-4000-8000-000000000004';
const fixtureLinkId = '00000000-0000-4000-8000-000000000005';
const fixturePriorityId = '00000000-0000-4000-8000-000000000006';
const fixtureSettingsId = '00000000-0000-4000-8000-000000000007';
const fixtureInstallationId = '00000000-0000-4000-8000-000000000008';
const fixtureInstant = 1792491630123;

/// Raw v1 fixture SQL is intentionally independent of today's repository/model.
void seedSchemaV1(File file) {
  final db = sqlite3.open(file.path);
  try {
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('BEGIN');
    db.execute(
      '''INSERT INTO courses
      (id,created_at,updated_at,name,term_start,term_end,archived_at)
      VALUES (?,?,?,?,?,?,?)''',
      [
        fixtureCourseId,
        fixtureInstant,
        fixtureInstant,
        'Archived Biology',
        '2026-10-01',
        '2027-02-28',
        fixtureInstant,
      ],
    );
    db.execute(
      '''INSERT INTO tasks
      (id,created_at,updated_at,title,description,course_id,status,priority,
       deadline_kind,deadline_date,deadline_zone,deadline_boundary_utc,target_utc,remaining_minutes)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)''',
      [
        fixtureTaskId,
        fixtureInstant,
        fixtureInstant,
        'Read chapter 🧬',
        'Keep this text',
        fixtureCourseId,
        'doing',
        'high',
        'dateOnly',
        '2026-11-01',
        'America/New_York',
        1793595600000,
        fixtureInstant,
        40,
      ],
    );
    db.execute(
      '''INSERT INTO subtasks
      (id,created_at,updated_at,task_id,title,position) VALUES (?,?,?,?,?,?)''',
      [
        fixtureSubtaskId,
        fixtureInstant,
        fixtureInstant,
        fixtureTaskId,
        'First page',
        0,
      ],
    );
    db.execute(
      '''INSERT INTO notes
      (id,created_at,updated_at,title,body,course_id,pinned) VALUES (?,?,?,?,?,?,?)''',
      [
        fixtureNoteId,
        fixtureInstant,
        fixtureInstant,
        'Lecture',
        'Original café\n日本語 🧬',
        fixtureCourseId,
        1,
      ],
    );
    db.execute(
      'INSERT INTO note_task_links (id,note_id,task_id,created_at) VALUES (?,?,?,?)',
      [fixtureLinkId, fixtureNoteId, fixtureTaskId, fixtureInstant],
    );
    db.execute(
      'INSERT INTO daily_priorities (id,day,task_id,slot,created_at) VALUES (?,?,?,?,?)',
      [fixturePriorityId, '2026-10-20', fixtureTaskId, 1, fixtureInstant],
    );
    db.execute(
      'INSERT INTO app_settings (id,singleton,theme,planning_zone,updated_at) VALUES (?,?,?,?,?)',
      [fixtureSettingsId, 1, 'dark', 'Asia/Manila', fixtureInstant],
    );
    db.execute(
      'INSERT INTO installations (id,singleton,created_at) VALUES (?,?,?)',
      [fixtureInstallationId, 1, fixtureInstant],
    );
    db.execute('COMMIT');
  } finally {
    db.close();
  }
}

List<Map<String, Object?>> readSchema(File file) {
  final db = sqlite3.open(file.path);
  try {
    return db
        .select(
          "SELECT type,name,tbl_name,sql FROM sqlite_schema "
          "WHERE name NOT LIKE 'sqlite_%' ORDER BY type,name",
        )
        .map((r) => Map<String, Object?>.from(r))
        .toList();
  } finally {
    db.close();
  }
}

Map<String, List<Map<String, Object?>>> readAllFixtureData(File file) {
  final db = sqlite3.open(file.path);
  try {
    return {
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
        table: db
            .select('SELECT * FROM $table ORDER BY id')
            .map((r) => Map<String, Object?>.from(r))
            .toList(),
    };
  } finally {
    db.close();
  }
}
