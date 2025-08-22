import 'package:flutter/material.dart';

/// Standard section header with title, optional description and trailing widget (e.g. action button).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool requiredMark;

  const SectionHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.padding = EdgeInsets.zero,
    this.spacing = 4,
    this.requiredMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final titleWidget = requiredMark
        ? RichText(
            text: TextSpan(
              children: [
                TextSpan(text: title, style: titleStyle),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        : Text(title, style: titleStyle);
    final hasDescription = description != null && description!.isNotEmpty;
    final descWidget = hasDescription
        ? Padding(
            padding: EdgeInsets.only(top: spacing),
            child: Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          )
        : const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [titleWidget, if (hasDescription) descWidget],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
