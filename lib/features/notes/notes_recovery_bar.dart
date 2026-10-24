import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_system.dart';
import '../../app/navigation.dart';
import '../../core/database/providers.dart';
import 'note_controller.dart';
import 'note_providers.dart';

class NotesRecoveryBar extends ConsumerWidget {
  const NotesRecoveryBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(noteDraftsProvider);
    final route = ref.watch(shellNavigationProvider);
    final storage = ref.watch(repositoryProvider);
    return ListenableBuilder(
      listenable: drafts,
      builder: (context, _) {
        final hidden = drafts.unsaved
            .where(
              (c) =>
                  !storage.hasValue ||
                  storage.hasError ||
                  route.destination != Destination.notes ||
                  route.selectedRecords[Destination.notes] != c.id,
            )
            .toList();
        if (hidden.isEmpty) return const SizedBox.shrink();
        final failed = hidden
            .where((c) => c.state == NoteSaveState.failed)
            .toList();
        final first = failed.isNotEmpty ? failed.first : hidden.first;
        return Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.lg,
              vertical: Space.sm,
            ),
            child: Wrap(
              spacing: Space.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  failed.isNotEmpty
                      ? 'A note couldn’t save. Your draft is kept here.'
                      : 'A note has unsaved changes.',
                ),
                TextButton(
                  key: const Key('review-note-draft'),
                  onPressed: () => ref
                      .read(shellNavigationProvider.notifier)
                      .selectRecord(Destination.notes, first.id),
                  child: const Text('Review note'),
                ),
                TextButton.icon(
                  key: const Key('copy-hidden-note-draft'),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy draft'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await Clipboard.setData(
                        ClipboardData(text: first.copyText),
                      );
                      if (messenger.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Draft copied.')),
                        );
                      }
                    } catch (_) {
                      if (messenger.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Couldn’t copy. Return to the note and select its text.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
