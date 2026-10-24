import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/providers.dart';
import 'components.dart';

class StorageGate extends ConsumerWidget {
  const StorageGate({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(repositoryProvider)
      .when(
        skipLoadingOnRefresh: false,
        data: (_) => child,
        loading: () => const WorkspaceScroll(
          child: LoadingState(message: 'Opening your saved workspace…'),
        ),
        error: (error, _) => WorkspaceScroll(
          child: ActionError(
            title: 'Your saved workspace could not open',
            message:
                'Your database has not been reset. Check available disk space '
                'and folder access, then retry. If the database is from a newer app version, '
                'open it with that version. For a migration or corruption error, keep '
                'the original files and seek repair before restoring a verified backup.',
            details: error.toString(),
            detailsLabel: 'Storage details',
            retryLabel: 'Retry opening',
            retryKey: const Key('retry-storage'),
            onRetry: () => ref.invalidate(repositoryProvider),
          ),
        ),
      );
}
