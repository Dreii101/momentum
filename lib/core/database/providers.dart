import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';
import 'repository.dart';
import 'value_types.dart';

final clockProvider = Provider<Clock>((ref) => utcNow);
final idGeneratorProvider = Provider<IdGenerator>((ref) => newUuid);
final databaseFileProvider = Provider<Future<File> Function()>(
  (ref) => () async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'product'));
    await directory.create(recursive: true);
    return File(p.join(directory.path, 'momentum.sqlite'));
  },
);

class StorageOpenFailure implements Exception {
  const StorageOpenFailure(this.path, this.cause);
  final String? path;
  final Object cause;
  @override
  String toString() =>
      'Could not open Momentum storage'
      '${path == null ? '' : ' at $path'}: $cause';
}

/// Owns one background connection for the provider container's lifetime.
/// Explicit retry disposes the failed attempt; there is no destructive fallback.
final repositoryProvider = FutureProvider<MomentumRepository>((ref) async {
  final locate = ref.watch(databaseFileProvider);
  final clock = ref.watch(clockProvider);
  final ids = ref.watch(idGeneratorProvider);
  String? path;
  AppDatabase? database;
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    final opened = database;
    if (opened != null) unawaited(opened.close());
  });
  try {
    final file = await locate();
    path = file.path;
    if (disposed) throw StateError('Storage opening was cancelled.');
    final opened = database = AppDatabase.file(file);
    await opened.ensureOpen();
    final repository = MomentumRepository(opened, clock: clock, ids: ids);
    await repository.initialize();
    return repository;
  } catch (error) {
    final failed = database;
    database = null;
    if (failed != null && !disposed) await failed.close();
    throw StorageOpenFailure(path, error);
  }
}, retry: (count, error) => null);

/// Direct subscriptions cancel even when Riverpod pauses an off-screen query.
/// Avoid intermediate paused generators when a record loses its consumers.
Stream<T> repositoryStream<T>(
  Ref ref,
  Stream<T> Function(MomentumRepository) query,
) => ref
    .watch(repositoryProvider)
    .when(
      data: query,
      error: (error, stack) => Stream<T>.error(error, stack),
      loading: () => const Stream.empty(),
    );

final coursesProvider = StreamProvider<List<Course>>((ref) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchCourses();
});
final tasksProvider = StreamProvider<List<Task>>((ref) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchTasks();
});
final notesProvider = StreamProvider<List<Note>>((ref) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchNotes();
});
final subtasksProvider = StreamProvider.family<List<Subtask>, String>(
  (ref, id) => repositoryStream(ref, (repo) => repo.watchSubtasks(id)),
);
final noteLinksProvider = StreamProvider.family<List<NoteTaskLink>, String>((
  ref,
  id,
) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchLinksForNote(id);
});
final dailyPrioritiesProvider =
    StreamProvider.family<List<DailyPriority>, CalendarDate>((ref, day) async* {
      yield* (await ref.watch(repositoryProvider.future)).watchPriorities(day);
    });
final settingsProvider = StreamProvider<Settings>((ref) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchSettings();
});
final installationProvider = StreamProvider<InstallationMetadata>((ref) async* {
  yield* (await ref.watch(repositoryProvider.future)).watchInstallation();
});
