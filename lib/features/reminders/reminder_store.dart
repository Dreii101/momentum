import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/planning_repository.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import 'reminder_types.dart';

class ReminderInputs {
  const ReminderInputs(
    this.planning,
    this.settings,
    this.preferences,
    this.installation,
    this.rules,
    this.sessions,
  );
  final PlanningSnapshot planning;
  final Settings settings;
  final ReminderPreferences preferences;
  final InstallationMetadata installation;
  final List<ReminderRule> rules;
  final List<FocusSession> sessions;
}

String reminderSourceId(ReminderRule r) =>
    r.taskId ?? r.seriesId ?? r.workId ?? r.installationId!;

class ReminderStore {
  ReminderStore(this.repository);
  final MomentumRepository repository;
  AppDatabase get db => repository.database;
  Future<void> initialize() => db
      .into(db.reminderPreferencesRows)
      .insert(
        ReminderPreferencesRowsCompanion.insert(
          id: repository.ids(),
          singleton: 1,
        ),
        mode: InsertMode.insertOrIgnore,
      );
  Future<ReminderInputs> read() => db.transaction(
    () async => ReminderInputs(
      await repository.planningSnapshot(),
      await repository.settings(),
      await db.select(db.reminderPreferencesRows).getSingle(),
      await repository.installation(),
      await db.select(db.reminderRules).get(),
      await db.select(db.focusSessions).get(),
    ),
  );
  Stream<void> get changes => db
      .customSelect(
        'SELECT 1 AS reminders_changed',
        readsFrom: {
          db.tasks,
          db.plannedWorkBlocks,
          db.activitySeriesRows,
          db.activityExceptions,
          db.courses,
          db.appSettings,
          db.focusSessions,
          db.reminderPreferencesRows,
          db.reminderRules,
        },
      )
      .watch()
      .map((_) {});
  Future<List<ReminderRegistration>> registrations() =>
      (db.select(db.reminderRegistrations)..orderBy([
            (r) => OrderingTerm.asc(r.dueUtc),
            (r) => OrderingTerm.asc(r.id),
          ]))
          .get();
  Future<void> preferences({
    required bool enabled,
    required bool quietEnabled,
    required int start,
    required int end,
  }) async {
    if (start < 0 || start > 1439 || end < 0 || end > 1439 || start == end) {
      throw const FormatException(
        'Quiet hours need different valid HH:MM start and end times.',
      );
    }
    await db
        .update(db.reminderPreferencesRows)
        .write(
          ReminderPreferencesRowsCompanion(
            enabled: Value(enabled),
            quietEnabled: Value(quietEnabled),
            quietStart: Value(start),
            quietEnd: Value(end),
          ),
        );
  }

  Future<ReminderRule> setRule(
    ReminderKind kind,
    String sourceId, {
    int leadMinutes = 0,
    bool enabled = true,
  }) => db.transaction(() async {
    if (leadMinutes < 0 ||
        leadMinutes > 10080 ||
        (kind == ReminderKind.timer && leadMinutes != 0)) {
      throw const FormatException(
        'Choose 0–10080 minutes before the source; timer endpoints use zero.',
      );
    }
    final data = await read();
    if (enabled) {
      switch (kind) {
        case ReminderKind.deadline:
          final task = await repository.task(sourceId);
          if (task.deletedAt != null ||
              task.archivedAt != null ||
              task.status == TaskStatus.done ||
              task.deadlineKind == DeadlineKind.none) {
            throw StateError(
              'Choose an unfinished, available task with an official deadline.',
            );
          }
        case ReminderKind.activity:
          final series = data.planning.schedule.series
              .where((s) => s.id == sourceId && s.deletedAt == null)
              .firstOrNull;
          if (series == null) {
            throw StateError(
              'Restore the activity before enabling its reminders.',
            );
          }
        case ReminderKind.work:
          final block = await repository.workBlock(sourceId);
          final task = await repository.task(block.taskId);
          if (block.deletedAt != null ||
              block.status != WorkBlockStatus.planned ||
              task.deletedAt != null ||
              task.archivedAt != null ||
              task.status == TaskStatus.done) {
            throw StateError(
              'Choose planned work for an available unfinished task.',
            );
          }
        case ReminderKind.timer:
          if (sourceId != data.installation.id) {
            throw StateError('Timer reminders belong to this installation.');
          }
      }
    }
    final previous = data.rules
        .where((r) => r.kind == kind && reminderSourceId(r) == sourceId)
        .firstOrNull;
    final id = previous?.id ?? repository.ids();
    await db
        .into(db.reminderRules)
        .insertOnConflictUpdate(
          ReminderRulesCompanion.insert(
            id: id,
            kind: kind,
            taskId: Value(kind == ReminderKind.deadline ? sourceId : null),
            seriesId: Value(kind == ReminderKind.activity ? sourceId : null),
            workId: Value(kind == ReminderKind.work ? sourceId : null),
            installationId: Value(kind == ReminderKind.timer ? sourceId : null),
            leadMinutes: Value(leadMinutes),
            enabled: Value(enabled),
          ),
        );
    return (db.select(
      db.reminderRules,
    )..where((r) => r.id.equals(id))).getSingle();
  });
  Future<ReminderRegistration> prepare(
    ReminderTarget target,
    String fingerprint,
  ) => db.transaction(() async {
    final old = await (db.select(
      db.reminderRegistrations,
    )..where((r) => r.identityKey.equals(target.key))).getSingleOrNull();
    if (old != null && old.fingerprint == fingerprint) return old;
    final maximum = await db
        .customSelect(
          'SELECT MAX(notification_id) AS value FROM reminder_registrations',
        )
        .getSingle();
    final notificationId =
        old?.notificationId ??
        ((maximum.readNullable<int>('value') ?? 999999) + 1);
    if (notificationId > 2147483000) {
      throw StateError(
        'Reminder ID capacity reached. Existing registrations are preserved.',
      );
    }
    final id = old?.id ?? repository.ids();
    await db
        .into(db.reminderRegistrations)
        .insertOnConflictUpdate(
          ReminderRegistrationsCompanion.insert(
            id: id,
            ruleId: target.ruleId,
            identityKey: target.key,
            notificationId: notificationId,
            originalDate: Value(target.originalDate),
            sessionId: Value(target.sessionId),
            sourceUtc: target.sourceUtc,
            dueUtc: target.dueUtc,
            fingerprint: fingerprint,
            state: RegistrationState.pending,
            error: const Value(null),
            registeredAtUtc: const Value(null),
            openedAtUtc: const Value(null),
          ),
        );
    return (db.select(
      db.reminderRegistrations,
    )..where((r) => r.id.equals(id))).getSingle();
  });
  Future<void> state(
    String id,
    RegistrationState state, {
    String? error,
    bool registered = false,
  }) => (db.update(db.reminderRegistrations)..where((r) => r.id.equals(id)))
      .write(
        ReminderRegistrationsCompanion(
          state: Value(state),
          error: Value(error),
          registeredAtUtc: registered
              ? Value(repository.clock().toUtc())
              : const Value.absent(),
        ),
      );
}
