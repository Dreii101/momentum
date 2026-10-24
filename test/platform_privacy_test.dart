import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android opts out of automatic backup and device transfer', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="false"'));
    expect(manifest, contains('@xml/data_extraction_rules'));
    expect(manifest, isNot(contains('android.permission.INTERNET')));
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();
    for (final kind in ['cloud-backup', 'device-transfer']) {
      final section = rules.split('<$kind>').last.split('</$kind>').first;
      for (final domain in [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
        'device_root',
        'device_file',
        'device_database',
        'device_sharedpref',
      ]) {
        expect(section, contains('<exclude domain="$domain" path="." />'));
      }
    }
  });
  test('product code has no content logging or network client imports', () {
    final unsafe = RegExp(
      r'\b(debugPrint|print)\s*\(|package:(http|dio)/|dart:(developer|html)',
    );
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'),
            )) {
      expect(
        unsafe.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains("capabilities: ''"),
    );
  });
}
