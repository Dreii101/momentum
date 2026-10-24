import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository.dart';
import 'backup_data.dart';

const maxBackupBytes = 50 * 1024 * 1024;
const maxBackupRecords = 200000;

Object? canonicalJson(Object? value) => switch (value) {
  Map map => {
    for (final key in map.keys.cast<String>().toList()..sort())
      key: canonicalJson(map[key]),
  },
  List list => list.map(canonicalJson).toList(),
  _ => value,
};

String payloadDigest(BackupPayload payload) =>
    sha256.convert(utf8.encode(jsonEncode(canonicalJson(payload)))).toString();

class ValidatedBackup {
  ValidatedBackup._(this.exportedAt, this.payload, this.counts, this.digest);
  final DateTime exportedAt;
  final BackupPayload payload;
  final Map<String, int> counts;
  final String digest;
  int get total => counts.values.fold(0, (a, b) => a + b);
  int get unfinished =>
      payload['focus_sessions']!.where((r) => r['state'] != 'finalized').length;
}

class BackupCodec {
  static Future<Uint8List> encode(BackupPayload payload, DateTime exportedAt) =>
      Isolate.run(() {
        final bytes = Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'format': 'momentum-backup',
              'version': 1,
              'schema': currentSchemaVersion,
              'exportedAt': exportedAt.toUtc().toIso8601String(),
              'counts': {
                for (final entry in payload.entries)
                  entry.key: entry.value.length,
              },
              'payloadSha256': payloadDigest(payload),
              'payload': payload,
            }),
          ),
        );
        if (bytes.length > maxBackupBytes ||
            payload.values.fold(0, (n, r) => n + r.length) > maxBackupRecords) {
          throw const FormatException(
            'Backup exceeds the 50 MiB or 200,000-record limit.',
          );
        }
        return bytes;
      });

  static Future<ValidatedBackup> decode(
    Uint8List bytes,
  ) => Isolate.run(() async {
    if (bytes.length > maxBackupBytes) {
      throw const FormatException('Backup exceeds 50 MiB.');
    }
    final root = jsonDecode(utf8.decode(bytes));
    if (root is! Map ||
        root.length != 7 ||
        root['format'] != 'momentum-backup' ||
        root['version'] is! int ||
        root['schema'] is! int ||
        root['version'] != 1 ||
        root['schema'] != currentSchemaVersion) {
      throw const FormatException(
        'Unsupported backup format/schema. Use a compatible Momentum version.',
      );
    }
    if (root['exportedAt'] is! String ||
        !RegExp(r'^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{1,6})?Z$')
            .hasMatch(root['exportedAt'])) {
      throw const FormatException('Backup export time must be a UTC instant.');
    }
    final exportedAt = DateTime.parse(root['exportedAt']);
    if (exportedAt.year < 1 ||
        exportedAt.toIso8601String().substring(0, 19) !=
            (root['exportedAt'] as String).substring(0, 19)) {
      throw const FormatException('Invalid export calendar date or time.');
    }
    if (root['payload'] is! Map || root['counts'] is! Map) {
      throw const FormatException('Missing backup records/counts.');
    }
    final raw = root['payload'] as Map, declared = root['counts'] as Map;
    if (raw.length != backupTables.length ||
        declared.length != backupTables.length) {
      throw const FormatException('Unexpected/missing backup sections.');
    }
    final data = <String, List<Map<String, Object?>>>{};
    var total = 0;
    for (final table in backupTables) {
      final rows = raw[table];
      if (rows is! List ||
          declared[table] is! int ||
          declared[table] != rows.length) {
        throw FormatException('Invalid count/records for $table.');
      }
      total += rows.length;
      if (total > maxBackupRecords) {
        throw const FormatException('Backup exceeds 200,000 records.');
      }
      data[table] = [
        for (final row in rows)
          if (row is Map<String, dynamic>)
            Map<String, Object?>.from(row)
          else
            throw FormatException('Invalid $table record.'),
      ];
    }
    if (data['app_settings']!.length != 1 ||
        data['reminder_preferences_rows']!.length != 1) {
      throw const FormatException(
        'Exactly one portable preferences record is required.',
      );
    }
    final digest = payloadDigest(data);
    if (root['payloadSha256'] != digest) {
      throw const FormatException(
        'Checksum mismatch. The file is damaged or was changed.',
      );
    }
    final db = AppDatabase(NativeDatabase.memory());
    try {
      final repo = MomentumRepository(db);
      await initializeBackupStore(repo);
      for (final table in backupTables) {
        final columns = await db
            .customSelect('PRAGMA table_info("$table")')
            .get();
        final expected = {
          for (final c in columns)
            if (!(excludedColumns[table]?.contains(c.read<String>('name')) ??
                false))
              c.read<String>('name'): c,
        };
        for (final row in data[table]!) {
          if (row.length != expected.length ||
              row.keys.any((k) => !expected.containsKey(k))) {
            throw FormatException('Unexpected/missing fields in $table.');
          }
          for (final field in row.entries) {
            final spec = expected[field.key]!, value = field.value;
            if (value == null && spec.read<int>('notnull') == 0) continue;
            final text = spec.read<String>('type') == 'TEXT';
            if (text ? value is! String : value is! int) {
              throw FormatException('Wrong field type: $table.${field.key}.');
            }
            if (value is String && value.contains('\u0000')) {
              throw const FormatException('Null characters are not supported.');
            }
            // Integer instants must be representable by Dart and the calendar UI.
            if (!text &&
                (field.key.endsWith('_utc') || field.key.endsWith('_at')) &&
                value is int) {
              final time = DateTime.fromMillisecondsSinceEpoch(
                value,
                isUtc: true,
              );
              final exclusiveLastDate =
                  field.key == 'deadline_boundary_utc' &&
                  row['deadline_kind'] == 'dateOnly' &&
                  time.year == 10000;
              if (time.year < 1 || (time.year > 9999 && !exclusiveLastDate)) {
                throw const FormatException('Timestamp out of range.');
              }
            }
          }
        }
      }
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        await writeBackupData(repo, data, normalizeSessions: false);
        if ((await db.customSelect('PRAGMA foreign_key_check').get())
            .isNotEmpty) {
          throw const FormatException('Broken record relationships.');
        }
        await validateBackupSemantics(db);
      });
    } catch (e) {
      throw FormatException('Backup validation failed: $e');
    } finally {
      await db.close();
    }
    return ValidatedBackup._(
      exportedAt,
      Map.unmodifiable({
        for (final entry in data.entries)
          entry.key: List<Map<String, Object?>>.unmodifiable(
            entry.value.map((r) => Map<String, Object?>.unmodifiable(r)),
          ),
      }),
      Map.unmodifiable({for (final e in data.entries) e.key: e.value.length}),
      digest,
    );
  });
}
