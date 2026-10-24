import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/database_fixture.dart';
import 'support/schema_fixture.dart';

/// Injects a failure into the real migration transaction boundary.
/// The destructive test statements never execute in the production migration.
class InterruptedMigrationDatabase extends AppDatabase {
  InterruptedMigrationDatabase(File file)
    : super(NativeDatabase.createInBackground(file));
  @override
  int get schemaVersion => 10;
  @override
  Future<void> migrateSchema(Migrator m, int from, int to) async {
    await super.migrateSchema(m, from, to);
    await customStatement('ALTER TABLE notes ADD COLUMN migration_test TEXT');
    await customStatement("UPDATE notes SET body = 'Must roll back'");
    throw StateError('Injected migration failure');
  }
}

void main() {
  late DatabaseFixture fixture;
  setUp(() async {
    fixture = await DatabaseFixture.create();
  });
  tearDown(() => fixture.dispose());

  test(
    'populated v2 upgrades preferences while retaining domain data and IDs',
    () async {
      createSchemaFixture(fixture.file, version: 2);
      seedSchemaV1(fixture.file);
      final before = readAllFixtureData(fixture.file);
      final db = fixture.open();
      await db.ensureOpen();
      final settings = await MomentumRepository(db).settings();
      expect(settings.id, fixtureSettingsId);
      expect(settings.theme, ThemePreference.dark);
      expect(settings.planningZone, 'Asia/Manila');
      expect(settings.focusMinutes, 25);
      expect(settings.breakMinutes, 5);
      expect(settings.reducedMotion, isFalse);
      await db.close();
      for (final row in before['app_settings']!) {
        row.addAll({
          'focus_minutes': 25,
          'break_minutes': 5,
          'reduced_motion': 0,
        });
      }
      for (final row in before['tasks']!) {
        row['archived_at'] = null;
      }
      expect(readAllFixtureData(fixture.file), before);
      final expected = File.fromUri(
        fixture.directory.uri.resolve('expected-v10.sqlite'),
      );
      createSchemaFixture(expected, version: 10);
      expect(readSchema(fixture.file), readSchema(expected));
    },
  );

  test('fresh production schema exactly matches frozen v10 tables, checks and indexes', () async {
    createSchemaFixture(fixture.file, version: 10);
    final expected = readSchema(fixture.file);
    final freshFile = File('${fixture.directory.path}/fresh.sqlite');
    final fresh = AppDatabase.file(freshFile);
    try {
      await fresh.ensureOpen();
    } finally {
      await fresh.close();
    }
    expect(readSchema(freshFile), expected);
    expect(expected.where((r) => r['type'] == 'table'), hasLength(20));
    expect(expected.where((r) => r['type'] == 'index'), hasLength(23));
  });

  test('real v1 to v10 migration preserves every record and matches frozen v10 schema', () async {
    createSchemaFixture(fixture.file);
    seedSchemaV1(fixture.file);
    final before = readAllFixtureData(fixture.file);
    final db = fixture.open();
    final repository = MomentumRepository(db);
    await repository.initialize();
    expect(
      (await repository.task(fixtureTaskId)).deadlineDate,
      CalendarDate(2026, 11, 1),
    );
    expect(
      (await repository.task(fixtureTaskId)).deadlineBoundaryUtc,
      DateTime.utc(2026, 11, 2, 5),
    );
    expect(
      (await repository.note(fixtureNoteId)).body,
      'Original café\n日本語 🧬',
    );
    expect((await repository.course(fixtureCourseId)).archivedAt, isNotNull);
    expect(
      (await repository.watchLinksForTask(fixtureTaskId).first).single.noteId,
      fixtureNoteId,
    );
    expect((await repository.installation()).id, fixtureInstallationId);
    await db.close();
    for (final row in before['app_settings']!) {
      row.addAll({
        'focus_minutes': 25,
        'break_minutes': 5,
        'reduced_motion': 0,
      });
    }
    for (final row in before['tasks']!) {
      row['archived_at'] = null;
    }
    expect(readAllFixtureData(fixture.file), before);
    final expectedFile = File('${fixture.directory.path}/expected-v10.sqlite');
    createSchemaFixture(expectedFile, version: 10);
    expect(readSchema(fixture.file), readSchema(expectedFile));
    final again = fixture.open();
    await again.ensureOpen();
    await again.close();
    expect(readAllFixtureData(fixture.file), before);
  });

  test('populated v3 gains only task archive state and retains all saved preferences', () async {
    createSchemaFixture(fixture.file, version: 3);
    seedSchemaV1(fixture.file);
    final raw = sql.sqlite3.open(fixture.file.path);
    raw.execute(
      'UPDATE app_settings SET focus_minutes = 41, break_minutes = 9, reduced_motion = 1',
    );
    raw.close();
    final before = readAllFixtureData(fixture.file);
    final db = fixture.open();
    await db.ensureOpen();
    await db.close();
    for (final row in before['tasks']!) {
      row['archived_at'] = null;
    }
    expect(readAllFixtureData(fixture.file), before);
    final expected = File.fromUri(
      fixture.directory.uri.resolve('expected-v10.sqlite'),
    );
    createSchemaFixture(expected, version: 10);
    expect(readSchema(fixture.file), readSchema(expected));
  });

  test(
    'future version refusal preserves populated data and schema version',
    () async {
      createSchemaFixture(fixture.file);
      seedSchemaV1(fixture.file);
      final before = readAllFixtureData(fixture.file);
      final raw = sql.sqlite3.open(fixture.file.path);
      raw.execute('PRAGMA user_version = 99');
      raw.close();
      final db = fixture.open();
      await expectLater(
        db.ensureOpen(),
        throwsA(
          predicate<Object>(
            (e) => e.toString().contains('schema 99 cannot be opened'),
          ),
        ),
      );
      await db.close();
      expect(readAllFixtureData(fixture.file), before);
      final after = sql.sqlite3.open(fixture.file.path);
      try {
        expect(after.select('PRAGMA user_version').single.values.single, 99);
      } finally {
        after.close();
      }
    },
  );

  test('failed migration rolls back DDL, DML and version, then real upgrade succeeds', () async {
    createSchemaFixture(fixture.file);
    seedSchemaV1(fixture.file);
    final before = readAllFixtureData(fixture.file);
    final schema = readSchema(fixture.file);
    final broken = InterruptedMigrationDatabase(fixture.file);
    try {
      await expectLater(
        broken.ensureOpen(),
        throwsA(
          predicate<Object>(
            (e) => e.toString().contains('Injected migration failure'),
          ),
        ),
      );
    } finally {
      await broken.close();
    }
    expect(readAllFixtureData(fixture.file), before);
    expect(readSchema(fixture.file), schema);
    final raw = sql.sqlite3.open(fixture.file.path);
    try {
      expect(raw.select('PRAGMA user_version').single.values.single, 1);
    } finally {
      raw.close();
    }
    await fixture.open().ensureOpen();
  });

  test(
    'v1 fractional slot refuses migration without losing original data',
    () async {
      createSchemaFixture(fixture.file);
      seedSchemaV1(fixture.file);
      final raw = sql.sqlite3.open(fixture.file.path);
      raw.execute('UPDATE daily_priorities SET slot = 1.5');
      raw.close();
      final before = readAllFixtureData(fixture.file);
      final schema = readSchema(fixture.file);
      final db = fixture.open();
      await expectLater(db.ensureOpen(), throwsException);
      await db.close();
      expect(readAllFixtureData(fixture.file), before);
      expect(readSchema(fixture.file), schema);
      final after = sql.sqlite3.open(fixture.file.path);
      try {
        expect(after.select('PRAGMA user_version').single.values.single, 1);
        expect(
          after.select('SELECT slot FROM daily_priorities').single['slot'],
          1.5,
        );
      } finally {
        after.close();
      }
    },
  );

  test(
    'malformed relationships cause open failure without discarding data',
    () async {
      createSchemaFixture(fixture.file);
      seedSchemaV1(fixture.file);
      final raw = sql.sqlite3.open(fixture.file.path);
      raw.execute('PRAGMA foreign_keys = OFF');
      raw.execute(
        "UPDATE tasks SET course_id = '00000000-0000-4000-8000-000000000099'",
      );
      raw.close();
      final before = readAllFixtureData(fixture.file);
      final db = fixture.open();
      await expectLater(
        db.ensureOpen(),
        throwsA(
          predicate<Object>(
            (e) => e.toString().contains('relationships failed validation'),
          ),
        ),
      );
      await db.close();
      expect(readAllFixtureData(fixture.file), before);
    },
  );
}
