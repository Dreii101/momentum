import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sql;

import 'value_types.dart';

/// Private, same-device SQLite recovery, including the local installation.
/// Portable JSON never includes these device-specific rows.
class RecoverySnapshots {
  RecoverySnapshots(this.directory);
  final Directory directory;

  Future<File> create(File source) => Isolate.run(() {
    final reader = sql.sqlite3.open(source.path, mode: sql.OpenMode.readOnly);
    try {
      return createSync(reader);
    } finally {
      reader.close();
    }
  });

  List<File> listSync() => !directory.existsSync()
      ? []
      : (directory
            .listSync(followLinks: false)
            .whereType<File>()
            .where(
              (f) =>
                  RegExp(r'^recovery-[0-9]+-[0-9a-f]+\.sqlite$')
                      .hasMatch(p.basename(f.path)),
            )
            .toList()
          ..sort(
            (a, b) =>
                int.parse(p.basename(b.path).split('-')[1])
                    .compareTo(int.parse(p.basename(a.path).split('-')[1])),
          ));

  static RecoverySnapshots forDatabase(File file) =>
      RecoverySnapshots(Directory(p.join(file.parent.path, 'recovery')));

  /// Called in the native database isolate, before any schema modification.
  File createSync(sql.Database source) {
    directory.createSync(recursive: true);
    final suffix = newUuid().replaceAll('-', '');
    var serial = DateTime.now().toUtc().microsecondsSinceEpoch;
    final previous = listSync();
    if (previous.isNotEmpty) {
      final last = int.parse(p.basename(previous.first.path).split('-')[1]);
      if (serial <= last) serial = last + 1;
    }
    final name = 'recovery-$serial-$suffix.sqlite';
    final pending = File(p.join(directory.path, '$name.pending'));
    final target = File(p.join(directory.path, name));
    try {
      source.execute('VACUUM INTO ?', [pending.path]);
      final check = sql.sqlite3.open(pending.path, mode: sql.OpenMode.readOnly);
      try {
        if (check.select('PRAGMA quick_check').single.values.single != 'ok') {
          throw StateError(
            'Recovery snapshot verification failed. Original data is preserved.',
          );
        }
      } finally {
        check.close();
      }
      final handle = pending.openSync(mode: FileMode.append);
      try {
        handle.flushSync();
      } finally {
        handle.closeSync();
      }
      pending.renameSync(target.path);
      for (final old in listSync().skip(3)) {
        old.deleteSync();
      }
      return target;
    } catch (_) {
      if (pending.existsSync()) pending.deleteSync();
      rethrow;
    }
  }
}
