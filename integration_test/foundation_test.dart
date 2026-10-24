import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/main.dart' as app;
import 'package:momentum/foundation/probe_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native shell, application-support storage and package detection',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Momentum'), findsOneWidget);
      expect(find.text('Make room for one next step'), findsOneWidget);
      expect(find.text('Your saved workspace could not open'), findsNothing);
      await tester.tap(find.byKey(const Key('open-development')));
      await tester.pumpAndSettle();
      final probes = ProbeServices();
      final written = await probes.databaseProbe(write: true);
      final read = await probes.databaseProbe(write: false);
      expect(read, written);
      expect(read, contains('Reopened saved probe:'));
      const minimumWrites = int.fromEnvironment(
        'MIN_PROBE_WRITES',
        defaultValue: 1,
      );
      final writes = int.parse(
        RegExp(r'probe: (\d+) write').firstMatch(read)!.group(1)!,
      );
      expect(writes, greaterThanOrEqualTo(minimumWrites));
      final environment = await probes.environmentProbe();
      expect(
        environment,
        contains(Platform.isWindows ? 'Package identity: false' : 'Android'),
      );
      // This runner is an unpackaged executable. Installed-MSIX checks are separate.
      if (Platform.isWindows) {
        await expectLater(
          probes.scheduleNotification(),
          throwsUnsupportedError,
        );
      }
      debugPrint('NATIVE_PROBE_EVIDENCE: $read\n$environment');
      expect(tester.takeException(), isNull);
    },
  );
}
