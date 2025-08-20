import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/expense_group.dart';

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
  final gloc = gen.AppLocalizations.of(context);
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
                gloc.options,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bottomInset = MediaQuery.of(context).padding.bottom;
                    const extra = 24.0;
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16 + bottomInset + extra,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              trip.pinned
                                  ? Icons.push_pin_outlined
                                  : Icons.push_pin_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                            ),
                            title: Text(
                trip.pinned
                  ? gloc.unpin_group
                  : gloc.pin_group,
                            ),
                            onTap: onPinToggle,
                          ),
                          ListTile(
                            leading: Icon(
                              trip.archived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                            ),
                            title: Text(
                trip.archived
                  ? gloc.unarchive
                  : gloc.archive,
                            ),
                            onTap: onArchiveToggle,
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                            ),
                            title: Text(gloc.edit_group),
                            onTap: onEdit,
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.file_download_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                            ),
                            title: Text(gloc.download_all_csv),
                            onTap: onDownloadCsv,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.share_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                            ),
                            title: Text(gloc.share_all_csv),
                            onTap: onShareCsv,
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            title: Text(
                              gloc.delete_group,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
