import 'dart:io';

import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/pages/expense_group_detail_page.dart';

/// A compact card widget for displaying expense groups in a horizontal carousel.
///
/// This widget shows:
/// - A square tile with rounded corners containing either the background image
///   or the group initials on the chosen color
/// - The group title below the tile
/// - The user's balance (total spent/owed) below the title
class CarouselGroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;

  /// Size of the square tile (width and height)
  static const double tileSize = 90.0;

  /// Border radius for the tile
  static const double tileBorderRadius = 12.0;

  /// Total height including text below the tile
  /// tile (90) + spacing (6) + title (~16) + spacing (2) + balance (~14)
  static const double totalHeight = tileSize + 38;

  const CarouselGroupCard({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
  });

  /// Gets the initials from the group title (up to 2 characters)
  String _getInitials(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';

    if (words.length == 1) {
      // Single word: take first 2 characters
      return words.first
          .substring(0, words.first.length.clamp(0, 2))
          .toUpperCase();
    }

    // Multiple words: take first letter of first two words
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Resolves the group color from palette or legacy value
  /// Falls back to surfaceContainerHigh to match the main card style
  Color _resolveGroupColor() {
    if (group.color != null) {
      if (ExpenseGroupColorPalette.isLegacyColorValue(group.color)) {
        return Color(group.color!);
      }
      return ExpenseGroupColorPalette.resolveColor(
            group.color,
            theme.colorScheme,
          ) ??
          theme.colorScheme.surfaceContainerHigh;
    }
    return theme.colorScheme.surfaceContainerHigh;
  }

  /// Determines if the given color is light or dark
  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Builds the square tile with image or initials
  Widget _buildTile(BuildContext context) {
    final hasImage =
        group.file != null &&
        group.file!.isNotEmpty &&
        File(group.file!).existsSync();

    if (hasImage) {
      return Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tileBorderRadius),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          image: DecorationImage(
            image: FileImage(File(group.file!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // No image - show initials on color background
    final backgroundColor = _resolveGroupColor();
    final isLight = _isLightColor(backgroundColor);
    final textColor = isLight ? Colors.black87 : Colors.white;

    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(tileBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(group.title),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  /// Calculates and formats the total spent in the group
  Widget _buildTotalSpentText(BuildContext context) {
    // Calculate total spent from all expenses
    double totalSpent = 0.0;
    for (final expense in group.expenses) {
      totalSpent += expense.amount ?? 0.0;
    }

    final totalText = CurrencyDisplay.formatCurrencyText(
      totalSpent,
      group.currency,
      showDecimals: true,
    );

    return Text(
      totalText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpenseGroupDetailPage(trip: group),
          ),
        );
        if (result == true) {
          onGroupUpdated();
        }
      },
      child: SizedBox(
        width: tileSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square tile with image or initials
            _buildTile(context),
            const SizedBox(height: 6),
            // Group title
            Text(
              group.title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            // Total spent
            _buildTotalSpentText(context),
          ],
        ),
      ),
    );
  }
}
