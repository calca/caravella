import 'package:flutter/material.dart';

/// A generic tile for selection lists, e.g. currency, image, or date.
///
/// - [leading]: Widget to show at the start (icon, image, etc)
/// - [title]: Main label
/// - [subtitle]: Optional secondary label
/// - [trailing]: Widget at the end (e.g. chevron)
/// - [onTap]: Tap callback
/// - [backgroundColor]: Optional background color
/// - [borderRadius]: Optional border radius (default 12)
class SelectionTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const SelectionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
    final tile = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: content,
      ),
    );
    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: tile,
      );
    } else {
      return tile;
    }
  }
}
