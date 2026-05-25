import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class GroupActions extends StatelessWidget {
  final bool hasExpenses;
  final bool isPinned;
  final VoidCallback? onOverview;
  final VoidCallback? onSearch;
  final VoidCallback? onFavorite;
  final VoidCallback? onOptions;
  const GroupActions({
    super.key,
    required this.hasExpenses,
    required this.isPinned,
    this.onOverview,
    this.onSearch,
    this.onFavorite,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    ButtonStyle ctaStyle() {
      return IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(54, 54),
      );
    }

    return SizedBox(
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: isPinned ? gloc.unpin_group : gloc.pin_group,
            child: IconButton.filledTonal(
              onPressed: onFavorite,
              icon: Icon(isPinned ? Icons.favorite : Icons.favorite_border),
              iconSize: 24,
              tooltip: isPinned ? gloc.unpin_group : gloc.pin_group,
              style: ctaStyle(),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: hasExpenses
                ? gloc.overview_and_statistics
                : gloc.no_expenses_to_display,
            child: IconButton.filledTonal(
              onPressed: hasExpenses ? onOverview : null,
              icon: const Icon(Icons.analytics_outlined),
              iconSize: 24,
              tooltip: gloc.overview,
              style: ctaStyle(),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: hasExpenses
                ? gloc.search_expenses
                : gloc.no_expenses_to_display,
            child: IconButton.filledTonal(
              onPressed: hasExpenses ? onSearch : null,
              icon: const Icon(Icons.search_outlined),
              iconSize: 24,
              tooltip: gloc.search_expenses,
              style: ctaStyle(),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: gloc.options,
            child: IconButton.filledTonal(
              onPressed: onOptions,
              icon: const Icon(Icons.settings_outlined),
              iconSize: 24,
              tooltip: gloc.options,
              style: ctaStyle(),
            ),
          ),
        ],
      ),
    );
  }
}
