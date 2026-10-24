import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../focus/timer_engine.dart';
import '../focus/timer_providers.dart';
import 'notification_service.dart';
import 'reminder_coordinator.dart';
import 'reminder_store.dart';
import 'reminder_types.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NativeNotificationService(),
);
final reminderNoticeProvider = NotifierProvider<ReminderNotice, String?>(
  ReminderNotice.new,
);

class ReminderNotice extends Notifier<String?> {
  @override
  String? build() => null;
  void show(String? message) => state = message;
}

class ReminderRoute {
  const ReminderRoute(this.destination, this.record);
  final Destination destination;
  final String record;
}

/// Notification payloads are untrusted references, never commands or saved content.
Future<ReminderRoute?> resolveReminder(
  ReminderStore store,
  String payload,
) async {
  if (!RegExp(r'^momentum:[0-9a-f-]{36}$').hasMatch(payload)) return null;
  final row = await (store.db.select(
    store.db.reminderRegistrations,
  )..where((r) => r.id.equals(payload.substring(9)))).getSingleOrNull();
  if (row == null) return null;
  final data = await store.read();
  final rule = data.rules
      .where((r) => r.id == row.ruleId && r.enabled)
      .firstOrNull;
  if (!data.preferences.enabled || rule == null) return null;
  bool taskAvailable(String? id) => data.planning.tasks.any(
    (t) =>
        t.id == id &&
        t.deletedAt == null &&
        t.archivedAt == null &&
        t.status != TaskStatus.done,
  );
  ReminderRoute? route;
  switch (rule.kind) {
    case ReminderKind.deadline:
      if (taskAvailable(rule.taskId) &&
          data.planning.tasks.any(
            (t) => t.id == rule.taskId && t.deadlineKind != DeadlineKind.none,
          )) {
        route = ReminderRoute(Destination.tasks, rule.taskId!);
      }
    case ReminderKind.work:
      final block = data.planning.blocks
          .where(
            (b) =>
                b.id == rule.workId &&
                b.deletedAt == null &&
                b.status == WorkBlockStatus.planned &&
                taskAvailable(b.taskId),
          )
          .firstOrNull;
      if (block != null) {
        route = ReminderRoute(Destination.plan, 'work/${block.id}');
      }
    case ReminderKind.activity:
      if (row.originalDate != null &&
          data.planning.schedule.series.any(
            (s) => s.id == rule.seriesId && s.deletedAt == null,
          )) {
        final occurrence = data.planning.schedule.occurrence(
          rule.seriesId!,
          CalendarDate.parse(row.originalDate!),
        );
        if (!occurrence.cancelled && !occurrence.superseded) {
          route = ReminderRoute(
            Destination.plan,
            'occurrence/${rule.seriesId}/${row.originalDate}',
          );
        }
      }
    case ReminderKind.timer:
      final session = data.sessions
          .where((s) => s.id == row.sessionId)
          .firstOrNull;
      if (session != null &&
          session.state != SessionState.finalized &&
          session.state != SessionState.paused &&
          session.outcome != SessionOutcome.stoppedEarly) {
        route = ReminderRoute(Destination.today, 'session/${session.id}');
      }
  }
  if (route != null) {
    await (store.db.update(
      store.db.reminderRegistrations,
    )..where((r) => r.id.equals(row.id))).write(
      ReminderRegistrationsCompanion(
        openedAtUtc: Value(store.repository.clock().toUtc()),
      ),
    );
  }
  return route;
}

final reminderCoordinatorProvider = FutureProvider<ReminderCoordinator>((
  ref,
) async {
  final repository = await ref.watch(repositoryProvider.future);
  await ref.watch(timerCoordinatorProvider.future);
  if (!ref.mounted) throw StateError('Reminder opening was cancelled.');
  final store = ReminderStore(repository);
  final coordinator = ReminderCoordinator(
    store,
    ref.watch(notificationServiceProvider),
    ref.watch(timerClockProvider),
    onResponse: (payload) async {
      final route = await resolveReminder(store, payload);
      if (!ref.mounted) return;
      if (route == null) {
        ref
            .read(reminderNoticeProvider.notifier)
            .show(
              'This reminder no longer matches an active record. Open Reminders in Settings to review its status.',
            );
      } else {
        ref
            .read(shellNavigationProvider.notifier)
            .selectRecord(route.destination, route.record);
      }
    },
  );
  ref.onDispose(coordinator.dispose);
  await coordinator.initialize();
  return coordinator;
}, retry: (count, error) => null);

final reminderViewProvider = StreamProvider<ReminderView>(
  (ref) => ref
      .watch(reminderCoordinatorProvider)
      .when(
        data: (owner) async* {
          yield owner.view;
          yield* owner.changes;
        },
        error: (e, s) => Stream.error(e, s),
        loading: () => const Stream.empty(),
      ),
  retry: (count, error) => null,
);
