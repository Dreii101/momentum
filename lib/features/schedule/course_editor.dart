import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/repository.dart';
import '../../core/database/value_types.dart';
import '../tasks/task_workflow.dart';
import 'schedule_providers.dart';

class CourseEditor extends ConsumerStatefulWidget {
  const CourseEditor({super.key, this.course});
  final Course? course;
  @override
  ConsumerState<CourseEditor> createState() => _CourseEditorState();
}

class _CourseEditorState extends ConsumerState<CourseEditor> {
  late final name = TextEditingController(text: widget.course?.name ?? '');
  late final start = TextEditingController(
    text: widget.course?.termStart?.toString() ?? '',
  );
  late final end = TextEditingController(
    text: widget.course?.termEnd?.toString() ?? '',
  );
  late String? color = widget.course?.color;
  bool busy = false, saved = false;
  Object? error;
  Future<void> Function()? retry;
  @override
  void dispose() {
    name.dispose();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      saved = false;
      retry = save;
    });
    try {
      final draft = CourseDraft(
        name: name.text,
        color: color,
        termStart: start.text.trim().isEmpty
            ? null
            : CalendarDate.parse(start.text.trim()),
        termEnd: end.text.trim().isEmpty
            ? null
            : CalendarDate.parse(end.text.trim()),
      );
      final repo = await ref.read(repositoryProvider.future);
      final row = widget.course == null
          ? await repo.createCourse(draft)
          : await repo.updateCourse(widget.course!.id, draft);
      if (mounted) {
        setState(() => saved = true);
        if (widget.course == null) openCourse(ref, row.id);
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> archive() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      retry = archive;
    });
    try {
      await (await ref.read(repositoryProvider.future)).archiveCourse(
        widget.course!.id,
        archived: widget.course!.archivedAt == null,
      );
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.course;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): save,
      },
      child: WorkspaceScroll(
        storageKey: 'course-editor-${row?.id ?? 'new'}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              row == null ? 'New course' : 'Course details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (row?.archivedAt != null)
              const Text(
                'Archived · tasks, notes and scheduled meetings are retained.',
              ),
            if (error != null)
              ActionError(
                title: 'Could not save course',
                message: error.toString(),
                onRetry: () => retry!(),
              ),
            TextField(
              key: const Key('course-name'),
              controller: name,
              onChanged: (_) => setState(() => saved = false),
              enabled: !busy,
              decoration: const InputDecoration(labelText: 'Course name'),
            ),
            const SizedBox(height: Space.md),
            TextField(
              key: const Key('course-start'),
              controller: start,
              onChanged: (_) => setState(() => saved = false),
              enabled: !busy,
              decoration: const InputDecoration(
                labelText: 'Term start (optional, YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: Space.md),
            TextField(
              key: const Key('course-end'),
              controller: end,
              onChanged: (_) => setState(() => saved = false),
              enabled: !busy,
              decoration: const InputDecoration(
                labelText: 'Term end (optional, YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: Space.md),
            DropdownButtonFormField<String>(
              initialValue: color ?? '',
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Color label (optional)',
              ),
              items: [
                for (final c in {'', 'Teal', 'Blue', 'Purple', 'Amber', ?color})
                  DropdownMenuItem(
                    value: c,
                    child: Text(c.isEmpty ? 'No color label' : c),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() {
                      color = v == '' ? null : v;
                      saved = false;
                    }),
            ),
            const SizedBox(height: Space.lg),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                FilledButton(
                  key: const Key('save-course'),
                  onPressed: busy ? null : save,
                  child: Text(busy ? 'Saving…' : 'Save course'),
                ),
                if (row != null)
                  OutlinedButton(
                    key: const Key('archive-course'),
                    onPressed: busy ? null : archive,
                    child: Text(
                      row.archivedAt == null
                          ? 'Archive course'
                          : 'Unarchive course',
                    ),
                  ),
              ],
            ),
            if (saved) const Text('Course saved.'),
            if (row != null) ...[
              const SizedBox(height: Space.xl),
              const Text('Related tasks'),
              ref
                  .watch(taskRecordsProvider)
                  .when(
                    loading: () => const Text('Loading tasks…'),
                    error: (e, _) => Text('Could not load tasks: $e'),
                    data: (tasks) => Column(
                      children: [
                        if (!tasks.any((t) => t.courseId == row.id))
                          const Text('No tasks assigned.'),
                        for (final task in tasks.where(
                          (t) => t.courseId == row.id,
                        ))
                          ListTile(
                            title: Text(
                              task.title +
                                  (task.deletedAt != null ? ' (in Trash)' : ''),
                            ),
                            onTap: () => ref
                                .read(shellNavigationProvider.notifier)
                                .selectRecord(Destination.tasks, task.id),
                          ),
                      ],
                    ),
                  ),
              const Text('Related notes'),
              ref
                  .watch(scheduleNotesProvider)
                  .when(
                    loading: () => const Text('Loading notes…'),
                    error: (e, _) => Text('Could not load notes: $e'),
                    data: (notes) => Column(
                      children: [
                        if (!notes.any((n) => n.courseId == row.id))
                          const Text('No notes assigned.'),
                        for (final note in notes.where(
                          (n) => n.courseId == row.id,
                        ))
                          ListTile(
                            title: Text(
                              (note.title.isEmpty
                                      ? 'Untitled note'
                                      : note.title) +
                                  (note.deletedAt != null ? ' (in Trash)' : ''),
                            ),
                            onTap: () => ref
                                .read(shellNavigationProvider.notifier)
                                .selectRecord(Destination.notes, note.id),
                          ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
