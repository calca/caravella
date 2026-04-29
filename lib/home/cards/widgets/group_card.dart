import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'group_card_content.dart';

class GroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback? onCategoryAdded;
  final bool isSelected;
  final double selectionProgress;

  const GroupCard({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.onCategoryAdded,
    this.isSelected = false,
    this.selectionProgress = 0.0,
  });

  /// Builds a consistent gradient overlay: light at the top, full color at 65% from the top.
  /// Used for both image and color card backgrounds.
  static LinearGradient _buildCardGradient(Color topColor, Color bottomColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
      stops: const [0.0, 0.65],
    );
  }

  Color _getSelectedColor(bool isDarkMode) {
    return theme.colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedColor = _getSelectedColor(isDarkMode);

    // Resolve base background using the shared utility, then blend with
    // selection progress for the interactive selection highlight.
    final bg = GroupBackgroundUtils.resolve(
      group,
      theme.colorScheme,
      baseColor: Color.lerp(
        theme.colorScheme.surface,
        selectedColor,
        selectionProgress * 0.3,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: double.infinity, // Assicura che usi tutto lo spazio verticale
      child: BaseCard(
        margin: const EdgeInsets.only(bottom: 16),
        borderRadius: BorderRadius.circular(32),
        backgroundColor: bg.color,
        backgroundImage: bg.imagePath,
        backgroundGradient: bg.gradient,
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
        child: GroupCardContent(
          group: group,
          localizations: localizations,
          theme: theme,
          onExpenseAdded: onGroupUpdated,
          onCategoryAdded: onCategoryAdded,
        ),
      ),
    );
  }
}
