import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/schedule_repository.dart';
import '../../core/database/value_types.dart';
import '../tasks/task_workflow.dart' show localInput;
import 'recurrence.dart';
import 'schedule_providers.dart';

class ActivityEditor extends ConsumerStatefulWidget {
  const ActivityEditor({
    super.key,
    required this.day,
    required this.zone,
    required this.data,
    this.replacing,
  });
  final CalendarDate day;
  final String zone;
  final ScheduleSnapshot data;
  final ActivitySeries? replacing;
  @override
  ConsumerState<ActivityEditor> createState() => _ActivityEditorState();
}

class _ActivityEditorState extends ConsumerState<ActivityEditor> {
  late final title = TextEditingController(text: widget.replacing?.title ?? '');
  late final start = TextEditingController(text: widget.day.toString());
  late final end = TextEditingController(
    text:
        widget.replacing?.endDate.toString() ??
        addDays(widget.day, 90).toString(),
  );
  late final startTime = TextEditingController(
    text: minuteLabel(widget.replacing?.startMinute ?? 540),
  );
  late final endTime = TextEditingController(
    text: minuteLabel(widget.replacing?.endMinute ?? 600),
  );
  late final zone = TextEditingController(
    text: widget.replacing?.zone ?? widget.zone,
  );
  late final location = TextEditingController(
    text: widget.replacing?.location ?? '',
  );
  late String recurrence = widget.replacing?.recurrence ?? 'weekly';
  late int weekdays =
      widget.replacing?.weekdays ?? (1 << (dateValue(widget.day).weekday - 1));
  late bool overnight = (widget.replacing?.endDayOffset ?? 0) == 1;
  late bool busyTime = widget.replacing?.busy ?? true;
  late String? courseId = widget.replacing?.courseId;
  bool saving = false, acceptOverlap = false;
  Object? error;
  ActivityDraft? reviewedDraft;
  SplitPreview? split;
  List<Occurrence> preview = [], conflicts = [];
  @override
  void dispose() {
    for (final c in [title, start, end, startTime, endTime, zone, location]) {
      c.dispose();
    }
    super.dispose();
  }

  ActivityDraft draft() => ActivityDraft(
    title: title.text,
    startDate: CalendarDate.parse(start.text.trim()),
    endDate: CalendarDate.parse(
      (recurrence == 'once' ? start : end).text.trim(),
    ),
    startMinute: parseMinute(startTime.text),
    endMinute: parseMinute(endTime.text),
    endDayOffset: overnight ? 1 : 0,
    zone: zone.text.trim(),
    location: location.text,
    recurrence: recurrence,
    weekdays: recurrence == 'once' ? 0 : weekdays,
    courseId: courseId,
    busy: busyTime,
  );

  Future<void> review() async {
    if (saving) return;
    setState(() {
      saving = true;
      error = null;
      reviewedDraft = null;
      split = null;
    });
    try {
      final d = draft();
      validateActivity(
        d,
        course: widget.data.courses
            .where((c) => c.id == d.courseId)
            .firstOrNull,
      );
      final repo = await ref.read(repositoryProvider.future);
      final data = await repo.scheduleSnapshot();
      final s = ActivitySeries(
        id: 'preview',
        createdAt: DateTime.utc(2000),
        updatedAt: DateTime.utc(2000),
        title: d.title,
        courseId: d.courseId,
        recurrence: d.recurrence,
        weekdays: d.weekdays,
        startDate: d.startDate,
        endDate: d.endDate,
        startMinute: d.startMinute,
        endMinute: d.endMinute,
        endDayOffset: d.endDayOffset,
        zone: d.zone,
        location: d.location,
        busy: d.busy,
      );
      final begin = resolveWall(dateValue(d.startDate), d.zone).instant;
      final until = resolveWall(
        dateValue(addDays(d.startDate, 14)),
        d.zone,
      ).instant;
      final proposed = generateOccurrences(
        ScheduleSnapshot([s], [], []),
        begin,
        until,
      );
      final existing = generateOccurrences(data, begin, until).where(
        (o) =>
            widget.replacing == null ||
            o.series.id != widget.replacing!.id ||
            o.originalDate.compareTo(widget.day) < 0,
      );
      final overlapping = existing
          .where((o) => proposed.any((p) => overlaps(o, p)))
          .toList();
      final replacement = widget.replacing == null
          ? null
          : await repo.previewSplit(widget.replacing!.id, widget.day);
      if (mounted) {
        setState(() {
          reviewedDraft = d;
          preview = proposed;
          conflicts = overlapping;
          split = replacement;
          acceptOverlap = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> save() async {
    if (saving ||
        reviewedDraft == null ||
        (conflicts.isNotEmpty && !acceptOverlap)) {
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final repo = await ref.read(repositoryProvider.future);
      final row = split == null
          ? await repo.createActivity(reviewedDraft!)
          : await repo.replaceFuture(split!, reviewedDraft!);
      if (mounted) openActivity(ref, row.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e;
          reviewedDraft = null;
        });
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void changed() => setState(() {
    reviewedDraft = null;
    split = null;
  });
  Widget input(
    String key,
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: Space.md),
    child: TextField(
      key: Key(key),
      controller: controller,
      enabled: enabled && !saving,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => changed(),
    ),
  );
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
          reviewedDraft == null ? review() : save(),
    },
    child: WorkspaceScroll(
      storageKey: 'activity-editor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.replacing == null
                ? 'New activity'
                : 'Replace this and future',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.replacing != null)
            Text(
              'Original dates from ${widget.day} will use a new series. Past dates stay intact. Review retained links before confirming.',
            ),
          if (error != null)
            ActionError(
              title: 'Activity was not saved',
              message: error.toString(),
              onRetry: review,
            ),
          input('activity-title', 'Activity title', title),
          DropdownButtonFormField<String>(
            initialValue: courseId ?? '',
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Course (optional)'),
            items: [
              const DropdownMenuItem(value: '', child: Text('No course')),
              for (final c in widget.data.courses.where(
                (c) => c.deletedAt == null || c.id == courseId,
              ))
                DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.name + (c.archivedAt != null ? ' (archived)' : ''),
                  ),
                ),
            ],
            onChanged: saving
                ? null
                : (v) {
                    courseId = v == '' ? null : v;
                    changed();
                  },
          ),
          const SizedBox(height: Space.md),
          DropdownButtonFormField<String>(
            key: const Key('activity-recurrence'),
            initialValue: recurrence,
            decoration: const InputDecoration(labelText: 'Repeat'),
            items: const [
              DropdownMenuItem(value: 'once', child: Text('One-off')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            ],
            onChanged: saving
                ? null
                : (v) {
                    recurrence = v!;
                    changed();
                  },
          ),
          if (recurrence == 'weekly')
            Wrap(
              spacing: 4,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    key: Key('weekday-${i + 1}'),
                    label: Text(
                      const [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ][i],
                    ),
                    selected: weekdays & (1 << i) != 0,
                    onSelected: saving
                        ? null
                        : (v) {
                            weekdays = v
                                ? weekdays | (1 << i)
                                : weekdays & ~(1 << i);
                            changed();
                          },
                  ),
              ],
            ),
          input(
            'activity-start',
            'First date (YYYY-MM-DD)',
            start,
            enabled: widget.replacing == null,
          ),
          if (recurrence == 'weekly')
            input('activity-end', 'Last date (inclusive, YYYY-MM-DD)', end),
          input('activity-start-time', 'Starts (HH:MM)', startTime),
          input('activity-end-time', 'Ends (HH:MM)', endTime),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ends the next day'),
            value: overnight,
            onChanged: saving
                ? null
                : (v) {
                    overnight = v!;
                    changed();
                  },
          ),
          input(
            'activity-zone',
            'Time zone (IANA, for example Asia/Manila)',
            zone,
          ),
          input('activity-location', 'Location (optional)', location),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(busyTime ? 'Busy commitment' : 'Free / informational'),
            value: busyTime,
            onChanged: saving
                ? null
                : (v) {
                    busyTime = v;
                    changed();
                  },
          ),
          const Text(
            'Clock gaps move the meeting forward by the gap. Repeated times use their first occurrence. Adjustments are shown in the timetable.',
          ),
          const SizedBox(height: Space.md),
          OutlinedButton(
            key: const Key('preview-activity'),
            onPressed: saving ? null : review,
            child: const Text('Preview activity'),
          ),
          if (reviewedDraft != null) ...[
            const Text(
              'Preview of the first 14 days. Later meetings are checked for overlap when viewed in the timetable.',
            ),
            for (final o in preview)
              Text(
                '${o.originalDate} · ${localInput(o.start, o.zone)} → ${localInput(o.end, o.zone)} · ${o.zone}${o.adjustments.isEmpty ? '' : '\n${o.adjustments.join('\n')}'}',
              ),
            if (conflicts.isNotEmpty) ...[
              Text(
                'Overlaps with: ${conflicts.map((o) => '${o.series.title} (${o.originalDate})').join(', ')}',
              ),
              CheckboxListTile(
                key: const Key('accept-overlap'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Keep this overlap deliberately'),
                value: acceptOverlap,
                onChanged: saving
                    ? null
                    : (v) => setState(() => acceptOverlap = v!),
              ),
            ],
            if (split != null) ...[
              Text(
                'Retain ${split!.exceptions.length} future exception(s) and ${split!.links.length} note link(s) on the original series. Nothing is reassigned.',
              ),
              for (final e in split!.exceptions)
                Text(
                  'Original ${e.originalDate}${e.cancelled ? ' · cancelled' : ''}${e.movedDate == null ? '' : ' · moved to ${e.movedDate}'}',
                ),
              ref
                  .watch(scheduleNotesProvider)
                  .when(
                    loading: () => const Text('Loading note names…'),
                    error: (e, _) => Text(
                      'Note names unavailable. Retained link IDs: ${split!.links.map((l) => l.noteId).join(', ')}',
                    ),
                    data: (notes) => Column(
                      children: [
                        for (final l in split!.links)
                          Text(
                            '${notes.where((n) => n.id == l.noteId).firstOrNull?.title ?? 'Note ${l.noteId}'} · ${l.originalDate?.toString() ?? 'whole original series'}',
                          ),
                      ],
                    ),
                  ),
            ],
            FilledButton(
              key: const Key('save-activity'),
              onPressed: saving || (conflicts.isNotEmpty && !acceptOverlap)
                  ? null
                  : save,
              child: Text(
                split == null
                    ? 'Save activity'
                    : 'Replace future schedule; retain links',
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
