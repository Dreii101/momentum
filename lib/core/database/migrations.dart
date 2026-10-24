import 'package:drift/drift.dart';

Future<void> upgradeBackupV9ToV10(GeneratedDatabase db) =>
    db.customStatement(notificationCleanupV10Sql);

// Retain native cancellation intent even when replacement removes old source IDs.
const notificationCleanupV10Sql =
    r'''CREATE TABLE IF NOT EXISTS "notification_cleanup_rows" ("notification_id" INTEGER NOT NULL CHECK(typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000), PRIMARY KEY ("notification_id"));''';

Future<void> upgradeProgressV8ToV9(GeneratedDatabase db) =>
    db.customStatement(progressV9Sql);

// Frozen additive schema 9: no existing records are rewritten.
const progressV9Sql =
    r'''CREATE TABLE IF NOT EXISTS "weekly_reflections" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "week_start" TEXT NOT NULL CHECK((week_start IS NULL OR (length(week_start) = 10 AND week_start GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(week_start,1,4) != '0000' AND date(week_start,'+0 days') IS NOT NULL AND date(week_start,'+0 days') = week_start)) AND strftime('%w',week_start) = '1') UNIQUE, "helped" TEXT NOT NULL CHECK(length(helped) <= 5000), "obstacles" TEXT NOT NULL CHECK(length(obstacles) <= 5000), "adjustment" TEXT NOT NULL CHECK(length(adjustment) <= 5000), "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"));''';

Future<void> upgradeRemindersV7ToV8(GeneratedDatabase db) async {
  for (final statement in remindersV8Sql) {
    await db.customStatement(statement);
  }
}

const remindersV8Sql = <String>[
  r'''CREATE TABLE IF NOT EXISTS "reminder_preferences_rows" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "singleton" INTEGER NOT NULL CHECK(singleton = 1) UNIQUE, "enabled" INTEGER NOT NULL DEFAULT 0 CHECK ("enabled" IN (0, 1)), "quiet_enabled" INTEGER NOT NULL DEFAULT 1 CHECK ("quiet_enabled" IN (0, 1)), "quiet_start" INTEGER NOT NULL DEFAULT 1320 CHECK(typeof(quiet_start)='integer' AND quiet_start BETWEEN 0 AND 1439), "quiet_end" INTEGER NOT NULL DEFAULT 420 CHECK(typeof(quiet_end)='integer' AND quiet_end BETWEEN 0 AND 1439), PRIMARY KEY ("id"), CHECK (quiet_start != quiet_end));''',
  r'''CREATE TABLE IF NOT EXISTS "reminder_rules" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "kind" TEXT NOT NULL CHECK(kind IN ('deadline','activity','work','timer')), "task_id" TEXT NULL UNIQUE REFERENCES tasks (id), "series_id" TEXT NULL UNIQUE REFERENCES activity_series (id), "work_id" TEXT NULL UNIQUE REFERENCES planned_work_blocks (id), "installation_id" TEXT NULL UNIQUE REFERENCES installations (id), "enabled" INTEGER NOT NULL DEFAULT 1 CHECK ("enabled" IN (0, 1)), "lead_minutes" INTEGER NOT NULL DEFAULT 0 CHECK(typeof(lead_minutes)='integer' AND lead_minutes BETWEEN 0 AND 10080), PRIMARY KEY ("id"), CHECK ((kind='deadline' AND task_id IS NOT NULL AND series_id IS NULL AND work_id IS NULL AND installation_id IS NULL) OR (kind='activity' AND task_id IS NULL AND series_id IS NOT NULL AND work_id IS NULL AND installation_id IS NULL) OR (kind='work' AND task_id IS NULL AND series_id IS NULL AND work_id IS NOT NULL AND installation_id IS NULL) OR (kind='timer' AND task_id IS NULL AND series_id IS NULL AND work_id IS NULL AND installation_id IS NOT NULL AND lead_minutes=0)));''',
  r'''CREATE TABLE IF NOT EXISTS "reminder_registrations" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "rule_id" TEXT NOT NULL REFERENCES reminder_rules (id), "identity_key" TEXT NOT NULL UNIQUE, "notification_id" INTEGER NOT NULL CHECK(typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000) UNIQUE, "original_date" TEXT NULL CHECK(original_date IS NULL OR (length(original_date) = 10 AND original_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(original_date,1,4) != '0000' AND date(original_date,'+0 days') IS NOT NULL AND date(original_date,'+0 days') = original_date)), "session_id" TEXT NULL REFERENCES focus_sessions (id), "source_utc" INTEGER NOT NULL, "due_utc" INTEGER NOT NULL, "fingerprint" TEXT NOT NULL, "state" TEXT NOT NULL CHECK(state IN ('pending','scheduled','cancelled','elapsed','scheduleFailed','cancelFailed')), "error" TEXT NULL, "registered_at_utc" INTEGER NULL, "opened_at_utc" INTEGER NULL, PRIMARY KEY ("id"));''',
  r'''CREATE INDEX reminders_due ON reminder_registrations (due_utc, state)''',
  r'''CREATE INDEX reminders_rule ON reminder_registrations (rule_id)''',
];

Future<void> upgradeTimerV6ToV7(GeneratedDatabase db) async {
  for (final statement in timerV7Sql) {
    await db.customStatement(statement);
  }
}

const timerV7Sql = <String>[
  r'''CREATE TABLE IF NOT EXISTS "focus_sessions" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "installation_id" TEXT NOT NULL REFERENCES installations (id), "task_id" TEXT NULL REFERENCES tasks (id), "subtask_id" TEXT NULL REFERENCES subtasks (id), "title_snapshot" TEXT NOT NULL CHECK(length(title_snapshot) BETWEEN 1 AND 200), "zone" TEXT NOT NULL CHECK(length(zone) BETWEEN 1 AND 100), "local_start_date" TEXT NOT NULL CHECK(local_start_date IS NULL OR (length(local_start_date) = 10 AND local_start_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(local_start_date,1,4) != '0000' AND date(local_start_date,'+0 days') IS NOT NULL AND date(local_start_date,'+0 days') = local_start_date)), "started_utc" INTEGER NOT NULL, "kind" TEXT NOT NULL CHECK(kind IN ('starter','focus','rest')), "state" TEXT NOT NULL CHECK(state IN ('running','paused','awaitingReview','finalized')), "outcome" TEXT NULL CHECK(outcome IN ('completed','stoppedEarly','interrupted')), "planned_ms" INTEGER NOT NULL, "elapsed_ms" INTEGER NOT NULL, "eligible_ms" INTEGER NOT NULL, "uncertain_ms" INTEGER NOT NULL, "has_uncertainty" INTEGER NOT NULL CHECK ("has_uncertainty" IN (0, 1)), "background" INTEGER NOT NULL CHECK ("background" IN (0, 1)), "checkpoint_utc" INTEGER NOT NULL, "elapsed_mark_ms" INTEGER NOT NULL CHECK(typeof(elapsed_mark_ms) = 'integer' AND elapsed_mark_ms >= 0), "clock_epoch" TEXT NOT NULL, "revision" INTEGER NOT NULL CHECK(typeof(revision) = 'integer' AND revision >= 0), "reported_ms" INTEGER NULL, "finalized_utc" INTEGER NULL, PRIMARY KEY ("id"), CHECK (typeof(planned_ms) = 'integer' AND ((kind='starter' AND planned_ms=120000) OR (kind='focus' AND planned_ms BETWEEN 60000 AND 10800000) OR (kind='rest' AND planned_ms BETWEEN 60000 AND 3600000))), CHECK (typeof(elapsed_ms)='integer' AND typeof(eligible_ms)='integer' AND typeof(uncertain_ms)='integer' AND elapsed_ms BETWEEN 0 AND planned_ms AND eligible_ms>=0 AND uncertain_ms>=0 AND eligible_ms+uncertain_ms<=elapsed_ms), CHECK ((kind='rest' AND eligible_ms=0) OR (kind!='rest' AND eligible_ms+uncertain_ms=elapsed_ms)), CHECK (subtask_id IS NULL OR task_id IS NOT NULL), CHECK ((state IN ('running','paused') AND outcome IS NULL) OR (state IN ('awaitingReview','finalized') AND outcome IS NOT NULL)), CHECK ((state='finalized' AND reported_ms IS NOT NULL AND typeof(reported_ms)='integer' AND reported_ms BETWEEN 0 AND eligible_ms AND finalized_utc IS NOT NULL) OR (state!='finalized' AND reported_ms IS NULL AND finalized_utc IS NULL)));''',
  r'''CREATE TABLE IF NOT EXISTS "focus_segments" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "session_id" TEXT NOT NULL REFERENCES focus_sessions (id), "sequence" INTEGER NOT NULL CHECK(sequence >= 1), "kind" TEXT NOT NULL CHECK(kind IN ('active','pause','gap')), "from_utc" INTEGER NOT NULL, "to_utc" INTEGER NOT NULL, "span_ms" INTEGER NOT NULL, "elapsed_ms" INTEGER NOT NULL, "eligible_ms" INTEGER NOT NULL, "reason" TEXT NULL, PRIMARY KEY ("id"), UNIQUE ("session_id", "sequence"), CHECK (typeof(span_ms)='integer' AND typeof(elapsed_ms)='integer' AND typeof(eligible_ms)='integer' AND span_ms>=0 AND elapsed_ms BETWEEN 0 AND span_ms AND eligible_ms BETWEEN 0 AND elapsed_ms), CHECK (kind!='pause' OR (elapsed_ms=0 AND eligible_ms=0)), CHECK (reason IS NULL OR eligible_ms=0));''',
  r'''CREATE TABLE IF NOT EXISTS "timer_command_receipts" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "session_id" TEXT NOT NULL REFERENCES focus_sessions (id), "action" TEXT NOT NULL CHECK(action IN ('start','pause','resume','extend','end','recover','finalize','background','foreground')), "payload" TEXT NOT NULL, "committed_utc" INTEGER NOT NULL, PRIMARY KEY ("id"));''',
  r"""CREATE UNIQUE INDEX one_unfinished_session ON focus_sessions (installation_id) WHERE state != 'finalized'""",
  r'''CREATE INDEX sessions_started ON focus_sessions (local_start_date, started_utc)''',
  r'''CREATE INDEX segments_session_order ON focus_segments (session_id, sequence)''',
  r'''CREATE INDEX timer_commands_session ON timer_command_receipts (session_id)''',
];

Future<void> upgradePlanningV5ToV6(GeneratedDatabase db) async {
  for (final statement in planningV6Sql) {
    await db.customStatement(statement);
  }
}

// Frozen schema-6 addition. Historical migrations must not use latest getters.
const planningV6Sql = <String>[
  r'''CREATE TABLE IF NOT EXISTS "planned_work_blocks" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, "deleted_at" INTEGER NULL, "task_id" TEXT NOT NULL REFERENCES tasks (id), "start_utc" INTEGER NOT NULL, "end_utc" INTEGER NOT NULL, "planning_zone" TEXT NOT NULL CHECK(length(planning_zone) BETWEEN 1 AND 100), "status" TEXT NOT NULL CHECK(status IN ('planned','completed','cancelled')), "locked" INTEGER NOT NULL DEFAULT 0 CHECK ("locked" IN (0, 1)), PRIMARY KEY ("id"), CHECK (typeof(start_utc) = 'integer' AND typeof(end_utc) = 'integer' AND end_utc > start_utc));''',
  r'''CREATE INDEX work_blocks_range ON planned_work_blocks (deleted_at, start_utc, end_utc)''',
  r'''CREATE INDEX work_blocks_task ON planned_work_blocks (task_id, deleted_at)''',
];

// Frozen from schema 5. Additive migration; original tables are untouched.
Future<void> upgradeScheduleV4ToV5(GeneratedDatabase db) async {
  for (final statement in scheduleV5Sql) {
    await db.customStatement(statement);
  }
}

const scheduleV5Sql = <String>[
  r'''CREATE TABLE IF NOT EXISTS "activity_series" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, "deleted_at" INTEGER NULL, "title" TEXT NOT NULL CHECK(length(trim(title)) BETWEEN 1 AND 200), "course_id" TEXT NULL REFERENCES courses (id), "recurrence" TEXT NOT NULL CHECK(recurrence IN ('once','weekly')), "weekdays" INTEGER NOT NULL CHECK(typeof(weekdays) = 'integer' AND weekdays BETWEEN 0 AND 127), "start_date" TEXT NOT NULL CHECK(start_date IS NULL OR (length(start_date) = 10 AND start_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(start_date,1,4) != '0000' AND date(start_date,'+0 days') IS NOT NULL AND date(start_date,'+0 days') = start_date)), "end_date" TEXT NOT NULL CHECK(end_date IS NULL OR (length(end_date) = 10 AND end_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(end_date,1,4) != '0000' AND date(end_date,'+0 days') IS NOT NULL AND date(end_date,'+0 days') = end_date)), "start_minute" INTEGER NOT NULL CHECK(typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439), "end_minute" INTEGER NOT NULL CHECK(typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439), "end_day_offset" INTEGER NOT NULL CHECK(end_day_offset IN (0,1)), "zone" TEXT NOT NULL CHECK(length(zone) BETWEEN 1 AND 100), "location" TEXT NOT NULL DEFAULT '', "busy" INTEGER NOT NULL DEFAULT 1 CHECK ("busy" IN (0, 1)), "superseded_from" TEXT NULL CHECK(superseded_from IS NULL OR (length(superseded_from) = 10 AND superseded_from GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(superseded_from,1,4) != '0000' AND date(superseded_from,'+0 days') IS NOT NULL AND date(superseded_from,'+0 days') = superseded_from)), "replaced_by" TEXT NULL REFERENCES activity_series (id), PRIMARY KEY ("id"), CHECK (start_date <= end_date), CHECK ((recurrence = 'once' AND start_date = end_date AND weekdays = 0) OR (recurrence = 'weekly' AND weekdays BETWEEN 1 AND 127)), CHECK (end_minute + end_day_offset * 1440 > start_minute), CHECK ((superseded_from IS NULL AND replaced_by IS NULL) OR (superseded_from IS NOT NULL AND replaced_by IS NOT NULL AND superseded_from >= start_date AND superseded_from <= end_date AND replaced_by != id)));''',
  r'''CREATE TABLE IF NOT EXISTS "activity_exceptions" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "series_id" TEXT NOT NULL REFERENCES activity_series (id), "original_date" TEXT NOT NULL CHECK(original_date IS NULL OR (length(original_date) = 10 AND original_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(original_date,1,4) != '0000' AND date(original_date,'+0 days') IS NOT NULL AND date(original_date,'+0 days') = original_date)), "cancelled" INTEGER NOT NULL DEFAULT 0 CHECK ("cancelled" IN (0, 1)), "moved_date" TEXT NULL CHECK(moved_date IS NULL OR (length(moved_date) = 10 AND moved_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(moved_date,1,4) != '0000' AND date(moved_date,'+0 days') IS NOT NULL AND date(moved_date,'+0 days') = moved_date)), "start_minute" INTEGER NULL CHECK(start_minute IS NULL OR (typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439)), "end_minute" INTEGER NULL CHECK(end_minute IS NULL OR (typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439)), "end_day_offset" INTEGER NULL CHECK(end_day_offset IN (0,1)), "zone" TEXT NULL CHECK(length(zone) BETWEEN 1 AND 100), "location" TEXT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), UNIQUE ("series_id", "original_date"), CHECK ((moved_date IS NULL AND start_minute IS NULL AND end_minute IS NULL AND end_day_offset IS NULL AND zone IS NULL AND location IS NULL) OR (moved_date IS NOT NULL AND start_minute IS NOT NULL AND end_minute IS NOT NULL AND end_day_offset IS NOT NULL AND zone IS NOT NULL AND location IS NOT NULL)), CHECK (moved_date IS NULL OR end_minute + end_day_offset * 1440 > start_minute));''',
  r'''CREATE TABLE IF NOT EXISTS "note_activity_links" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "note_id" TEXT NOT NULL REFERENCES notes (id), "series_id" TEXT NOT NULL REFERENCES activity_series (id), "original_date" TEXT NULL CHECK(original_date IS NULL OR (length(original_date) = 10 AND original_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(original_date,1,4) != '0000' AND date(original_date,'+0 days') IS NOT NULL AND date(original_date,'+0 days') = original_date)), "created_at" INTEGER NOT NULL, PRIMARY KEY ("id"));''',
  r'''CREATE INDEX activities_course ON activity_series (course_id)''',
  r'''CREATE INDEX activities_dates ON activity_series (start_date, end_date)''',
  r'''CREATE INDEX activity_exceptions_moved ON activity_exceptions (moved_date)''',
  r'''CREATE UNIQUE INDEX note_activity_pair ON note_activity_links (note_id, series_id, COALESCE(original_date, ''))''',
  r'''CREATE INDEX note_activity_target ON note_activity_links (series_id, original_date)''',
];

// Frozen from drift_schema_v2.json. Never replace with the latest table getter:
// later schema changes must not alter the historical 1 -> 2 migration.
const prioritiesV2Sql =
    r'''CREATE TABLE IF NOT EXISTS "daily_priorities" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "day" TEXT NOT NULL CHECK(day IS NULL OR (length(day) = 10 AND day GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND substr(day,1,4) != '0000' AND date(day,'+0 days') IS NOT NULL AND date(day,'+0 days') = day)), "task_id" TEXT NOT NULL REFERENCES tasks (id), "slot" INTEGER NOT NULL CHECK(slot IN (1, 2, 3)), "created_at" INTEGER NOT NULL, PRIMARY KEY ("id"), UNIQUE ("day", "slot"), UNIQUE ("day", "task_id"));''';
const prioritiesV2IndexSql =
    r'''CREATE INDEX daily_priorities_task ON daily_priorities (task_id)''';

/// Runs inside AppDatabase's migration transaction. Invalid historical slots
/// fail the copy and roll back all changes, preserving the original database.
Future<void> upgradePrioritiesV1ToV2(GeneratedDatabase db) async {
  await db.customStatement(
    'ALTER TABLE daily_priorities RENAME TO daily_priorities_before_v2',
  );
  await db.customStatement(prioritiesV2Sql);
  await db.customStatement('''
    INSERT INTO daily_priorities (id, day, task_id, slot, created_at)
    SELECT id, day, task_id, slot, created_at FROM daily_priorities_before_v2
  ''');
  await db.customStatement('DROP TABLE daily_priorities_before_v2');
  await db.customStatement(prioritiesV2IndexSql);
}

// Frozen version-3 Settings definition. Existing IDs and preference values survive.
const preferencesV3Sql =
    r'''CREATE TABLE IF NOT EXISTS "app_settings" ("id" TEXT NOT NULL CHECK(length(id) = 36 AND substr(id,9,1) = '-' AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') AND substr(id,20,1) IN ('8','9','a','b')), "singleton" INTEGER NOT NULL CHECK(singleton = 1) UNIQUE, "theme" TEXT NOT NULL CHECK(theme IN ('system','light','dark')), "planning_zone" TEXT NOT NULL CHECK(length(planning_zone) BETWEEN 1 AND 100), "focus_minutes" INTEGER NOT NULL DEFAULT 25 CHECK(typeof(focus_minutes) = 'integer' AND focus_minutes BETWEEN 1 AND 180), "break_minutes" INTEGER NOT NULL DEFAULT 5 CHECK(typeof(break_minutes) = 'integer' AND break_minutes BETWEEN 1 AND 60), "reduced_motion" INTEGER NOT NULL DEFAULT 0 CHECK ("reduced_motion" IN (0, 1)), "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"));''';

Future<void> upgradePreferencesV2ToV3(GeneratedDatabase db) async {
  await db.customStatement(
    'ALTER TABLE app_settings RENAME TO app_settings_before_v3',
  );
  await db.customStatement(preferencesV3Sql);
  await db.customStatement('''
    INSERT INTO app_settings (id, singleton, theme, planning_zone, updated_at)
    SELECT id, singleton, theme, planning_zone, updated_at FROM app_settings_before_v3
  ''');
  await db.customStatement('DROP TABLE app_settings_before_v3');
}

/// Additive migration: task IDs, links, dates and preferences remain untouched.
Future<void> upgradeTasksV3ToV4(GeneratedDatabase db) async {
  await db.customStatement(
    'ALTER TABLE tasks ADD COLUMN "archived_at" INTEGER NULL',
  );
  await db.customStatement(
    'CREATE INDEX tasks_visibility ON tasks (deleted_at, archived_at)',
  );
}
