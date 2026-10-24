import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/planning_repository.dart';
import '../../core/database/providers.dart';

final planningProvider = StreamProvider<PlanningSnapshot>(
  (ref) => repositoryStream(ref, (r) => r.watchPlanningInputs()),
  retry: (count, error) => null,
);

// The reminders phase can consume this full-state stream even when calendar UI
// is closed. Initial emission supports restart reconciliation.
final reminderReconciliationInputsProvider = StreamProvider<PlanningSnapshot>(
  (ref) => repositoryStream(ref, (r) => r.watchReminderReconciliationInputs()),
  retry: (count, error) => null,
);
