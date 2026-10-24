import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'file_fixture.dart';
import 'probe_database.dart';
import '../app/release_info.dart';
import '../features/reminders/notification_service.dart'
    show dispatchNotificationResponse;

final probeServicesProvider = Provider<ProbeServices>((_) => ProbeServices());

class ProbeServices {
  static const notificationId = 190017;
  static const _platform = MethodChannel('dev.momentum/platform');
  final _notifications = FlutterLocalNotificationsPlugin();
  bool _notificationReady = false;

  Future<File> databaseFile() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'foundation_checks'));
    await directory.create(recursive: true);
    return File(p.join(directory.path, 'probe.sqlite'));
  }

  Future<String> databaseProbe({required bool write}) async {
    final file = await databaseFile();
    if (write) {
      final writer = ProbeDatabase(file);
      try {
        await writer.writeProbe();
      } finally {
        await writer.close();
      }
    }
    final reader = ProbeDatabase(file);
    try {
      final row = await reader.readProbe();
      return row == null
          ? 'No saved probe yet. Choose Write and reopen.\n${file.path}'
          : 'Reopened saved probe: ${row.writes} write(s).\n'
                'Saved UTC: ${row.updatedAt.toUtc().toIso8601String()}\n${file.path}';
    } finally {
      await reader.close();
    }
  }

  Future<String> saveFixture() async {
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Save Momentum foundation fixture',
      fileName: 'momentum-foundation.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: FileFixture.encode(),
    );
    return uri == null
        ? 'Save cancelled. No fixture exported.'
        : 'Fixture save completed. Open the chosen file to verify its contents.\n$uri';
  }

  Future<String> openFixture() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Open Momentum foundation fixture',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return 'Open cancelled. No data changed.';
    final length = await file.length();
    if (length != null && length > FileFixture.maxBytes) {
      throw const FormatException('File exceeds the 64 KiB probe limit.');
    }
    await FileFixture.validateStream(file.readAsByteStream());
    return 'Fixture contents verified. This diagnostic is not a data backup.';
  }

  Future<bool> windowsHasIdentity() async =>
      await _platform.invokeMethod<bool>('hasPackageIdentity') ?? false;

  Future<String> environmentProbe() async {
    if (Platform.isAndroid) {
      return 'Android ${Platform.operatingSystemVersion}\n'
          'No physical-device, delivery or reboot claim follows from this check.';
    }
    final identity = await windowsHasIdentity();
    return 'Windows ${Platform.operatingSystemVersion}\nPackage identity: $identity\n'
        '${identity ? 'Installed identity detected.' : 'Unpackaged executable: notification checks are gated.'}';
  }

  Future<void> _initializeNotifications() async {
    if (_notificationReady) return;
    if (Platform.isWindows && !await windowsHasIdentity()) {
      throw UnsupportedError(
        'Use the installed diagnostic Windows package '
        'for notification schedule/cancel checks.',
      );
    }
    tz_data.initializeTimeZones();
    final initialized = await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_momentum'),
        windows: WindowsInitializationSettings(
          appName: 'Momentum',
          appUserModelId: windowsNotificationAppId,
          guid: windowsNotificationGuid,
        ),
      ),
      onDidReceiveNotificationResponse: dispatchNotificationResponse,
    );
    if (initialized == false) {
      throw StateError('Notifications did not initialize.');
    }
    _notificationReady = true;
  }

  Future<String> scheduleNotification({int delaySeconds = 60}) async {
    await _initializeNotifications();
    if (Platform.isAndroid) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (await android?.requestNotificationsPermission() == false) {
        return 'Notification permission denied. Nothing was scheduled.';
      }
    }
    final due = tz.TZDateTime.now(tz.UTC).add(Duration(seconds: delaySeconds));
    await _notifications.zonedSchedule(
      id: notificationId,
      title: 'Momentum foundation check',
      body: 'Diagnostic notification. No task or timer was completed.',
      scheduledDate: due,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'momentum_foundation',
          'Foundation checks',
          channelDescription: 'Explicit development-only notification checks.',
          importance: Importance.defaultImportance,
        ),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    final pending = await _notifications.pendingNotificationRequests();
    if (!pending.any((request) => request.id == notificationId)) {
      throw StateError(
        'Scheduling returned, but the probe was not registered.',
      );
    }
    return 'Probe registered for ${due.toLocal()}.\n'
        'Delivery has not been observed. Android timing is approximate.';
  }

  Future<String> cancelNotification() async {
    await _initializeNotifications();
    await _notifications.cancel(id: notificationId);
    final pending = await _notifications.pendingNotificationRequests();
    if (pending.any((request) => request.id == notificationId)) {
      throw StateError('The probe is still pending.');
    }
    return 'Probe absent from pending requests after cancellation.\n'
        'Observe beyond its due time; compare with a separate delivery control.';
  }

  Future<String> inspectNotification() async {
    await _initializeNotifications();
    final pending = await _notifications.pendingNotificationRequests();
    final active = await _notifications.getActiveNotifications();
    final registered = pending.any((item) => item.id == notificationId);
    final inHistory = active.any((item) => item.id == notificationId);
    return 'Probe pending: $registered\nOS-active notification: $inHistory\n'
        'Notification history does not establish that a person saw a banner.';
  }
}
