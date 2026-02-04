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
  static const double tileBorderRadius = 100.0;

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

  /// Builds the square tile with image or initials
  Widget _buildTile(BuildContext context) {
    final hasImage =
        group.file != null &&
        group.file!.isNotEmpty &&
        File(group.file!).existsSync();

    Widget tileContent;
    if (hasImage) {
      tileContent = ClipRRect(
        borderRadius: BorderRadius.circular(tileBorderRadius),
        child: Image.file(
          File(group.file!),
          width: tileSize,
          height: tileSize,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: child,
            );
          },
        ),
      );
    } else {
      // No image - show initials on color background
      final backgroundColor = ExpenseGroupColorPalette.resolveGroupColor(
        group,
        theme.colorScheme,
      );
      final textColor = ExpenseGroupColorPalette.getContrastingTextColor(
        backgroundColor,
      );

      tileContent = Center(
        child: Text(
          _getInitials(group.title),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return BaseCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      backgroundColor: hasImage
          ? Colors.transparent
          : ExpenseGroupColorPalette.resolveGroupColor(
              group,
              theme.colorScheme,
            ),
      borderRadius: BorderRadius.circular(tileBorderRadius),
      backgroundImage: hasImage ? group.file : null,
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
      child: SizedBox(width: tileSize, height: tileSize, child: tileContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tileSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Square tile with image or initials (now has its own InkWell)
          _buildTile(context),
          const SizedBox(height: 6),
          // Group title
          Text(
            group.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          // Total spent
          // _buildTotalSpentText(context),
        ],
      ),
    );
  }
}
