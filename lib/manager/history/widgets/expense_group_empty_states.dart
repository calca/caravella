import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class ExpsenseGroupEmptyStates extends StatelessWidget {
  final String searchQuery;
  final String periodFilter;
  final VoidCallback onTripAdded;

  const ExpsenseGroupEmptyStates({
    super.key,
    required this.searchQuery,
    required this.periodFilter,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    // Search has priority
    if (searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(context);
    }

    // Specific archived empty state
    if (periodFilter == 'archived') return _buildArchivedEmptyState(context);

    return _buildAllEmptyState(context);
  }

  Widget _buildSimpleEmptyState(
    BuildContext context, {
    required IconData icon,
    double size = 64,
    Color? iconColor,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? action,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  }) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: size, color: iconColor ?? theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          title,
          style: titleStyle ?? theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null || subtitleWidget != null) ...[
          const SizedBox(height: 8),
          subtitleWidget ??
              Text(
                subtitle!,
                style: subtitleStyle ?? theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
        ],
        if (action != null) ...[const SizedBox(height: 16), action],
      ],
    );
  }

  Widget _buildArchivedEmptyState(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return _buildSimpleEmptyState(
      context,
      icon: Icons.archive_outlined,
      title: gloc.no_archived_groups,
      subtitle: gloc.no_archived_groups_subtitle,
      iconColor: Theme.of(context).colorScheme.outline,
    );
  }

  Widget _buildSearchEmptyState(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return _buildSimpleEmptyState(
      context,
      icon: Icons.search_off_outlined,
      title: '${gloc.no_search_results} "$searchQuery"',
      iconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      subtitleWidget: Text(
        gloc.try_different_search,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAllEmptyState(BuildContext context) {
    // Use a layout similar to archived but for the 'all' state
    final gloc = gen.AppLocalizations.of(context);
    return _buildSimpleEmptyState(
      context,
      icon: Icons.play_circle_outline_outlined,
      title: gloc.no_active_groups,
      subtitle: gloc.create_first_group,
      iconColor: Theme.of(context).colorScheme.outline,
    );
  }
}
