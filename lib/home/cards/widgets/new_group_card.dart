import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import '../../../manager/group/pages/group_creation_wizard_page.dart';
import '../../../manager/group/pages/expenses_group_edit_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class NewGroupCard extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final void Function([String? groupId]) onGroupAdded;
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
              builder: (context) => const GroupCreationWizardPage(),
            ),
          );
          if (result != null) {
            if (result is String) {
              // User wants to go to group page
              onGroupAdded(result);
            } else if (result is Map && result['action'] == 'settings') {
              // User wants to go to settings
              final groupId = result['groupId'] as String?;
              if (groupId != null && context.mounted) {
                final storage = ExpenseGroupStorageV2();
                final group = await storage.getGroupById(groupId);
                if (group != null && context.mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpensesGroupEditPage(
                        trip: group,
                        mode: GroupEditMode.edit,
                      ),
                    ),
                  );
                  // After editing, go to the group
                  if (context.mounted) {
                    onGroupAdded(groupId);
                  }
                }
              }
            }
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
