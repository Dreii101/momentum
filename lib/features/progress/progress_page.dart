import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import '../focus/timer_engine.dart';
import '../focus/timer_providers.dart';
import '../focus/focus_workflow.dart';
import '../schedule/recurrence.dart';
import 'progress_providers.dart';
import 'progress_repository.dart';

String _workTime(int ms) =>
    '${ms ~/ 60000}:${((ms ~/ 1000) % 60).toString().padLeft(2, '0')}';

class _ReflectionDraft {
  _ReflectionDraft(WeeklyReflection? saved)
    : helped = TextEditingController(text: saved?.helped ?? ''),
      obstacles = TextEditingController(text: saved?.obstacles ?? ''),
      adjustment = TextEditingController(text: saved?.adjustment ?? ''),
      status = saved == null ? 'Not saved yet' : 'Saved';
  final TextEditingController helped, obstacles, adjustment;
  String status;
  Object? error;
  bool busy = false;
  void dispose() {
    helped.dispose();
    obstacles.dispose();
    adjustment.dispose();
  }
}

class _CreditDraft {
  _CreditDraft(FocusSession row)
    : amount = TextEditingController(text: '${row.reportedMs! ~/ 1000}'),
      revision = row.revision;
  final TextEditingController amount;
  int revision;
  bool confirmed = false, busy = false;
  Object? error;
  String? status;
}

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key, required this.wide});
  final bool wide;
  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  CalendarDate? week;
  final reflections = <CalendarDate, _ReflectionDraft>{};
  final corrections = <String, _CreditDraft>{};
  final detailKey = GlobalKey();
  String? shownSession;
  @override
  void dispose() {
    for (final draft in reflections.values) {
      draft.dispose();
    }
    for (final draft in corrections.values) {
      draft.amount.dispose();
    }
    super.dispose();
  }

  void open(Destination destination, String? id) {
    final navigation = ref.read(shellNavigationProvider.notifier);
    if (id == null) {
      navigation.clearRecord(destination);
    } else {
      navigation.selectRecord(destination, id);
    }
  }

  @override
  Widget build(BuildContext context) => WorkspaceScroll(
    storageKey: 'progress-scroll',
    child: ref
        .watch(settingsProvider)
        .when(
          loading: () =>
              const LoadingState(message: 'Loading progress preferences…'),
          error: (e, _) => ActionError(
            title: 'Could not load progress preferences',
            message: 'Retry to choose the correct calendar week.',
            details: '$e',
            onRetry: () => ref.invalidate(settingsProvider),
          ),
          data: (settings) {
            final local = tz.TZDateTime.from(
              ref.read(clockProvider)(),
              requireTimeZone(settings.planningZone),
            );
            week ??= progressWeek(
              CalendarDate(local.year, local.month, local.day),
            );
            final range = (week: week!, zone: settings.planningZone);
            final selected = ref
                .watch(shellNavigationProvider)
                .selectedRecords[Destination.progress];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Space.lg),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('progress-previous'),
                      onPressed: week!.year <= 1
                          ? null
                          : () => setState(() => week = addDays(week!, -7)),
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous week'),
                    ),
                    Text(
                      '${week!} – ${addDays(week!, 6)}',
                      key: const Key('progress-week'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('progress-next'),
                      onPressed: week!.year >= 9999
                          ? null
                          : () => setState(() => week = addDays(week!, 7)),
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next week'),
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => week = progressWeek(
                          CalendarDate(local.year, local.month, local.day),
                        ),
                      ),
                      child: const Text('This week'),
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                ref
                    .watch(progressProvider(range))
                    .when(
                      loading: () => const LoadingState(
                        message: 'Loading saved progress…',
                      ),
                      error: (e, _) => ActionError(
                        title: 'Could not load progress',
                        message: 'Totals are unavailable. Your reflection draft is kept here while you retry.',
                        details: '$e',
                        onRetry: () => ref.invalidate(progressProvider(range)),
                      ),
                      data: (snapshot) => LayoutBuilder(
                        builder: (context, space) {
                          if (selected != shownSession) {
                            shownSession = selected;
                            if (selected != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final detailContext = detailKey.currentContext;
                                if (mounted && detailContext != null) {
                                  Scrollable.ensureVisible(detailContext);
                                }
                              });
                            }
                          }
                          final width = widget.wide
                              ? (space.maxWidth - Space.xl) / 2
                              : space.maxWidth;
                          return Wrap(
                            spacing: Space.xl,
                            runSpacing: Space.xl,
                            children: [
                              SizedBox(
                                width: width,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    summary(snapshot, settings.planningZone),
                                    const SizedBox(height: Space.xl),
                                    history(snapshot),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (selected != null) ...[
                                      KeyedSubtree(
                                        key: detailKey,
                                        child: detail(selected),
                                      ),
                                      const SizedBox(height: Space.xl),
                                    ],
                                    reflection(snapshot.reflection),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              ],
            );
          },
        ),
  );

  Widget summary(ProgressSnapshot data, String zone) => SectionCard(
    title: 'This week in saved records',
    description:
        'Monday to Sunday. Completed items use $zone. Archived items count; trashed items do not. Reopening removes the current completion.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Completed tasks: ${data.tasks.length}',
          key: const Key('progress-task-total'),
        ),
        Text(
          'Completed subtasks: ${data.steps.length}',
          key: const Key('progress-step-total'),
        ),
        Text(
          'Reported focus time: ${_workTime(data.reportedMs)}',
          key: const Key('progress-work-total'),
        ),
        Text('Reviewed starters: ${data.count(SessionKind.starter)}'),
        Text('Reviewed focus sessions: ${data.count(SessionKind.focus)}'),
        const SizedBox(height: Space.lg),
        const Text(
          'Times are minutes:seconds, rounded down to whole seconds. Time includes confirmed starter and focus work only. Zero-work reviews still count as sessions. Breaks and unreviewed sessions give no credit.',
        ),
        const Text(
          'Sessions belong to their saved local start date, even across midnight or after a time-zone change. Continuing a starter creates a separate focus interval; each saved interval counts once.',
        ),
        if (data.unresolved > 0)
          Text(
            '${data.unresolved} unfinished session(s) excluded. Open history below to review them.',
          ),
        ExpansionTile(
          key: const PageStorageKey('progress-completions'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Records behind completion counts'),
          children: [
            if (data.tasks.isEmpty && data.steps.isEmpty)
              const Text(
                'No current completions in this week. Choose a manageable next step when you are ready.',
              ),
            for (final task in data.tasks)
              TextButton(
                onPressed: () => open(Destination.tasks, task.id),
                child: Text('Task: ${task.title}'),
              ),
            for (final item in data.steps)
              TextButton(
                onPressed: () => open(Destination.tasks, item.task.id),
                child: Text('Step: ${item.step.title} · ${item.task.title}'),
              ),
          ],
        ),
      ],
    ),
  );

  Widget history(ProgressSnapshot data) => SectionCard(
    title: 'Session history',
    description: 'All saved sessions starting in this week, including breaks and sessions still needing review.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.sessions.isEmpty)
          const Text(
            'No sessions started this week. Your next small start can be here when you need it.',
          ),
        for (final row in data.sessions)
          TextButton(
            key: Key('progress-session-${row.id}'),
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => open(Destination.progress, row.id),
            child: Text(
              '${sessionKindLabel(row.kind)} · ${row.titleSnapshot}\n${row.localStartDate} · ${row.state == SessionState.finalized ? '${_workTime(row.reportedMs!)} confirmed' : sessionStateLabel(row.state)}',
            ),
          ),
      ],
    ),
  );

  Widget detail(String id) => ref
      .watch(sessionRecordProvider(id))
      .when(
        loading: () => const LoadingState(message: 'Loading session details…'),
        error: (e, _) => ActionError(
          title: 'Could not load session details',
          message: 'Retry to inspect the saved record.',
          details: '$e',
          onRetry: () => ref.invalidate(sessionRecordProvider(id)),
        ),
        data: (row) {
          if (row == null) {
            return const Text(
              'This session is unavailable. Other records are preserved.',
            );
          }
          final canCorrect =
              row.state == SessionState.finalized &&
              row.kind != SessionKind.rest;
          final draft = canCorrect
              ? corrections.putIfAbsent(id, () => _CreditDraft(row))
              : null;
          return SectionCard(
            title: 'Session details',
            description: '${sessionKindLabel(row.kind)} · ${row.titleSnapshot}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Saved start date: ${row.localStartDate} · ${row.zone}'),
                Text('Started (UTC): ${row.startedUtc.toIso8601String()}'),
                const Text(
                  'The entire interval is grouped by this saved local start date. Midnight, later zone preferences and correction dates do not move it to another week.',
                ),
                Text(
                  'State: ${sessionStateLabel(row.state)} · ${switch (row.outcome) {
                    SessionOutcome.completed => 'Interval ended',
                    SessionOutcome.stoppedEarly => 'Ended early',
                    SessionOutcome.interrupted => 'Interrupted',
                    null => 'Not ended',
                  }}',
                ),
                Text(
                  'Elapsed: ${_workTime(row.elapsedMs)} · eligible: ${_workTime(row.eligibleMs)} · uncertain: ${_workTime(row.uncertainMs)}',
                ),
                if (row.hasUncertainty)
                  const Text(
                    'Some time was uncertain and cannot receive work credit.',
                  ),
                if (row.kind == SessionKind.rest)
                  const Text('Breaks give no work credit.'),
                if (row.state == SessionState.finalized)
                  Text(
                    'Saved confirmed work: ${_workTime(row.reportedMs!)}',
                    key: const Key('progress-saved-credit'),
                  ),
                if (draft != null) ...[
                  const SizedBox(height: Space.lg),
                  TextField(
                    key: const Key('progress-correction'),
                    controller: draft.amount,
                    enabled: !draft.busy,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {
                      draft.confirmed = false;
                      draft.status = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Correct reported work (whole seconds)',
                      helperText:
                          'From 0 to ${row.eligibleMs ~/ 1000} seconds. Elapsed evidence stays unchanged.',
                    ),
                  ),
                  CheckboxListTile(
                    key: const Key('progress-confirm'),
                    contentPadding: EdgeInsets.zero,
                    value: draft.confirmed,
                    onChanged: draft.busy
                        ? null
                        : (v) => setState(() => draft.confirmed = v!),
                    title: const Text(
                      'I reviewed and confirm this corrected amount.',
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('progress-save-correction'),
                    onPressed: draft.busy ? null : () => correct(row, draft),
                    child: Text(draft.busy ? 'Saving…' : 'Save correction'),
                  ),
                  if (draft.status != null)
                    Text(
                      draft.status!,
                      key: const Key('progress-correction-status'),
                    ),
                  if (draft.error != null) ...[
                    ActionError(
                      title: 'Could not save correction',
                      message: 'Your input is kept. Check the amount and confirmation, then retry. If the record changed, reload its saved amount first.',
                      details: '${draft.error}',
                      onRetry: () => correct(row, draft),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        draft.amount.text = '${row.reportedMs! ~/ 1000}';
                        draft.revision = row.revision;
                        draft.error = null;
                        draft.confirmed = false;
                      }),
                      child: const Text('Reload saved amount'),
                    ),
                  ],
                ],
                if (row.state != SessionState.finalized)
                  TextButton(
                    onPressed: () => openFocus(ref, 'session/$id'),
                    child: const Text('Open active session / review'),
                  ),
                if (row.taskId != null)
                  TextButton(
                    onPressed: () => open(Destination.tasks, row.taskId),
                    child: const Text('Open linked task'),
                  ),
                TextButton(
                  onPressed: () => open(Destination.progress, null),
                  child: const Text('Close details'),
                ),
              ],
            ),
          );
        },
      );

  Future<void> correct(FocusSession row, _CreditDraft draft) async {
    if (draft.busy) return;
    setState(() {
      draft.busy = true;
      draft.error = null;
      draft.status = null;
    });
    try {
      final reportedMs = reportedWorkMilliseconds(
        draft.amount.text,
        row.eligibleMs,
      );
      final repo = await ref.read(repositoryProvider.future);
      final saved = await repo.correctReportedWork(
        row.id,
        reportedMs: reportedMs,
        expectedRevision: draft.revision,
        confirmed: draft.confirmed,
      );
      draft.revision = saved.revision;
      draft.confirmed = false;
      draft.status = 'Correction saved';
    } catch (e) {
      draft.error = e;
    } finally {
      draft.busy = false;
      if (mounted) setState(() {});
    }
  }

  Widget reflection(WeeklyReflection? saved) {
    final selectedWeek = week!;
    final draft = reflections.putIfAbsent(
      selectedWeek,
      () => _ReflectionDraft(saved),
    );
    Future<void> save() async {
      if (draft.busy) return;
      setState(() {
        draft.busy = true;
        draft.error = null;
        draft.status = 'Saving…';
      });
      try {
        final repo = await ref.read(repositoryProvider.future);
        await repo.saveReflection(
          selectedWeek,
          helped: draft.helped.text,
          obstacles: draft.obstacles.text,
          adjustment: draft.adjustment.text,
        );
        draft.status = 'Saved';
      } catch (e) {
        draft.error = e;
        draft.status = "Couldn't save";
      } finally {
        draft.busy = false;
        if (mounted) setState(() {});
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): save,
      },
      child: SectionCard(
        title: 'Weekly reflection',
        description: 'Optional, up to 5,000 characters per answer. Save to keep it after closing Momentum. Unsaved drafts stay here while you switch weeks or destinations.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in [
              (draft.helped, 'What helped?', 'reflection-helped'),
              (draft.obstacles, 'What got in the way?', 'reflection-obstacles'),
              (
                draft.adjustment,
                'One adjustment for next week',
                'reflection-adjustment',
              ),
            ]) ...[
              TextField(
                key: Key(field.$3),
                controller: field.$1,
                enabled: !draft.busy,
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(labelText: field.$2),
                onChanged: (_) =>
                    setState(() => draft.status = 'Unsaved changes'),
              ),
              const SizedBox(height: Space.lg),
            ],
            Text(
              draft.status,
              key: const Key('reflection-status'),
              semanticsLabel: 'Reflection: ${draft.status}',
            ),
            FilledButton(
              key: const Key('reflection-save'),
              onPressed: draft.busy ? null : save,
              child: const Text('Save reflection'),
            ),
            if (draft.error != null)
              ActionError(
                title: 'Could not save reflection',
                message: 'Your draft is kept. Check answer lengths and retry; copy your text before closing the app.',
                details: '${draft.error}',
                onRetry: save,
              ),
          ],
        ),
      ),
    );
  }
}
