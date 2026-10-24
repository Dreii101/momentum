import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../tasks/task_workflow.dart';
import 'activity_detail.dart';
import 'activity_editor.dart';
import 'course_editor.dart';
import 'recurrence.dart';
import 'schedule_providers.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key, required this.wide});
  final bool wide;
  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final dateInput = TextEditingController();
  final editorKeys = <String, GlobalKey>{};
  CalendarDate? chosen;
  bool courses = false, archived = false;
  Object? dateError;
  @override
  void dispose() {
    dateInput.dispose();
    super.dispose();
  }

  void select(String id) => ref
      .read(shellNavigationProvider.notifier)
      .selectRecord(Destination.plan, id);
  void back() => ref
      .read(shellNavigationProvider.notifier)
      .selectRecord(Destination.plan, 'timetable');
  void changeDay(CalendarDate day) => setState(() {
    if (day.year < 2 || day.year > 9998) {
      dateError = 'Choose a viewing year from 0002 through 9998 so the surrounding week fits.';
      return;
    }
    chosen = day;
    dateInput.text = day.toString();
    dateError = null;
  });
  @override
  Widget build(BuildContext context) {
    final zone =
        ref.watch(settingsProvider).value?.planningZone ?? 'Asia/Manila';
    chosen ??= localDay(ref.read(clockProvider)(), zone);
    if (dateInput.text.isEmpty) dateInput.text = chosen.toString();
    final selected = ref
        .watch(shellNavigationProvider)
        .selectedRecords[Destination.plan];
    final query = ref.watch(scheduleProvider);
    return PopScope(
      canPop: selected == null || selected == 'timetable',
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
                if (selected != null && selected != 'timetable')
                  TextButton.icon(
                    key: const Key('back-to-timetable'),
                    onPressed: back,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Plan overview'),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() => courses = false);
                    back();
                  },
                  child: const Text('Timetable'),
                ),
                TextButton(
                  key: const Key('plan-courses'),
                  onPressed: () {
                    setState(() => courses = true);
                    back();
                  },
                  child: const Text('Courses'),
                ),
                FilledButton.icon(
                  key: const Key('new-course'),
                  onPressed: () => select('new-course'),
                  icon: const Icon(Icons.add),
                  label: const Text('New course'),
                ),
                FilledButton.icon(
                  key: const Key('new-activity'),
                  onPressed: () => select('new-activity'),
                  icon: const Icon(Icons.add),
                  label: const Text('New activity'),
                ),
              ],
            ),
          ),
          Expanded(
            child: query.when(
              loading: () => const LoadingState(message: 'Opening timetable…'),
              error: (e, _) => WorkspaceScroll(
                child: ActionError(
                  title: 'Could not load timetable',
                  message: 'Your saved schedule is preserved.',
                  details: e.toString(),
                  onRetry: () => ref.invalidate(scheduleProvider),
                ),
              ),
              data: (data) {
                final library = courses
                    ? courseList(data)
                    : timetable(data, zone);
                if (selected == null ||
                    selected == 'timetable' ||
                    ![
                      'new-course',
                      'new-activity',
                      'course',
                      'activity',
                      'occurrence',
                      'replace',
                    ].contains(selected.split('/').first)) {
                  return library;
                }
                final detail = KeyedSubtree(
                  key: editorKeys.putIfAbsent(selected, () => GlobalKey()),
                  child: detailFor(selected, data, zone),
                );
                if (!widget.wide) return detail;
                return LayoutBuilder(
                  builder: (context, size) => Row(
                    children: [
                      SizedBox(
                        width: math.min(380, size.maxWidth * .4),
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

  Widget detailFor(String route, ScheduleSnapshot data, String zone) {
    if (route == 'new-course') return const CourseEditor();
    if (route == 'new-activity') {
      return ActivityEditor(day: chosen!, zone: zone, data: data);
    }
    final parts = route.split('/');
    if (parts.length < 2) return const Text('Choose an activity or course.');
    if (parts[0] == 'course') {
      final course = data.courses.where((c) => c.id == parts[1]).firstOrNull;
      return course == null
          ? const Text('Course not found.')
          : CourseEditor(course: course);
    }
    final series = data.series.where((s) => s.id == parts[1]).firstOrNull;
    if (series == null) {
      return const Text('Activity not found. Original links are preserved.');
    }
    final original = parts.length == 3 ? CalendarDate.parse(parts[2]) : null;
    if (parts[0] == 'replace' && original != null) {
      return ActivityEditor(
        day: original,
        zone: series.zone,
        data: data,
        replacing: series,
      );
    }
    return ActivityDetail(series: series, data: data, original: original);
  }

  Widget courseList(ScheduleSnapshot data) => WorkspaceScroll(
    storageKey: 'course-library',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Courses', style: Theme.of(context).textTheme.headlineMedium),
        const Text(
          'Tasks and notes can stay unassigned. Archiving preserves their relationships and scheduled meetings.',
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show archived courses'),
          value: archived,
          onChanged: (v) => setState(() => archived = v!),
        ),
        if (!data.courses.any(
          (c) => c.deletedAt == null && (archived || c.archivedAt == null),
        ))
          const Text('No courses yet. Add one when it helps you organize.'),
        for (final c in data.courses.where(
          (c) => c.deletedAt == null && (archived || c.archivedAt == null),
        ))
          ListTile(
            key: ValueKey('course-row-${c.id}'),
            title: Text(c.name),
            subtitle: Text(
              '${c.archivedAt != null ? 'Archived · ' : ''}${c.color ?? ''}\n${c.termStart?.toString() ?? 'No start bound'} → ${c.termEnd?.toString() ?? 'No end bound'}',
            ),
            onTap: () => openCourse(ref, c.id),
          ),
      ],
    ),
  );
  Widget timetable(ScheduleSnapshot data, String zone) {
    final weekly = Theme.of(context).platform == TargetPlatform.windows;
    final first = weekly
        ? addDays(chosen!, 1 - dateValue(chosen!).weekday)
        : chosen!;
    final count = weekly ? 7 : 1;
    final from = resolveWall(dateValue(first), zone).instant;
    final until = resolveWall(dateValue(addDays(first, count)), zone).instant;
    final rows = generateOccurrences(data, from, until);
    final conflicts = <String>{
      for (final a in rows)
        if (rows.any((b) => overlaps(a, b))) a.identity,
    };
    Widget dayColumn(CalendarDate day) {
      final begin = resolveWall(dateValue(day), zone).instant;
      final end = resolveWall(dateValue(addDays(day, 1)), zone).instant;
      final meetings = rows
          .where((o) => o.end.isAfter(begin) && o.start.isBefore(end))
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateValue(day).weekday - 1]}\n$day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (meetings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(Space.md),
              child: Text('No activities.'),
            ),
          for (final o in meetings)
            Card(
              child: ListTile(
                key: ValueKey('meeting-${o.identity}-$day'),
                title: Text(o.series.title),
                subtitle: Text(
                  '${localInput(o.start, zone)} → ${localInput(o.end, zone)}\n${o.cancelled
                      ? 'Cancelled'
                      : o.series.busy
                      ? 'Busy'
                      : 'Free'}${o.moved ? ' · moved from ${o.originalDate}' : ''}${o.location.isEmpty ? '' : '\n${o.location}'}${o.series.courseId == null ? '' : '\n${data.courses.where((c) => c.id == o.series.courseId).firstOrNull?.name ?? 'Course'}'}${conflicts.contains(o.identity) ? '\nOverlap with another busy activity.' : ''}${o.adjustments.isEmpty ? '' : '\n${o.adjustments.join('\n')}'}',
                ),
                onTap: () => openActivity(ref, o.series.id, o.originalDate),
              ),
            ),
        ],
      );
    }

    return WorkspaceScroll(
      storageKey: 'timetable-library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            weekly ? 'Weekly timetable' : 'Daily timetable',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('Displayed in $zone. Activity time zones stay unchanged.'),
          Wrap(
            spacing: Space.sm,
            children: [
              IconButton(
                tooltip: 'Previous ${weekly ? 'week' : 'day'}',
                onPressed: () => changeDay(addDays(chosen!, -count)),
                icon: const Icon(Icons.chevron_left),
              ),
              TextButton(
                onPressed: () =>
                    changeDay(localDay(ref.read(clockProvider)(), zone)),
                child: const Text('Today'),
              ),
              IconButton(
                tooltip: 'Next ${weekly ? 'week' : 'day'}',
                onPressed: () => changeDay(addDays(chosen!, count)),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          TextField(
            key: const Key('timetable-date'),
            controller: dateInput,
            decoration: const InputDecoration(
              labelText: 'View date (YYYY-MM-DD)',
            ),
          ),
          TextButton(
            key: const Key('view-timetable-date'),
            onPressed: () {
              try {
                changeDay(CalendarDate.parse(dateInput.text.trim()));
              } catch (e) {
                setState(() => dateError = e);
              }
            },
            child: const Text('View date'),
          ),
          if (dateError != null) Text('Check the date: $dateError'),
          const SizedBox(height: Space.lg),
          if (weekly)
            LayoutBuilder(
              builder: (context, size) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(
                    size.maxWidth,
                    7 *
                        190 *
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
          else
            dayColumn(first),
          const SizedBox(height: Space.xl),
          ExpansionTile(
            key: const PageStorageKey('schedule-series-disclosure'),
            title: const Text('All series, including retained originals'),
            children: [
              if (data.series.isEmpty) const Text('No activities yet.'),
              for (final s in data.series)
                ListTile(
                  title: Text(s.title),
                  subtitle: Text(
                    s.supersededFrom == null
                        ? 'Current series'
                        : 'Replaced · original history retained',
                  ),
                  onTap: () => openActivity(ref, s.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
