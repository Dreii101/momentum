import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import 'timer_clock.dart';
import 'timer_coordinator.dart';
import 'timer_store.dart';
import 'timer_engine.dart';

final sessionRecordProvider = StreamProvider.autoDispose
    .family<FocusSession?, String>(
      (ref, id) => repositoryStream(
        ref,
        (r) => (r.database.select(
          r.database.focusSessions,
        )..where((s) => s.id.equals(id))).watchSingleOrNull(),
      ),
      retry: (count, error) => null,
    );
final sessionHistoryProvider = StreamProvider.autoDispose<List<FocusSession>>(
  (ref) => repositoryStream(
    ref,
    (r) =>
        (r.database.select(r.database.focusSessions)
              ..where((s) => s.state.equalsValue(SessionState.finalized))
              ..orderBy([
                (s) => OrderingTerm.desc(s.startedUtc),
                (s) => OrderingTerm.asc(s.id),
              ])
              ..limit(20))
            .watch(),
  ),
  retry: (count, error) => null,
);

final timerClockProvider = Provider<TimerClock>(
  (ref) => SystemTimerClock(
    wallClock: ref.watch(clockProvider),
    epoch: ref.read(idGeneratorProvider)(),
  ),
);

final timerCoordinatorProvider = FutureProvider<TimerCoordinator>((ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  if (!ref.mounted) throw StateError('Timer opening was cancelled.');
  final coordinator = TimerCoordinator(
    TimerStore(repository),
    ref.watch(timerClockProvider),
  );
  ref.onDispose(coordinator.dispose);
  await coordinator.initialize();
  return coordinator;
}, retry: (count, error) => null);

final timerViewProvider = StreamProvider<TimerEngineView>(
  (ref) => ref
      .watch(timerCoordinatorProvider)
      .when(
        data: (coordinator) async* {
          yield coordinator.view;
          yield* coordinator.changes;
        },
        error: (e, stack) => Stream.error(e, stack),
        loading: () => const Stream.empty(),
      ),
  retry: (count, error) => null,
);
