// Run explicitly on the isolated emulator with notification access granted.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/main.dart' as app;
import 'package:momentum/foundation/probe_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native scheduling, cancellation and delivery control', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    final probes = ProbeServices();
    expect(
      Platform.isAndroid,
      isTrue,
      reason: 'Installed Windows has a separate check.',
    );
    final registered = await probes.scheduleNotification(delaySeconds: 10);
    expect(registered, contains('registered'));
    expect(await probes.cancelNotification(), contains('absent from pending'));
    await Future<void>.delayed(const Duration(seconds: 20));
    final notifications = FlutterLocalNotificationsPlugin();
    expect(
      (await notifications.getActiveNotifications()).where(
        (item) => item.id == ProbeServices.notificationId,
      ),
      isEmpty,
    );
    debugPrint(
      'CANCELLATION_OBSERVATION: no active probe 20 seconds after cancellation.',
    );
    expect(
      await probes.scheduleNotification(delaySeconds: 10),
      contains('registered'),
    );
    var delivered = false;
    for (var attempt = 0; attempt < 24; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      delivered = (await notifications.getActiveNotifications()).any(
        (item) => item.id == ProbeServices.notificationId,
      );
      if (delivered) break;
    }
    expect(
      delivered,
      isTrue,
      reason: 'An OS-active delivery control must be observed; registration alone is insufficient.',
    );
    debugPrint(
      'DELIVERY_CONTROL: Android NotificationManager reports the scheduled probe active.',
    );
    await probes.cancelNotification();
  }, timeout: const Timeout(Duration(minutes: 4)));
}
