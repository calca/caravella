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
  final VoidCallback? onShareQr;
  final VoidCallback? onManageDevices;
  final VoidCallback? onForceSync;

  const OptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onExportShare,
    this.onShareQr,
    this.onManageDevices,
    this.onForceSync,
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
              trip.pinned ? Icons.favorite : Icons.favorite_border,
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
              color: trip.archived
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38)
                  : Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(
              gloc.edit_group,
              style: trip.archived
                  ? TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
            ),
            onTap: trip.archived ? null : onEdit,
          ),
          if (onShareQr != null)
            ListTile(
              leading: Icon(
                Icons.qr_code_2,
                color: Theme.of(context).colorScheme.onPrimaryFixed,
              ),
              title: const Text('Share via QR'),
              subtitle: const Text('Multi-device sync'),
              onTap: onShareQr,
            ),
          if (onManageDevices != null)
            ListTile(
              leading: Icon(
                Icons.devices,
                color: Theme.of(context).colorScheme.onPrimaryFixed,
              ),
              title: const Text('Manage Devices'),
              subtitle: const Text('View and revoke access'),
              onTap: onManageDevices,
            ),
          if (onForceSync != null && trip.syncEnabled)
            ListTile(
              leading: Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.onPrimaryFixed,
              ),
              title: const Text('Force Sync'),
              subtitle: const Text('Synchronize now'),
              onTap: onForceSync,
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
