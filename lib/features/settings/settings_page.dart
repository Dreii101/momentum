import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/components.dart';
import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../app/release_info.dart';
import '../reminders/reminder_page.dart';
import '../backup/backup_page.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';

class SaveSettingsIntent extends Intent {
  const SaveSettingsIntent();
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _form = GlobalKey<FormState>();
  final _zone = TextEditingController();
  final _focus = TextEditingController();
  final _break = TextEditingController();
  Settings? _initial;
  ThemePreference _theme = ThemePreference.system;
  bool _reduced = false;
  bool _saving = false;
  String? _error;
  String? _savedMessage;
  @override
  void dispose() {
    _zone.dispose();
    _focus.dispose();
    _break.dispose();
    super.dispose();
  }

  void _initialize(Settings settings) {
    if (_initial != null) return;
    _initial = settings;
    _theme = settings.theme;
    _zone.text = settings.planningZone;
    _focus.text = settings.focusMinutes.toString();
    _break.text = settings.breakMinutes.toString();
    _reduced = settings.reducedMotion;
  }

  void _changed() {
    if (_savedMessage != null) setState(() => _savedMessage = null);
  }

  String? _minutes(String? value, int max) {
    final minutes = int.tryParse(value ?? '');
    return minutes == null || minutes < 1 || minutes > max
        ? 'Enter a whole number from 1 to $max.'
        : null;
  }

  Future<void> _save() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
      _savedMessage = null;
    });
    try {
      final repository = await ref.read(repositoryProvider.future);
      await repository.updateSettings(
        theme: _theme,
        planningZone: _zone.text.trim(),
        focusMinutes: int.parse(_focus.text),
        breakMinutes: int.parse(_break.text),
        reducedMotion: _reduced,
      );
      if (!mounted) return;
      setState(() => _savedMessage = 'Saved on this device.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref
            .watch(shellNavigationProvider)
            .selectedRecords[Destination.settings] ==
        'data') {
      return const BackupPage();
    }
    if (ref
            .watch(shellNavigationProvider)
            .selectedRecords[Destination.settings] ==
        'reminders') {
      return const ReminderPage();
    }
    final settings = ref.watch(settingsProvider);
    final current = settings.value;
    if (current != null) _initialize(current);
    if (_initial == null) {
      return WorkspaceScroll(
        child: settings.hasError
            ? ActionError(
                title: 'Preferences could not open',
                message: 'Retry to read your saved preferences. No defaults have been saved over them.',
                details: settings.error.toString(),
                onRetry: () => ref.invalidate(settingsProvider),
              )
            : const LoadingState(message: 'Opening preferences…'),
      );
    }
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyS, control: true):
            SaveSettingsIntent(),
      },
      child: Actions(
        actions: {
          SaveSettingsIntent: CallbackAction<SaveSettingsIntent>(
            onInvoke: (_) {
              _save();
              return null;
            },
          ),
        },
        child: WorkspaceScroll(
          storageKey: 'settings-scroll',
          child: Form(
            key: _form,
            onChanged: _changed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Space.sm),
                const Text(
                  'Make this space comfortable for you. Changes apply when you save.',
                ),
                const SizedBox(height: Space.xl),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(shellNavigationProvider.notifier)
                      .selectRecord(Destination.settings, 'reminders'),
                  icon: const Icon(Icons.notifications_outlined),
                  label: const Text('Reminders and notification access'),
                ),
                const SizedBox(height: Space.xl),
                OutlinedButton.icon(
                  key: const Key('open-data'),
                  onPressed: () => ref
                      .read(shellNavigationProvider.notifier)
                      .selectRecord(Destination.settings, 'data'),
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Data, export and replacement restore'),
                ),
                const SizedBox(height: Space.xl),
                if (settings.hasError) ...[
                  ActionError(
                    title: 'Saved preferences could not refresh',
                    message: 'Your edits are still here. Retry reading without clearing this form.',
                    details: settings.error.toString(),
                    onRetry: () => ref.invalidate(settingsProvider),
                  ),
                  const SizedBox(height: Space.xl),
                ],
                SectionCard(
                  title: 'Appearance',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<ThemePreference>(
                        key: const Key('theme-preference'),
                        initialValue: _theme,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Theme',
                          helperText: 'System follows your device appearance.',
                        ),
                        items: [
                          for (final theme in ThemePreference.values)
                            DropdownMenuItem(
                              value: theme,
                              child: Text(switch (theme) {
                                ThemePreference.system => 'System',
                                ThemePreference.light => 'Light',
                                ThemePreference.dark => 'Dark',
                              }),
                            ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _theme = value!;
                                _savedMessage = null;
                              }),
                      ),
                      const SizedBox(height: Space.lg),
                      SwitchListTile(
                        key: const Key('reduced-motion'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reduce motion'),
                        subtitle: const Text(
                          'Use immediate changes and fewer transitions. Device accessibility settings are always respected.',
                        ),
                        value: _reduced,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _reduced = value;
                                _savedMessage = null;
                              }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xl),
                SectionCard(
                  title: 'Timer defaults',
                  description: 'Starter sessions always last two minutes.',
                  child: Column(
                    children: [
                      PreferenceField(
                        key: const Key('focus-minutes'),
                        controller: _focus,
                        label: 'Focus minutes',
                        help: '1–180 minutes',
                        numeric: true,
                        enabled: !_saving,
                        validator: (value) => _minutes(value, 180),
                      ),
                      const SizedBox(height: Space.xl),
                      PreferenceField(
                        key: const Key('break-minutes'),
                        controller: _break,
                        label: 'Break minutes',
                        help: '1–60 minutes',
                        numeric: true,
                        enabled: !_saving,
                        validator: (value) => _minutes(value, 60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xl),
                SectionCard(
                  title: 'Planning',
                  child: PreferenceField(
                    key: const Key('planning-zone'),
                    controller: _zone,
                    label: 'Planning time zone',
                    enabled: !_saving,
                    help: 'For example Asia/Manila or Europe/London. Saved deadlines keep their original time zone.',
                    validator: (value) {
                      try {
                        requireTimeZone((value ?? '').trim());
                        return null;
                      } catch (_) {
                        return 'Enter a valid time zone, such as Asia/Manila.';
                      }
                    },
                  ),
                ),
                const SizedBox(height: Space.xl),
                if (_error != null) ...[
                  ActionError(
                    title: 'Changes could not be saved',
                    message: 'Your edits are still here. Check storage access and retry.',
                    details: _error,
                    onRetry: _save,
                    retryLabel: 'Retry saving',
                  ),
                  const SizedBox(height: Space.lg),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    key: const Key('save-settings'),
                    onPressed: _saving ? null : _save,
                    icon: Icon(_saving ? Icons.hourglass_empty : Icons.check),
                    label: Text(_saving ? 'Saving…' : 'Save changes'),
                  ),
                ),
                const SizedBox(height: Space.md),
                Semantics(
                  liveRegion: true,
                  child: Text(_savedMessage ?? 'Changes stay on this device.'),
                ),
                const SizedBox(height: Space.xl),
                const SectionCard(
                  title: 'About Momentum',
                  child: SelectableText(
                    'Version $momentumVersion (build $momentumBuild) · Private MVP\n'
                    'Your workspace stays on this device. Export a backup outside '
                    'app storage before reinstalling or moving devices. Backups '
                    'are unencrypted; keep them somewhere private.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
