// Explicit native dialog acceptance. The operator chooses isolated fixture files only.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/features/backup/backup_providers.dart';
import 'package:momentum/features/backup/backup_codec.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:path/path.dart' as p;

import '../test/support/progress_fixture.dart';
import 'backup_restart_app.dart' as acceptance;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.semanticsEnabledTestValue = true;
  tearDownAll(binding.platformDispatcher.clearSemanticsEnabledTestValue);
  testWidgets(
    'native backup pick/validate, replacement, export and both cancellations',
    (tester) async {
      final directory = await acceptance.launchBackupFixture();
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repo = await container.read(repositoryProvider.future),
          identity = (await repo.installation()).id;
      final controller = container.read(backupControllerProvider.notifier);
      debugPrint(
        'BACKUP_DIALOG_1: Open ${p.join(directory.path, 'source-backup.json')}',
      );
      await controller.inspect();
      await tester.pumpAndSettle();
      expect(container.read(backupControllerProvider).error, isNull);
      expect(container.read(backupControllerProvider).preview, isNotNull);
      expect(find.text('Validated backup preview'), findsOneWidget);
      // The command test replaces only this explicitly isolated fixture.
      await controller.replace(confirmed: true);
      await tester.pumpAndSettle();
      expect(container.read(backupControllerProvider).error, isNull);
      expect((await repo.installation()).id, identity);
      expect(
        (await repo.progressSnapshot(fixtureWeek, 'Asia/Manila')).reportedMs,
        390000,
      );
      debugPrint(
        'BACKUP_DIALOG_2: Save a new isolated JSON file in the verification folder.',
      );
      await controller.export();
      await tester.pumpAndSettle();
      expect(container.read(backupControllerProvider).error, isNull);
      expect(
        container.read(backupControllerProvider).message,
        startsWith('Backup file saved successfully.'),
      );
      debugPrint('BACKUP_DIALOG_3: Cancel Open.');
      await controller.inspect();
      await tester.pumpAndSettle();
      expect(
        container.read(backupControllerProvider).message,
        startsWith('Selection cancelled.'),
      );
      debugPrint('BACKUP_DIALOG_4: Cancel Save.');
      await controller.export();
      await tester.pumpAndSettle();
      expect(
        container.read(backupControllerProvider).message,
        startsWith('Export cancelled.'),
      );
      final service = await container.read(backupServiceProvider.future);
      final decoded = await BackupCodec.decode(await service.exportBytes());
      await File(p.join(directory.path, 'dialog-result.json')).writeAsString(
        jsonEncode({
          'pid': pid,
          'platform': Platform.operatingSystem,
          'installationRetained': (await repo.installation()).id == identity,
          'records': decoded.total,
          'reportedMs': (await repo.progressSnapshot(
            fixtureWeek,
            'Asia/Manila',
          )).reportedMs,
          'snapshots': service.snapshots.listSync().length,
          'nativeOpen': true,
          'nativeSave': true,
          'cancelOpen': true,
          'cancelSave': true,
        }),
        flush: true,
      );
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
