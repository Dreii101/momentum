import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../notes/note_providers.dart';
import '../tasks/task_workflow.dart';
import 'focus_workflow.dart';
import 'timer_coordinator.dart';
import 'timer_engine.dart';
import 'timer_providers.dart';
import 'timer_store.dart';

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key, required this.route});
  final String route;
  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage> {
  final duration = TextEditingController(),
      reported = TextEditingController(text: '0');
  String? taskId, stepId;
  bool initialized = false, busy = false, confirmed = false;
  Object? error;
  Future<void> Function()? retry;
  @override
  void initState() {
    super.initState();
    final parts = widget.route.split('/');
    if (parts.length > 1 && parts.first != 'session') taskId = parts[1];
  }

  @override
  void dispose() {
    duration.dispose();
    reported.dispose();
    super.dispose();
  }

  void today() =>
      ref.read(shellNavigationProvider.notifier).clearRecord(Destination.today);
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

  Widget button(
    String key,
    String label,
    Future<void> Function()? action, {
    bool primary = false,
  }) {
    final pressed = busy || action == null ? null : () => run(action);
    return primary
        ? FilledButton(key: Key(key), onPressed: pressed, child: Text(label))
        : OutlinedButton(key: Key(key), onPressed: pressed, child: Text(label));
  }

  int minutes() {
    final value = int.tryParse(duration.text.trim());
    if (value == null) {
      throw const FormatException('Enter a whole number of minutes.');
    }
    return value;
  }

  Future<void> start(
    TimerCoordinator owner,
    SessionKind kind,
    Settings settings,
  ) async {
    final row = await owner.start(
      kind,
      minutes: kind == SessionKind.starter ? 2 : minutes(),
      zone: settings.planningZone,
      taskId: kind == SessionKind.rest ? null : taskId,
      subtaskId: kind == SessionKind.rest ? null : stepId,
    );
    if (mounted) openFocus(ref, 'session/${row!.id}');
  }

  @override
  Widget build(BuildContext context) {
    final opening = ref.watch(timerCoordinatorProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) today();
      },
      child: WorkspaceScroll(
        storageKey: 'focus-${widget.route}',
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: Space.md,
                  runSpacing: Space.sm,
                  children: [
                    TextButton.icon(
                      key: const Key('focus-back'),
                      onPressed: today,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Today'),
                    ),
                    TextButton(
                      key: const Key('focus-history'),
                      onPressed: () => openFocus(ref, 'history'),
                      child: const Text('Recent sessions'),
                    ),
                  ],
                ),
                opening.when(
                  loading: () =>
                      const LoadingState(message: 'Opening your session…'),
                  error: (e, _) => ActionError(
                    title: 'Your session could not open',
                    message: 'Your saved session is preserved. Retry opening before starting another.',
                    details: e.toString(),
                    onRetry: () => ref.invalidate(timerCoordinatorProvider),
                  ),
                  data: (owner) {
                    final observed = ref.watch(timerViewProvider);
                    final view = observed.value ?? owner.view;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null || view.error != null) ...[
                          ActionError(
                            title: 'This change was not confirmed saved',
                            message: 'Your input and last saved session are still available.',
                            details: (error ?? view.error).toString(),
                            onRetry: () {
                              final previous = retry;
                              run(() async {
                                if (owner.view.error != null) {
                                  await owner.retry();
                                } else {
                                  await previous?.call();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: Space.lg),
                        ],
                        if (observed.hasError)
                          ActionError(
                            title: 'Could not observe the session',
                            message: observed.error.toString(),
                            onRetry: () => ref.invalidate(timerViewProvider),
                          ),
                        if (widget.route == 'history')
                          history()
                        else if (widget.route.startsWith('session/'))
                          session(owner, widget.route.substring(8))
                        else
                          setup(owner, view),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget setup(TimerCoordinator owner, TimerEngineView view) {
    final settings = ref.watch(settingsProvider);
    final tasks = ref.watch(taskRecordsProvider);
    if (settings.hasError || tasks.hasError) {
      return ActionError(
        title: 'Could not load your starting choices',
        message: (settings.error ?? tasks.error).toString(),
        onRetry: () {
          ref.invalidate(settingsProvider);
          ref.invalidate(taskRecordsProvider);
        },
      );
    }
    if (!settings.hasValue || !tasks.hasValue) {
      return const LoadingState(message: 'Loading your starting choices…');
    }
    final starter = widget.route.startsWith('starter/'),
        rest = widget.route == 'break';
    final kind = starter
        ? SessionKind.starter
        : rest
        ? SessionKind.rest
        : SessionKind.focus;
    final preferences = settings.requireValue;
    if (!initialized) {
      duration.text =
          '${rest ? preferences.breakMinutes : preferences.focusMinutes}';
      initialized = true;
    }
    final selected = tasks.requireValue
        .where((t) => t.id == taskId)
        .firstOrNull;
    bool available(Task t) =>
        t.deletedAt == null &&
        t.archivedAt == null &&
        t.status != TaskStatus.done;
    final valid = taskId == null
        ? !starter
        : selected != null && available(selected);
    final unfinished =
        view.session != null && view.session!.state != SessionState.finalized;
    final allowed = valid && !unfinished && !view.saving;
    Future<void> begin() => start(owner, kind, preferences);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          if (allowed) run(begin);
        },
      },
      child: SectionCard(
        title: starter
            ? 'A small start is enough'
            : rest
            ? 'Take a break'
            : 'Make room for focus',
        description: starter
            ? 'Choose one small action. Nothing starts until you press Start for 2 minutes.'
            : rest
            ? 'Rest is separate from work. Start when you are ready.'
            : 'Choose a length you can manage. You can pause or stop.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (unfinished) ...[
              const Text(
                'You already have an unfinished session. Return to it before starting another.',
              ),
              button(
                'setup-return-session',
                'Return to session',
                () async => openFocus(ref, 'session/${view.session!.id}'),
              ),
              const SizedBox(height: Space.lg),
            ],
            if (!rest) ...[
              DropdownButtonFormField<String>(
                key: const Key('focus-task'),
                initialValue: taskId ?? '',
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Task'),
                items: [
                  if (!starter)
                    const DropdownMenuItem(
                      value: '',
                      child: Text('General focus'),
                    ),
                  for (final t in tasks.requireValue.where(
                    (t) => available(t) || t.id == taskId,
                  ))
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        '${t.title}${available(t) ? '' : ' (restore or reopen first)'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (taskId != null && selected == null)
                    DropdownMenuItem(
                      value: taskId,
                      child: const Text('Task unavailable'),
                    ),
                ],
                onChanged: busy
                    ? null
                    : (id) => setState(() {
                        taskId = id == '' ? null : id;
                        stepId = null;
                      }),
              ),
              const SizedBox(height: Space.lg),
            ],
            if (starter && selected != null) starterActions(selected),
            if (!starter) ...[
              if (!rest)
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    for (final value in [10, 25, 50])
                      OutlinedButton(
                        key: Key('focus-preset-$value'),
                        onPressed: busy
                            ? null
                            : () => setState(() => duration.text = '$value'),
                        child: Text('$value minutes'),
                      ),
                  ],
                ),
              const SizedBox(height: Space.lg),
              TextField(
                key: const Key('focus-duration'),
                controller: duration,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: rest
                      ? 'Break minutes (1–60)'
                      : 'Custom minutes (1–180)',
                ),
              ),
              const SizedBox(height: Space.lg),
            ],
            if (!valid)
              const Text(
                'Choose an available task, or restore/reopen the linked task first.',
              ),
            button(
              'focus-start',
              starter
                  ? 'Start for 2 minutes'
                  : rest
                  ? 'Start break'
                  : 'Start focus',
              allowed ? begin : null,
              primary: true,
            ),
            const SizedBox(height: Space.lg),
            const ExpansionTile(
              key: PageStorageKey('starting-suggestions'),
              tilePadding: EdgeInsets.zero,
              title: Text('Make starting easier (optional)'),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: Space.lg),
                  child: Text(
                    'Open the file. Read one question. Write one imperfect sentence. You can stop after this interval.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget starterActions(Task task) => ref
      .watch(subtasksProvider(task.id))
      .when(
        loading: () => const LoadingState(message: 'Loading small steps…'),
        error: (e, _) => ActionError(
          title: 'Could not load small steps',
          message: e.toString(),
          onRetry: () => ref.invalidate(subtasksProvider(task.id)),
        ),
        data: (rows) {
          final incomplete = rows.where((s) => s.completedAt == null).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: Space.lg),
            child: DropdownButtonFormField<String>(
              key: ValueKey('starter-action-${task.id}'),
              initialValue: stepId ?? '',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'One small action'),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(
                    task.nextAction?.isNotEmpty == true
                        ? task.nextAction!
                        : 'Open the task and find one small first step',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                for (final step in incomplete)
                  DropdownMenuItem(
                    value: step.id,
                    child: Text(step.title, overflow: TextOverflow.ellipsis),
                  ),
                if (stepId != null && !incomplete.any((s) => s.id == stepId))
                  DropdownMenuItem(
                    value: stepId,
                    child: const Text('Step changed — choose another action'),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (id) => setState(() => stepId = id == '' ? null : id),
            ),
          );
        },
      );

  Widget session(TimerCoordinator owner, String id) => ref
      .watch(sessionRecordProvider(id))
      .when(
        loading: () =>
            const LoadingState(message: 'Loading your saved session…'),
        error: (e, _) => ActionError(
          title: 'Could not load the saved session',
          message: e.toString(),
          onRetry: () => ref.invalidate(sessionRecordProvider(id)),
        ),
        data: (row) {
          if (row == null) {
            return const Text(
              'This session could not be found. Your other records are preserved.',
            );
          }
          final active =
              row.state == SessionState.running ||
              row.state == SessionState.paused;
          final current = owner.view.session?.id == row.id;
          return SectionCard(
            title: active
                ? sessionKindLabel(row.kind)
                : row.outcome == SessionOutcome.interrupted &&
                      row.state != SessionState.finalized
                ? 'Welcome back. Review this session.'
                : row.state == SessionState.finalized
                ? 'Your review is saved'
                : 'A little progress is worth noticing',
            description:
                '${row.titleSnapshot} · ${sessionKindLabel(row.kind)} · ${sessionStateLabel(row.state)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (active) ...[
                  SessionCountdown(session: row, owner: owner),
                  const Text(
                    'You can leave this screen. Your session stays available below.',
                  ),
                  const SizedBox(height: Space.lg),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: [
                      button(
                        'focus-pause-resume',
                        row.state == SessionState.paused ? 'Resume' : 'Pause',
                        !current
                            ? null
                            : () async => owner.command(
                                row.state == SessionState.paused
                                    ? TimerAction.resume
                                    : TimerAction.pause,
                              ),
                      ),
                      if (row.kind != SessionKind.starter)
                        button(
                          'focus-extend',
                          'Add 5 minutes',
                          !current
                              ? null
                              : () async => owner.command(
                                  TimerAction.extend,
                                  minutes: 5,
                                ),
                        ),
                      button(
                        'focus-end',
                        'End and review',
                        !current
                            ? null
                            : () async => owner.command(TimerAction.end),
                        primary: true,
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    row.outcome == SessionOutcome.interrupted
                        ? 'Some time could not be verified. Nothing has been credited automatically.'
                        : row.outcome == SessionOutcome.stoppedEarly
                        ? 'Stopping early is okay. Review what you actually worked on.'
                        : 'The interval ended. You decide what work to report.',
                  ),
                  const SizedBox(height: Space.lg),
                  Text(
                    'Intended ${timerText(row.plannedMs)} · elapsed ${timerText(row.elapsedMs)}',
                  ),
                  Text(
                    'Eligible work: ${row.eligibleMs ~/ 1000} seconds · uncertain: ${row.uncertainMs ~/ 1000} seconds',
                  ),
                  if (row.kind == SessionKind.rest)
                    const Text('Break time gives no work credit.'),
                  if (row.hasUncertainty)
                    const Text(
                      'Background, restart or clock gaps are excluded from eligible work. You can report zero.',
                    ),
                  const SizedBox(height: Space.lg),
                  if (row.state == SessionState.awaitingReview && current) ...[
                    TextField(
                      key: const Key('focus-reported'),
                      controller: reported,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Work to report in whole seconds',
                        helperText: 'Zero is allowed. Report no more than eligible work.',
                      ),
                    ),
                    CheckboxListTile(
                      key: const Key('focus-confirm'),
                      contentPadding: EdgeInsets.zero,
                      value: confirmed,
                      onChanged: busy
                          ? null
                          : (value) => setState(() => confirmed = value!),
                      title: const Text(
                        'I reviewed this amount and want to save it.',
                      ),
                    ),
                    button('focus-save-review', 'Save reviewed work', () async {
                      await owner.command(
                        TimerAction.finalize,
                        reportedMs: reportedWorkMilliseconds(
                          reported.text,
                          row.eligibleMs,
                        ),
                        confirmed: confirmed,
                      );
                    }, primary: true),
                    const Text(
                      'Review does not complete a task or step. Save before continuing or taking a break.',
                    ),
                  ],
                  if (row.state == SessionState.finalized) ...[
                    Text(
                      '${row.reportedMs! ~/ 1000} seconds explicitly confirmed',
                      key: const Key('focus-saved-credit'),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(shellNavigationProvider.notifier)
                          .selectRecord(Destination.progress, row.id),
                      child: const Text(
                        'View progress / correct reported work',
                      ),
                    ),
                    const Text(
                      'You can stop here. Another interval starts only when you choose it.',
                    ),
                    const SizedBox(height: Space.lg),
                    followUp(owner, row),
                  ],
                ],
                const SizedBox(height: Space.xl),
                Text('Started on ${row.localStartDate} · ${row.zone}'),
                if (row.taskId != null) links(row),
              ],
            ),
          );
        },
      );

  Widget followUp(TimerCoordinator owner, FocusSession row) {
    final task = row.taskId == null
        ? null
        : ref.watch(taskRecordProvider(row.taskId!)).value;
    final usable =
        row.taskId == null ||
        (task != null &&
            task.deletedAt == null &&
            task.archivedAt == null &&
            task.status != TaskStatus.done);
    final unfinished =
        owner.view.session != null &&
        owner.view.session!.state != SessionState.finalized;
    Future<void> continueFor(int minutes) async {
      final settings = await ref.read(settingsProvider.future);
      String? step = row.subtaskId;
      if (step != null) {
        final saved = await owner.store.repository.subtask(step);
        if (saved.deletedAt != null || saved.completedAt != null) step = null;
      }
      final next = await owner.start(
        SessionKind.focus,
        minutes: minutes,
        zone: settings.planningZone,
        taskId: row.taskId,
        subtaskId: step,
      );
      if (mounted) openFocus(ref, 'session/${next!.id}');
    }

    final steps = row.taskId == null
        ? <Subtask>[]
        : ref.watch(subtasksProvider(row.taskId!)).value ?? <Subtask>[];
    final step = steps
        .where((s) => s.id == row.subtaskId && s.completedAt == null)
        .firstOrNull;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        if (row.kind == SessionKind.starter) ...[
          for (final value in [10, 25])
            button(
              'continue-$value',
              'Continue $value minutes',
              usable && !unfinished ? () => continueFor(value) : null,
              primary: true,
            ),
          button(
            'continue-custom',
            'Custom focus',
            usable && !unfinished
                ? () async => openFocus(
                    ref,
                    row.taskId == null ? 'focus' : 'focus/${row.taskId}',
                  )
                : null,
          ),
          if (row.subtaskId != null)
            button(
              'focus-mark-step',
              step == null ? 'Step done or unavailable' : 'Mark step done',
              usable && step != null
                  ? () async {
                      final fresh = await owner.store.repository.subtask(
                        step.id,
                      );
                      if (fresh.deletedAt != null) {
                        throw StateError(
                          'This step was removed. Your reviewed session is preserved.',
                        );
                      }
                      await owner.store.repository.updateSubtask(
                        fresh.id,
                        title: fresh.title,
                        position: fresh.position,
                        completed: true,
                      );
                    }
                  : null,
            ),
        ] else
          button(
            'focus-another',
            'Prepare another focus',
            !unfinished ? () async => openFocus(ref, 'focus') : null,
          ),
        if (row.kind != SessionKind.rest)
          button(
            'focus-break',
            'Prepare a break',
            !unfinished ? () async => openFocus(ref, 'break') : null,
          ),
        button('focus-stop', 'Stop here', () async => today()),
      ],
    );
  }

  Widget links(FocusSession row) {
    final task = ref.watch(taskRecordProvider(row.taskId!));
    final notes = ref.watch(linkedNotesProvider(row.taskId!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.lg),
        if (task.hasError) Text('Linked task could not load: ${task.error}'),
        if (task.value?.deletedAt != null)
          const Text(
            'The linked task is in Trash. Your session and notes are retained.',
          ),
        if (task.value?.status == TaskStatus.done)
          const Text(
            'The linked task is complete. Session review stays separate.',
          ),
        OutlinedButton(
          key: const Key('focus-open-task'),
          onPressed: () => ref
              .read(shellNavigationProvider.notifier)
              .selectRecord(Destination.tasks, row.taskId!),
          child: const Text('Open linked task'),
        ),
        notes.when(
          loading: () => const Text('Loading linked notes…'),
          error: (e, _) => ActionError(
            title: 'Could not load linked notes',
            message: e.toString(),
            onRetry: () => ref.invalidate(linkedNotesProvider(row.taskId!)),
          ),
          data: (rows) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (rows.isEmpty) const Text('No notes linked to this task.'),
              for (final note in rows)
                TextButton(
                  key: ValueKey('focus-note-${note.id}'),
                  onPressed: () => ref
                      .read(shellNavigationProvider.notifier)
                      .selectRecord(Destination.notes, note.id),
                  child: Text(
                    '${noteTitle(note)}${note.deletedAt == null ? '' : ' (in Trash)'}',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget history() => SectionCard(
    title: 'Recent reviewed sessions',
    description: 'The latest 20 saved reviews. Reported work is your confirmation, not a measure of attention.',
    child: ref
        .watch(sessionHistoryProvider)
        .when(
          loading: () => const LoadingState(message: 'Loading saved reviews…'),
          error: (e, _) => ActionError(
            title: 'Could not load session history',
            message: e.toString(),
            onRetry: () => ref.invalidate(sessionHistoryProvider),
          ),
          data: (rows) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (rows.isEmpty)
                const Text(
                  'No reviewed sessions yet. Unfinished sessions stay available in the session control.',
                ),
              for (final row in rows)
                ListTile(
                  key: ValueKey('history-${row.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${sessionKindLabel(row.kind)} · ${row.titleSnapshot}',
                  ),
                  subtitle: Text(
                    '${row.localStartDate} · ${row.zone}\n${row.reportedMs! ~/ 1000} seconds confirmed',
                  ),
                  onTap: () => openFocus(ref, 'session/${row.id}'),
                ),
            ],
          ),
        ),
  );
}

/// Repaints a projection of the same engine; ticks never write or measure time.
class SessionCountdown extends StatefulWidget {
  const SessionCountdown({
    super.key,
    required this.session,
    required this.owner,
  });
  final FocusSession session;
  final TimerCoordinator owner;
  @override
  State<SessionCountdown> createState() => _SessionCountdownState();
}

class _SessionCountdownState extends State<SessionCountdown> {
  Timer? ticker;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateTicker();
  }

  @override
  void didUpdateWidget(covariant SessionCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateTicker();
  }

  void updateTicker() {
    ticker?.cancel();
    if (widget.session.state == SessionState.running &&
        TickerMode.valuesOf(context).enabled) {
      ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = TimerMachine.advance(
      timerRecord(widget.session),
      widget.owner.clock.sample(),
    ).record.remainingMs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Countdown. Last saved remaining time is shown below.',
          liveRegion: false,
          child: ExcludeSemantics(
            child: Text(
              timerText(remaining),
              key: const Key('focus-countdown'),
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
        Text(
          'Last saved remaining time: ${timerText(widget.session.plannedMs - widget.session.elapsedMs)}',
        ),
      ],
    );
  }
}
