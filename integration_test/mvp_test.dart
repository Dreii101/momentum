import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';

import '../test/mvp_journey_test.dart' show registerJourney;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerJourney(TargetPlatform.windows, const Size(1440, 1100));
}
