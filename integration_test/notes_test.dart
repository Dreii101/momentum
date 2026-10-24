import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/features/notes/note_controller.dart';
import 'package:momentum/features/notes/note_providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'notes_restart_app.dart' as acceptance;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native writing autosaves, Ctrl+S commits and task entry reopens the same note',
    (tester) async {
      final name = 'phase5_notes_ui_${DateTime.now().microsecondsSinceEpoch}';
      await acceptance.launchNotesFixture(name: name);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repo = await container.read(repositoryProvider.future);
      final id = container
          .read(shellNavigationProvider)
          .selectedRecords[Destination.notes]!;
      final editor = container.read(noteDraftsProvider).existing(id)!;
      final body = find.byKey(const Key('note-body'));
      await tester.ensureVisible(body);
      await tester.enterText(body, 'Native UI 日本語 🧬\nRapid edit');
      await tester.enterText(
        body,
        'Native UI 日本語 🧬\nFinal text after rapid edits',
      );
      for (
        var attempt = 0;
        attempt < 100 && editor.state != NoteSaveState.saved;
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
      expect(editor.state, NoteSaveState.saved);
      expect(
        (await repo.note(id)).body,
        'Native UI 日本語 🧬\nFinal text after rapid edits',
      );
      final title = find.byKey(const Key('note-title'));
      await tester.ensureVisible(title);
      await tester.enterText(title, 'Native edited note');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect((await repo.note(id)).title, 'Native edited note');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Use this note'));
      await tester.tap(find.text('Use this note'));
      await tester.pumpAndSettle();
      expect(
        container.read(shellNavigationProvider).destination,
        Destination.tasks,
      );
      await tester.ensureVisible(find.byKey(ValueKey('open-linked-note-$id')));
      await tester.tap(find.byKey(ValueKey('open-linked-note-$id')));
      await tester.pumpAndSettle();
      expect(
        container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.notes],
        id,
      );
      expect(
        identical(container.read(noteDraftsProvider).existing(id), editor),
        isTrue,
      );
      expect(
        editor.body.text,
        'Native UI 日本語 🧬\nFinal text after rapid edits',
      );
      final support = await getApplicationSupportDirectory();
      await File(p.join(support.path, 'phase5-ui-result.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'platform': Platform.operatingSystem,
          'noteId': id,
          'title': (await repo.note(id)).title,
          'body': (await repo.note(id)).body,
          'sameOriginalNote': true,
          'autosaveAndKeyboardSave': true,
        }),
        flush: true,
      );
      if (Platform.isWindows) {
        await tester.ensureVisible(title);
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(p.join(support.path, 'phase5-note-editor.png'))
            .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
        image.dispose();
      }
      debugPrint(
        'PHASE5_NATIVE_NOTES: autosave, Unicode, Ctrl+S and note -> task -> same note passed.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
