import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/app/adaptive_shell.dart';
import 'package:momentum/app/navigation.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/schedule_repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'schedule_restart_app.dart' as acceptance;

Future<void> capture(WidgetTester tester, String filename) async {
  final support = await getApplicationSupportDirectory();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).first,
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(p.join(support.path, filename))
      .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  image.dispose();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native timetable, cancellation and retained original note navigation',
    (tester) async {
      await acceptance.launchScheduleFixture(
        name: 'phase6_ui_${DateTime.now().microsecondsSinceEpoch}',
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AdaptiveShell)),
      );
      final repo = await container.read(repositoryProvider.future);
      final data = await repo.scheduleSnapshot();
      final s = data.series.singleWhere((s) => s.title == 'Native class');
      expect(find.text('Weekly timetable'), findsOneWidget);
      await capture(tester, 'phase6-weekly-grid.png');
      final meeting = find.byKey(
        ValueKey('meeting-${s.id}/2026-10-21-2026-10-22'),
      );
      await tester.ensureVisible(meeting);
      await tester.tap(meeting);
      await tester.pumpAndSettle();
      expect(
        find.text('Rescheduled · original identity and notes retained.'),
        findsOneWidget,
      );
      final cancel = find.byKey(const Key('cancel-occurrence'));
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(
        (await repo.occurrence(s.id, CalendarDate(2026, 10, 21))).cancelled,
        isTrue,
      );
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(
        (await repo.occurrence(s.id, CalendarDate(2026, 10, 21))).cancelled,
        isFalse,
      );
      final links = await repo.watchActivityLinks(seriesId: s.id).first;
      final retained = links.singleWhere(
        (l) => l.originalDate == CalendarDate(2026, 10, 26),
      );
      final visible = find.byKey(ValueKey('activity-note-${links.first.id}'));
      await tester.ensureVisible(visible);
      await tester.tap(visible);
      await tester.pumpAndSettle();
      expect(
        container.read(shellNavigationProvider).destination,
        Destination.notes,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('note-body')))
            .controller!
            .text,
        'Original class material 日本語',
      );
      final original = find.byKey(ValueKey('note-activity-${retained.id}'));
      await tester.ensureVisible(original);
      await tester.tap(original);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Retained superseded occurrence'),
        findsOneWidget,
      );
      expect(
        container
            .read(shellNavigationProvider)
            .selectedRecords[Destination.plan],
        'occurrence/${s.id}/2026-10-26',
      );
      await capture(tester, 'phase6-retained-occurrence.png');
      final support = await getApplicationSupportDirectory();
      await File(p.join(support.path, 'phase6-ui-result.json')).writeAsString(
        jsonEncode({
          'status': 'PASS',
          'platform': Platform.operatingSystem,
          'seriesId': s.id,
          'noteId': retained.noteId,
          'retainedDate': '2026-10-26',
          'nativeCancellation': true,
          'sameOriginalNote': true,
        }),
        flush: true,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
