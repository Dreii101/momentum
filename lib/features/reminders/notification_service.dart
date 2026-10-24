import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_types.dart';
import '../../app/release_info.dart';

// Platform diagnostics and product notifications must share the plugin callback.
final _responses = StreamController<String>.broadcast();
void dispatchNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null && payload.startsWith('momentum:')) {
    _responses.add(payload);
  }
}

abstract class NotificationService {
  Future<NotificationCapability> capability();
  Future<void> initialize();
  Future<void> requestPermission();
  Future<void> requestExactAccess();
  Future<void> openSettings();
  Stream<String> get responses;
  Future<String?> launchPayload();
  Future<Set<int>> pending();
  Future<void> schedule(
    int id,
    ReminderTarget target,
    String payload, {
    required bool exact,
  });
  Future<void> cancel(int id);
  Future<void> test();
}

class NativeNotificationService implements NotificationService {
  NativeNotificationService({
    this.windows = const WindowsInitializationSettings(
      appName: 'Momentum',
      appUserModelId: windowsNotificationAppId,
      guid: windowsNotificationGuid,
    ),
  });
  final WindowsInitializationSettings windows;
  final plugin = FlutterLocalNotificationsPlugin();
  static const testId = 190018;
  static const channel = MethodChannel('dev.momentum/platform');
  bool ready = false;
  AndroidFlutterLocalNotificationsPlugin? get android => plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  Future<bool> get packaged async =>
      await channel.invokeMethod<bool>('hasPackageIdentity') ?? false;
  @override
  Stream<String> get responses => _responses.stream;
  @override
  Future<void> initialize() async {
    if (ready) return;
    if (Platform.isWindows && !await packaged) {
      throw UnsupportedError(
        'Install the Windows package to manage reminders. Your records are saved.',
      );
    }
    tz_data.initializeTimeZones();
    final success = await plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('ic_stat_momentum'),
        windows: windows,
      ),
      onDidReceiveNotificationResponse: dispatchNotificationResponse,
    );
    if (success == false) {
      throw StateError(
        'Notification initialization failed. Retry from Reminders.',
      );
    }
    ready = true;
  }

  @override
  Future<NotificationCapability> capability() async {
    if (Platform.isWindows && !await packaged) {
      return const NotificationCapability(
        supported: false,
        allowed: false,
        exact: false,
        message: 'This Windows executable has no installed package identity. Reminders need the installed package; core features still work.',
      );
    }
    await initialize();
    if (Platform.isAndroid) {
      final allowed = await android!.areNotificationsEnabled() == true;
      final exact = await android!.canScheduleExactNotifications() == true;
      return NotificationCapability(
        supported: true,
        allowed: allowed,
        exact: exact,
        message:
            '${allowed ? 'Notification access granted.' : 'Notification access denied or revoked. Enable it in Android settings.'} ${exact ? 'Exact-alarm access granted.' : 'Exact-alarm access unavailable: reminders use approximate timing.'} Do Not Disturb and channel settings still apply.',
      );
    }
    final setting = await channel.invokeMethod<int>('notificationSetting');
    return NotificationCapability(
      supported: true,
      allowed: setting == 0,
      exact: false,
      message: setting == 0
          ? 'Windows allows notifications. Do Not Disturb still applies; off-time can delay or drop alerts.'
          : 'Windows notification access is blocked or unknown (setting $setting). Check app, user and administrator settings.',
    );
  }

  @override
  Future<void> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) await android!.requestNotificationsPermission();
  }

  @override
  Future<void> requestExactAccess() async {
    await initialize();
    if (Platform.isAndroid) await android!.requestExactAlarmsPermission();
  }

  @override
  Future<void> openSettings() async {
    if (await channel.invokeMethod<bool>('openNotificationSettings') != true) {
      throw StateError(
        'Device notification settings could not open. Open them manually and retry status.',
      );
    }
  }

  @override
  Future<String?> launchPayload() async {
    await initialize();
    final details = await plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true
        ? details?.notificationResponse?.payload
        : null;
  }

  @override
  Future<Set<int>> pending() async {
    await initialize();
    return (await plugin.pendingNotificationRequests())
        .map((n) => n.id)
        .toSet();
  }

  NotificationDetails get details => const NotificationDetails(
    android: AndroidNotificationDetails(
      'momentum_reminders',
      'Momentum reminders',
      channelDescription: 'Reminders you deliberately enable.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    windows: WindowsNotificationDetails(),
  );
  @override
  Future<void> schedule(
    int id,
    ReminderTarget target,
    String payload, {
    required bool exact,
  }) async {
    await initialize();
    await plugin.zonedSchedule(
      id: id,
      title: target.title,
      body: target.body,
      scheduledDate: tz.TZDateTime.from(target.dueUtc, tz.UTC),
      notificationDetails: details,
      payload: payload,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await plugin.cancel(id: id);
  }

  @override
  Future<void> test() async {
    await initialize();
    await plugin.show(
      id: testId,
      title: 'Momentum reminder test',
      body: 'A test only. Nothing was completed or credited.',
      notificationDetails: details,
    );
  }
}
