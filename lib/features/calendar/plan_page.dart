import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../schedule/schedule_page.dart';
import 'calendar_page.dart';

/// Both destinations retain their local date/filter/form state. Original
/// schedule routes remain valid from notes and course/task relationships.
class PlanPage extends ConsumerWidget {
  const PlanPage({super.key, required this.wide});
  final bool wide;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.plan];
    final schedule =
        selected != null &&
        [
          'timetable',
          'course',
          'activity',
          'occurrence',
          'replace',
          'new-course',
          'new-activity',
        ].contains(selected.split('/').first);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          child: Wrap(
            spacing: Space.sm,
            children: [
              TextButton(
                key: const Key('plan-calendar'),
                onPressed: () => ref
                    .read(shellNavigationProvider.notifier)
                    .clearRecord(Destination.plan),
                child: const Text('Calendar'),
              ),
              TextButton(
                key: const Key('plan-timetable'),
                onPressed: () => ref
                    .read(shellNavigationProvider.notifier)
                    .selectRecord(Destination.plan, 'timetable'),
                child: const Text('Timetable & courses'),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: schedule ? 1 : 0,
            children: [
              ExcludeFocus(
                excluding: schedule,
                child: CalendarPage(
                  key: const ValueKey('calendar-page'),
                  wide: wide,
                ),
              ),
              ExcludeFocus(
                excluding: !schedule,
                child: SchedulePage(
                  key: const ValueKey('schedule-page'),
                  wide: wide,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
