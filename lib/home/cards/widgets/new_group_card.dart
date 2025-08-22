import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../manager/group/pages/expenses_group_edit_page.dart';
import '../../../manager/group/group_edit_mode.dart';
import '../../../widgets/base_card.dart';

class NewGroupCard extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupAdded;
  final bool isSelected;
  final double selectionProgress;

  const NewGroupCard({
    super.key,
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
    this.isSelected = false,
    this.selectionProgress = 0.0,
  });

  Color _getSelectedColor(bool isDarkMode) {
    return theme.colorScheme.surfaceDim;
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
      height: double.infinity, // Assicura che usi tutto lo spazio verticale
      child: BaseCard(
        margin: const EdgeInsets.only(bottom: 16),
        backgroundColor: backgroundColor,
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const ExpensesGroupEditPage(mode: GroupEditMode.create),
            ),
          );
          if (result == true) {
            onGroupAdded();
          }
        },
        child: _buildNewGroupCardContent(),
      ),
    );
  }

  Widget _buildNewGroupCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.add_circle_outline,
          size: 64,
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(height: 24),
        Text(
          localizations.new_expense_group,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          localizations.tap_to_create,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
