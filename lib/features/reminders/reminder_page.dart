import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/value_types.dart';
import '../schedule/recurrence.dart';
import 'reminder_providers.dart';
import 'reminder_store.dart';
import 'reminder_types.dart';

class ReminderPage extends ConsumerStatefulWidget {
  const ReminderPage({super.key});
  @override
  ConsumerState<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends ConsumerState<ReminderPage> {
  final start = TextEditingController(),
      end = TextEditingController(),
      lead = TextEditingController(text: '0');
  bool initialized = false, quiet = true, busy = false;
  ReminderKind kind = ReminderKind.deadline;
  String? source, error, message;
  @override
  void dispose() {
    start.dispose();
    end.dispose();
    lead.dispose();
    super.dispose();
  }

  Future<void> act(Future<void> Function() command, {String? success}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      await command();
      if (mounted) setState(() => message = success);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String stamp(DateTime? d) =>
      d == null ? 'None confirmed' : '${d.toIso8601String()} (UTC)';
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderViewProvider);
    final view = state.value, data = view?.inputs;
    final owner = ref.watch(reminderCoordinatorProvider).value;
    if (data == null || owner == null) {
      return WorkspaceScroll(
        child: state.hasError
            ? ActionError(
                title: 'Reminders could not open',
                message: 'Your records are still saved. Retry opening reminder controls.',
                details: state.error.toString(),
                onRetry: () => ref.invalidate(reminderCoordinatorProvider),
              )
            : const LoadingState(message: 'Opening reminders…'),
      );
    }
    if (!initialized) {
      start.text = minuteLabel(data.preferences.quietStart);
      end.text = minuteLabel(data.preferences.quietEnd);
      quiet = data.preferences.quietEnabled;
      initialized = true;
    }
    final choices = <String, String>{};
    switch (kind) {
      case ReminderKind.deadline:
        for (final t in data.planning.tasks.where(
          (t) =>
              t.deletedAt == null &&
              t.archivedAt == null &&
              t.status != TaskStatus.done &&
              t.deadlineKind != DeadlineKind.none,
        )) {
          choices[t.id] = t.title;
        }
      case ReminderKind.activity:
        for (final s in data.planning.schedule.series.where(
          (s) => s.deletedAt == null,
        )) {
          choices[s.id] = s.title;
        }
      case ReminderKind.work:
        for (final b in data.planning.blocks.where(
          (b) => b.deletedAt == null && b.status == WorkBlockStatus.planned,
        )) {
          final task = data.planning.tasks
              .where(
                (t) =>
                    t.id == b.taskId &&
                    t.deletedAt == null &&
                    t.archivedAt == null &&
                    t.status != TaskStatus.done,
              )
              .firstOrNull;
          if (task != null) {
            choices[b.id] = '${task.title} · ${stamp(b.startUtc)}';
          }
        }
      case ReminderKind.timer:
        choices[data.installation.id] =
            'Starter, focus and break endpoints on this installation';
    }
    final selected = choices.containsKey(source) ? source : null;
    final notice = ref.watch(reminderNoticeProvider);
    return WorkspaceScroll(
      storageKey: 'reminders-scroll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref
                  .read(shellNavigationProvider.notifier)
                  .clearRecord(Destination.settings),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Settings'),
            ),
          ),
          Text('Reminders', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Space.md),
          const Text(
            'Choose which records may alert you. Notifications never finish tasks or credit work. Device settings and Do Not Disturb still apply.',
          ),
          if (notice != null) ...[
            Text(notice),
            TextButton(
              onPressed: () =>
                  ref.read(reminderNoticeProvider.notifier).show(null),
              child: const Text('Dismiss message'),
            ),
          ],
          const SizedBox(height: Space.lg),
          SectionCard(
            title: 'Access and status',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable reminders'),
                  subtitle: const Text(
                    'Enabling asks Android for notification access. Exact-alarm access is separate and optional.',
                  ),
                  value: data.preferences.enabled,
                  onChanged: busy ? null : (v) => act(() => owner.enable(v)),
                ),
                Text(
                  view!.capability?.message ?? 'Access has not been requested. Enable reminders or check status.',
                ),
                Text('Last checked: ${stamp(view.checkedUtc)}'),
                Text(
                  'Actual scheduled-through date (last future alert): ${stamp(view.scheduledThrough)}',
                ),
                Text('Sources checked through: ${stamp(view.coverageThrough)}'),
                Text(
                  'Confirmed future alerts: ${view.registrations.where((r) => r.state == RegistrationState.scheduled && r.dueUtc.isAfter(owner.clock.sample().wallUtc)).length}. Capacity: 127 general alerts plus one timer endpoint. Late alerts and cancellation failures can also occupy slots.',
                ),
                if (view.plan != null)
                  Text(
                    '${view.plan!.truncated} deferred by capacity; ${view.plan!.quietSuppressed} suppressed by quiet hours. The rolling horizon refreshes on launch, return, edits and while the app runs.',
                  ),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () =>
                                act(() => owner.reconcile(refreshStatus: true)),
                      child: const Text('Refresh / Retry scheduling'),
                    ),
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => act(owner.service.openSettings),
                      child: const Text('Device notification settings'),
                    ),
                    if (Theme.of(context).platform == TargetPlatform.android)
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => act(() async {
                                await owner.service.requestExactAccess();
                                await owner.reconcile(refreshStatus: true);
                              }),
                        child: const Text('Optional exact-alarm access'),
                      ),
                    OutlinedButton(
                      onPressed: busy || !data.preferences.enabled
                          ? null
                          : () => act(
                              owner.testNotification,
                              success: 'The device accepted the test request. This does not confirm that it was displayed or seen.',
                            ),
                      child: const Text('Test notification'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          SectionCard(
            title: 'Quiet hours',
            description:
                'Uses ${data.settings.planningZone}. General alerts move to quiet-hours end only if still useful before their source time. Timer alerts during quiet hours are suppressed.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use quiet hours'),
                  value: quiet,
                  onChanged: busy ? null : (v) => setState(() => quiet = v),
                ),
                TextField(
                  controller: start,
                  decoration: const InputDecoration(
                    labelText: 'Quiet start (HH:MM)',
                  ),
                ),
                const SizedBox(height: Space.md),
                TextField(
                  controller: end,
                  decoration: const InputDecoration(
                    labelText: 'Quiet end (HH:MM)',
                  ),
                ),
                const SizedBox(height: Space.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () => act(() async {
                            await owner.store.preferences(
                              enabled: data.preferences.enabled,
                              quietEnabled: quiet,
                              start: parseMinute(start.text),
                              end: parseMinute(end.text),
                            );
                            await owner.reconcile();
                          }, success: 'Quiet hours saved.'),
                    child: const Text('Save quiet hours'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          SectionCard(
            title: 'Add or update a reminder',
            description: 'One opt-in rule per record. Date-only deadlines use 09:00 in the deadline’s saved zone. No overdue catch-up alerts.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<ReminderKind>(
                  initialValue: kind,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Reminder type'),
                  items: [
                    for (final k in ReminderKind.values)
                      DropdownMenuItem(value: k, child: Text(k.name)),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          kind = v!;
                          source = null;
                          if (kind == ReminderKind.timer) lead.text = '0';
                        }),
                ),
                const SizedBox(height: Space.lg),
                if (choices.isEmpty)
                  const Text(
                    'No eligible records yet. Create a deadline, activity or planned work first.',
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey('$kind/$selected/${choices.keys.join()}'),
                    initialValue: selected,
                    isExpanded: true,
                    itemHeight: null,
                    selectedItemBuilder: (_) => [
                      for (final title in choices.values)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    decoration: const InputDecoration(labelText: 'Record'),
                    items: [
                      for (final entry in choices.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: busy ? null : (v) => setState(() => source = v),
                  ),
                const SizedBox(height: Space.lg),
                TextField(
                  controller: lead,
                  enabled: kind != ReminderKind.timer,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes before (0–10080)',
                  ),
                ),
                const SizedBox(height: Space.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: busy || selected == null
                        ? null
                        : () => act(
                            () async {
                              final minutes = int.tryParse(lead.text);
                              if (minutes == null) {
                                throw const FormatException(
                                  'Enter whole minutes.',
                                );
                              }
                              await owner.store.setRule(
                                kind,
                                selected,
                                leadMinutes: minutes,
                              );
                              await owner.reconcile();
                            },
                            success:
                                'Rule saved. Check scheduling status above.',
                          ),
                    child: const Text('Save reminder rule'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          SectionCard(
            title: 'Your rules',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.rules.isEmpty) const Text('No reminders selected.'),
                for (final rule in data.rules)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${rule.kind.name} · ${_sourceTitle(data, rule.kind, reminderSourceId(rule))}',
                    ),
                    subtitle: Text('${rule.leadMinutes} minutes before'),
                    value: rule.enabled,
                    onChanged: busy
                        ? null
                        : (v) => act(() async {
                            await owner.store.setRule(
                              rule.kind,
                              reminderSourceId(rule),
                              enabled: v,
                              leadMinutes: rule.leadMinutes,
                            );
                            await owner.reconcile();
                          }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          if (view.error != null || error != null)
            ActionError(
              title: 'Reminder action needs attention',
              message: 'Saved source records are preserved. Check access and storage, then retry.',
              details: (error ?? view.error).toString(),
              onRetry: () => act(() => owner.reconcile(refreshStatus: true)),
            ),
          if (message != null)
            Semantics(liveRegion: true, child: Text(message!)),
          SectionCard(
            title: 'Recent scheduling results',
            description: 'Elapsed means the trigger time passed, not delivered or seen. No automatic overdue nagging. Opened is recorded only after you open a valid notification source.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (view.registrations.isEmpty)
                  const Text('No notification registrations yet.'),
                for (final row in view.registrations.reversed.take(30))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${row.state.name} · ${stamp(row.dueUtc)}${row.openedAtUtc == null ? ' · opening unconfirmed' : ' · opened'}',
                        ),
                        if (row.error != null) Text(row.error!),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: busy
                                ? null
                                : () => act(
                                    () =>
                                        owner.onResponse('momentum:${row.id}'),
                                  ),
                            child: const Text('Open current source'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sourceTitle(ReminderInputs data, ReminderKind k, String id) =>
      switch (k) {
        ReminderKind.deadline =>
          data.planning.tasks.where((t) => t.id == id).firstOrNull?.title ??
              'Unavailable task',
        ReminderKind.activity =>
          data.planning.schedule.series
                  .where((s) => s.id == id)
                  .firstOrNull
                  ?.title ??
              'Unavailable activity',
        ReminderKind.work => 'Work block $id',
        ReminderKind.timer => 'Session endpoints',
      };
}
