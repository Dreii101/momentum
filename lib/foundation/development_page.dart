import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'probe_services.dart';
import '../features/focus/timer_development_panel.dart';

class DevelopmentPage extends ConsumerStatefulWidget {
  const DevelopmentPage({super.key});
  @override
  ConsumerState<DevelopmentPage> createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends ConsumerState<DevelopmentPage> {
  final Map<String, String> _results = {};
  String? _busy;

  Future<void> _run(String section, Future<String> Function() operation) async {
    if (_busy != null) return;
    setState(() => _busy = section);
    try {
      final result = await operation();
      if (mounted) setState(() => _results[section] = result);
    } catch (error) {
      if (mounted) {
        setState(() => _results[section] = 'Check could not finish: $error');
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.read(probeServicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Development checks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Platform diagnostics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These probes use separate storage and one notification ID. '
                  'They do not create tasks, notes, timers or backups. '
                  'Checks are hidden in ordinary release builds.',
                ),
                const SizedBox(height: 16),
                _section(
                  'database',
                  'Local database',
                  'Write, close and reopen. Relaunch the application, then read the saved probe.',
                  [
                    _action(
                      'Write and reopen',
                      'probe-write',
                      () => _run(
                        'database',
                        () => services.databaseProbe(write: true),
                      ),
                    ),
                    _action(
                      'Read saved probe',
                      'probe-read',
                      () => _run(
                        'database',
                        () => services.databaseProbe(write: false),
                      ),
                    ),
                  ],
                ),
                _section(
                  'files',
                  'Native file dialogs',
                  'Save the small JSON fixture, then select it using Open. Also cancel each dialog. This is not backup/restore.',
                  [
                    _action(
                      'Save fixture',
                      'fixture-save',
                      () => _run('files', services.saveFixture),
                    ),
                    _action(
                      'Open fixture',
                      'fixture-open',
                      () => _run('files', services.openFixture),
                    ),
                  ],
                ),
                _section(
                  'environment',
                  'Platform and package identity',
                  'Executable and installed-package checks are recorded separately.',
                  [
                    _action(
                      'Check environment',
                      'environment-check',
                      () => _run('environment', services.environmentProbe),
                    ),
                  ],
                ),
                _section(
                  'notifications',
                  'Notification scheduling',
                  'Schedule one probe around a minute ahead, then cancel before it is due. '
                      'Run a separate delivery control. Permission is requested only after Schedule.',
                  [
                    _action(
                      'Schedule probe',
                      'notification-schedule',
                      () =>
                          _run('notifications', services.scheduleNotification),
                    ),
                    _action(
                      'Cancel probe',
                      'notification-cancel',
                      () => _run('notifications', services.cancelNotification),
                    ),
                    _action(
                      'Inspect probe',
                      'notification-inspect',
                      () => _run('notifications', services.inspectNotification),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const TimerDevelopmentPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _action(String label, String key, VoidCallback action) =>
      OutlinedButton(
        key: Key(key),
        onPressed: _busy == null ? action : null,
        child: Text(label),
      );

  Widget _section(
    String id,
    String title,
    String explanation,
    List<Widget> buttons,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(explanation),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 8, children: buttons),
            if (_busy == id) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                semanticsLabel: 'Check in progress',
              ),
            ],
            if (_results[id] != null) ...[
              const SizedBox(height: 12),
              SelectableText(_results[id]!, key: Key('$id-result')),
            ],
          ],
        ),
      ),
    ),
  );
}
