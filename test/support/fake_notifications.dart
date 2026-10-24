import 'dart:async';

import 'package:momentum/features/reminders/notification_service.dart';
import 'package:momentum/features/reminders/reminder_types.dart';

class FakeNotifications implements NotificationService {
  bool allowed = true,
      exact = true,
      supported = true,
      failSchedule = false,
      failCancel = false,
      revokeExactOnSchedule = false;
  int schedules = 0,
      cancellations = 0,
      permissions = 0,
      capabilityReads = 0,
      tests = 0;
  final items = <int, ReminderTarget>{};
  final payloads = <int, String>{};
  final exactModes = <bool>[];
  final callbacks = StreamController<String>.broadcast();
  @override
  Stream<String> get responses => callbacks.stream;
  @override
  Future<NotificationCapability> capability() async {
    capabilityReads++;
    return NotificationCapability(
      supported: supported,
      allowed: allowed,
      exact: exact,
      message: !supported
          ? 'Package required'
          : allowed
          ? (exact ? 'Exact access' : 'Approximate timing')
          : 'Permission denied',
    );
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<String?> launchPayload() async => null;
  @override
  Future<void> requestPermission() async {
    permissions++;
  }

  @override
  Future<void> requestExactAccess() async {
    exact = true;
  }

  @override
  Future<void> openSettings() async {}
  @override
  Future<Set<int>> pending() async => items.keys.toSet();
  @override
  Future<void> schedule(
    int id,
    ReminderTarget target,
    String payload, {
    required bool exact,
  }) async {
    exactModes.add(exact);
    if (revokeExactOnSchedule && exact) {
      this.exact = false;
      revokeExactOnSchedule = false;
      throw StateError('Exact access revoked');
    }
    if (failSchedule) throw StateError('Injected scheduling failure');
    schedules++;
    items[id] = target;
    payloads[id] = payload;
  }

  @override
  Future<void> cancel(int id) async {
    if (failCancel) throw StateError('Injected cancellation failure');
    cancellations++;
    items.remove(id);
    payloads.remove(id);
  }

  @override
  Future<void> test() async {
    tests++;
  }
}
