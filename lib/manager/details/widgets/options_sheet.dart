import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
// ...existing code...
import '../../../data/expense_group.dart';
// ...existing code...

class OptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onDownloadCsv;
  final VoidCallback onShareCsv;
  const OptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onDownloadCsv,
    required this.onShareCsv,
  });

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      maxChildSize: 0.6,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loc.get('options'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Pin/Unpin action
                    ListTile(
                      leading: Icon(
                        trip.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      title: Text(trip.pinned
                          ? loc.get('unpin_group')
                          : loc.get('pin_group')),
                      onTap: onPinToggle,
                    ),
                    // Archive/Unarchive action
                    ListTile(
                      leading: Icon(
                        trip.archived
                            ? Icons.unarchive_rounded
                            : Icons.archive_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      title: Text(trip.archived
                          ? loc.get('unarchive')
                          : loc.get('archive')),
                      onTap: onArchiveToggle,
                    ),
                    const Divider(),
                    // Edit Group action
                    ListTile(
                      leading: Icon(
                        Icons.edit_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      title: Text(loc.get('edit_group')),
                      onTap: onEdit,
                    ),
                    const Divider(),
                    // Download CSV action
                    ListTile(
                      leading: Icon(
                        Icons.file_download_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      title: Text(loc.get('download_all_csv')),
                      onTap: onDownloadCsv,
                    ),
                    // Share CSV action
                    ListTile(
                      leading: Icon(
                        Icons.share_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      title: Text(loc.get('share_all_csv')),
                      onTap: onShareCsv,
                    ),
                    const Divider(),
                    // Delete action
                    ListTile(
                      leading: Icon(
                        Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: Text(
                        loc.get('delete_group'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
