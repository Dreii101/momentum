import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../core/database/app_database.dart';
import '../../core/database/recovery_snapshots.dart';
import '../../core/database/repository.dart';
import 'backup_codec.dart';
import 'backup_data.dart';

class BackupInput {
  const BackupInput(this.name, this.bytes, {this.length});
  final String name;
  final int? length;
  final Stream<List<int>> bytes;
}

class BackupFiles {
  Future<BackupInput?> pick() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Validate a Momentum backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    return BackupInput(
      file.name,
      file.readAsByteStream(),
      length: await file.length(),
    );
  }

  Future<Uri?> save(Uint8List bytes, String name) => FilePicker.saveFile(
    dialogTitle: 'Export an unencrypted Momentum backup',
    fileName: name,
    type: FileType.custom,
    allowedExtensions: ['json'],
    bytes: bytes,
    mimeType: 'application/json',
  );
}

Future<Uint8List> boundedBackupRead(BackupInput input) async {
  if (input.length != null && input.length! > maxBackupBytes) {
    throw const FormatException('Backup exceeds 50 MiB.');
  }
  final buffer = BytesBuilder(copy: false);
  await for (final chunk in input.bytes) {
    if (buffer.length + chunk.length > maxBackupBytes) {
      throw const FormatException('Backup exceeds 50 MiB.');
    }
    buffer.add(chunk);
  }
  return buffer.takeBytes();
}

class BackupService {
  BackupService(this.repository, this.databaseFile, this.snapshots, this.files);
  final MomentumRepository repository;
  final File databaseFile;
  final RecoverySnapshots snapshots;
  final BackupFiles files;

  Future<Uint8List> exportBytes({DateTime? exportedAt}) async {
    await initializeBackupStore(repository);
    final bytes = await BackupCodec.encode(
      await readBackupData(repository),
      exportedAt ?? repository.clock(),
    );
    // Exports must pass the same checks before being described as restorable.
    await BackupCodec.decode(bytes);
    return bytes;
  }

  Future<Uri?> export() async => files.save(
    await exportBytes(),
    'momentum-${repository.clock().toUtc().toIso8601String().replaceAll(':', '-')}.json',
  );

  Future<ValidatedBackup?> inspect() async {
    final selected = await files.pick();
    return selected == null
        ? null
        : BackupCodec.decode(await boundedBackupRead(selected));
  }

  Future<ValidatedBackup> inspectRecovery(File selected) async {
    if (!snapshots.listSync().any(
      (f) => f.absolute.path == selected.absolute.path,
    )) {
      throw const FormatException('Unknown local recovery snapshot.');
    }
    final temporary = await Directory.systemTemp.createTemp(
      'momentum-recovery-',
    );
    AppDatabase? db;
    try {
      final copy = await selected.copy(
        p.join(temporary.path, 'recovery.sqlite'),
      );
      db = AppDatabase.file(copy);
      final service = BackupService(
        MomentumRepository(db),
        copy,
        RecoverySnapshots.forDatabase(copy),
        files,
      );
      return await BackupCodec.decode(
        await service.exportBytes(
          exportedAt: (await selected.lastModified()).toUtc(),
        ),
      );
    } finally {
      await db?.close();
      final root = await Directory.systemTemp.resolveSymbolicLinks(),
          path = await temporary.resolveSymbolicLinks();
      if (!p.isWithin(root, path) ||
          !p.basename(path).startsWith('momentum-recovery-')) {
        throw StateError('Unexpected temporary recovery directory.');
      }
      await temporary.delete(recursive: true);
    }
  }

  Future<File> replace(ValidatedBackup backup) async {
    // Check before the snapshot and again in the committing transaction.
    Future<void> requireResolvedSession() async {
      final unfinished = await repository.database
          .customSelect(
            "SELECT id FROM focus_sessions WHERE state != 'finalized' LIMIT 1",
          )
          .get();
      if (unfinished.isNotEmpty) {
        throw StateError(
          'Review and finalize the current session before replacing data.',
        );
      }
    }

    await requireResolvedSession();
    final db = repository.database;
    return db.transaction(() async {
      // Reserve the writer before snapshotting; no identity value changes.
      await db.customStatement(
        'UPDATE installations SET created_at=created_at WHERE singleton=1',
      );
      await requireResolvedSession();
      final snapshot = await snapshots.create(databaseFile);
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      // Keep cancellation intent through crashes and OS failures after commit.
      await db.customStatement(
        'INSERT OR IGNORE INTO notification_cleanup_rows(notification_id) SELECT notification_id FROM reminder_registrations',
      );
      await db.delete(db.reminderRegistrations).go();
      await db.delete(db.timerCommandReceipts).go();
      for (final name in backupTables.reversed) {
        if (name == 'app_settings' || name == 'reminder_preferences_rows') {
          continue;
        }
        await db.customStatement('DELETE FROM "$name"');
      }
      await writeBackupData(
        repository,
        backup.payload,
        normalizeSessions: true,
      );
      if ((await db.customSelect('PRAGMA foreign_key_check').get())
          .isNotEmpty) {
        throw const FormatException('Broken restored relationships.');
      }
      db.markTablesUpdated(db.allTables.toSet());
      return snapshot;
    });
  }
}
