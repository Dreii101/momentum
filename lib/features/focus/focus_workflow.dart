import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import 'timer_engine.dart';
import 'timer_providers.dart';

void openFocus(WidgetRef ref, [String route = 'focus']) => ref
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.today, route);

void openStarter(WidgetRef ref, String taskId) =>
    openFocus(ref, 'starter/$taskId');

String sessionKindLabel(SessionKind kind) => switch (kind) {
  SessionKind.starter => 'Two-minute starter',
  SessionKind.focus => 'Focus',
  SessionKind.rest => 'Break',
};
String sessionStateLabel(SessionState state) => switch (state) {
  SessionState.running => 'Running',
  SessionState.paused => 'Paused',
  SessionState.awaitingReview => 'Ready for review',
  SessionState.finalized => 'Review saved',
};
String timerText(int milliseconds) {
  final seconds = (milliseconds / 1000).ceil();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

int reportedWorkMilliseconds(String input, int eligibleMs) {
  // Bound before multiplication so native integer overflow cannot disguise invalid input.
  final seconds = int.tryParse(input.trim());
  if (seconds == null || seconds < 0 || seconds > eligibleMs ~/ 1000) {
    throw FormatException(
      'Enter whole seconds from 0 to ${eligibleMs ~/ 1000}.',
    );
  }
  return seconds * 1000;
}

/// Both task-completion entry points resolve running work through the engine.
Future<void> completeTaskWithReview(
  WidgetRef ref,
  MomentumRepository repo,
  String taskId,
) async {
  final owner = await ref.read(timerCoordinatorProvider.future);
  final session = owner.view.session;
  final linked =
      session?.taskId == taskId && session?.state != SessionState.finalized;
  if (linked &&
      (session!.state == SessionState.running ||
          session.state == SessionState.paused)) {
    await owner.command(TimerAction.end);
  }
  await repo.setTaskStatus(taskId, TaskStatus.done);
  if (linked && ref.context.mounted) openFocus(ref, 'session/${session!.id}');
}
