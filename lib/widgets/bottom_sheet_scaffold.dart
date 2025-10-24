import 'package:flutter/material.dart';

/// Standard layout wrapper for bottom sheets in group manager section.
/// Provides consistent horizontal padding, optional title, and vertical spacing.
class GroupBottomSheetScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;
  final double spacing;
  final bool scrollable;
  final bool showHandle;
  final ScrollController? scrollController;
  const GroupBottomSheetScaffold({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
    this.spacing = 12,
    this.scrollable = false,
    this.showHandle = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHandle) ...[
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: spacing),
        ],
        child,
      ],
    );
    final padded = Padding(padding: padding, child: content);
    return SafeArea(
      top: false,
      child: scrollable
          ? SingleChildScrollView(controller: scrollController, child: padded)
          : padded,
    );
  }
}
