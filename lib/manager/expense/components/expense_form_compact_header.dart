library;

import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Builds the compact group header shown at the top of the form
class ExpenseFormCompactHeader extends StatelessWidget {
  final String? groupTitle;
  final bool showGroupHeader;

  const ExpenseFormCompactHeader({
    super.key,
    required this.groupTitle,
    required this.showGroupHeader,
  });

  @override
  Widget build(BuildContext context) {
    if (!(showGroupHeader && groupTitle != null)) {
      return const SizedBox.shrink();
    }

    final gloc = gen.AppLocalizations.of(context);
    final title = groupTitle!.trim();
    if (title.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prefixStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    );
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      overflow: TextOverflow.ellipsis,
    );

    return Semantics(
      container: true,
      header: true,
      label: '${gloc.in_group_prefix} $title',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Tooltip(
                message: title,
                waitDuration: const Duration(milliseconds: 400),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${gloc.in_group_prefix} ',
                        style: prefixStyle,
                      ),
                      TextSpan(text: title, style: titleStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
