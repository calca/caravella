import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../details/pages/expense_group_detail_page.dart';
import 'group_options.dart';

/// Expense group card with long-press contextual menu
class SwipeableExpenseGroupCard extends StatelessWidget {
  final ExpenseGroup trip;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final String? searchQuery;

  const SwipeableExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onArchiveToggle,
    this.onDelete,
    this.onPin,
    this.searchQuery,
  });

  void _showContextMenu(BuildContext context) => showGroupOptionsSheet(
    context,
    trip: trip,
    onArchiveToggle: onArchiveToggle,
    onDelete: onDelete,
    onPin: onPin,
  );

  @override
  Widget build(BuildContext context) {
    final total = trip.getTotalExpenses();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildCard(context, total),
    );
  }

  Widget _buildCard(BuildContext context, double total) {
    return Semantics(
      button: true,
      child: MergeSemantics(child: _buildCardInkWell(context, total)),
    );
  }

  Widget _buildCardInkWell(BuildContext context, double total) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpenseGroupDetailPage(trip: trip),
          ),
        );
      },
      onLongPress: () => _showContextMenu(context),
      borderRadius: BorderRadius.circular(16),
      child: BaseCard(
        backgroundColor: Theme.of(context).colorScheme.surface,
        noBorder: true,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExpenseGroupAvatar(
              trip: trip,
              size: 48,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedTitle(context),
                  const SizedBox(height: 8),
                  _buildParticipantsRow(context),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CurrencyDisplay(
                  value: total,
                  currency: trip.currency,
                  valueFontSize: 20.0,
                  currencyFontSize: 16.0,
                  alignment: MainAxisAlignment.end,
                  showDecimals: true,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(BuildContext context) {
    final title = trip.title;
    final query = searchQuery?.toLowerCase().trim();

    if (query == null || query.isEmpty) {
      return Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final highlightStyle = baseStyle?.copyWith(
      backgroundColor: colorScheme.primaryContainer,
      color: colorScheme.onPrimaryContainer,
    );

    final lowerTitle = title.toLowerCase();
    final spans = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < title.length) {
      final queryIndex = lowerTitle.indexOf(query, currentIndex);

      if (queryIndex == -1) {
        spans.add(
          TextSpan(text: title.substring(currentIndex), style: baseStyle),
        );
        break;
      }

      if (queryIndex > currentIndex) {
        spans.add(
          TextSpan(
            text: title.substring(currentIndex, queryIndex),
            style: baseStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: title.substring(queryIndex, queryIndex + query.length),
          style: highlightStyle,
        ),
      );
      currentIndex = queryIndex + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildParticipantsRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.group_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            trip.participants.length <= 2
                ? trip.participants.map((p) => p.name).join(', ')
                : gen.AppLocalizations.of(
                    context,
                  ).participant_count(trip.participants.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
