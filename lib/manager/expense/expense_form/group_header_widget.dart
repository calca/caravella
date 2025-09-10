import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Displays the group title header (only when extended fields are visible).
class GroupHeaderWidget extends StatelessWidget {
  final bool show;
  final String? groupTitle;

  const GroupHeaderWidget({
    super.key,
    required this.show,
    required this.groupTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (!show || groupTitle == null) return const SizedBox.shrink();
    final title = groupTitle!.trim();
    if (title.isEmpty) return const SizedBox.shrink();
    final gloc = gen.AppLocalizations.of(context);
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
