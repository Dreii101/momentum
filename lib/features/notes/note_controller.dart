import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository.dart';

enum NoteSaveState { unsaved, saving, saved, failed }

/// One transient buffer and one serialized writer per note. No extra disk store.
class NoteController extends ChangeNotifier {
  NoteController(
    Note note,
    this.repository, {
    this.debounce = const Duration(milliseconds: 500),
  }) : id = note.id,
       lastPersisted = note,
       title = TextEditingController(text: note.title),
       body = TextEditingController(text: note.body),
       courseId = note.courseId,
       pinned = note.pinned,
       trashed = note.deletedAt != null,
       _lastTitle = note.title,
       _lastBody = note.body {
    title.addListener(_textChanged);
    body.addListener(_textChanged);
  }
  final String id;
  Note lastPersisted;
  final Future<MomentumRepository> Function() repository;
  final Duration debounce;
  final TextEditingController title, body;
  String? courseId;
  bool pinned, trashed;
  String _lastTitle, _lastBody;
  int _revision = 0, _savedRevision = 0;
  bool _disposed = false, _saving = false;
  Timer? _timer;
  Future<bool>? _inFlight;
  Object? error;
  bool get dirty => _revision != _savedRevision;
  NoteSaveState get state => error != null
      ? NoteSaveState.failed
      : _saving
      ? NoteSaveState.saving
      : dirty
      ? NoteSaveState.unsaved
      : NoteSaveState.saved;
  String get label => switch (state) {
    NoteSaveState.unsaved => 'Unsaved changes',
    NoteSaveState.saving => 'Saving…',
    NoteSaveState.saved => 'Saved on this device.',
    NoteSaveState.failed => 'Couldn’t save',
  };
  String get copyText =>
      title.text.isEmpty ? body.text : '${title.text}\n\n${body.text}';
  NoteDraft get draft => NoteDraft(
    title: title.text,
    body: body.text,
    courseId: courseId,
    pinned: pinned,
  );

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _textChanged() {
    if (title.text == _lastTitle && body.text == _lastBody) return;
    _lastTitle = title.text;
    _lastBody = body.text;
    _changed();
  }

  void _changed() {
    if (_disposed) return;
    _revision++;
    error = null;
    _timer?.cancel();
    if (!trashed) {
      _timer = Timer(debounce, () {
        unawaited(flush());
      });
    }
    _notify();
  }

  void setPinned(bool value) {
    if (value == pinned) return;
    pinned = value;
    _changed();
  }

  void setCourse(String? value) {
    if (value == courseId) return;
    courseId = value;
    _changed();
  }

  void setTrashed(bool value) {
    trashed = value;
    if (value) _timer?.cancel();
    _notify();
  }

  /// Database echoes never replace newer text or reset an unchanged selection.
  void observe(Note row) {
    if (_disposed) return;
    if (row.title == lastPersisted.title && row.body == lastPersisted.body) {
      lastPersisted = row;
    }
    trashed = row.deletedAt != null;
    if (trashed) _timer?.cancel();
    _notify();
  }

  /// Callers share the same future; edits during a write drain in a later write.
  /// Only a matching committed revision can produce Saved.
  Future<bool> flush() {
    _timer?.cancel();
    if (_disposed) return Future.value(false);
    if (_inFlight != null) return _inFlight!;
    if (!dirty) return Future.value(true);
    final completion = Completer<bool>();
    _inFlight = completion.future;
    unawaited(_drain(completion));
    return completion.future;
  }

  Future<void> _drain(Completer<bool> completion) async {
    var success = false;
    try {
      while (!_disposed && dirty) {
        final revision = _revision;
        final snapshot = draft;
        _saving = true;
        error = null;
        _notify();
        if (trashed) throw StateError('Restore this note to save its draft.');
        validateNoteDraft(snapshot);
        lastPersisted = await (await repository()).updateNote(id, snapshot);
        _savedRevision = revision;
      }
      success = !_disposed && !dirty;
    } catch (failure) {
      if (!_disposed) error = failure;
    } finally {
      _timer?.cancel();
      _saving = false;
      _inFlight = null;
      _notify();
      completion.complete(success);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    title.dispose();
    body.dispose();
    super.dispose();
  }
}

/// Keeps recovery buffers alive when their editor is hidden or reconstructed.
class NoteDrafts extends ChangeNotifier {
  NoteDrafts(this.repository);
  final Future<MomentumRepository> Function() repository;
  final Map<String, NoteController> _controllers = {};
  NoteController open(Note row) => _controllers.putIfAbsent(row.id, () {
    final controller = NoteController(row, repository);
    controller.addListener(notifyListeners);
    return controller;
  });
  NoteController? existing(String id) => _controllers[id];
  List<NoteController> get unsaved =>
      _controllers.values.where((c) => c.dirty).toList(growable: false);
  Future<void> flush(String? id) async {
    if (id != null) await _controllers[id]?.flush();
  }

  Future<void> flushAll() async {
    await Future.wait([
      for (final c in _controllers.values)
        if (c.dirty) c.flush(),
    ]);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.removeListener(notifyListeners);
      c.dispose();
    }
    super.dispose();
  }
}
