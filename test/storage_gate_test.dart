import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';

import 'support/database_fixture.dart';
import 'support/widget_storage.dart';

void main() {
  testWidgets('storage loading is distinct from ready workspace', (
    tester,
  ) async {
    final opening = Completer<MomentumRepository>();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readyPreferencesOverride,
          ...readyWorkflowOverrides,
          repositoryProvider.overrideWith((ref) => opening.future),
        ],
        child: const MomentumApp(),
      ),
    );
    expect(find.text('Opening your saved workspace…'), findsOneWidget);
    expect(find.text('Make room for one next step'), findsNothing);
    opening.complete(MomentumRepository(db));
    await tester.pumpAndSettle();
    expect(find.text('Opening your saved workspace…'), findsNothing);
    expect(find.text('Make room for one next step'), findsOneWidget);
  });

  testWidgets(
    'failure shows recovery and details; explicit retry opens successfully at 200% text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      var attempts = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readyPreferencesOverride,
            ...readyWorkflowOverrides,
            repositoryProvider.overrideWith((ref) async {
              attempts++;
              if (attempts == 1) {
                throw const StorageOpenFailure(
                  'preserved.sqlite',
                  'Schema too new',
                );
              }
              return MomentumRepository(db);
            }),
          ],
          child: const MomentumApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your saved workspace could not open'), findsOneWidget);
      expect(
        find.textContaining('Your database has not been reset'),
        findsOneWidget,
      );
      expect(find.text('Make room for one next step'), findsNothing);
      await tester.ensureVisible(find.text('Storage details'));
      await tester.tap(find.text('Storage details'));
      await tester.pumpAndSettle();
      expect(find.textContaining('preserved.sqlite'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('retry-storage')));
      await tester.tap(find.byKey(const Key('retry-storage')));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text('Make room for one next step'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('real provider failure, retry and live query provider use the same durable database', () async {
    final fixture = await DatabaseFixture.create();
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        databaseFileProvider.overrideWithValue(() async {
          if (++attempts == 1) {
            throw StateError('Folder temporarily unavailable');
          }
          return fixture.file;
        }),
      ],
    );
    try {
      await expectLater(
        container.read(repositoryProvider.future),
        throwsA(isA<StorageOpenFailure>()),
      );
      expect(attempts, 1);
      container.invalidate(repositoryProvider);
      final repository = await container
          .read(repositoryProvider.future)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw StateError('timeout opening retry'),
          );
      final saved = await repository.createTask(
        const TaskDraft(title: 'Provider saved'),
      );
      final tasksSubscription = container.listen(tasksProvider, (_, _) {});
      final settingsSubscription = container.listen(
        settingsProvider,
        (_, _) {},
      );
      expect(
        (await container
                .read(tasksProvider.future)
                .timeout(
                  const Duration(seconds: 5),
                  onTimeout: () => throw StateError('timeout task stream'),
                ))
            .single
            .id,
        saved.id,
      );
      expect(
        (await container
                .read(settingsProvider.future)
                .timeout(
                  const Duration(seconds: 5),
                  onTimeout: () => throw StateError('timeout settings stream'),
                ))
            .planningZone,
        'Asia/Manila',
      );
      // Dispose subscribers before awaiting SQLite close. A paused stream
      // consumer can otherwise prevent its close event from being delivered.
      tasksSubscription.close();
      settingsSubscription.close();
      container.invalidate(tasksProvider);
      container.invalidate(settingsProvider);
      container.invalidate(repositoryProvider);
      await repository.database.close().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw StateError('timeout closing old database'),
      );
      final reopened = await container
          .read(repositoryProvider.future)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw StateError('timeout reopening'),
          );
      expect(await reopened.task(saved.id), saved);
    } finally {
      final current = container.read(repositoryProvider).value;
      container.dispose();
      if (current != null) {
        await current.database.close().timeout(const Duration(seconds: 5));
      }
      await fixture.dispose();
    }
  });
}
