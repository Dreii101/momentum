import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/foundation/file_fixture.dart';
import 'package:momentum/foundation/probe_database.dart';
import 'package:momentum/foundation/probe_services.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sql;

import 'support/widget_storage.dart';

class FailingProbeServices extends ProbeServices {
  @override
  Future<String> databaseProbe({required bool write}) async =>
      throw const FileSystemException('Storage unavailable');
}

Future<void> removeFixtureDirectory(Directory directory) async {
  final temporaryRoot = await Directory.systemTemp.resolveSymbolicLinks();
  final target = await directory.resolveSymbolicLinks();
  if (!p.isWithin(temporaryRoot, target) ||
      !p.basename(target).startsWith('momentum-')) {
    throw StateError(
      'Refusing to remove a directory outside the test fixtures.',
    );
  }
  await directory.delete(recursive: true);
}

void main() {
  test(
    'SQLite probe persists through separate connections and increments',
    () async {
      final directory = await Directory.systemTemp.createTemp('momentum-test-');
      try {
        final file = File('${directory.path}/probe.sqlite');
        final first = ProbeDatabase(file);
        expect(await first.writeProbe(), 1);
        await first.close();
        final second = ProbeDatabase(file);
        expect((await second.readProbe())!.writes, 1);
        expect(await second.writeProbe(), 2);
        await second.close();
        final third = ProbeDatabase(file);
        expect((await third.readProbe())!.writes, 2);
        await third.close();
      } finally {
        await removeFixtureDirectory(directory);
      }
    },
  );

  test(
    'a future database schema is rejected without losing its records',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'momentum-future-',
      );
      final file = File('${directory.path}/future.sqlite');
      try {
        final native = sql.sqlite3.open(file.path);
        native.execute('CREATE TABLE retained (value TEXT NOT NULL)');
        native.execute("INSERT INTO retained VALUES ('keep this record')");
        native.execute('PRAGMA user_version = 99');
        native.close();
        final database = ProbeDatabase(file);
        try {
          await expectLater(
            database.readProbe(),
            throwsA(
              predicate<Object>(
                (error) =>
                    error.toString().contains('version 99 is unsupported'),
              ),
            ),
          );
        } finally {
          await database.close();
        }
        final retained = sql.sqlite3.open(file.path);
        expect(retained.select('PRAGMA user_version').single.values.single, 99);
        expect(
          retained.select('SELECT value FROM retained').single['value'],
          'keep this record',
        );
        retained.close();
      } finally {
        await removeFixtureDirectory(directory);
      }
    },
  );

  test('fixture accepts a valid file split across stream chunks', () async {
    final bytes = FileFixture.encode();
    await FileFixture.validateStream(
      Stream.fromIterable([bytes.sublist(0, 7), bytes.sublist(7)]),
    );
  });
  test('fixture rejects unrelated JSON', () async {
    await expectLater(
      FileFixture.validateStream(Stream.value(utf8.encode('{"notes":[]}'))),
      throwsFormatException,
    );
  });
  test('fixture stops an oversize stream at its bound', () async {
    await expectLater(
      FileFixture.validateStream(
        Stream.fromIterable([
          List.filled(FileFixture.maxBytes, 32),
          [32],
        ]),
      ),
      throwsFormatException,
    );
  });
  test('fixture rejects invalid UTF-8', () async {
    await expectLater(
      FileFixture.validateStream(Stream.value([255, 254])),
      throwsFormatException,
    );
  });

  for (final size in [const Size(360, 800), const Size(1280, 850)]) {
    testWidgets('adaptive shell at $size and 200% text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readyStorageOverride,
            readyPreferencesOverride,
            ...readyWorkflowOverrides,
          ],
          child: const MomentumApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Momentum'), findsOneWidget);
      await tester.tap(find.text('Notes').last);
      await tester.pumpAndSettle();
      expect(find.text('Notes'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ordinary release-style shell does not expose diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readyStorageOverride,
          readyPreferencesOverride,
          ...readyWorkflowOverrides,
        ],
        child: const MomentumApp(showDevelopment: false),
      ),
    );
    expect(find.byKey(const Key('open-development')), findsNothing);
  });

  testWidgets('storage failure is visible and retry remains available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readyStorageOverride,
          readyPreferencesOverride,
          ...readyWorkflowOverrides,
          probeServicesProvider.overrideWithValue(FailingProbeServices()),
        ],
        child: const MomentumApp(),
      ),
    );
    await tester.tap(find.byKey(const Key('open-development')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('probe-write')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Storage unavailable'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('probe-write')))
          .onPressed,
      isNotNull,
    );
  });
}
