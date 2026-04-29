import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/pages/expense_group_detail_page.dart';
import '../../../manager/details/widgets/group_header.dart';

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

  /// Builds the circular tile using [ExpenseGroupAvatar] for consistency.
  Widget _buildTile(BuildContext context) {
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
      child: ExpenseGroupAvatar(trip: group, size: tileSize),
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
