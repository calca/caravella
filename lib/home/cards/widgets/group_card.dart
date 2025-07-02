import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import '../../../manager/detail_page/trip_detail_page.dart';
import '../../../widgets/widgets.dart';
import 'group_card_content.dart';

class GroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final bool isSelected;
  final double selectionProgress;

  const GroupCard({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.isSelected = false,
    this.selectionProgress = 0.0,
  });

  Color _getSelectedColor(bool isDarkMode) {
    if (isDarkMode) {
      return const Color(0xFF90659A); // Colore tema scuro
    } else {
      return const Color(0xFFC9E9CA); // Colore tema chiaro
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedColor = _getSelectedColor(isDarkMode);
    final defaultBackgroundColor = theme.colorScheme.surface;

    // Interpola tra il colore di default e quello selezionato
    final backgroundColor = Color.lerp(
      defaultBackgroundColor,
      selectedColor,
      selectionProgress * 0.3, // 30% di intensità massima
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: BaseCard(
        margin: const EdgeInsets.only(bottom: 16),
        backgroundColor: backgroundColor,
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripDetailPage(trip: group),
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
        ),
      ),
    );
  }
}
