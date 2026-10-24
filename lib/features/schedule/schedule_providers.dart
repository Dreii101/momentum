import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/schedule_repository.dart';
import '../../core/database/value_types.dart';
import 'recurrence.dart';

final scheduleProvider = StreamProvider<ScheduleSnapshot>(
  (ref) => repositoryStream(ref, (r) => r.watchSchedule()),
  retry: (count, error) => null,
);
final activityLinksProvider = StreamProvider.autoDispose
    .family<List<NoteActivityLink>, String>(
      (ref, id) =>
          repositoryStream(ref, (r) => r.watchActivityLinks(seriesId: id)),
      retry: (count, error) => null,
    );
final noteScheduleLinksProvider = StreamProvider.autoDispose
    .family<List<NoteActivityLink>, String>(
      (ref, id) =>
          repositoryStream(ref, (r) => r.watchActivityLinks(noteId: id)),
      retry: (count, error) => null,
    );
final scheduleNotesProvider = StreamProvider<List<Note>>(
  (ref) => repositoryStream(ref, (r) => r.watchNotes(includeDeleted: true)),
  retry: (count, error) => null,
);
void openActivity(WidgetRef ref, String id, [CalendarDate? date]) => ref
    .read(shellNavigationProvider.notifier)
    .selectRecord(
      Destination.plan,
      date == null ? 'activity/$id' : 'occurrence/$id/$date',
    );
void openCourse(WidgetRef ref, String id) => ref
    .read(shellNavigationProvider.notifier)
    .selectRecord(Destination.plan, 'course/$id');
