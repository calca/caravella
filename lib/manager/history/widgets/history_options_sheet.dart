import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../widgets/bottom_sheet_scaffold.dart';

class HistoryOptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  const HistoryOptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GroupBottomSheetScaffold(
      title: trip.title,
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
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            title: Text(trip.pinned ? gloc.unpin : gloc.pin),
            onTap: onPinToggle,
          ),
          ListTile(
            leading: Icon(
              trip.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              color: trip.archived
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            title: Text(trip.archived ? gloc.unarchive : gloc.archive),
            onTap: onArchiveToggle,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              gloc.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
