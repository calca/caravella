import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// A single "who did this" line: e.g. "Added by Mario".
class AuthorshipLine {
  final IconData icon;
  final String label;
  final String name;

  const AuthorshipLine({
    required this.icon,
    required this.label,
    required this.name,
  });
}

/// Decides which authorship lines to show for [expense].
///
/// - Both `null` when there's nothing usable to display (no line at all).
/// - Only "added by" when the expense was never edited by anyone else, or
///   the edit came from the same device/user that created it.
/// - Only "edited by" when `createdBy` has no display name (e.g. a legacy
///   expense from before this feature existed) — no fabricated authorship.
/// - Both when creation and last edit differ.
List<AuthorshipLine> buildAuthorshipLines({
  required ExpenseDetails expense,
  required String addedByLabel,
  required String editedByLabel,
}) {
  final createdBy = expense.createdBy;
  final updatedBy = expense.updatedBy;
  final sameAuthor = createdBy != null && createdBy == updatedBy;

  final lines = <AuthorshipLine>[];

  final createdName = createdBy?.displayName;
  if (createdName != null) {
    lines.add(
      AuthorshipLine(
        icon: Icons.person_add_alt_outlined,
        label: addedByLabel,
        name: createdName,
      ),
    );
  }

  final updatedName = updatedBy?.displayName;
  if (updatedName != null && !sameAuthor) {
    lines.add(
      AuthorshipLine(
        icon: Icons.edit_outlined,
        label: editedByLabel,
        name: updatedName,
      ),
    );
  }

  return lines;
}

/// Shows who created/last edited [expense] — but only once it's confirmed
/// the group actually has another paired device (checked via
/// [orchestrator]), so a solo user never sees "Added by" themselves.
class ExpenseAuthorshipInfo extends StatefulWidget {
  final SyncOrchestrator orchestrator;
  final ExpenseGroup group;
  final ExpenseDetails expense;

  const ExpenseAuthorshipInfo({
    super.key,
    required this.orchestrator,
    required this.group,
    required this.expense,
  });

  @override
  State<ExpenseAuthorshipInfo> createState() => _ExpenseAuthorshipInfoState();
}

class _ExpenseAuthorshipInfoState extends State<ExpenseAuthorshipInfo> {
  late Future<List<PairedDevice>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.orchestrator.getPairedDevicesForGroup(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PairedDevice>>(
      future: _future,
      builder: (context, snapshot) {
        final devices = snapshot.data;
        if (devices == null || devices.isEmpty) {
          return const SizedBox.shrink();
        }

        final gloc = gen.AppLocalizations.of(context);
        final lines = buildAuthorshipLines(
          expense: widget.expense,
          addedByLabel: gloc.added_by,
          editedByLabel: gloc.edited_by,
        );
        if (lines.isEmpty) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final mutedColor = colorScheme.onSurface.withValues(alpha: 0.7);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(line.icon, size: 13, color: mutedColor),
                      const SizedBox(width: 4),
                      Text(
                        '${line.label} ${line.name}',
                        style: textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
