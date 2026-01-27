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

  Color _getSelectedColor(bool isDarkMode) {
    return theme
        .colorScheme
        .surface; //const Color(0xFFC9E9CA); // Colore tema chiaro
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedColor = _getSelectedColor(isDarkMode);
    final defaultBackgroundColor = theme.colorScheme.surface;

    // Use group color if set and no image, otherwise use selection color
    Color? backgroundColor;
    if (group.file != null && group.file!.isNotEmpty) {
      // Image is present, use interpolated selection color
      backgroundColor = Color.lerp(
        defaultBackgroundColor,
        selectedColor,
        selectionProgress * 0.3, // 30% di intensità massima
      );
    } else if (group.color != null) {
      // No image but color is set, resolve from palette or use legacy color
      Color groupColor;
      if (ExpenseGroupColorPalette.isLegacyColorValue(group.color)) {
        // Legacy ARGB value - use as-is
        groupColor = Color(group.color!);
      } else {
        // New palette index - resolve to theme-aware color
        groupColor =
            ExpenseGroupColorPalette.resolveColor(
              group.color,
              theme.colorScheme,
            ) ??
            theme.colorScheme.primary;
      }
      backgroundColor = Color.lerp(
        groupColor,
        selectedColor,
        selectionProgress * 0.3, // 30% di intensità massima per la selezione
      );
    } else {
      // No image and no color, use selection color
      backgroundColor = Color.lerp(
        defaultBackgroundColor,
        selectedColor,
        selectionProgress * 0.3, // 30% di intensità massima
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: double.infinity, // Assicura che usi tutto lo spazio verticale
      child: BaseCard(
        margin: const EdgeInsets.only(bottom: 16),
        backgroundColor: backgroundColor,
        backgroundImage: group.file,
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
