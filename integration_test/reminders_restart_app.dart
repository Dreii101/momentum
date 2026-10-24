// Explicit native acceptance entry; ordinary builds never import this fixture.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/focus/timer_providers.dart';
import 'package:momentum/features/reminders/notification_service.dart';
import 'package:momentum/features/reminders/reminder_coordinator.dart';
import 'package:momentum/features/reminders/reminder_providers.dart';
import 'package:momentum/features/reminders/reminder_store.dart';
import 'package:momentum/features/reminders/reminder_types.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final folder = Directory(p.join(support.path, 'phase10_reminder_checks'));
  await folder.create(recursive: true);
  final db = AppDatabase.file(File(p.join(folder.path, 'reminders.sqlite')));
  final repo = MomentumRepository(db);
  await repo.initialize();
  final service = NativeNotificationService(
    windows: const WindowsInitializationSettings(
      appName: 'Momentum Reminder Checks',
      appUserModelId: 'dev.momentum.reminderchecks',
      guid: '82571343-45ab-482d-bd42-e46f366ce234',
    ),
  );
  final clock = SystemTimerClock(wallClock: DateTime.now, epoch: 'native-$pid');
  final store = ReminderStore(repo);
  await store.initialize();
  final report = <String, Object?>{
    'pid': pid,
    'platform': Platform.operatingSystem,
    'schema': db.schemaVersion,
    'at': DateTime.now().toUtc().toIso8601String(),
  };
  Future<void> save(String name) => File(p.join(folder.path, '$name.json'))
      .writeAsString(
        const JsonEncoder.withIndent('  ').convert(report),
        flush: true,
      );
  final cap = await service.capability();
  report['capability'] = {
    'supported': cap.supported,
    'allowed': cap.allowed,
    'exact': cap.exact,
    'message': cap.message,
  };
  if (cap.supported) {
    report['pendingBefore'] = (await service.pending()).toList();
    report['activeBefore'] = (await service.plugin.getActiveNotifications())
        .map((n) => n.id)
        .toList();
  }
  ProviderContainer? container;
  final owner = ReminderCoordinator(
    store,
    service,
    clock,
    onResponse: (payload) async {
      final route = await resolveReminder(store, payload);
      report['callback'] = {'payload': payload, 'route': route?.record};
      await save('callback-$pid');
      if (route != null) {
        container
            ?.read(shellNavigationProvider.notifier)
            .selectRecord(route.destination, route.record);
      }
    },
  );
  container = ProviderContainer(
    overrides: [
      repositoryProvider.overrideWith((ref) => repo),
      notificationServiceProvider.overrideWithValue(service),
      timerClockProvider.overrideWithValue(clock),
      reminderCoordinatorProvider.overrideWith((ref) => owner),
      shellNavigationProvider.overrideWith(() => FixtureNavigation()),
    ],
  );
  await owner.initialize();
  final marker = File(p.join(folder.path, 'control.json'));
  if (cap.allowed && cap.supported && !await marker.exists()) {
    final now = DateTime.now().toUtc();
    final delay = Platform.isAndroid ? 90 : 30;
    final a = await repo.createTask(
      TaskDraft(
        title: 'Phase 10 delivery control',
        deadline: Deadline.timed(now.add(Duration(seconds: delay)), 'UTC'),
      ),
    );
    final b = await repo.createTask(
      TaskDraft(
        title: 'Phase 10 cancellation control',
        deadline: Deadline.timed(now.add(Duration(seconds: delay + 10)), 'UTC'),
      ),
    );
    await store.preferences(
      enabled: true,
      quietEnabled: false,
      start: 1320,
      end: 420,
    );
    await store.setRule(ReminderKind.deadline, a.id);
    await store.setRule(ReminderKind.deadline, b.id);
    await owner.reconcile();
    final before = await store.registrations();
    await owner.reconcile();
    await store.setRule(ReminderKind.deadline, b.id, enabled: false);
    await owner.reconcile();
    final rows = await store.registrations();
    final ruleA = (await store.read()).rules.singleWhere(
      (r) => r.taskId == a.id,
    );
    final delivery = rows.singleWhere((r) => r.ruleId == ruleA.id);
    report['duplicateStableIds'] = before
        .map((r) => r.notificationId)
        .toSet()
        .containsAll(rows.map((r) => r.notificationId));
    report['deliveryTask'] = a.id;
    report['cancelTask'] = b.id;
    report['registrations'] = rows
        .map(
          (r) => {
            'id': r.id,
            'notificationId': r.notificationId,
            'state': r.state.name,
            'due': r.dueUtc.toIso8601String(),
            'opened': r.openedAtUtc?.toIso8601String(),
          },
        )
        .toList();
    report['pendingAfterCancel'] = (await service.pending()).toList();
    report['note'] =
        'OS active observations are separate from pending registrations.';
    await save('control');
    unawaited(() async {
      for (var i = 0; i < 48; i++) {
        await Future<void>.delayed(const Duration(seconds: 5));
        report['observedAt'] = DateTime.now().toUtc().toIso8601String();
        report['activeObserved'] =
            (await service.plugin.getActiveNotifications())
                .map((n) => n.id)
                .toList();
        report['pendingObserved'] = (await service.pending()).toList();
        await save('observation-$pid');
      }
    }());
    report['deliveryRegistration'] = delivery.id;
  }
  await save('startup-$pid');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MomentumApp(showDevelopment: false),
    ),
  );
}

class FixtureNavigation extends ShellNavigation {
  @override
  ShellRoute build() => const ShellRoute(
    destination: Destination.settings,
    selectedRecords: {Destination.settings: 'reminders'},
  );
}
