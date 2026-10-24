import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/providers.dart';
import 'task_controls.dart';
import 'task_workflow.dart';
import '../focus/focus_page.dart';
import '../focus/focus_workflow.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.today];
    if (route != null &&
        (route == 'focus' ||
            route == 'break' ||
            route == 'history' ||
            route.startsWith('starter/') ||
            route.startsWith('focus/') ||
            route.startsWith('session/'))) {
      return FocusPage(key: ValueKey(route), route: route);
    }
    final preferences = ref.watch(settingsProvider);
    return WorkspaceScroll(
      storageKey: 'today-scroll',
      child: preferences.when(
        loading: () => const LoadingState(message: 'Loading Today…'),
        error: (e, _) => ActionError(
          title: 'Today could not load',
          message: 'Your saved tasks are preserved.',
          details: e.toString(),
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (settings) {
          final now = ref.watch(workflowInstantProvider);
          final day = localDay(now, settings.planningZone);
          final daily = ref.watch(dailyTasksProvider(day));
          final upcoming = ref.watch(upcomingTasksProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Make room for one next step',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Space.sm),
              Text('$day · ${settings.planningZone}'),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  FilledButton.icon(
                    key: const Key('today-focus'),
                    onPressed: () => openFocus(ref),
                    icon: const Icon(Icons.timelapse),
                    label: const Text('Prepare focus'),
                  ),
                  OutlinedButton(
                    key: const Key('today-history'),
                    onPressed: () => openFocus(ref, 'history'),
                    child: const Text('Recent sessions'),
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              SectionCard(
                title: 'Today’s three',
                description: 'Choose up to three tasks deliberately. A small selection is enough.',
                child: daily.when(
                  loading: () =>
                      const LoadingState(message: 'Loading priorities…'),
                  error: (e, _) => ActionError(
                    title: 'Could not load priorities',
                    message: 'Retry to see your saved selection.',
                    details: e.toString(),
                    onRetry: () => ref.invalidate(dailyTasksProvider(day)),
                  ),
                  data: (rows) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${rows.length} of 3 selected'),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: Space.md),
                          child: Text(
                            'No priorities selected. Capture a task or choose one from Tasks.',
                          ),
                        ),
                      for (final task in rows) ...[
                        TaskSummary(
                          task: task,
                          now: now,
                          onOpen: () => openTask(ref, task.id),
                          onStart: () => openStarter(ref, task.id),
                        ),
                        DailyPriorityButton(key: ValueKey(task.id), task: task),
                      ],
                      const SizedBox(height: Space.md),
                      OutlinedButton(
                        key: const Key('today-open-tasks'),
                        onPressed: () => ref
                            .read(shellNavigationProvider.notifier)
                            .go(Destination.tasks),
                        child: const Text('Capture or choose a task'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.xl),
              SectionCard(
                title: 'Deadlines and internal targets',
                description: 'Upcoming and overdue task commitments. Open Plan to see these together with classes and reserved work time.',
                child: upcoming.when(
                  loading: () =>
                      const LoadingState(message: 'Loading commitments…'),
                  error: (e, _) => ActionError(
                    title: 'Could not load commitments',
                    message: 'Retry to see saved deadlines.',
                    details: e.toString(),
                    onRetry: () => ref.invalidate(upcomingTasksProvider),
                  ),
                  data: (rows) => rows.isEmpty
                      ? const Text(
                          'No upcoming task commitments. Add an optional deadline in task details.',
                        )
                      : Column(
                          children: [
                            for (final task in rows)
                              TaskSummary(
                                task: task,
                                now: now,
                                onOpen: () => openTask(ref, task.id),
                                onStart: () => openStarter(ref, task.id),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
