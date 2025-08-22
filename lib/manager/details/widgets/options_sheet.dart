import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../../widgets/bottom_sheet_scaffold.dart';

class OptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onDownloadCsv;
  final VoidCallback onShareCsv;
  final VoidCallback onDownloadOfx;
  final VoidCallback onShareOfx;

  const OptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onDownloadCsv,
    required this.onShareCsv,
    required this.onDownloadOfx,
    required this.onShareOfx,
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
              trip.pinned ? Icons.push_pin_outlined : Icons.push_pin_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(trip.pinned ? gloc.unpin_group : gloc.pin_group),
            onTap: onPinToggle,
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
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.download_all_csv),
            onTap: onDownloadCsv,
          ),
          ListTile(
            leading: Icon(
              Icons.share_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.share_all_csv),
            onTap: onShareCsv,
          ),
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.download_all_ofx),
            onTap: onDownloadOfx,
          ),
          ListTile(
            leading: Icon(
              Icons.share_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.share_all_ofx),
            onTap: onShareOfx,
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
