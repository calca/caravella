import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Reusable styled FAB with consistent shadow and primary coloring.
class AddFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final String? heroTag;
  final IconData icon;
  final double iconSize;

  const AddFab({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    this.icon = Icons.add_rounded,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localizations = gen.AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Semantics(
        button: true,
        label: tooltip ?? localizations.accessibility_add_new_item,
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          child: Icon(icon, size: iconSize),
        ),
      ),
    );
  }
}
