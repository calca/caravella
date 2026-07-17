import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../sync/settings_sync_badge.dart';

class GroupActions extends StatelessWidget {
  final bool hasExpenses;
  final bool isPinned;
  final bool syncEnabled;
  final SyncOrchestrator? orchestrator;
  final VoidCallback? onOverview;
  final VoidCallback? onSearch;
  final VoidCallback? onFavorite;
  final VoidCallback? onSync;
  final VoidCallback? onOptions;
  const GroupActions({
    super.key,
    required this.hasExpenses,
    required this.isPinned,
    this.syncEnabled = false,
    this.orchestrator,
    this.onOverview,
    this.onSearch,
    this.onFavorite,
    this.onSync,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = 0.0;
        return SizedBox(
          height: 54,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Tooltip(
                  message: isPinned ? gloc.unpin_group : gloc.pin_group,
                  child: IconButton.filledTonal(
                    onPressed: onFavorite,
                    icon: Icon(
                      isPinned ? Icons.favorite : Icons.favorite_border,
                    ),
                    iconSize: 24,
                    tooltip: isPinned ? gloc.unpin_group : gloc.pin_group,
                    style: ctaStyle(),
                  ),
                ),
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
                Tooltip(
                  message: gloc.sync_title,
                  child: IconButton.filledTonal(
                    onPressed: onSync,
                    icon: syncEnabled && orchestrator != null
                        ? SyncStatusIcon(
                            orchestrator: orchestrator!,
                            icon: Icons.sync_outlined,
                            defaultColor: colorScheme.onSurface,
                          )
                        : const Icon(Icons.sync_outlined),
                    iconSize: 24,
                    tooltip: gloc.sync_title,
                    style: ctaStyle(),
                  ),
                ),
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
          ),
        );
      },
    );
  }
}
