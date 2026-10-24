import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_system.dart';

class WorkspaceScroll extends StatelessWidget {
  const WorkspaceScroll({super.key, required this.child, this.storageKey});
  final Widget child;
  final String? storageKey;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: storageKey == null ? null : PageStorageKey(storageKey),
    padding: const EdgeInsets.all(Space.xl),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: child,
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.description,
  });
  final String title;
  final String? description;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (description != null) ...[
            const SizedBox(height: Space.sm),
            Text(description!),
          ],
          const SizedBox(height: Space.xl),
          child,
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Space.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: Space.lg),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Space.sm),
        Text(message),
      ],
    ),
  );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!MediaQuery.disableAnimationsOf(context))
        const LinearProgressIndicator()
      else
        const Icon(Icons.hourglass_empty),
      const SizedBox(height: Space.lg),
      Text(message, semanticsLabel: message),
    ],
  );
}

class ActionError extends StatelessWidget {
  const ActionError({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryKey,
    this.detailsLabel = 'Details',
    this.details,
    this.retryLabel = 'Retry',
  });
  final String title;
  final String message;
  final String? details;
  final String retryLabel;
  final VoidCallback onRetry;
  final Key? retryKey;
  final String detailsLabel;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: Space.lg),
      Text(message),
      const SizedBox(height: Space.lg),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: retryKey,
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryLabel),
        ),
      ),
      if (details != null)
        _ErrorDetails(label: detailsLabel, details: details!),
    ],
  );
}

class _ErrorDetails extends StatefulWidget {
  const _ErrorDetails({required this.label, required this.details});
  final String label;
  final String details;
  @override
  State<_ErrorDetails> createState() => _ErrorDetailsState();
}

class _ErrorDetailsState extends State<_ErrorDetails> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          expanded: _expanded,
          child: TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(widget.label),
          ),
        ),
      ),
      if (_expanded) SelectableText(widget.details),
    ],
  );
}

class PreferenceField extends StatelessWidget {
  const PreferenceField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.help,
    this.numeric = false,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String label;
  final String? help;
  final String? Function(String?) validator;
  final bool numeric;
  final bool enabled;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    validator: validator,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
    autocorrect: false,
    decoration: InputDecoration(labelText: label, helperText: help),
    textInputAction: TextInputAction.next,
  );
}
