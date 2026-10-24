import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../tasks/task_workflow.dart';
import 'timer_engine.dart';
import 'focus_workflow.dart';
import 'timer_providers.dart';

class TimerDevelopmentPanel extends ConsumerStatefulWidget {
  const TimerDevelopmentPanel({super.key});
  @override
  ConsumerState<TimerDevelopmentPanel> createState() =>
      _TimerDevelopmentPanelState();
}

class _TimerDevelopmentPanelState extends ConsumerState<TimerDevelopmentPanel> {
  final minutes = TextEditingController(text: '25'),
      extension = TextEditingController(text: '5'),
      reported = TextEditingController(text: '0');
  String? taskId, lastId;
  bool confirmed = false;
  Object? inputError;
  @override
  void dispose() {
    minutes.dispose();
    extension.dispose();
    reported.dispose();
    super.dispose();
  }

  Future<void> run(Future<Object?> Function() action) async {
    setState(() => inputError = null);
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => inputError = e);
    }
  }

  int number(TextEditingController c) {
    final n = int.tryParse(c.text.trim());
    if (n == null) throw const FormatException('Enter a whole number.');
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(timerCoordinatorProvider);
    return SectionCard(
      title: 'Timer engine · development controls',
      description: 'Uses real workspace sessions. Saved checkpoints, uncertainty and explicitly confirmed work stay separate. Use Today for the normal starter and focus flow.',
      child: owner.when(
        loading: () => const Text('Opening timer engine…'),
        error: (e, _) => ActionError(
          title: 'Timer engine could not open',
          message: e.toString(),
          onRetry: () => ref.invalidate(timerCoordinatorProvider),
        ),
        data: (coordinator) {
          final observed = ref.watch(timerViewProvider);
          final view = observed.value ?? coordinator.view;
          final s = view.session;
          if (s?.id != lastId) {
            lastId = s?.id;
            confirmed = false;
            reported.text = '0';
          }
          final running = s?.state == SessionState.running,
              paused = s?.state == SessionState.paused;
          final review = s?.state == SessionState.awaitingReview;
          final idle = s == null || s.state == SessionState.finalized;
          final tasks = ref.watch(taskRecordsProvider);
          Widget button(
            String key,
            String label,
            Future<Object?> Function()? action,
          ) => OutlinedButton(
            key: Key(key),
            onPressed: view.saving || action == null ? null : () => run(action),
            child: Text(label),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (observed.hasError)
                Text('Could not observe timer: ${observed.error}'),
              if (view.error != null)
                ActionError(
                  title: 'Timer command was not confirmed saved',
                  message: view.error.toString(),
                  onRetry: () => run(coordinator.retry),
                ),
              if (inputError != null) Text('Check this command: $inputError'),
              Text(
                'Last committed state: ${s?.state.name ?? 'no unfinished session'}',
                key: const Key('timer-state'),
              ),
              if (view.saving) const Text('Saving timer…'),
              if (s != null) ...[
                Text(
                  '${s.titleSnapshot} · ${s.kind == SessionKind.rest ? 'break' : s.kind.name}',
                ),
                Text('Local start date: ${s.localStartDate} · ${s.zone}'),
                Text(
                  'Intended: ${s.plannedMs ~/ 1000}s · elapsed: ${s.elapsedMs ~/ 1000}s · remaining: ${(s.plannedMs - s.elapsedMs) ~/ 1000}s',
                ),
                Text(
                  'Eligible: ${s.eligibleMs ~/ 1000}s · uncertain: ${s.uncertainMs ~/ 1000}s',
                ),
                if (s.hasUncertainty)
                  const Text(
                    'Uncertain intervals are excluded from eligible work. Review the segment details.',
                  ),
                Text(
                  'Outcome: ${s.outcome?.name ?? 'not ended'} · reported work: ${s.reportedMs == null ? 'not confirmed' : '${s.reportedMs! ~/ 1000}s'}',
                ),
                Text(
                  'Last saved checkpoint: ${s.checkpointUtc.toIso8601String()}',
                ),
              ],
              const SizedBox(height: 12),
              tasks.when(
                loading: () => const Text('Loading task choices…'),
                error: (e, _) => Text('Task choices unavailable: $e'),
                data: (rows) => DropdownButtonFormField<String>(
                  initialValue: taskId ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Optional task for the next session',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('General session'),
                    ),
                    for (final t in rows.where(
                      (t) =>
                          t.id == taskId ||
                          (t.deletedAt == null && t.archivedAt == null),
                    ))
                      DropdownMenuItem(
                        value: t.id,
                        child: Text(t.title, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: idle && !view.saving
                      ? (v) => setState(() => taskId = v == '' ? null : v)
                      : null,
                ),
              ),
              TextField(
                key: const Key('timer-minutes'),
                controller: minutes,
                decoration: const InputDecoration(
                  labelText: 'Focus 1–180 / break 1–60 minutes',
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in SessionKind.values)
                    button(
                      'timer-start-${kind.name}',
                      kind == SessionKind.starter
                          ? 'Start 120-second starter'
                          : kind == SessionKind.rest
                          ? 'Start break'
                          : 'Start focus',
                      idle
                          ? () => coordinator.start(
                              kind,
                              minutes: kind == SessionKind.starter
                                  ? 2
                                  : number(minutes),
                              taskId: taskId,
                            )
                          : null,
                    ),
                  button(
                    'timer-pause',
                    'Pause',
                    running
                        ? () => coordinator.command(TimerAction.pause)
                        : null,
                  ),
                  button(
                    'timer-resume',
                    'Resume',
                    paused
                        ? () => coordinator.command(TimerAction.resume)
                        : null,
                  ),
                  button(
                    'timer-end',
                    'End for review',
                    running || paused
                        ? () => coordinator.command(TimerAction.end)
                        : null,
                  ),
                  button(
                    'timer-checkpoint',
                    'Save checkpoint',
                    running || paused ? coordinator.checkpoint : null,
                  ),
                  button(
                    'timer-recover',
                    'Recover for review',
                    running || paused
                        ? () => coordinator.command(TimerAction.recover)
                        : null,
                  ),
                ],
              ),
              if (s != null &&
                  s.kind != SessionKind.starter &&
                  (running ||
                      paused ||
                      (review && s.outcome == SessionOutcome.completed))) ...[
                TextField(
                  key: const Key('timer-extension'),
                  controller: extension,
                  decoration: const InputDecoration(
                    labelText: 'Additional minutes',
                  ),
                ),
                button(
                  'timer-extend',
                  'Explicitly extend',
                  () => coordinator.command(
                    TimerAction.extend,
                    minutes: number(extension),
                  ),
                ),
              ],
              if (review) ...[
                TextField(
                  key: const Key('timer-reported'),
                  controller: reported,
                  decoration: const InputDecoration(
                    labelText:
                        'Reported work in whole seconds (zero is allowed)',
                  ),
                ),
                CheckboxListTile(
                  key: const Key('timer-confirm'),
                  contentPadding: EdgeInsets.zero,
                  value: confirmed,
                  onChanged: view.saving
                      ? null
                      : (v) => setState(() => confirmed = v!),
                  title: const Text(
                    'I confirm this reported work after reviewing eligible time.',
                  ),
                ),
                button(
                  'timer-finalize',
                  'Finalize once',
                  () => coordinator.command(
                    TimerAction.finalize,
                    reportedMs: reportedWorkMilliseconds(
                      reported.text,
                      s!.eligibleMs,
                    ),
                    confirmed: confirmed,
                  ),
                ),
              ],
              ExpansionTile(
                key: const PageStorageKey('timer-segments'),
                title: const Text('Saved segment details'),
                children: [
                  for (final segment in view.segments)
                    ListTile(
                      title: Text(
                        '${segment.kind.name} · elapsed ${segment.elapsedMs} ms · eligible ${segment.eligibleMs} ms',
                      ),
                      subtitle: Text(
                        '${segment.fromUtc.toIso8601String()} → ${segment.toUtc.toIso8601String()}\n${segment.reason ?? 'observed interval'} · span ${segment.spanMs} ms',
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
