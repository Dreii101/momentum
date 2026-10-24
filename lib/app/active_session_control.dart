import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system.dart';
import 'navigation.dart';
import '../features/focus/focus_workflow.dart';
import '../features/focus/timer_engine.dart';
import '../features/focus/timer_providers.dart';

@immutable
class ActiveSessionPresentation {
  const ActiveSessionPresentation({
    required this.id,
    required this.title,
    required this.status,
  });
  final String id;
  final String title;
  final String status;
}

final activeSessionProvider = Provider<ActiveSessionPresentation?>((ref) {
  final session =
      ref.watch(timerViewProvider).value?.session ??
      ref.watch(timerCoordinatorProvider).value?.view.session;
  if (session == null || session.state == SessionState.finalized) return null;
  return ActiveSessionPresentation(
    id: session.id,
    title: session.titleSnapshot,
    status:
        '${sessionKindLabel(session.kind)} · ${sessionStateLabel(session.state)}',
  );
});
final openActiveSessionProvider = Provider<void Function(String)?>(
  (ref) =>
      (id) => ref
          .read(shellNavigationProvider.notifier)
          .selectRecord(
            Destination.today,
            id == 'new' ? 'focus' : 'session/$id',
          ),
);

class ActiveSessionControl extends ConsumerWidget {
  const ActiveSessionControl({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final open = ref.watch(openActiveSessionProvider);
    final failure =
        ref.watch(timerCoordinatorProvider).hasError ||
        ref.watch(timerViewProvider).value?.error != null;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xl,
          vertical: Space.md,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final text = Row(
              children: [
                const Icon(Icons.timelapse_outlined),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session?.title ??
                            (failure
                                ? 'Focus needs attention'
                                : 'Focus sessions'),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        failure
                            ? 'Open focus to retry.'
                            : session?.status ?? 'Ready when you are.',
                      ),
                    ],
                  ),
                ),
              ],
            );
            final button = open != null
                ? OutlinedButton(
                    key: Key(
                      session == null ? 'open-focus' : 'return-to-session',
                    ),
                    onPressed: () => open(session?.id ?? 'new'),
                    child: Text(
                      session == null ? 'Open focus' : 'Return to session',
                    ),
                  )
                : null;
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  text,
                  if (button != null) ...[
                    const SizedBox(height: Space.sm),
                    button,
                  ],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: text),
                if (button != null) ...[
                  const SizedBox(width: Space.lg),
                  button,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
