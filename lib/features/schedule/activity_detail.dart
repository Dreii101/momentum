import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/schedule_repository.dart';
import '../../core/database/value_types.dart';
import '../tasks/task_workflow.dart';
import 'recurrence.dart';
import 'schedule_links.dart';
import 'schedule_providers.dart';

class ActivityDetail extends ConsumerStatefulWidget {
  const ActivityDetail({
    super.key,
    required this.series,
    required this.data,
    this.original,
  });
  final ActivitySeries series;
  final ScheduleSnapshot data;
  final CalendarDate? original;
  @override
  ConsumerState<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends ConsumerState<ActivityDetail> {
  final date = TextEditingController(),
      start = TextEditingController(),
      end = TextEditingController(),
      zone = TextEditingController(),
      location = TextEditingController();
  final lookup = TextEditingController();
  bool moving = false, overnight = false, busy = false;
  bool acceptOverlap = false;
  List<String> moveConflicts = [];
  Object? error;
  Future<void> Function()? retry;
  @override
  void dispose() {
    for (final c in [date, start, end, zone, location, lookup]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retry = action;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.series;
    Occurrence? o;
    try {
      if (widget.original != null) {
        o = widget.data.occurrence(s.id, widget.original!);
      }
    } catch (e) {
      return WorkspaceScroll(child: Text('Cannot open occurrence: $e'));
    }
    final occurrence = o;
    final course = widget.data.courses
        .where((c) => c.id == s.courseId)
        .firstOrNull;
    final canChange =
        occurrence != null && !occurrence.superseded && s.deletedAt == null;
    return WorkspaceScroll(
      storageKey: 'activity-detail-${s.id}${widget.original?.toString() ?? ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.title, style: Theme.of(context).textTheme.headlineSmall),
          Text(s.recurrence == 'once' ? 'One-off activity' : 'Weekly series'),
          Text('${s.startDate} through ${s.endDate} · ${s.zone}'),
          Text(
            '${minuteLabel(s.startMinute)}–${minuteLabel(s.endMinute)}${s.endDayOffset == 1 ? ' (+1 day)' : ''} · ${s.busy ? 'Busy' : 'Free'}',
          ),
          if (s.location.isNotEmpty) Text(s.location),
          if (course != null)
            TextButton(
              onPressed: () => openCourse(ref, course.id),
              child: Text(
                'Course: ${course.name}${course.archivedAt == null ? '' : ' (archived)'}',
              ),
            ),
          if (s.supersededFrom != null) ...[
            Text(
              'Replaced from original date ${s.supersededFrom}. Original records and notes remain accessible here.',
            ),
            TextButton(
              onPressed: () => openActivity(ref, s.replacedBy!),
              child: const Text('Open replacement series'),
            ),
          ],
          if (occurrence == null) ...[
            const SizedBox(height: Space.md),
            TextField(
              key: const Key('occurrence-lookup'),
              controller: lookup,
              decoration: const InputDecoration(
                labelText: 'Open original meeting date (YYYY-MM-DD)',
              ),
            ),
            OutlinedButton(
              onPressed: () => run(() async {
                final original = CalendarDate.parse(lookup.text.trim());
                occurrenceFor(s, original);
                openActivity(ref, s.id, original);
              }),
              child: const Text('Open occurrence'),
            ),
            const Text(
              'Use the timetable or enter an original date to change one meeting or replace this and future.',
            ),
          ] else ...[
            const SizedBox(height: Space.lg),
            Text('Original meeting: ${occurrence.originalDate}'),
            Text(
              '${localInput(occurrence.start, occurrence.zone)} → ${localInput(occurrence.end, occurrence.zone)} · ${occurrence.zone}',
            ),
            Text(occurrence.location),
            if (occurrence.cancelled)
              const Text('Cancelled · excluded from busy time.'),
            if (occurrence.moved)
              const Text('Rescheduled · original identity and notes retained.'),
            if (occurrence.superseded)
              const Text(
                'Retained superseded occurrence · excluded from the current timetable.',
              ),
            for (final adjustment in occurrence.adjustments) Text(adjustment),
            if (canChange) ...[
              const Text(
                'These controls affect this original occurrence only. Other dates and note links stay intact.',
              ),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  OutlinedButton(
                    key: const Key('cancel-occurrence'),
                    onPressed: busy
                        ? null
                        : () => run(() async {
                            await (await ref.read(repositoryProvider.future))
                                .changeOccurrence(
                                  s.id,
                                  occurrence.originalDate,
                                  cancelled: !occurrence.cancelled,
                                );
                          }),
                    child: Text(
                      occurrence.cancelled
                          ? 'Restore this occurrence'
                          : 'Cancel this occurrence',
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('move-occurrence'),
                    onPressed: busy
                        ? null
                        : () {
                            if (!moving) {
                              final current = localInput(
                                occurrence.start,
                                occurrence.zone,
                              );
                              date.text = current.substring(0, 10);
                              start.text = current.substring(11);
                              end.text = localInput(
                                occurrence.end,
                                occurrence.zone,
                              ).substring(11);
                              zone.text = occurrence.zone;
                              location.text = occurrence.location;
                              overnight =
                                  localDay(occurrence.start, occurrence.zone) !=
                                  localDay(occurrence.end, occurrence.zone);
                            }
                            setState(() => moving = !moving);
                          },
                    child: Text(
                      moving
                          ? 'Close reschedule editor'
                          : 'Reschedule this occurrence',
                    ),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => run(
                            () async =>
                                (await ref.read(repositoryProvider.future))
                                    .changeOccurrence(
                                      s.id,
                                      occurrence.originalDate,
                                      reset: true,
                                    ),
                          ),
                    child: const Text(
                      'Restore original time and cancellation state',
                    ),
                  ),
                ],
              ),
              if (moving) ...[
                for (final field in [
                  (date, 'Moved date (YYYY-MM-DD)', 'move-date'),
                  (start, 'Starts (HH:MM)', 'move-start'),
                  (end, 'Ends (HH:MM)', 'move-end'),
                  (zone, 'Time zone', 'move-zone'),
                  (location, 'Location', 'move-location'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(top: Space.md),
                    child: TextField(
                      key: Key(field.$3),
                      controller: field.$1,
                      enabled: !busy,
                      onChanged: (_) => setState(() {
                        acceptOverlap = false;
                        moveConflicts = [];
                      }),
                      decoration: InputDecoration(labelText: field.$2),
                    ),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ends next day'),
                  value: overnight,
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          overnight = v!;
                          acceptOverlap = false;
                          moveConflicts = [];
                        }),
                ),
                if (moveConflicts.isNotEmpty) ...[
                  Text('Overlaps with: ${moveConflicts.join(', ')}'),
                  CheckboxListTile(
                    key: const Key('accept-move-overlap'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Keep this overlap deliberately'),
                    value: acceptOverlap,
                    onChanged: busy
                        ? null
                        : (v) => setState(() => acceptOverlap = v!),
                  ),
                ],
                FilledButton(
                  key: const Key('save-occurrence-move'),
                  onPressed: busy
                      ? null
                      : () => run(() async {
                          final move = OccurrenceMove(
                            date: CalendarDate.parse(date.text.trim()),
                            startMinute: parseMinute(start.text),
                            endMinute: parseMinute(end.text),
                            endDayOffset: overnight ? 1 : 0,
                            zone: zone.text.trim(),
                            location: location.text,
                          );
                          final repo = await ref.read(
                            repositoryProvider.future,
                          );
                          final interval = resolveInterval(
                            move.date,
                            move.startMinute,
                            move.endMinute,
                            move.endDayOffset,
                            move.zone,
                          );
                          final data = await repo.scheduleSnapshot();
                          final conflicts =
                              generateOccurrences(
                                    data,
                                    interval.start.subtract(
                                      const Duration(days: 1),
                                    ),
                                    interval.end.add(const Duration(days: 1)),
                                  )
                                  .where(
                                    (other) =>
                                        other.identity != occurrence.identity &&
                                        !other.cancelled &&
                                        other.series.busy &&
                                        s.busy &&
                                        other.start.isBefore(interval.end) &&
                                        other.end.isAfter(interval.start),
                                  )
                                  .map((other) => other.series.title)
                                  .toList();
                          if (conflicts.isNotEmpty && !acceptOverlap) {
                            if (mounted) {
                              setState(() => moveConflicts = conflicts);
                            }
                            return;
                          }
                          await repo.changeOccurrence(
                            s.id,
                            occurrence.originalDate,
                            move: move,
                            cancelled: false,
                          );
                          if (mounted) setState(() => moving = false);
                        }),
                  child: const Text('Save this occurrence'),
                ),
                const Text(
                  'Any busy overlap is shown before saving. You can deliberately keep it.',
                ),
              ],
              if (s.supersededFrom == null &&
                  occurrenceFor(
                    s,
                    occurrence.originalDate,
                  ).start.isAfter(ref.read(clockProvider)()))
                OutlinedButton(
                  key: const Key('replace-future'),
                  onPressed: busy
                      ? null
                      : () => ref
                            .read(shellNavigationProvider.notifier)
                            .selectRecord(
                              Destination.plan,
                              'replace/${s.id}/${occurrence.originalDate}',
                            ),
                  child: const Text('Change this and future…'),
                ),
            ],
          ],
          if (error != null)
            ActionError(
              title: 'Activity action did not finish',
              message: error.toString(),
              onRetry: () => run(retry!),
            ),
          const SizedBox(height: Space.xl),
          ActivityNoteLinks(seriesId: s.id, original: widget.original),
        ],
      ),
    );
  }
}
