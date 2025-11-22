import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'location_widget_constants.dart';

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

    // Don't show anything if not retrieving and no location
    if (!isRetrieving && location == null) {
      return const SizedBox.shrink();
    }

    final IconData icon;
    final Color iconColor;

    if (isRetrieving) {
      icon = LocationWidgetConstants.loadingIcon;
      iconColor = theme.colorScheme.primary;
    } else if (location != null) {
      icon = LocationWidgetConstants.successIcon;
      iconColor = theme.colorScheme.tertiary;
    } else {
      return const SizedBox.shrink();
    }

    return Semantics(
      button: true,
      label: isRetrieving ? gloc.getting_location : gloc.location,
      hint: onCancel != null
          ? 'Double tap to ${isRetrieving ? "cancel location retrieval" : "clear location"}'
          : null,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(40, 40),
        ),
        onPressed: onCancel,
        icon: isRetrieving
            ? SizedBox(
                width: LocationWidgetConstants.loaderSize,
                height: LocationWidgetConstants.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: LocationWidgetConstants.loaderStrokeWidth,
                  color: iconColor,
                ),
              )
            : Icon(
                icon,
                size: LocationWidgetConstants.iconSize,
                color: iconColor,
              ),
        tooltip: isRetrieving ? gloc.getting_location : gloc.location,
      ),
    );
  }
}
