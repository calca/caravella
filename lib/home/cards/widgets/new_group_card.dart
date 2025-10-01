import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/group/pages/expenses_group_edit_page.dart';
import '../../../manager/group/group_edit_mode.dart';
import '../../../widgets/base_card.dart';

class NewGroupCard extends StatefulWidget {
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

  @override
  State<NewGroupCard> createState() => _NewGroupCardState();
}

class _NewGroupCardState extends State<NewGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  Color _getSelectedColor(bool isDarkMode) {
    return widget.theme.colorScheme.surfaceDim;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.theme.brightness == Brightness.dark;
    final selectedColor = _getSelectedColor(isDarkMode);
    final defaultBackgroundColor = widget.theme.colorScheme.surface;

    // Interpola tra il colore di default e quello selezionato
    final backgroundColor = Color.lerp(
      defaultBackgroundColor,
      selectedColor,
      widget.selectionProgress * 0.3, // 30% di intensità massima
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
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
              widget.onGroupAdded();
            }
          },
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: _buildNewGroupCardContent(),
        ),
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
          color: widget.theme.colorScheme.onSurface,
        ),
        const SizedBox(height: 24),
        Text(
          widget.localizations.new_expense_group,
          style: widget.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 22,
            color: widget.theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          widget.localizations.tap_to_create,
          style: widget.theme.textTheme.bodyMedium?.copyWith(
            color: widget.theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
