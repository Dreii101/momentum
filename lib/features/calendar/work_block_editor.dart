import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/planning_repository.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../tasks/task_workflow.dart';
import 'calendar_projection.dart';

class WorkBlockEditor extends ConsumerStatefulWidget {
  const WorkBlockEditor({
    super.key,
    required this.data,
    required this.day,
    required this.zone,
    this.block,
    this.initialTask,
  });
  final PlanningSnapshot data;
  final CalendarDate day;
  final String zone;
  final PlannedWorkBlock? block;
  final String? initialTask;
  @override
  ConsumerState<WorkBlockEditor> createState() => _WorkBlockEditorState();
}

class _WorkBlockEditorState extends ConsumerState<WorkBlockEditor> {
  late final zone = TextEditingController(
    text: widget.block?.planningZone ?? widget.zone,
  );
  late final date = TextEditingController(
    text: widget.block == null
        ? widget.day.toString()
        : localDay(widget.block!.startUtc, zone.text).toString(),
  );
  late final time = TextEditingController(
    text: widget.block == null
        ? '09:00'
        : localInput(widget.block!.startUtc, zone.text).substring(11),
  );
  late final length = TextEditingController(
    text: widget.block == null
        ? '25'
        : widget.block!.endUtc
              .difference(widget.block!.startUtc)
              .inMinutes
              .toString(),
  );
  late String? taskId =
      widget.block?.taskId ??
      widget.initialTask ??
      widget.data.tasks
          .where(
            (t) =>
                t.deletedAt == null &&
                t.archivedAt == null &&
                t.status != TaskStatus.done,
          )
          .firstOrNull
          ?.id;
  late WorkBlockStatus status = widget.block?.status ?? WorkBlockStatus.planned;
  late bool locked = widget.block?.locked ?? false;
  bool busy = false, acknowledged = false;
  List<CalendarEntry> conflicts = [];
  Object? error;
  Future<void> Function()? retry;
  bool timeEdited = false;
  @override
  void dispose() {
    for (final c in [zone, date, time, length]) {
      c.dispose();
    }
    super.dispose();
  }

  void changed({bool temporal = false}) => setState(() {
    acknowledged = false;
    conflicts = [];
    if (temporal) timeEdited = true;
  });
  Future<void> command(Future<void> Function() action) async {
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

  Future<void> save() => command(() async {
    if (taskId == null) {
      throw const FormatException(
        'Choose a task, or capture one in Tasks first.',
      );
    }
    final minutes = int.tryParse(length.text.trim());
    if (minutes == null || minutes < 1 || minutes > 1440) {
      throw const FormatException('Choose a work length of 1–1440 minutes.');
    }
    final original = widget.block;
    final start = original != null && !timeEdited
        ? original.startUtc
        : parseWallTime(date.text, time.text, zone.text.trim());
    final end = original != null && !timeEdited
        ? original.endUtc
        : start.add(Duration(minutes: minutes));
    final repo = await ref.read(repositoryProvider.future);
    final latest = await repo.planningSnapshot();
    final warnings = status != WorkBlockStatus.planned
        ? <CalendarEntry>[]
        : workConflicts(
            latest,
            start,
            end,
            zone.text.trim(),
            excluding: original?.id,
          );
    if (warnings.isNotEmpty && !acknowledged) {
      if (mounted) setState(() => conflicts = warnings);
      return;
    }
    final row = await repo.saveWorkBlock(
      WorkBlockDraft(
        taskId: taskId!,
        startUtc: start,
        endUtc: end,
        planningZone: zone.text.trim(),
        status: status,
        locked: locked,
      ),
      id: original?.id,
    );
    if (mounted) {
      ref
          .read(shellNavigationProvider.notifier)
          .selectRecord(Destination.plan, 'work/${row.id}');
    }
  });
  Future<void> remove() => command(() async {
    await (await ref.read(repositoryProvider.future)).deleteWorkBlock(
      widget.block!.id,
      deleted: widget.block!.deletedAt == null,
    );
  });
  Widget field(String key, String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: Space.md),
    child: TextField(
      key: Key(key),
      controller: c,
      enabled: !busy,
      onChanged: (_) => changed(temporal: true),
      decoration: InputDecoration(labelText: label),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final source = widget.data.tasks.where((t) => t.id == taskId).firstOrNull;
    final deleted = block?.deletedAt != null;
    final unavailable = source?.deletedAt != null || source?.archivedAt != null;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (!deleted) save();
        },
      },
      child: WorkspaceScroll(
        storageKey: 'work-editor-${block?.id ?? 'new'}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              block == null ? 'Reserve work time' : 'Planned work',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text(
              'Reserve time deliberately. Moving work keeps the official deadline and internal target unchanged.',
            ),
            if (deleted)
              const Text(
                'Removed from the calendar. Restore keeps this original block.',
              ),
            if (unavailable)
              const Text(
                'The source task is in Trash or archived. Open it to restore before editing this plan.',
              ),
            if (error != null)
              ActionError(
                title: 'Work was not saved',
                message: error.toString(),
                onRetry: () => command(retry!),
              ),
            const SizedBox(height: Space.md),
            DropdownButtonFormField<String>(
              key: const Key('work-task'),
              initialValue: taskId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Task'),
              items: [
                for (final t in widget.data.tasks.where(
                  (t) =>
                      t.id == taskId ||
                      (t.deletedAt == null && t.archivedAt == null),
                ))
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(t.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: busy || deleted
                  ? null
                  : (v) {
                      taskId = v;
                      changed();
                    },
            ),
            const SizedBox(height: Space.md),
            if (!deleted) ...[
              field('work-date', 'Start date (YYYY-MM-DD)', date),
              field('work-time', 'Start time (HH:MM, 24-hour)', time),
              field('work-zone', 'Planning time zone (IANA)', zone),
              Wrap(
                spacing: Space.sm,
                children: [
                  for (final n in [25, 50, 90])
                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              length.text = '$n';
                              changed(temporal: true);
                            },
                      child: Text('$n minutes'),
                    ),
                ],
              ),
              field('work-length', 'Work length in minutes (1–1440)', length),
              const Text(
                'Length is elapsed time, including clock changes. For a repeated or skipped local start, choose an unambiguous time or use UTC.',
              ),
              const SizedBox(height: Space.md),
              DropdownButtonFormField<WorkBlockStatus>(
                key: const Key('work-status'),
                initialValue: status,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Plan status'),
                items: [
                  for (final s in WorkBlockStatus.values)
                    DropdownMenuItem(value: s, child: Text(s.name)),
                ],
                onChanged: busy
                    ? null
                    : (v) {
                        status = v!;
                        changed();
                      },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Manually locked'),
                subtitle: const Text(
                  'Keep this reservation fixed for future planning tools. You can still edit it deliberately.',
                ),
                value: locked,
                onChanged: busy
                    ? null
                    : (v) {
                        locked = v!;
                        changed();
                      },
              ),
              const Text(
                'Completed describes this plan only. It does not complete the task or record focus credit.',
              ),
              if (conflicts.isNotEmpty) ...[
                Text(
                  'Overlap warning: ${conflicts.map((e) => e.title).join(', ')}',
                ),
                CheckboxListTile(
                  key: const Key('work-accept-overlap'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Keep this overlap deliberately'),
                  value: acknowledged,
                  onChanged: busy
                      ? null
                      : (v) => setState(() => acknowledged = v!),
                ),
              ],
              FilledButton(
                key: const Key('save-work'),
                onPressed: busy || unavailable ? null : save,
                child: Text(busy ? 'Saving…' : 'Save work block'),
              ),
            ],
            if (source != null) ...[
              const SizedBox(height: Space.md),
              Text(deadlineLabel(source)),
              Text(
                'Remaining estimate: ${source.remainingMinutes?.toString() ?? 'not set'} minutes',
              ),
              Text(
                'Internal target: ${source.targetUtc == null ? 'not set' : localInput(source.targetUtc!, zone.text.trim().isEmpty ? widget.zone : (block?.planningZone ?? widget.zone))}',
              ),
              TextButton(
                key: const Key('work-open-task'),
                onPressed: () => ref
                    .read(shellNavigationProvider.notifier)
                    .selectRecord(Destination.tasks, source.id),
                child: const Text('Open task · estimate and internal target'),
              ),
            ],
            if (block != null)
              OutlinedButton(
                key: const Key('delete-work'),
                onPressed: busy ? null : remove,
                child: Text(
                  deleted ? 'Restore work block' : 'Remove work block',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
