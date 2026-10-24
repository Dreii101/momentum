import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/providers.dart';
import '../core/database/value_types.dart';
import '../features/notes/note_providers.dart';
import '../features/tasks/task_workflow.dart';
import '../features/focus/timer_providers.dart';
import '../features/reminders/reminder_providers.dart';
import '../features/backup/backup_providers.dart';
import 'components.dart';
import 'adaptive_shell.dart';
import 'design_system.dart';
import 'navigation.dart';

const developmentChecksEnabled =
    kDebugMode || bool.fromEnvironment('MOMENTUM_DEV_CHECKS');

class MomentumApp extends ConsumerStatefulWidget {
  const MomentumApp({
    super.key,
    this.showDevelopment = developmentChecksEnabled,
    this.platform,
  });
  final bool showDevelopment;
  final TargetPlatform? platform;
  @override
  ConsumerState<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends ConsumerState<MomentumApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() => setState(() {});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timer = ref.read(timerCoordinatorProvider).value;
    if (timer != null && state != AppLifecycleState.hidden) {
      unawaited(
        timer
            .lifecycle(state != AppLifecycleState.resumed)
            .catchError((Object _) => null),
      );
    }
    if (state == AppLifecycleState.resumed) {
      final reminders = ref.read(reminderCoordinatorProvider).value;
      if (reminders != null) {
        unawaited(reminders.reconcile(refreshStatus: true));
      }
      ref.read(workflowInstantProvider.notifier).refresh();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(ref.read(noteDraftsProvider).flushAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    // The timer owner outlives every destination and development page.
    ref.watch(timerCoordinatorProvider);
    ref.watch(reminderCoordinatorProvider);
    // This listener lives outside paused destination subtrees.
    ref.listen(shellNavigationProvider, (previous, next) {
      if (previous?.destination == Destination.notes &&
          (next.destination != Destination.notes ||
              previous?.selectedRecords[Destination.notes] !=
                  next.selectedRecords[Destination.notes])) {
        unawaited(
          ref
              .read(noteDraftsProvider)
              .flush(previous?.selectedRecords[Destination.notes]),
        );
      }
    });
    final preferences = ref.watch(settingsProvider).value;
    final backupBusy = ref.watch(
      backupControllerProvider.select((s) => s.busy),
    );
    final workspaceVersion = ref.watch(
      shellNavigationProvider.select((s) => s.workspaceVersion),
    );
    final reduced =
        (preferences?.reducedMotion ?? false) ||
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: momentumTheme(Brightness.light, platform: widget.platform),
      darkTheme: momentumTheme(Brightness.dark, platform: widget.platform),
      themeMode: switch (preferences?.theme) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      themeAnimationDuration: reduced ? Duration.zero : Space.motion,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: media.disableAnimations || reduced,
          ),
          child: Stack(
            children: [
              ExcludeFocus(excluding: backupBusy, child: child!),
              if (backupBusy) ...[
                const Positioned.fill(
                  child: ModalBarrier(
                    dismissible: false,
                    color: Color(0x99000000),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: LoadingState(
                          message:
                              'Working with your backup. Keep Momentum open…',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      home: AdaptiveShell(
        key: ValueKey(workspaceVersion),
        showDevelopment: widget.showDevelopment,
      ),
    );
  }
}
