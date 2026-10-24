import 'dart:async';

import 'package:drift/native.dart';
import 'package:momentum/core/database/app_database.dart';
import 'package:momentum/core/database/providers.dart';
import 'package:momentum/core/database/repository.dart';
import 'package:momentum/core/database/value_types.dart';
import 'package:momentum/features/tasks/task_workflow.dart';
import 'package:momentum/features/notes/note_providers.dart';
import 'package:momentum/features/schedule/schedule_providers.dart';
import 'package:momentum/features/schedule/recurrence.dart';
import 'package:momentum/features/calendar/calendar_providers.dart';
import 'package:momentum/core/database/planning_repository.dart';
import 'package:momentum/features/progress/progress_providers.dart';
import 'package:momentum/features/progress/progress_repository.dart';

// Layout/opening tests isolate feature queries; task tests use real storage.
final readyWorkflowOverrides = [
  progressProvider.overrideWith(
    (ref, range) => Stream.value(const ProgressSnapshot([], [], [], null)),
  ),
  planningProvider.overrideWith(
    (ref) => Stream.value(
      const PlanningSnapshot([], [], ScheduleSnapshot([], [], [])),
    ),
  ),
  scheduleProvider.overrideWith(
    (ref) => Stream.value(const ScheduleSnapshot([], [], [])),
  ),
  noteScheduleLinksProvider.overrideWith((ref, id) => Stream.value([])),
  taskRecordsProvider.overrideWith((ref) => Stream.value([])),
  upcomingTasksProvider.overrideWith((ref) => Stream.value([])),
  dailyTasksProvider.overrideWith((ref, day) => Stream.value([])),
  noteLibraryProvider.overrideWith((ref, query) => Stream.value([])),
  linkedNotesProvider.overrideWith((ref, taskId) => Stream.value([])),
];

// Shell tests don't query records. Real storage is covered by database/native tests.
final readyStorageOverride = repositoryProvider.overrideWith((ref) {
  final database = AppDatabase(NativeDatabase.memory());
  ref.onDispose(() => unawaited(database.close()));
  final repository = MomentumRepository(database);

  return repository;
});

final defaultTestSettings = Settings(
  id: '00000000-0000-4000-8000-000000000001',
  singleton: 1,
  theme: ThemePreference.system,
  planningZone: 'Asia/Manila',
  focusMinutes: 25,
  breakMinutes: 5,
  reducedMotion: false,
  updatedAt: DateTime.utc(2026, 10, 21),
);
final readyPreferencesOverride = settingsProvider.overrideWith(
  (ref) => Stream.value(defaultTestSettings),
);
