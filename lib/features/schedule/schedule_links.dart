import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/navigation.dart';
import '../../core/database/providers.dart';
import '../../core/database/schedule_repository.dart';
import '../../core/database/value_types.dart';
import '../notes/note_providers.dart';
import 'schedule_providers.dart';

class ActivityNoteLinks extends ConsumerStatefulWidget {
  const ActivityNoteLinks({super.key, required this.seriesId, this.original});
  final String seriesId;
  final CalendarDate? original;
  @override
  ConsumerState<ActivityNoteLinks> createState() => _ActivityNoteLinksState();
}

class _ActivityNoteLinksState extends ConsumerState<ActivityNoteLinks> {
  String? noteId;
  bool selecting = false, wholeSeries = false, busy = false;
  Object? error;
  Future<void> Function()? retry;
  String linkedTitle(String id) {
    final note = ref
        .read(scheduleNotesProvider)
        .value
        ?.where((n) => n.id == id)
        .firstOrNull;
    return note == null ? 'Open linked note' : noteTitle(note);
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
    final links = ref.watch(activityLinksProvider(widget.seriesId));
    final notes = ref.watch(scheduleNotesProvider);
    return SectionCard(
      title: 'Linked notes',
      description:
          'Open the original note. Links survive moving or replacing meetings.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          links.when(
            loading: () => const Text('Loading links…'),
            error: (e, _) => ActionError(
              title: 'Could not load links',
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(activityLinksProvider(widget.seriesId)),
            ),
            data: (rows) => Column(
              children: [
                for (final link in rows.where(
                  (l) =>
                      widget.original == null ||
                      l.originalDate == null ||
                      l.originalDate == widget.original,
                ))
                  ListTile(
                    key: ValueKey('activity-note-${link.id}'),
                    title: Text(linkedTitle(link.noteId)),
                    subtitle: Text(
                      link.originalDate == null
                          ? 'Whole series'
                          : 'Original meeting ${link.originalDate}',
                    ),
                    onTap: () => ref
                        .read(shellNavigationProvider.notifier)
                        .selectRecord(Destination.notes, link.noteId),
                    trailing: IconButton(
                      tooltip: 'Unlink note',
                      icon: const Icon(Icons.link_off),
                      onPressed: busy
                          ? null
                          : () => run(
                              () async =>
                                  (await ref.read(repositoryProvider.future))
                                      .setActivityLink(
                                        link.noteId,
                                        widget.seriesId,
                                        link.originalDate,
                                        linked: false,
                                      ),
                            ),
                    ),
                  ),
                if (rows.isEmpty) const Text('No notes linked yet.'),
              ],
            ),
          ),
          if (error != null)
            ActionError(
              title: 'Could not change link',
              message: error.toString(),
              onRetry: () => run(retry!),
            ),
          OutlinedButton(
            onPressed: () => setState(() => selecting = !selecting),
            child: Text(
              selecting ? 'Close note selector' : 'Link an existing note',
            ),
          ),
          if (selecting) ...[
            if (widget.original != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  wholeSeries
                      ? 'Link to the whole series'
                      : 'Link to this original occurrence',
                ),
                value: wholeSeries,
                onChanged: busy ? null : (v) => setState(() => wholeSeries = v),
              ),
            notes.when(
              loading: () => const Text('Loading notes…'),
              error: (e, _) => ActionError(
                title: 'Could not load notes',
                message: e.toString(),
                onRetry: () => ref.invalidate(scheduleNotesProvider),
              ),
              data: (rows) => DropdownButtonFormField<String>(
                key: const Key('schedule-link-note'),
                initialValue: noteId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Choose a note'),
                items: [
                  for (final n in rows.where(
                    (n) => n.deletedAt == null || n.id == noteId,
                  ))
                    DropdownMenuItem(value: n.id, child: Text(noteTitle(n))),
                ],
                onChanged: busy ? null : (v) => setState(() => noteId = v),
              ),
            ),
            FilledButton(
              key: const Key('save-schedule-link'),
              onPressed: busy || noteId == null
                  ? null
                  : () => run(
                      () async => (await ref.read(repositoryProvider.future))
                          .setActivityLink(
                            noteId!,
                            widget.seriesId,
                            wholeSeries ? null : widget.original,
                            linked: true,
                          ),
                    ),
              child: const Text('Link note'),
            ),
          ],
        ],
      ),
    );
  }
}

class NoteScheduleLinks extends ConsumerStatefulWidget {
  const NoteScheduleLinks({super.key, required this.noteId});
  final String noteId;
  @override
  ConsumerState<NoteScheduleLinks> createState() => _NoteScheduleLinksState();
}

class _NoteScheduleLinksState extends ConsumerState<NoteScheduleLinks> {
  Object? error;
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(scheduleProvider);
    return SectionCard(
      title: 'Linked activities',
      description:
          'Series and original meeting links open their retained schedule.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ref
              .watch(noteScheduleLinksProvider(widget.noteId))
              .when(
                loading: () => const Text('Loading activity links…'),
                error: (e, _) => ActionError(
                  title: 'Could not load activity links',
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(noteScheduleLinksProvider(widget.noteId)),
                ),
                data: (links) => Column(
                  children: [
                    if (links.isEmpty)
                      const Text(
                        'No activity links yet. Choose an activity in Plan to link this note.',
                      ),
                    for (final link in links)
                      ListTile(
                        key: ValueKey('note-activity-${link.id}'),
                        title: Text(
                          data.value?.series
                                  .where((s) => s.id == link.seriesId)
                                  .firstOrNull
                                  ?.title ??
                              'Open linked activity',
                        ),
                        subtitle: Text(
                          link.originalDate == null
                              ? 'Whole original series'
                              : 'Original meeting ${link.originalDate}',
                        ),
                        onTap: () =>
                            openActivity(ref, link.seriesId, link.originalDate),
                        trailing: IconButton(
                          tooltip: 'Unlink activity',
                          icon: const Icon(Icons.link_off),
                          onPressed: busy
                              ? null
                              : () async {
                                  setState(() {
                                    busy = true;
                                    error = null;
                                  });
                                  try {
                                    await (await ref.read(
                                      repositoryProvider.future,
                                    )).setActivityLink(
                                      widget.noteId,
                                      link.seriesId,
                                      link.originalDate,
                                      linked: false,
                                    );
                                  } catch (e) {
                                    if (mounted) setState(() => error = e);
                                  } finally {
                                    if (mounted) setState(() => busy = false);
                                  }
                                },
                        ),
                      ),
                  ],
                ),
              ),
          if (error != null)
            Text('Could not unlink. Try the unlink control again. $error'),
          TextButton(
            onPressed: () =>
                ref.read(shellNavigationProvider.notifier).go(Destination.plan),
            child: const Text('Open Plan'),
          ),
        ],
      ),
    );
  }
}
