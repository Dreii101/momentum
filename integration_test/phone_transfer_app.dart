// Verify an actual phone-saved JSON in a separate Windows workspace.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/recovery_snapshots.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/backup/backup_codec.dart';
import 'package:momentum/features/backup/backup_data.dart';
import 'package:momentum/features/backup/backup_service.dart';
import 'package:momentum/features/progress/progress_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = Directory(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'phase13_phone_return',
    ),
  );
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, 'return.sqlite'));
  final db = AppDatabase.file(file), repo = MomentumRepository(db);
  await initializeBackupStore(repo);
  final identity = (await repo.installation()).id;
  final input = File(const String.fromEnvironment('MOMENTUM_TRANSFER_FILE'));
  final preview = await BackupCodec.decode(await input.readAsBytes());
  final marker = File(p.join(directory.path, 'completed.json'));
  final reopened = await marker.exists();
  if (!reopened) {
    await repo.createNote(
      const NoteDraft(title: 'Replace only this test workspace'),
    );
    await BackupService(
      repo,
      file,
      RecoverySnapshots.forDatabase(file),
      BackupFiles(),
    ).replace(preview);
  }
  final actual = await readBackupData(repo);
  final progress = await repo.progressSnapshot(
    CalendarDate(2026, 10, 19),
    'Asia/Manila',
  );
  if (payloadDigest(actual) != preview.digest ||
      progress.reportedMs != 390000 ||
      (await repo.installation()).id != identity) {
    throw StateError('Physical transfer preservation check failed.');
  }
  await marker.writeAsString(
    jsonEncode({
      'pid': pid,
      'platform': Platform.operatingSystem,
      'reopened': reopened,
      'format': 1,
      'schema': db.schemaVersion,
      'payloadDigest': preview.digest,
      'records': preview.total,
      'reportedMs': progress.reportedMs,
      'portableRowsIdentical': true,
      'receivingIdentityPreserved': true,
      'snapshots': RecoverySnapshots.forDatabase(file).listSync().length,
    }),
    flush: true,
  );
  runApp(
    ProviderScope(
      overrides: [repositoryProvider.overrideWith((ref) => repo)],
      child: const MomentumApp(showDevelopment: false),
    ),
  );
}
