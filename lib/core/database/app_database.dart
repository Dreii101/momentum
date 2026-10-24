import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'value_types.dart';
import 'migrations.dart';
import 'recovery_snapshots.dart';
import '../../features/focus/timer_engine.dart';
import '../../features/reminders/reminder_types.dart';

part 'app_database.g.dart';

// SQL checks also protect writes made outside repositories and future imports.
const uuidCheckSql =
    "length(id) = 36 AND substr(id,9,1) = '-' "
    "AND substr(id,14,1) = '-' AND substr(id,19,1) = '-' "
    "AND substr(id,24,1) = '-' AND length(replace(id,'-','')) = 32 "
    "AND replace(id,'-','') NOT GLOB '*[^0-9a-f]*' "
    "AND substr(id,15,1) IN ('1','2','3','4','5','6','7','8') "
    "AND substr(id,20,1) IN ('8','9','a','b')";

String validDateSql(String column) =>
    "$column IS NULL OR (length($column) = 10 AND $column GLOB "
    "'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' "
    "AND substr($column,1,4) != '0000' "
    "AND date($column,'+0 days') IS NOT NULL "
    "AND date($column,'+0 days') = $column)";

mixin Identified on Table {
  TextColumn get id => text().check(const CustomExpression(uuidCheckSql))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

mixin Audited on Table {
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
  IntColumn get updatedAt => integer().map(const UtcInstantConverter())();
  IntColumn get deletedAt =>
      integer().nullable().map(const UtcInstantConverter())();
}

@DataClassName('Course')
@TableIndex(name: 'courses_visibility', columns: {#deletedAt, #archivedAt})
class Courses extends Table with Identified, Audited {
  TextColumn get name => text().check(
    const CustomExpression("length(trim(name)) BETWEEN 1 AND 200"),
  )();
  TextColumn get color => text().nullable()();
  TextColumn get termStart => text()
      .nullable()
      .check(CustomExpression(validDateSql('term_start')))
      .map(const CalendarDateConverter())();
  TextColumn get termEnd => text()
      .nullable()
      .check(CustomExpression(validDateSql('term_end')))
      .map(const CalendarDateConverter())();
  IntColumn get archivedAt =>
      integer().nullable().map(const UtcInstantConverter())();
  @override
  List<String> get customConstraints => [
    'CHECK (term_start IS NULL OR term_end IS NULL OR term_start <= term_end)',
  ];
}

@DataClassName('Task')
@TableIndex(name: 'tasks_course', columns: {#courseId})
@TableIndex(
  name: 'tasks_status_updated',
  columns: {#deletedAt, #status, #updatedAt},
)
@TableIndex(name: 'tasks_deadline', columns: {#deletedAt, #deadlineBoundaryUtc})
@TableIndex(name: 'tasks_visibility', columns: {#deletedAt, #archivedAt})
class Tasks extends Table with Identified, Audited {
  TextColumn get title => text().check(
    const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
  )();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get nextAction => text().nullable()();
  TextColumn get courseId => text().nullable().references(Courses, #id)();
  TextColumn get status => textEnum<TaskStatus>().check(
    const CustomExpression("status IN ('todo','doing','done')"),
  )();
  TextColumn get priority => textEnum<TaskPriority>().check(
    const CustomExpression("priority IN ('low','normal','high')"),
  )();
  TextColumn get deadlineKind => textEnum<DeadlineKind>().check(
    const CustomExpression("deadline_kind IN ('none','dateOnly','timed')"),
  )();
  TextColumn get deadlineDate => text()
      .nullable()
      .check(CustomExpression(validDateSql('deadline_date')))
      .map(const CalendarDateConverter())();
  IntColumn get deadlineUtc =>
      integer().nullable().map(const UtcInstantConverter())();
  TextColumn get deadlineZone => text().nullable().check(
    const CustomExpression('length(deadline_zone) BETWEEN 1 AND 100'),
  )();

  /// Derived boundary: exclusive for dateOnly, inclusive for timed.
  IntColumn get deadlineBoundaryUtc =>
      integer().nullable().map(const UtcInstantConverter())();
  IntColumn get targetUtc =>
      integer().nullable().map(const UtcInstantConverter())();
  IntColumn get remainingMinutes => integer().nullable().check(
    const CustomExpression('remaining_minutes >= 0'),
  )();
  IntColumn get completedAt =>
      integer().nullable().map(const UtcInstantConverter())();
  IntColumn get archivedAt =>
      integer().nullable().map(const UtcInstantConverter())();
  @override
  List<String> get customConstraints => [
    """CHECK (
      (deadline_kind = 'none' AND deadline_date IS NULL AND deadline_utc IS NULL
        AND deadline_zone IS NULL AND deadline_boundary_utc IS NULL) OR
      (deadline_kind = 'dateOnly' AND deadline_date IS NOT NULL AND deadline_utc IS NULL
        AND deadline_zone IS NOT NULL AND deadline_boundary_utc IS NOT NULL) OR
      (deadline_kind = 'timed' AND deadline_date IS NULL AND deadline_utc IS NOT NULL
        AND deadline_zone IS NOT NULL AND deadline_boundary_utc IS NOT NULL
        AND deadline_boundary_utc = deadline_utc))""",
    """CHECK (target_utc IS NULL OR deadline_kind = 'none' OR
      (deadline_kind = 'dateOnly' AND target_utc < deadline_boundary_utc) OR
      (deadline_kind = 'timed' AND target_utc <= deadline_boundary_utc))""",
    """CHECK ((status = 'done' AND completed_at IS NOT NULL) OR
      (status != 'done' AND completed_at IS NULL))""",
  ];
}

@DataClassName('Subtask')
@TableIndex(
  name: 'subtasks_task_order',
  columns: {#taskId, #deletedAt, #position},
)
class Subtasks extends Table with Identified, Audited {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text().check(
    const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
  )();
  IntColumn get position =>
      integer().check(const CustomExpression('position >= 0'))();
  IntColumn get completedAt =>
      integer().nullable().map(const UtcInstantConverter())();
}

@DataClassName('Note')
@TableIndex(name: 'notes_course', columns: {#courseId})
@TableIndex(
  name: 'notes_visibility_updated',
  columns: {#deletedAt, #pinned, #updatedAt},
)
class Notes extends Table with Identified, Audited {
  TextColumn get title =>
      text().check(const CustomExpression('length(title) <= 200'))();
  TextColumn get body =>
      text().check(const CustomExpression('length(body) <= 100000'))();
  TextColumn get courseId => text().nullable().references(Courses, #id)();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
}

@DataClassName('NoteTaskLink')
@TableIndex(name: 'note_links_task', columns: {#taskId})
class NoteTaskLinks extends Table with Identified {
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get taskId => text().references(Tasks, #id)();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {noteId, taskId},
  ];
}

@DataClassName('DailyPriority')
@TableIndex(name: 'daily_priorities_task', columns: {#taskId})
class DailyPriorities extends Table with Identified {
  TextColumn get day => text()
      .check(CustomExpression(validDateSql('day')))
      .map(const CalendarDateConverter())();
  TextColumn get taskId => text().references(Tasks, #id)();
  IntColumn get slot =>
      integer().check(const CustomExpression('slot IN (1, 2, 3)'))();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {day, slot},
    {day, taskId},
  ];
}

@DataClassName('Settings')
class AppSettings extends Table with Identified {
  IntColumn get singleton =>
      integer().unique().check(const CustomExpression('singleton = 1'))();
  TextColumn get theme => textEnum<ThemePreference>().check(
    const CustomExpression("theme IN ('system','light','dark')"),
  )();
  TextColumn get planningZone => text().check(
    const CustomExpression('length(planning_zone) BETWEEN 1 AND 100'),
  )();
  IntColumn get focusMinutes => integer()
      .withDefault(const Constant(25))
      .check(
        const CustomExpression(
          "typeof(focus_minutes) = 'integer' AND focus_minutes BETWEEN 1 AND 180",
        ),
      )();
  IntColumn get breakMinutes => integer()
      .withDefault(const Constant(5))
      .check(
        const CustomExpression(
          "typeof(break_minutes) = 'integer' AND break_minutes BETWEEN 1 AND 60",
        ),
      )();
  BoolColumn get reducedMotion =>
      boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer().map(const UtcInstantConverter())();
}

@DataClassName('InstallationMetadata')
class Installations extends Table with Identified {
  IntColumn get singleton =>
      integer().unique().check(const CustomExpression('singleton = 1'))();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
}

@DataClassName('ActivitySeries')
@TableIndex(name: 'activities_course', columns: {#courseId})
@TableIndex(name: 'activities_dates', columns: {#startDate, #endDate})
class ActivitySeriesRows extends Table with Identified, Audited {
  @override
  String get tableName => 'activity_series';
  TextColumn get title => text().check(
    const CustomExpression("length(trim(title)) BETWEEN 1 AND 200"),
  )();
  TextColumn get courseId => text().nullable().references(Courses, #id)();
  TextColumn get recurrence =>
      text().check(const CustomExpression("recurrence IN ('once','weekly')"))();
  IntColumn get weekdays => integer().check(
    const CustomExpression(
      "typeof(weekdays) = 'integer' AND weekdays BETWEEN 0 AND 127",
    ),
  )();
  TextColumn get startDate => text()
      .check(CustomExpression(validDateSql('start_date')))
      .map(const CalendarDateConverter())();
  TextColumn get endDate => text()
      .check(CustomExpression(validDateSql('end_date')))
      .map(const CalendarDateConverter())();
  IntColumn get startMinute => integer().check(
    const CustomExpression(
      "typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439",
    ),
  )();
  IntColumn get endMinute => integer().check(
    const CustomExpression(
      "typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439",
    ),
  )();
  IntColumn get endDayOffset =>
      integer().check(const CustomExpression('end_day_offset IN (0,1)'))();
  TextColumn get zone =>
      text().check(const CustomExpression('length(zone) BETWEEN 1 AND 100'))();
  TextColumn get location => text().withDefault(const Constant(''))();
  BoolColumn get busy => boolean().withDefault(const Constant(true))();
  // Original bounds never change: retained exceptions/notes can resolve forever.
  TextColumn get supersededFrom => text()
      .nullable()
      .check(CustomExpression(validDateSql('superseded_from')))
      .map(const CalendarDateConverter())();
  TextColumn get replacedBy =>
      text().nullable().references(ActivitySeriesRows, #id)();
  @override
  List<String> get customConstraints => [
    'CHECK (start_date <= end_date)',
    "CHECK ((recurrence = 'once' AND start_date = end_date AND weekdays = 0) OR (recurrence = 'weekly' AND weekdays BETWEEN 1 AND 127))",
    'CHECK (end_minute + end_day_offset * 1440 > start_minute)',
    'CHECK ((superseded_from IS NULL AND replaced_by IS NULL) OR (superseded_from IS NOT NULL AND replaced_by IS NOT NULL AND superseded_from >= start_date AND superseded_from <= end_date AND replaced_by != id))',
  ];
}

@DataClassName('ActivityException')
@TableIndex(name: 'activity_exceptions_moved', columns: {#movedDate})
class ActivityExceptions extends Table with Identified {
  TextColumn get seriesId => text().references(ActivitySeriesRows, #id)();
  TextColumn get originalDate => text()
      .check(CustomExpression(validDateSql('original_date')))
      .map(const CalendarDateConverter())();
  BoolColumn get cancelled => boolean().withDefault(const Constant(false))();
  TextColumn get movedDate => text()
      .nullable()
      .check(CustomExpression(validDateSql('moved_date')))
      .map(const CalendarDateConverter())();
  IntColumn get startMinute => integer().nullable().check(
    const CustomExpression(
      "start_minute IS NULL OR (typeof(start_minute) = 'integer' AND start_minute BETWEEN 0 AND 1439)",
    ),
  )();
  IntColumn get endMinute => integer().nullable().check(
    const CustomExpression(
      "end_minute IS NULL OR (typeof(end_minute) = 'integer' AND end_minute BETWEEN 0 AND 1439)",
    ),
  )();
  IntColumn get endDayOffset => integer().nullable().check(
    const CustomExpression('end_day_offset IN (0,1)'),
  )();
  TextColumn get zone => text().nullable().check(
    const CustomExpression('length(zone) BETWEEN 1 AND 100'),
  )();
  TextColumn get location => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
  IntColumn get updatedAt => integer().map(const UtcInstantConverter())();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {seriesId, originalDate},
  ];
  @override
  List<String> get customConstraints => [
    'CHECK ((moved_date IS NULL AND start_minute IS NULL AND end_minute IS NULL AND end_day_offset IS NULL AND zone IS NULL AND location IS NULL) OR (moved_date IS NOT NULL AND start_minute IS NOT NULL AND end_minute IS NOT NULL AND end_day_offset IS NOT NULL AND zone IS NOT NULL AND location IS NOT NULL))',
    'CHECK (moved_date IS NULL OR end_minute + end_day_offset * 1440 > start_minute)',
  ];
}

@DataClassName('NoteActivityLink')
@TableIndex.sql(
  "CREATE UNIQUE INDEX note_activity_pair ON note_activity_links (note_id, series_id, COALESCE(original_date, ''))",
)
@TableIndex(name: 'note_activity_target', columns: {#seriesId, #originalDate})
class NoteActivityLinks extends Table with Identified {
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get seriesId => text().references(ActivitySeriesRows, #id)();
  // Null means the complete series; a date means its original occurrence.
  TextColumn get originalDate => text()
      .nullable()
      .check(CustomExpression(validDateSql('original_date')))
      .map(const CalendarDateConverter())();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
}

@DataClassName('PlannedWorkBlock')
@TableIndex(
  name: 'work_blocks_range',
  columns: {#deletedAt, #startUtc, #endUtc},
)
@TableIndex(name: 'work_blocks_task', columns: {#taskId, #deletedAt})
class PlannedWorkBlocks extends Table with Identified, Audited {
  TextColumn get taskId => text().references(Tasks, #id)();
  IntColumn get startUtc => integer().map(const UtcInstantConverter())();
  IntColumn get endUtc => integer().map(const UtcInstantConverter())();
  TextColumn get planningZone => text().check(
    const CustomExpression('length(planning_zone) BETWEEN 1 AND 100'),
  )();
  TextColumn get status => textEnum<WorkBlockStatus>().check(
    const CustomExpression("status IN ('planned','completed','cancelled')"),
  )();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  @override
  List<String> get customConstraints => [
    "CHECK (typeof(start_utc) = 'integer' AND typeof(end_utc) = 'integer' AND end_utc > start_utc)",
  ];
}

@DataClassName('FocusSession')
@TableIndex.sql(
  "CREATE UNIQUE INDEX one_unfinished_session ON focus_sessions (installation_id) WHERE state != 'finalized'",
)
@TableIndex(name: 'sessions_started', columns: {#localStartDate, #startedUtc})
class FocusSessions extends Table with Identified {
  TextColumn get installationId => text().references(Installations, #id)();
  TextColumn get taskId => text().nullable().references(Tasks, #id)();
  TextColumn get subtaskId => text().nullable().references(Subtasks, #id)();
  TextColumn get titleSnapshot => text().check(
    const CustomExpression('length(title_snapshot) BETWEEN 1 AND 200'),
  )();
  TextColumn get zone =>
      text().check(const CustomExpression('length(zone) BETWEEN 1 AND 100'))();
  TextColumn get localStartDate => text()
      .check(CustomExpression(validDateSql('local_start_date')))
      .map(const CalendarDateConverter())();
  IntColumn get startedUtc => integer().map(const UtcInstantConverter())();
  TextColumn get kind => textEnum<SessionKind>().check(
    const CustomExpression("kind IN ('starter','focus','rest')"),
  )();
  TextColumn get state => textEnum<SessionState>().check(
    const CustomExpression(
      "state IN ('running','paused','awaitingReview','finalized')",
    ),
  )();
  TextColumn get outcome => textEnum<SessionOutcome>().nullable().check(
    const CustomExpression(
      "outcome IN ('completed','stoppedEarly','interrupted')",
    ),
  )();
  IntColumn get plannedMs => integer()();
  IntColumn get elapsedMs => integer()();
  IntColumn get eligibleMs => integer()();
  IntColumn get uncertainMs => integer()();
  BoolColumn get hasUncertainty => boolean()();
  BoolColumn get background => boolean()();
  IntColumn get checkpointUtc => integer().map(const UtcInstantConverter())();
  IntColumn get elapsedMarkMs => integer().check(
    const CustomExpression(
      "typeof(elapsed_mark_ms) = 'integer' AND elapsed_mark_ms >= 0",
    ),
  )();
  TextColumn get clockEpoch => text()();
  IntColumn get revision => integer().check(
    const CustomExpression("typeof(revision) = 'integer' AND revision >= 0"),
  )();
  IntColumn get reportedMs => integer().nullable()();
  IntColumn get finalizedUtc =>
      integer().nullable().map(const UtcInstantConverter())();
  @override
  List<String> get customConstraints => [
    "CHECK (typeof(planned_ms) = 'integer' AND ((kind='starter' AND planned_ms=120000) OR (kind='focus' AND planned_ms BETWEEN 60000 AND 10800000) OR (kind='rest' AND planned_ms BETWEEN 60000 AND 3600000)))",
    "CHECK (typeof(elapsed_ms)='integer' AND typeof(eligible_ms)='integer' AND typeof(uncertain_ms)='integer' AND elapsed_ms BETWEEN 0 AND planned_ms AND eligible_ms>=0 AND uncertain_ms>=0 AND eligible_ms+uncertain_ms<=elapsed_ms)",
    "CHECK ((kind='rest' AND eligible_ms=0) OR (kind!='rest' AND eligible_ms+uncertain_ms=elapsed_ms))",
    'CHECK (subtask_id IS NULL OR task_id IS NOT NULL)',
    "CHECK ((state IN ('running','paused') AND outcome IS NULL) OR (state IN ('awaitingReview','finalized') AND outcome IS NOT NULL))",
    "CHECK ((state='finalized' AND reported_ms IS NOT NULL AND typeof(reported_ms)='integer' AND reported_ms BETWEEN 0 AND eligible_ms AND finalized_utc IS NOT NULL) OR (state!='finalized' AND reported_ms IS NULL AND finalized_utc IS NULL))",
  ];
}

@DataClassName('FocusSegment')
@TableIndex(name: 'segments_session_order', columns: {#sessionId, #sequence})
class FocusSegments extends Table with Identified {
  TextColumn get sessionId => text().references(FocusSessions, #id)();
  IntColumn get sequence =>
      integer().check(const CustomExpression('sequence >= 1'))();
  TextColumn get kind => textEnum<SegmentKind>().check(
    const CustomExpression("kind IN ('active','pause','gap')"),
  )();
  IntColumn get fromUtc => integer().map(const UtcInstantConverter())();
  IntColumn get toUtc => integer().map(const UtcInstantConverter())();
  IntColumn get spanMs => integer()();
  IntColumn get elapsedMs => integer()();
  IntColumn get eligibleMs => integer()();
  TextColumn get reason => text().nullable()();
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, sequence},
  ];
  @override
  List<String> get customConstraints => [
    "CHECK (typeof(span_ms)='integer' AND typeof(elapsed_ms)='integer' AND typeof(eligible_ms)='integer' AND span_ms>=0 AND elapsed_ms BETWEEN 0 AND span_ms AND eligible_ms BETWEEN 0 AND elapsed_ms)",
    "CHECK (kind!='pause' OR (elapsed_ms=0 AND eligible_ms=0))",
    'CHECK (reason IS NULL OR eligible_ms=0)',
  ];
}

@DataClassName('TimerCommandReceipt')
@TableIndex(name: 'timer_commands_session', columns: {#sessionId})
class TimerCommandReceipts extends Table with Identified {
  TextColumn get sessionId => text().references(FocusSessions, #id)();
  TextColumn get action => text().check(
    const CustomExpression(
      "action IN ('start','pause','resume','extend','end','recover','finalize','background','foreground')",
    ),
  )();
  TextColumn get payload => text()();
  IntColumn get committedUtc => integer().map(const UtcInstantConverter())();
}

@DataClassName('ReminderPreferences')
class ReminderPreferencesRows extends Table with Identified {
  IntColumn get singleton =>
      integer().unique().check(const CustomExpression('singleton = 1'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  BoolColumn get quietEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get quietStart => integer()
      .withDefault(const Constant(1320))
      .check(
        const CustomExpression(
          "typeof(quiet_start)='integer' AND quiet_start BETWEEN 0 AND 1439",
        ),
      )();
  IntColumn get quietEnd => integer()
      .withDefault(const Constant(420))
      .check(
        const CustomExpression(
          "typeof(quiet_end)='integer' AND quiet_end BETWEEN 0 AND 1439",
        ),
      )();
  @override
  List<String> get customConstraints => ['CHECK (quiet_start != quiet_end)'];
}

@DataClassName('ReminderRule')
class ReminderRules extends Table with Identified {
  TextColumn get kind => textEnum<ReminderKind>().check(
    const CustomExpression("kind IN ('deadline','activity','work','timer')"),
  )();
  TextColumn get taskId => text().nullable().unique().references(Tasks, #id)();
  TextColumn get seriesId =>
      text().nullable().unique().references(ActivitySeriesRows, #id)();
  TextColumn get workId =>
      text().nullable().unique().references(PlannedWorkBlocks, #id)();
  TextColumn get installationId =>
      text().nullable().unique().references(Installations, #id)();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get leadMinutes => integer()
      .withDefault(const Constant(0))
      .check(
        const CustomExpression(
          "typeof(lead_minutes)='integer' AND lead_minutes BETWEEN 0 AND 10080",
        ),
      )();
  @override
  List<String> get customConstraints => [
    "CHECK ((kind='deadline' AND task_id IS NOT NULL AND series_id IS NULL AND work_id IS NULL AND installation_id IS NULL) OR (kind='activity' AND task_id IS NULL AND series_id IS NOT NULL AND work_id IS NULL AND installation_id IS NULL) OR (kind='work' AND task_id IS NULL AND series_id IS NULL AND work_id IS NOT NULL AND installation_id IS NULL) OR (kind='timer' AND task_id IS NULL AND series_id IS NULL AND work_id IS NULL AND installation_id IS NOT NULL AND lead_minutes=0))",
  ];
}

@DataClassName('ReminderRegistration')
@TableIndex(name: 'reminders_due', columns: {#dueUtc, #state})
@TableIndex(name: 'reminders_rule', columns: {#ruleId})
class ReminderRegistrations extends Table with Identified {
  TextColumn get ruleId => text().references(ReminderRules, #id)();
  TextColumn get identityKey => text().unique()();
  IntColumn get notificationId => integer().unique().check(
    const CustomExpression(
      "typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000",
    ),
  )();
  TextColumn get originalDate => text().nullable().check(
    CustomExpression(validDateSql('original_date')),
  )();
  TextColumn get sessionId =>
      text().nullable().references(FocusSessions, #id)();
  IntColumn get sourceUtc => integer().map(const UtcInstantConverter())();
  IntColumn get dueUtc => integer().map(const UtcInstantConverter())();
  TextColumn get fingerprint => text()();
  TextColumn get state => textEnum<RegistrationState>().check(
    const CustomExpression(
      "state IN ('pending','scheduled','cancelled','elapsed','scheduleFailed','cancelFailed')",
    ),
  )();
  TextColumn get error => text().nullable()();
  IntColumn get registeredAtUtc =>
      integer().nullable().map(const UtcInstantConverter())();
  IntColumn get openedAtUtc =>
      integer().nullable().map(const UtcInstantConverter())();
}

@DataClassName('WeeklyReflection')
class WeeklyReflections extends Table with Identified {
  TextColumn get weekStart => text()
      .unique()
      .check(
        CustomExpression(
          "(${validDateSql('week_start')}) AND strftime('%w',week_start) = '1'",
        ),
      )
      .map(const CalendarDateConverter())();
  TextColumn get helped =>
      text().check(const CustomExpression('length(helped) <= 5000'))();
  TextColumn get obstacles =>
      text().check(const CustomExpression('length(obstacles) <= 5000'))();
  TextColumn get adjustment =>
      text().check(const CustomExpression('length(adjustment) <= 5000'))();
  IntColumn get createdAt => integer().map(const UtcInstantConverter())();
  IntColumn get updatedAt => integer().map(const UtcInstantConverter())();
}

class NotificationCleanupRows extends Table {
  IntColumn get notificationId => integer().check(
    const CustomExpression(
      "typeof(notification_id)='integer' AND notification_id BETWEEN 1000000 AND 2147483000",
    ),
  )();
  @override
  Set<Column<Object>> get primaryKey => {notificationId};
}

const currentSchemaVersion = 10;

@DriftDatabase(
  tables: [
    Courses,
    Tasks,
    Subtasks,
    Notes,
    NoteTaskLinks,
    DailyPriorities,
    AppSettings,
    Installations,
    ActivitySeriesRows,
    ActivityExceptions,
    NoteActivityLinks,
    PlannedWorkBlocks,
    FocusSessions,
    FocusSegments,
    TimerCommandReceipts,
    ReminderPreferencesRows,
    ReminderRules,
    ReminderRegistrations,
    WeeklyReflections,
    NotificationCleanupRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  AppDatabase.file(File file)
    : super(
        NativeDatabase.createInBackground(
          file,
          setup: (database) {
            database.execute('PRAGMA foreign_keys = ON');
            database.execute('PRAGMA busy_timeout = 5000');
            final version = database.userVersion;
            if (version > 0 && version < currentSchemaVersion) {
              RecoverySnapshots.forDatabase(file).createSync(database);
            }
            database.execute('PRAGMA journal_mode = WAL');
            database.execute('PRAGMA synchronous = FULL');
          },
        ),
      );

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => transaction(m.createAll),
    onUpgrade: (m, from, to) => transaction(() => migrateSchema(m, from, to)),
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _checkRelationships();
    },
  );

  /// Only explicitly implemented version pairs may migrate. Never reset data.
  /// Version-specific steps use frozen SQL rather than the latest table getters.
  Future<void> migrateSchema(Migrator migrator, int from, int to) async {
    await _checkRelationships();
    if (from >= 1 && from < to && to == currentSchemaVersion) {
      if (from == 1) await upgradePrioritiesV1ToV2(this);
      if (from <= 2) await upgradePreferencesV2ToV3(this);
      if (from <= 3) await upgradeTasksV3ToV4(this);
      if (from <= 4) await upgradeScheduleV4ToV5(this);
      if (from <= 5) await upgradePlanningV5ToV6(this);
      if (from <= 6) await upgradeTimerV6ToV7(this);
      if (from <= 7) await upgradeRemindersV7ToV8(this);
      if (from <= 8) await upgradeProgressV8ToV9(this);
      await upgradeBackupV9ToV10(this);
      return;
    }
    throw StateError(
      'Database schema $from cannot be opened by schema $to. '
      'Use a compatible app version. The database has been preserved.',
    );
  }

  Future<void> ensureOpen() => customSelect('SELECT 1').get();
  Future<void> _checkRelationships() async {
    final violations = await customSelect('PRAGMA foreign_key_check').get();
    if (violations.isNotEmpty) {
      throw StateError(
        'Stored relationships failed validation. '
        'The database is preserved. Restore a verified copy or seek repair.',
      );
    }
  }
}
