import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/planning_repository.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../schedule/recurrence.dart';
import '../schedule/schedule_providers.dart';
import '../tasks/task_workflow.dart';
import 'calendar_projection.dart';
import 'calendar_providers.dart';
import 'work_block_editor.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key, required this.wide});
  final bool wide;
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarView? view;
  CalendarDate? chosen;
  final date = TextEditingController();
  final editorKeys = <String, GlobalKey>{};
  final kinds = CalendarKind.values.toSet();
  bool cancelled = false, completed = false, filtersOpen = false;
  String? courseId;
  Object? dateError;
  @override
  void dispose() {
    date.dispose();
    super.dispose();
  }

  void select(String id) => ref
      .read(shellNavigationProvider.notifier)
      .selectRecord(Destination.plan, id);
  void back() =>
      ref.read(shellNavigationProvider.notifier).clearRecord(Destination.plan);
  void changeDate(CalendarDate d) => setState(() {
    if (d.year < 2 || d.year > 9998) {
      dateError = 'Choose a viewing year from 0002 through 9998.';
      return;
    }
    chosen = d;
    date.text = d.toString();
    dateError = null;
  });
  @override
  Widget build(BuildContext context) {
    final zone =
        ref.watch(settingsProvider).value?.planningZone ?? 'Asia/Manila';
    chosen ??= localDay(ref.read(clockProvider)(), zone);
    view ??= Theme.of(context).platform == TargetPlatform.windows
        ? CalendarView.week
        : CalendarView.agenda;
    if (date.text.isEmpty) date.text = chosen.toString();
    final selected = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.plan];
    final query = ref.watch(planningProvider);
    return PopScope(
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                if (selected != null)
                  TextButton.icon(
                    key: const Key('calendar-back'),
                    onPressed: back,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Calendar overview'),
                  ),
                FilledButton.icon(
                  key: const Key('new-work'),
                  onPressed: () => select('new-work'),
                  icon: const Icon(Icons.add),
                  label: const Text('Reserve work time'),
                ),
              ],
            ),
          ),
          Expanded(
            child: query.when(
              loading: () => const LoadingState(message: 'Opening calendar…'),
              error: (e, _) => WorkspaceScroll(
                child: ActionError(
                  title: 'Could not load calendar',
                  message: 'Saved records are preserved.',
                  details: e.toString(),
                  onRetry: () => ref.invalidate(planningProvider),
                ),
              ),
              data: (data) {
                final library = calendar(data, zone);
                if (selected == null || selected == 'timetable') return library;
                final detail = KeyedSubtree(
                  key: editorKeys.putIfAbsent(selected, () => GlobalKey()),
                  child: detailFor(selected, data, zone),
                );
                if (!widget.wide) return detail;
                return LayoutBuilder(
                  builder: (context, size) => Row(
                    children: [
                      SizedBox(
                        width: math.min(620, size.maxWidth * .52),
                        child: library,
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: detail),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget detailFor(String route, PlanningSnapshot data, String zone) {
    final parts = route.split('/');
    if (parts.first == 'new-work') {
      return WorkBlockEditor(
        data: data,
        day: chosen!,
        zone: zone,
        initialTask: parts.length > 1 ? parts[1] : null,
      );
    }
    if (parts.first == 'work' && parts.length == 2) {
      final b = data.blocks.where((b) => b.id == parts[1]).firstOrNull;
      return b == null
          ? const Text('Work block not found.')
          : WorkBlockEditor(data: data, day: chosen!, zone: zone, block: b);
    }
    if (parts.first == 'calendar-task' && parts.length == 2) {
      final t = data.tasks.where((t) => t.id == parts[1]).firstOrNull;
      if (t == null) return const Text('Task not found.');
      return WorkspaceScroll(
        storageKey: 'calendar-task-${t.id}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
            if (t.deletedAt != null || t.archivedAt != null)
              const Text(
                'This task is in Trash or archived. Its original records are preserved.',
              ),
            Text(deadlineLabel(t)),
            Text(
              'Internal target: ${t.targetUtc == null ? 'not set' : localInput(t.targetUtc!, zone)}',
            ),
            Text(
              'Remaining estimate: ${t.remainingMinutes?.toString() ?? 'not set'} minutes',
            ),
            TextButton(
              key: const Key('calendar-open-task'),
              onPressed: () => ref
                  .read(shellNavigationProvider.notifier)
                  .selectRecord(Destination.tasks, t.id),
              child: const Text(
                'Open task · edit deadline, target or estimate',
              ),
            ),
            OutlinedButton(
              onPressed: () => select('new-work/${t.id}'),
              child: const Text('Reserve work for this task'),
            ),
          ],
        ),
      );
    }
    if (parts.first == 'calendar-occurrence' && parts.length == 3) {
      final o = data.schedule.occurrence(
        parts[1],
        CalendarDate.parse(parts[2]),
      );
      return WorkspaceScroll(
        storageKey: route,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              o.series.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${localInput(o.start, o.zone)} → ${localInput(o.end, o.zone)} · ${o.zone}',
            ),
            Text(o.location),
            if (o.cancelled) const Text('Cancelled'),
            if (o.moved) Text('Moved from original date ${o.originalDate}'),
            for (final adjustment in o.adjustments) Text(adjustment),
            TextButton(
              key: const Key('calendar-open-activity'),
              onPressed: () => openActivity(ref, o.series.id, o.originalDate),
              child: const Text('Open original meeting · edit or link notes'),
            ),
          ],
        ),
      );
    }
    return const Text('Choose a calendar item.');
  }

  Widget calendar(PlanningSnapshot data, String zone) {
    final first = view == CalendarView.week
        ? addDays(chosen!, 1 - dateValue(chosen!).weekday)
        : chosen!;
    final count = view == CalendarView.day ? 1 : 7;
    final rows = projectCalendar(
      data,
      first,
      addDays(first, count),
      zone,
      filters: CalendarFilters(
        kinds: kinds,
        cancelled: cancelled,
        completed: completed,
        courseId: courseId,
      ),
    );
    Widget entry(CalendarEntry e) => Card(
      child: ListTile(
        key: ValueKey('calendar-${e.identity}'),
        leading: Icon(switch (e.kind) {
          CalendarKind.deadline => Icons.flag_outlined,
          CalendarKind.target => Icons.my_location,
          CalendarKind.activity => Icons.school_outlined,
          CalendarKind.work => Icons.work_outline,
        }),
        title: Text(
          '${switch (e.kind) {
            CalendarKind.deadline => 'Deadline',
            CalendarKind.target => 'Internal target',
            CalendarKind.activity => 'Class / activity',
            CalendarKind.work => 'Work',
          }} · ${e.title}',
        ),
        subtitle: Text(
          '${e.day != null ? 'All day · ${e.day} · ${e.task!.deadlineZone}' : '${localInput(e.start, zone)}${e.end == e.start ? '' : ' → ${localInput(e.end, zone)}'} · $zone'}'
          '${e.cancelled ? '\nCancelled' : ''}${e.block == null ? '' : '\n${e.block!.status.name}${e.block!.locked ? ' · locked' : ''}'}'
          '${e.occurrence?.moved == true ? '\nMoved from ${e.occurrence!.originalDate}' : ''}'
          '${e.busy && rows.any((other) => other.busy && other.identity != e.identity && other.start.isBefore(e.end) && other.end.isAfter(e.start)) ? '\nOverlap warning' : ''}'
          '${e.occurrence?.adjustments.isNotEmpty == true ? '\n${e.occurrence!.adjustments.join('\n')}' : ''}',
        ),
        onTap: () => select(switch (e.kind) {
          CalendarKind.work => 'work/${e.block!.id}',
          CalendarKind.activity =>
            'calendar-occurrence/${e.occurrence!.series.id}/${e.occurrence!.originalDate}',
          _ => 'calendar-task/${e.task!.id}',
        }),
      ),
    );
    Widget dayColumn(CalendarDate day) {
      final entries = rows.where((e) => entryOnDay(e, day, zone)).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$day', style: Theme.of(context).textTheme.titleMedium),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(Space.sm),
              child: Text('No commitments.'),
            ),
          for (final e in entries) entry(e),
        ],
      );
    }

    return WorkspaceScroll(
      storageKey: 'unified-calendar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${view!.name[0].toUpperCase()}${view!.name.substring(1)} calendar',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Displayed in $zone. All-day deadlines keep their written date and own zone.',
          ),
          Wrap(
            spacing: Space.sm,
            children: [
              for (final v in CalendarView.values)
                ChoiceChip(
                  key: Key('calendar-view-${v.name}'),
                  label: Text(v.name[0].toUpperCase() + v.name.substring(1)),
                  selected: view == v,
                  onSelected: (_) => setState(() => view = v),
                ),
            ],
          ),
          Wrap(
            spacing: Space.sm,
            children: [
              IconButton(
                tooltip:
                    'Previous ${view == CalendarView.day ? 'day' : 'week'}',
                onPressed: () => changeDate(addDays(chosen!, -count)),
                icon: const Icon(Icons.chevron_left),
              ),
              TextButton(
                onPressed: () =>
                    changeDate(localDay(ref.read(clockProvider)(), zone)),
                child: const Text('Today'),
              ),
              IconButton(
                tooltip: 'Next ${view == CalendarView.day ? 'day' : 'week'}',
                onPressed: () => changeDate(addDays(chosen!, count)),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          TextField(
            key: const Key('calendar-date'),
            controller: date,
            decoration: const InputDecoration(
              labelText: 'View date (YYYY-MM-DD)',
            ),
          ),
          TextButton(
            key: const Key('calendar-view-date'),
            onPressed: () {
              try {
                changeDate(CalendarDate.parse(date.text.trim()));
              } catch (e) {
                setState(() => dateError = e);
              }
            },
            child: const Text('View date'),
          ),
          if (dateError != null) Text('Check the date: $dateError'),
          ExpansionTile(
            key: const PageStorageKey('calendar-filters'),
            title: const Text('Calendar filters'),
            children: [
              Wrap(
                spacing: Space.sm,
                children: [
                  for (final k in CalendarKind.values)
                    FilterChip(
                      key: Key('filter-${k.name}'),
                      label: Text(k.name),
                      selected: kinds.contains(k),
                      onSelected: (v) => setState(() {
                        v ? kinds.add(k) : kinds.remove(k);
                      }),
                    ),
                ],
              ),
              CheckboxListTile(
                key: const Key('calendar-cancelled'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Include cancelled classes and work'),
                value: cancelled,
                onChanged: (v) => setState(() => cancelled = v!),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include completed tasks and work'),
                value: completed,
                onChanged: (v) => setState(() => completed = v!),
              ),
              DropdownButtonFormField<String>(
                initialValue: courseId ?? '',
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Course filter'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All courses')),
                  for (final c in data.schedule.courses)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => courseId = v == '' ? null : v),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          if (view == CalendarView.week)
            LayoutBuilder(
              builder: (context, size) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(
                    size.maxWidth,
                    7 *
                        240 *
                        math.min(MediaQuery.textScalerOf(context).scale(1), 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: dayColumn(addDays(first, i)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else if (view == CalendarView.day)
            dayColumn(first)
          else ...[
            if (rows.isEmpty)
              const EmptyState(
                icon: Icons.calendar_today_outlined,
                title: 'No commitments in this range',
                message:
                    'Capture a task, add an activity or reserve work time.',
              ),
            for (final e in rows) entry(e),
          ],
        ],
      ),
    );
  }
}
