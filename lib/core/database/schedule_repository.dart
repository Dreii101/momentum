import 'package:drift/drift.dart';

import '../../features/schedule/recurrence.dart';
import 'app_database.dart';
import 'repository.dart';
import 'value_types.dart';

class SplitPreview {
  const SplitPreview(
    this.seriesId,
    this.from,
    this.revision,
    this.exceptions,
    this.links,
  );
  final String seriesId, revision;
  final CalendarDate from;
  final List<ActivityException> exceptions;
  final List<NoteActivityLink> links;
}

extension ScheduleRepository on MomentumRepository {
  Future<ActivitySeries> activity(String id) => (database.select(
    database.activitySeriesRows,
  )..where((t) => t.id.equals(id))).getSingle();
  Future<ActivityException?> activityException(String id, CalendarDate date) =>
      (database.select(database.activityExceptions)..where(
            (t) => t.seriesId.equals(id) & t.originalDate.equalsValue(date),
          ))
          .getSingleOrNull();

  Future<ScheduleSnapshot> scheduleSnapshot() => database.transaction(
    () async => ScheduleSnapshot(
      await database.select(database.activitySeriesRows).get(),
      await database.select(database.activityExceptions).get(),
      await database.select(database.courses).get(),
    ),
  );

  Stream<ScheduleSnapshot> watchSchedule() => database
      .customSelect(
        'SELECT 1',
        readsFrom: {
          database.activitySeriesRows,
          database.activityExceptions,
          database.courses,
        },
      )
      .watch()
      .asyncMap((_) => scheduleSnapshot());

  Future<ActivitySeries> createActivity(ActivityDraft draft) =>
      database.transaction(() async {
        final linkedCourse = draft.courseId == null
            ? null
            : await course(draft.courseId!);
        if (linkedCourse?.deletedAt != null) {
          throw StateError('Restore the course before adding an activity.');
        }
        validateActivity(draft, course: linkedCourse);
        final id = ids(), now = clock().toUtc();
        await database
            .into(database.activitySeriesRows)
            .insert(
              ActivitySeriesRowsCompanion.insert(
                id: id,
                title: draft.title.trim(),
                courseId: Value(draft.courseId),
                recurrence: draft.recurrence,
                weekdays: draft.weekdays,
                startDate: draft.startDate,
                endDate: draft.endDate,
                startMinute: draft.startMinute,
                endMinute: draft.endMinute,
                endDayOffset: draft.endDayOffset,
                zone: draft.zone,
                location: Value(draft.location),
                busy: Value(draft.busy),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return activity(id);
      });

  Future<Occurrence> occurrence(String seriesId, CalendarDate original) async =>
      occurrenceFor(
        await activity(seriesId),
        original,
        await activityException(seriesId, original),
      );

  Future<void> changeOccurrence(
    String id,
    CalendarDate original, {
    OccurrenceMove? move,
    bool? cancelled,
    bool reset = false,
  }) => database.transaction(() async {
    final series = await activity(id);
    final previous = await activityException(id, original);
    final current = occurrenceFor(series, original, previous);
    if (current.superseded || series.deletedAt != null) {
      throw StateError(
        'This retained occurrence is superseded. Its history and links are read-only.',
      );
    }
    if (reset) {
      await (database.delete(database.activityExceptions)..where(
            (t) => t.seriesId.equals(id) & t.originalDate.equalsValue(original),
          ))
          .go();
      return;
    }
    if (move != null) {
      resolveInterval(
        move.date,
        move.startMinute,
        move.endMinute,
        move.endDayOffset,
        move.zone,
      );
    }
    final now = clock().toUtc();
    await database
        .into(database.activityExceptions)
        .insertOnConflictUpdate(
          ActivityExceptionsCompanion.insert(
            id: previous?.id ?? ids(),
            seriesId: id,
            originalDate: original,
            cancelled: Value(cancelled ?? previous?.cancelled ?? false),
            movedDate: Value(move?.date ?? previous?.movedDate),
            startMinute: Value(move?.startMinute ?? previous?.startMinute),
            endMinute: Value(move?.endMinute ?? previous?.endMinute),
            endDayOffset: Value(move?.endDayOffset ?? previous?.endDayOffset),
            zone: Value(move?.zone ?? previous?.zone),
            location: Value(move?.location ?? previous?.location),
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
          ),
        );
  });

  Future<SplitPreview> previewSplit(String id, CalendarDate from) =>
      database.transaction(() async {
        final series = await activity(id);
        final original = occurrenceFor(series, from);
        if (series.supersededFrom != null ||
            series.deletedAt != null ||
            !original.start.isAfter(clock().toUtc())) {
          throw StateError(
            'Choose an upcoming original occurrence in the current series. Past meetings are preserved.',
          );
        }
        final exceptions =
            await (database.select(database.activityExceptions)
                  ..where((t) => t.seriesId.equals(id))
                  ..orderBy([(t) => OrderingTerm.asc(t.id)]))
                .get();
        final links =
            await (database.select(database.noteActivityLinks)
                  ..where((t) => t.seriesId.equals(id))
                  ..orderBy([(t) => OrderingTerm.asc(t.id)]))
                .get();
        return SplitPreview(
          id,
          from,
          [
            series.toString(),
            ...exceptions.map((e) => e.toString()),
            ...links.map((l) => l.toString()),
          ].join('\n'),
          exceptions.where((e) => e.originalDate.compareTo(from) >= 0).toList(),
          links
              .where(
                (l) =>
                    l.originalDate == null ||
                    l.originalDate!.compareTo(from) >= 0,
              )
              .toList(),
        );
      });

  Future<ActivitySeries> replaceFuture(
    SplitPreview accepted,
    ActivityDraft replacement,
  ) => database.transaction(() async {
    final current = await previewSplit(accepted.seriesId, accepted.from);
    if (current.revision != accepted.revision) {
      throw StateError(
        'This preview is stale. Review the current future exceptions and note links again.',
      );
    }
    if (replacement.startDate != accepted.from) {
      throw const FormatException(
        'The replacement must start on the chosen original date.',
      );
    }
    final previous = await activity(accepted.seriesId);
    if (current.exceptions.any(
      (e) =>
          !e.cancelled &&
          !occurrenceFor(
            previous,
            e.originalDate,
            e,
          ).start.isAfter(clock().toUtc()),
    )) {
      throw StateError(
        'An affected rescheduled meeting has already started. Choose a later original split date to preserve past meetings.',
      );
    }
    final next = await createActivity(replacement);
    // A replacement for today must not introduce already-ended/started meetings.
    for (var i = 0; i < 7; i++) {
      final day = addDays(next.startDate, i);
      if (isOriginalDate(next, day)) {
        if (!occurrenceFor(next, day).start.isAfter(clock().toUtc())) {
          throw StateError('The replacement must begin in the future.');
        }
        break;
      }
    }
    await (database.update(
      database.activitySeriesRows,
    )..where((t) => t.id.equals(accepted.seriesId))).write(
      ActivitySeriesRowsCompanion(
        supersededFrom: Value(accepted.from),
        replacedBy: Value(next.id),
        updatedAt: Value(clock().toUtc()),
      ),
    );
    return next;
  });

  Stream<List<NoteActivityLink>> watchActivityLinks({
    String? noteId,
    String? seriesId,
  }) {
    final query = database.select(database.noteActivityLinks)
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (noteId != null) query.where((t) => t.noteId.equals(noteId));
    if (seriesId != null) query.where((t) => t.seriesId.equals(seriesId));
    return query.watch();
  }

  Future<void> setActivityLink(
    String noteId,
    String seriesId,
    CalendarDate? original, {
    required bool linked,
  }) => database.transaction(() async {
    final query = database.select(database.noteActivityLinks)
      ..where(
        (t) =>
            t.noteId.equals(noteId) &
            t.seriesId.equals(seriesId) &
            (original == null
                ? t.originalDate.isNull()
                : t.originalDate.equalsValue(original)),
      );
    final existing = await query.getSingleOrNull();
    if (!linked) {
      if (existing != null) {
        await (database.delete(
          database.noteActivityLinks,
        )..where((t) => t.id.equals(existing.id))).go();
      }
      return;
    }
    final series = await activity(seriesId);
    if (original != null) occurrenceFor(series, original);
    if ((await note(noteId)).deletedAt != null || series.deletedAt != null) {
      throw StateError('Restore the note and activity before adding a link.');
    }
    if (existing != null) return;
    await database
        .into(database.noteActivityLinks)
        .insert(
          NoteActivityLinksCompanion.insert(
            id: ids(),
            noteId: noteId,
            seriesId: seriesId,
            originalDate: Value(original),
            createdAt: clock().toUtc(),
          ),
        );
  });
}
