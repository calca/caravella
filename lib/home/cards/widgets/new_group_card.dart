import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../navigation_helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    // Interpola tra il colore di default e quello selezionato
    final backgroundColor = Color.lerp(
      theme.colorScheme.surface,
      theme.colorScheme.surfaceDim,
      selectionProgress * 0.3, // 30% di intensità massima
    );

    return BaseCard(
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: backgroundColor,
      onTap: () async {
        await NavigationHelpers.openGroupCreationWithCallback(
          context,
          onGroupAdded: onGroupAdded,
        );
      },
      child: _buildNewGroupCardContent(context),
    );
  }

  Widget _buildNewGroupCardContent(BuildContext context) {
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
          style: AppTextStyles.subtle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
