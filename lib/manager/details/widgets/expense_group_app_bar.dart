import 'package:flutter/material.dart';

/// Animated app bar for expense group detail page with collapsible title
class ExpenseGroupAppBar extends StatelessWidget {
  final String groupTitle;
  final bool showCollapsedTitle;
  final VoidCallback onBackPressed;
  
  const ExpenseGroupAppBar({
    super.key,
    required this.groupTitle,
    required this.showCollapsedTitle,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surfaceContainer,
      foregroundColor: colorScheme.onSurface,
      toolbarHeight: 56,
      collapsedHeight: 56,
      centerTitle: false,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: showCollapsedTitle
            ? Text(
                groupTitle,
                key: const ValueKey('appbar-title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : const SizedBox(key: ValueKey('appbar-empty')),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackPressed,
      ),
    );
  }
}