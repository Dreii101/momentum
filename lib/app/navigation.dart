import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Destination {
  today('Today', Icons.wb_sunny_outlined),
  tasks('Tasks', Icons.check_circle_outline),
  plan('Plan', Icons.calendar_month_outlined),
  notes('Notes', Icons.description_outlined),
  progress('Progress', Icons.insights_outlined),
  settings('Settings', Icons.settings_outlined);

  const Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}

@immutable
class ShellRoute {
  const ShellRoute({
    this.destination = Destination.today,
    this.selectedRecords = const {},
    this.workspaceVersion = 0,
  });
  final Destination destination;
  final int workspaceVersion;

  /// Selection is transient route state, ready for later list/detail editors.
  final Map<Destination, String> selectedRecords;
}

class ShellNavigation extends Notifier<ShellRoute> {
  @override
  ShellRoute build() => const ShellRoute();
  void go(Destination destination) => state = ShellRoute(
    destination: destination,
    selectedRecords: state.selectedRecords,
    workspaceVersion: state.workspaceVersion,
  );
  void selectRecord(Destination destination, String id) => state = ShellRoute(
    destination: destination,
    workspaceVersion: state.workspaceVersion,
    selectedRecords: Map.unmodifiable({
      ...state.selectedRecords,
      destination: id,
    }),
  );
  void clearRecord(Destination destination) => state = ShellRoute(
    destination: destination,
    workspaceVersion: state.workspaceVersion,
    selectedRecords: Map.unmodifiable(
      {...state.selectedRecords}..remove(destination),
    ),
  );
  void resetAfterReplacement() => state = ShellRoute(
    destination: Destination.settings,
    selectedRecords: const {Destination.settings: 'data'},
    workspaceVersion: state.workspaceVersion + 1,
  );
}

final shellNavigationProvider = NotifierProvider<ShellNavigation, ShellRoute>(
  ShellNavigation.new,
);
