import 'package:flutter/material.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: widget.isExpanded
              ? _buildExpandedSearch(context)
              : _buildCollapsedSearch(context),
        );
      },
    );
  }

  Widget _buildExpandedSearch(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onSearchChanged,
      autofocus: true,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Cerca gruppi...',
  // rely on theme hintStyle
        prefixIcon: Icon(
          Icons.search_rounded,
          color: widget.searchQuery.isNotEmpty
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  size: 20,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onSearchChanged('');
                },
              ),
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: widget.onToggle,
            ),
          ],
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCollapsedSearch(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: widget.onToggle,
      icon: Icon(
        Icons.search_outlined,
        color: colorScheme.onSurface,
        size: 20,
      ),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        minimumSize: const Size(54, 54),
      ),
    );
  }
}
