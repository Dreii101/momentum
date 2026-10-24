import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings_page.dart';
import '../features/reminders/reminder_providers.dart';
import '../features/calendar/plan_page.dart';
import '../features/notes/notes_page.dart';
import '../features/notes/notes_recovery_bar.dart';
import '../features/tasks/tasks_page.dart';
import '../features/tasks/today_page.dart';
import '../foundation/development_page.dart';
import 'active_session_control.dart';
import 'design_system.dart';
import 'navigation.dart';
import 'storage_gate.dart';
import '../features/progress/progress_page.dart';

class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({super.key, required this.showDevelopment});
  final bool showDevelopment;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(shellNavigationProvider);
    void go(Destination destination) =>
        ref.read(shellNavigationProvider.notifier).go(destination);
    final windows = Theme.of(context).platform == TargetPlatform.windows;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final expanded = constraints.maxWidth >= 1000;
        final destinations = windows && !compact
            ? Destination.values
            : Destination.values.take(4).toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Momentum'),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final reminders = ref.watch(reminderViewProvider);
                  final attention =
                      reminders.hasError ||
                      reminders.value?.error != null ||
                      ref.watch(reminderNoticeProvider) != null ||
                      reminders.value?.registrations.any(
                            (r) => r.error != null,
                          ) ==
                          true;
                  if (!attention) return const SizedBox.shrink();
                  return IconButton(
                    tooltip: attention
                        ? 'Reminders need attention'
                        : 'Reminders',
                    onPressed: () => ref
                        .read(shellNavigationProvider.notifier)
                        .selectRecord(Destination.settings, 'reminders'),
                    icon: Icon(
                      attention
                          ? Icons.notification_important_outlined
                          : Icons.notifications_outlined,
                    ),
                  );
                },
              ),
              if (showDevelopment)
                IconButton(
                  key: const Key('open-development'),
                  tooltip: 'Development checks',
                  onPressed: () => Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      transitionDuration:
                          MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : Space.motion,
                      reverseTransitionDuration:
                          MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : Space.motion,
                      pageBuilder: (_, animation, secondary) =>
                          const DevelopmentPage(),
                      transitionsBuilder: (_, animation, secondary, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  ),
                  icon: const Icon(Icons.science_outlined),
                ),
              if (!windows || compact)
                PopupMenuButton<Destination>(
                  key: const Key('workspace-menu'),
                  tooltip: 'More destinations',
                  onSelected: go,
                  itemBuilder: (_) => [
                    for (final destination in [
                      Destination.progress,
                      Destination.settings,
                    ])
                      PopupMenuItem(
                        value: destination,
                        height: Space.touch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Space.sm,
                          ),
                          child: Row(
                            children: [
                              Icon(destination.icon),
                              const SizedBox(width: Space.md),
                              Flexible(child: Text(destination.label)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (!compact)
                      SizedBox(
                        key: const Key('workspace-navigation'),
                        width: expanded ? 248 : 80,
                        child: expanded
                            ? FocusTraversalGroup(
                                child: _Sidebar(
                                  destinations: destinations,
                                  selected: route.destination,
                                  onSelected: go,
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, available) =>
                                    SingleChildScrollView(
                                      child: SizedBox(
                                        height: math.max(
                                          available.maxHeight,
                                          destinations.length * 64.0 + 24,
                                        ),
                                        child: NavigationRail(
                                          key: const Key('navigation-rail'),
                                          selectedIndex:
                                              !destinations.contains(
                                                route.destination,
                                              )
                                              ? null
                                              : destinations.indexOf(
                                                  route.destination,
                                                ),
                                          onDestinationSelected: (index) =>
                                              go(destinations[index]),
                                          destinations: [
                                            for (final destination
                                                in destinations)
                                              NavigationRailDestination(
                                                icon: Tooltip(
                                                  message: destination.label,
                                                  child: Icon(destination.icon),
                                                ),
                                                label: Text(destination.label),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ),
                      ),
                    Expanded(
                      key: const Key('workspace-pages'),
                      child: StorageGate(
                        child: IndexedStack(
                          key: const Key('workspace-content'),
                          index: route.destination.index,
                          sizing: StackFit.expand,
                          children: [
                            for (final destination in Destination.values)
                              ExcludeFocus(
                                key: ValueKey(destination),
                                excluding: destination != route.destination,
                                child: TickerMode(
                                  enabled: destination == route.destination,
                                  child: switch (destination) {
                                    Destination.settings =>
                                      const SettingsPage(),
                                    Destination.tasks => TasksPage(
                                      split: expanded && windows,
                                    ),
                                    Destination.today => const TodayPage(),
                                    Destination.plan => PlanPage(
                                      wide: expanded && windows,
                                    ),
                                    Destination.notes => NotesPage(
                                      split: expanded && windows,
                                    ),
                                    Destination.progress => ProgressPage(
                                      wide: expanded && windows,
                                    ),
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const NotesRecoveryBar(),
              const ActiveSessionControl(key: Key('active-session-control')),
            ],
          ),
          bottomNavigationBar: compact
              ? Material(
                  key: const Key('bottom-navigation'),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        for (final destination in Destination.values.take(4))
                          Expanded(
                            child: Semantics(
                              selected: route.destination == destination,
                              child: TextButton(
                                key: Key('nav-${destination.name}'),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 72),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 2,
                                  ),
                                  backgroundColor:
                                      route.destination == destination
                                      ? Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => go(destination),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(destination.icon),
                                    const SizedBox(height: Space.xs),
                                    Text(
                                      destination.label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.selected,
    required this.onSelected,
  });
  final List<Destination> destinations;
  final Destination selected;
  final ValueChanged<Destination> onSelected;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: ListView(
      key: const Key('navigation-sidebar'),
      padding: const EdgeInsets.all(Space.md),
      children: [
        const Padding(
          padding: EdgeInsets.all(Space.md),
          child: Text('Your workspace'),
        ),
        for (final destination in destinations)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: ListTile(
              key: Key('nav-${destination.name}'),
              minVerticalPadding: Space.md,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: selected == destination,
              selectedTileColor: Theme.of(context)
                  .colorScheme
                  .secondaryContainer,
              leading: Icon(destination.icon),
              title: Text(destination.label),
              onTap: () => onSelected(destination),
            ),
          ),
      ],
    ),
  );
}
