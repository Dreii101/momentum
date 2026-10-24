// Explicit interactive native-dialog verification. Run separately; never in CI
// without an operator because the OS dialogs require a selection/cancellation.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momentum/main.dart' as app;
import 'package:momentum/foundation/probe_services.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // A native accessibility client can attach while the operator inspects a
  // dialog. Establish that semantics baseline before test leak accounting.
  binding.platformDispatcher.semanticsEnabledTestValue = true;
  tearDownAll(binding.platformDispatcher.clearSemanticsEnabledTestValue);
  testWidgets(
    'native fixture save, open, save cancellation, open cancellation',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();
      final probes = ProbeServices();
      // The operator chooses only the diagnostic fixture, never personal files.
      debugPrint(
        'DIALOG_STEP_1: Save the diagnostic fixture to a local test folder.',
      );
      expect(await probes.saveFixture(), contains('save completed'));
      debugPrint('DIALOG_STEP_2: Open the fixture just saved.');
      expect(await probes.openFixture(), contains('contents verified'));
      debugPrint('DIALOG_STEP_3: Cancel Save.');
      expect(await probes.saveFixture(), contains('Save cancelled'));
      debugPrint('DIALOG_STEP_4: Cancel Open.');
      expect(await probes.openFixture(), contains('Open cancelled'));
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
