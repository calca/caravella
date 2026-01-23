import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'carousel_group_card.dart';
import '../../../manager/group/pages/group_creation_wizard_page.dart';

class HorizontalGroupsList extends StatefulWidget {
  final List<ExpenseGroup> groups;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback onGroupAdded;
  final VoidCallback? onCategoryAdded;

  const HorizontalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    required this.onGroupAdded,
    this.onCategoryAdded,
  });

  @override
  State<HorizontalGroupsList> createState() => _HorizontalGroupsListState();
}

class _HorizontalGroupsListState extends State<HorizontalGroupsList>
    with SingleTickerProviderStateMixin {
  late List<ExpenseGroup> _localGroups;
  bool _isLoadingNewGroup = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _localGroups = List.from(widget.groups);

    // Setup fade-in animation for smooth loading
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(HorizontalGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna solo se i gruppi sono effettivamente cambiati
    if (oldWidget.groups != widget.groups) {
      // Check if a new group was added
      if (widget.groups.length > _localGroups.length) {
        if (_isLoadingNewGroup) {
          setState(() {
            _isLoadingNewGroup = false;
            _localGroups = List.from(widget.groups);
          });
        } else {
          _localGroups = List.from(widget.groups);
        }
      } else {
        _localGroups = List.from(widget.groups);
      }
    }
  }

  Future<void> _updateGroupLocally(String groupId) async {
    final groups = await ExpenseGroupStorageV2.getAllGroups();
    final found = groups.where((g) => g.id == groupId);
    if (found.isNotEmpty) {
      final updatedGroup = found.first;
      if (mounted) {
        setState(() {
          final index = _localGroups.indexWhere((g) => g.id == groupId);
          if (index != -1) {
            // Update existing group
            _localGroups[index] = updatedGroup;
          } else {
            // New group - add it at the beginning
            _localGroups.insert(0, updatedGroup);
          }
        });
      }
    } else {
      // Fallback al callback originale se non trovato
      widget.onGroupUpdated();
    }
  }

  void _handleGroupUpdated([String? groupId]) async {
    if (groupId != null) {
      // Specific group ID provided - update locally
      setState(() {
        _isLoadingNewGroup = true;
      });

      await _updateGroupLocally(groupId);

      if (mounted) {
        setState(() {
          _isLoadingNewGroup = false;
        });
      }
    } else {
      // No group ID provided - call parent's onGroupAdded
      setState(() {
        _isLoadingNewGroup = true;
      });

      // Call parent callback which will refresh the list
      widget.onGroupAdded();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total items: groups + 1 for "add new" card
    final totalItems = _localGroups.length + 1;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: CarouselGroupCard.totalHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // Last item is the "add new group" card
            if (index == _localGroups.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _AddNewGroupTile(
                  localizations: widget.localizations,
                  theme: widget.theme,
                  onGroupAdded: _handleGroupUpdated,
                ),
              );
            }

            final group = _localGroups[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CarouselGroupCard(
                group: group,
                localizations: widget.localizations,
                theme: widget.theme,
                onGroupUpdated: () => _handleGroupUpdated(group.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compact "Add New Group" tile for the carousel
class _AddNewGroupTile extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final void Function([String? groupId]) onGroupAdded;

  const _AddNewGroupTile({
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GroupCreationWizardPage(),
          ),
        );
        if (result != null && result is String) {
          onGroupAdded(result);
        }
      },
      child: SizedBox(
        width: CarouselGroupCard.tileSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square tile with + icon
            Container(
              width: CarouselGroupCard.tileSize,
              height: CarouselGroupCard.tileSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(
                  CarouselGroupCard.tileBorderRadius,
                ),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 28,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              localizations.new_expense_group,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
