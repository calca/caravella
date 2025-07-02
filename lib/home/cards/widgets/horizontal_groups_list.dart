import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import 'group_card.dart';

class HorizontalGroupsList extends StatefulWidget {
  final List<ExpenseGroup> groups;
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;

  const HorizontalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
  });

  @override
  State<HorizontalGroupsList> createState() => _HorizontalGroupsListState();
}

class _HorizontalGroupsListState extends State<HorizontalGroupsList> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.groups.length,
      padEnds: false,
      controller: _pageController,
      itemBuilder: (context, index) {
        final group = widget.groups[index];

        // Calcola quanto questa card è vicina al centro
        final double distanceFromCenter = (index - _currentPage).abs();
        final bool isSelected = distanceFromCenter < 0.5;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(
            right: 16,
            top: isSelected ? 0 : 8,
            bottom: isSelected ? 0 : 8,
          ),
          child: GroupCard(
            group: group,
            localizations: widget.localizations,
            theme: widget.theme,
            onGroupUpdated: widget.onGroupUpdated,
            isSelected: isSelected,
            selectionProgress: 1.0 - distanceFromCenter.clamp(0.0, 1.0),
          ),
        );
      },
    );
  }
}
