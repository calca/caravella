import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Compact indicator showing location retrieval status in the expense form
/// Used in compact mode to show auto-location activity
class CompactLocationIndicator extends StatelessWidget {
  final bool isRetrieving;
  final ExpenseLocation? location;
  final VoidCallback? onCancel;
  final TextStyle? textStyle;

  const CompactLocationIndicator({
    super.key,
    required this.isRetrieving,
    this.location,
    this.onCancel,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    // Don't show anything if not retrieving and no location
    if (!isRetrieving && location == null) {
      return const SizedBox.shrink();
    }

    IconData icon;
    String label;
    Color iconColor;

    if (isRetrieving) {
      icon = Icons.location_searching;
      label = gloc.getting_location;
      iconColor = theme.colorScheme.primary;
    } else if (location != null) {
      icon = Icons.place;
      label = gloc.location;
      iconColor = theme.colorScheme.tertiary;
    } else {
      return const SizedBox.shrink();
    }

    return Semantics(
      button: true,
      label: isRetrieving 
        ? gloc.getting_location 
        : gloc.location,
      hint: onCancel != null 
        ? 'Double tap to ${isRetrieving ? "cancel location retrieval" : "clear location"}' 
        : null,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: borderColor.withValues(alpha: 0.8), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onCancel,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRetrieving)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            else
              Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: (textStyle ?? FormTheme.getSelectTextStyle(context))
                    ?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (onCancel != null && (isRetrieving || location != null))
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
