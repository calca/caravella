import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class OptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onExportShare;

  const OptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onExportShare,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GroupBottomSheetScaffold(
      title: gloc.options,
      scrollable: false, // dynamic height, no internal scroll
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        bottomInset > 0 ? bottomInset : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              trip.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: trip.archived
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38)
                  : Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(
              trip.pinned ? gloc.unpin_group : gloc.pin_group,
              style: trip.archived
                  ? TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
            ),
            onTap: trip.archived ? null : onPinToggle,
          ),
          ListTile(
            leading: Icon(
              trip.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(trip.archived ? gloc.unarchive : gloc.archive),
            onTap: onArchiveToggle,
          ),
          ListTile(
            leading: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.edit_group),
            onTap: onEdit,
          ),
          ListTile(
            leading: Icon(
              Icons.ios_share_outlined,
              color: trip.expenses.isEmpty
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38)
                  : Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(
              gloc.export_share,
              style: trip.expenses.isEmpty
                  ? TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
            ),
            onTap: trip.expenses.isEmpty ? null : onExportShare,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            title: Text(
              gloc.delete_group,
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
