import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class ExpandableSearchBar extends StatefulWidget {
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onToggle;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController controller;

  const ExpandableSearchBar({
    super.key,
    required this.isExpanded,
    required this.searchQuery,
    required this.onToggle,
    required this.onSearchChanged,
    required this.controller,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 54,
          child: widget.isExpanded
              ? _buildExpandedSearch(context)
              : _buildCollapsedSearch(context),
        );
      },
    );
  }

  Widget _buildExpandedSearch(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading search icon button (same width/padding of action icons)
          SizedBox(
            width: 54,
            height: 54,
            child: IconButton(
              tooltip: gloc.search_groups,
              padding: EdgeInsets.zero,
              onPressed: () => _focusNode.requestFocus(),
              icon: Icon(
                Icons.search_outlined,
                color: widget.searchQuery.isNotEmpty
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          // Text field expanded
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onSearchChanged,
              focusNode: _focusNode,
              autofocus: true,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.2),
            ),
          ),
          // Trailing actions
          Row(
            children: [
              if (widget.searchQuery.isNotEmpty)
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                    tooltip: 'Clear',
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.clear_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onSearchChanged('');
                    },
                  ),
                ),
              SizedBox(
                width: 54,
                height: 54,
                child: IconButton(
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onToggle,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearch(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: widget.onToggle,
      icon: Icon(Icons.search_outlined, color: colorScheme.onSurface, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        minimumSize: const Size(54, 54),
        fixedSize: const Size(54, 54),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
