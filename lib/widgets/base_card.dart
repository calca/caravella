import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isFlat;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const BaseCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.isFlat = true,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(16);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    Widget cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: effectiveBorderRadius,
        border: isFlat
            ? Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              )
            : null,
        boxShadow: isFlat
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: elevation ?? 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: effectiveBorderRadius,
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
