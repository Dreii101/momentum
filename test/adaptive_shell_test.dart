import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/app/active_session_control.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/app/momentum_app.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/settings/settings_page.dart';
import 'package:momentum/features/focus/timer_clock.dart';
import 'package:momentum/features/focus/timer_providers.dart';

class ShellHarness {
  ShellHarness(this.container, this.repository);
  final ProviderContainer container;
  final MomentumRepository repository;
}

Future<ShellHarness> pumpShell(
  WidgetTester tester, {
  Size size = const Size(1280, 850),
  TargetPlatform platform = TargetPlatform.windows,
  double textScale = 1,
  MomentumRepository Function(AppDatabase)? repositoryFactory,
  ActiveSessionPresentation? session,
  void Function(String)? openSession,
  bool diagnostics = true,
  bool realSessions = false,
  Clock? clock,
  TimerClock? timerClock,
  Object? Function()? openingFailure,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final database = AppDatabase(NativeDatabase.memory());
  final repository =
      repositoryFactory?.call(database) ??
      MomentumRepository(database, clock: clock);
  await tester.runAsync(repository.initialize);
  final container = ProviderContainer(
    overrides: [
      repositoryProvider.overrideWith((ref) {
        final failure = openingFailure?.call();
        if (failure != null) throw failure;
        return repository;
      }),
      if (clock != null) clockProvider.overrideWithValue(clock),
      if (timerClock != null) timerClockProvider.overrideWithValue(timerClock),
      if (!realSessions) activeSessionProvider.overrideWithValue(session),
      if (!realSessions)
        openActiveSessionProvider.overrideWithValue(openSession),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
    await tester.runAsync(database.close);
    await tester.pump();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MomentumApp(platform: platform, showDevelopment: diagnostics),
    ),
  );
  await tester.pumpAndSettle();
  return ShellHarness(container, repository);
}

Finder preferenceField(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(TextFormField),
);

Future<void> edit(WidgetTester tester, String key, String text) async {
  final field = preferenceField(key);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('save-settings')));
  await tester.tap(find.byKey(const Key('save-settings')));
  await tester.pumpAndSettle();
}

void settings(ShellHarness harness) => harness.container
    .read(shellNavigationProvider.notifier)
    .go(Destination.settings);

class FailingSettingsRepository extends MomentumRepository {
  FailingSettingsRepository(super.database);
  bool fail = true;
  @override
  Future<void> updateSettings({
    required ThemePreference theme,
    required String planningZone,
    int? focusMinutes,
    int? breakMinutes,
    bool? reducedMotion,
  }) {
    if (fail) {
      throw const FileSystemException('Storage temporarily unavailable');
    }
    return super.updateSettings(
      theme: theme,
      planningZone: planningZone,
      focusMinutes: focusMinutes,
      breakMinutes: breakMinutes,
      reducedMotion: reducedMotion,
    );
  }
}

void main() {
  for (final width in [360.0, 600.0, 999.0, 1000.0, 1440.0]) {
    testWidgets('Windows navigation at width $width and 200% text', (
      tester,
    ) async {
      final harness = await pumpShell(
        tester,
        size: Size(width, 850),
        textScale: 2,
      );
      expect(
        find.byKey(const Key('bottom-navigation')),
        width < 600 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('navigation-rail')),
        width >= 600 && width < 1000 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('navigation-sidebar')),
        width >= 1000 ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.byIcon(Icons.description_outlined).last);
      await tester.pumpAndSettle();
      expect(
        harness.container.read(shellNavigationProvider).destination,
        Destination.notes,
      );
      expect(
        find.byKey(const Key('notes-detail-slot')),
        width >= 1000 ? findsOneWidget : findsNothing,
      );
      if (width < 600) {
        await tester.tap(find.byKey(const Key('workspace-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings').last);
      } else {
        if (width >= 1000) {
          await tester.scrollUntilVisible(
            find.byKey(const Key('nav-settings')),
            100,
            scrollable: find.descendant(
              of: find.byKey(const Key('navigation-sidebar')),
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('nav-settings')));
        } else {
          await tester.tap(find.byIcon(Icons.settings_outlined).last);
        }
      }
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('theme-preference')), findsOneWidget);
      expect(
        harness.container.read(shellNavigationProvider).destination,
        Destination.settings,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [360.0, 1100.0]) {
    testWidgets(
      'Android has four primary destinations and a menu at width $width',
      (tester) async {
        final harness = await pumpShell(
          tester,
          platform: TargetPlatform.android,
          size: Size(width, 850),
          textScale: 2,
        );
        expect(find.byKey(const Key('nav-settings')), findsNothing);
        await tester.tap(find.byKey(const Key('workspace-menu')));
        await tester.pumpAndSettle();
        expect(find.text('Progress'), findsOneWidget);
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();
        expect(
          harness.container.read(shellNavigationProvider).destination,
          Destination.progress,
        );
        expect(find.text('This week in saved records'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'settings drafts, selected record route and session host survive every breakpoint',
    (tester) async {
      String? opened;
      final harness = await pumpShell(
        tester,
        session: const ActiveSessionPresentation(
          id: 'test-session',
          title: 'A real future session',
          status: 'Paused',
        ),
        openSession: (id) => opened = id,
      );
      final navigation = harness.container.read(
        shellNavigationProvider.notifier,
      );
      navigation.selectRecord(Destination.notes, 'selected-note-id');
      settings(harness);
      await tester.pumpAndSettle();
      await edit(tester, 'focus-minutes', '42');
      final formElement = tester.element(find.byType(SettingsPage));
      final sessionElement = tester.element(find.byType(ActiveSessionControl));
      for (final width in [360.0, 600.0, 1000.0, 599.0, 999.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 850);
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(SettingsPage)), same(formElement));
        expect(
          tester
              .widget<TextFormField>(preferenceField('focus-minutes'))
              .controller!
              .text,
          '42',
        );
        expect(
          tester.element(find.byType(ActiveSessionControl)),
          same(sessionElement),
        );
        expect(
          harness.container
              .read(shellNavigationProvider)
              .selectedRecords[Destination.notes],
          'selected-note-id',
        );
        expect(tester.takeException(), isNull);
      }
      navigation.go(Destination.tasks);
      await tester.pumpAndSettle();
      settings(harness);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(preferenceField('focus-minutes'))
            .controller!
            .text,
        '42',
      );
      await tester.tap(find.byKey(const Key('return-to-session')));
      expect(opened, 'test-session');
    },
  );

  testWidgets(
    'settings commit all values, apply dark theme and reduce motion',
    (tester) async {
      final harness = await pumpShell(tester);
      settings(harness);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('theme-preference')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('reduced-motion')));
      await tester.tap(find.byKey(const Key('reduced-motion')));
      await edit(tester, 'focus-minutes', '45');
      await edit(tester, 'break-minutes', '8');
      await edit(tester, 'planning-zone', 'Europe/London');
      await save(tester);
      expect(find.text('Saved on this device.'), findsOneWidget);
      final committed = await tester.runAsync(harness.repository.settings);
      expect(committed!.focusMinutes, 45);
      expect(committed.breakMinutes, 8);
      expect(committed.planningZone, 'Europe/London');
      expect(committed.reducedMotion, isTrue);
      expect(committed.theme, ThemePreference.dark);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(app.themeAnimationDuration, Duration.zero);
      expect(
        Theme.of(tester.element(find.byType(AdaptiveShell))).brightness,
        Brightness.dark,
      );
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.byType(AdaptiveShell)),
        ),
        isTrue,
      );
    },
  );

  testWidgets('invalid preferences never replace saved values', (tester) async {
    final harness = await pumpShell(
      tester,
      size: const Size(360, 850),
      textScale: 2,
    );
    settings(harness);
    await tester.pumpAndSettle();
    await edit(tester, 'focus-minutes', '0');
    await edit(tester, 'break-minutes', '61');
    await edit(tester, 'planning-zone', 'Not/AZone');
    await save(tester);
    expect(find.text('Enter a whole number from 1 to 180.'), findsOneWidget);
    expect(find.text('Enter a whole number from 1 to 60.'), findsOneWidget);
    expect(
      find.text('Enter a valid time zone, such as Asia/Manila.'),
      findsOneWidget,
    );
    final committed = await tester.runAsync(harness.repository.settings);
    expect(committed!.focusMinutes, 25);
    expect(committed.breakMinutes, 5);
    expect(committed.planningZone, 'Asia/Manila');
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save retains edits and retry commits them', (
    tester,
  ) async {
    final harness = await pumpShell(
      tester,
      repositoryFactory: FailingSettingsRepository.new,
    );
    settings(harness);
    await tester.pumpAndSettle();
    await edit(tester, 'focus-minutes', '48');
    await save(tester);
    expect(find.text('Changes could not be saved'), findsOneWidget);
    expect(find.text('Saved on this device.'), findsNothing);
    expect(
      (await tester.runAsync(harness.repository.settings))!.focusMinutes,
      25,
    );
    (harness.repository as FailingSettingsRepository).fail = false;
    await tester.ensureVisible(find.text('Retry saving'));
    await tester.tap(find.text('Retry saving'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(harness.repository.settings))!.focusMinutes,
      48,
    );
    expect(find.text('Saved on this device.'), findsOneWidget);
  });

  testWidgets(
    'system theme follows device, explicit light overrides it, OS reduced motion wins',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final harness = await pumpShell(tester);
      expect(
        Theme.of(tester.element(find.byType(AdaptiveShell))).brightness,
        Brightness.dark,
      );
      await tester.runAsync(
        () => harness.repository.updateSettings(
          theme: ThemePreference.light,
          planningZone: 'Asia/Manila',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(AdaptiveShell))).brightness,
        Brightness.light,
      );
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MaterialApp>(find.byType(MaterialApp))
            .themeAnimationDuration,
        Duration.zero,
      );
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.byType(AdaptiveShell)),
        ),
        isTrue,
      );
    },
  );

  testWidgets('Tab and Enter navigate Windows; Ctrl+S saves from a field', (
    tester,
  ) async {
    final harness = await pumpShell(tester, diagnostics: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(shellNavigationProvider).destination,
      Destination.tasks,
    );
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(shellNavigationProvider).destination,
      Destination.settings,
    );
    await edit(tester, 'focus-minutes', '40');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(harness.repository.settings))!.focusMinutes,
      40,
    );
  });
}
