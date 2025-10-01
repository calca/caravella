import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';
import '../../../widgets/widgets.dart';
import 'group_card_content.dart';

class GroupCard extends StatefulWidget {
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

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard>
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
    return widget
        .theme
        .colorScheme
        .primaryFixed; //const Color(0xFFC9E9CA); // Colore tema chiaro
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.theme.brightness == Brightness.dark;
    final selectedColor = _getSelectedColor(isDarkMode);
    final defaultBackgroundColor = widget.theme.colorScheme.surface;

    // Use group color if set and no image, otherwise use selection color
    Color? backgroundColor;
    if (widget.group.file != null && widget.group.file!.isNotEmpty) {
      // Image is present, use interpolated selection color
      backgroundColor = Color.lerp(
        defaultBackgroundColor,
        selectedColor,
        widget.selectionProgress * 0.3, // 30% di intensità massima
      );
    } else if (widget.group.color != null) {
      // No image but color is set, use group color with selection overlay
      final groupColor = Color(widget.group.color!);
      backgroundColor = Color.lerp(
        groupColor,
        selectedColor,
        widget.selectionProgress * 0.3, // 30% di intensità massima per la selezione
      );
    } else {
      // No image and no color, use selection color
      backgroundColor = Color.lerp(
        defaultBackgroundColor,
        selectedColor,
        widget.selectionProgress * 0.3, // 30% di intensità massima
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: double.infinity, // Assicura che usi tutto lo spazio verticale
        child: BaseCard(
          margin: const EdgeInsets.only(bottom: 16),
          backgroundColor: backgroundColor,
          backgroundImage: widget.group.file,
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExpenseGroupDetailPage(trip: widget.group),
              ),
            );
            if (result == true) {
              widget.onGroupUpdated();
            }
          },
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: GroupCardContent(
            group: widget.group,
            localizations: widget.localizations,
            theme: widget.theme,
            onExpenseAdded: widget.onGroupUpdated,
            onCategoryAdded: widget.onCategoryAdded,
          ),
        ),
      ),
    );
  }
}
