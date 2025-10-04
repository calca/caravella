import 'package:flutter/material.dart';
import 'dart:io';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isFlat;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final String? backgroundImage;
  final bool noBorder;

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
    this.backgroundImage,
    this.noBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(16);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    // Check if there's a background image
    final hasBackgroundImage =
        backgroundImage != null &&
        backgroundImage!.isNotEmpty &&
        File(backgroundImage!).existsSync();

    // Build the decoration
    BoxDecoration decoration;
    if (hasBackgroundImage) {
      decoration = BoxDecoration(
        borderRadius: effectiveBorderRadius,
        image: DecorationImage(
          image: FileImage(File(backgroundImage!)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.surface.withValues(alpha: 0.9),
            BlendMode.srcOver,
          ),
        ),
        border: (isFlat && !noBorder)
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
      );
    } else {
      decoration = BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainer,
        borderRadius: effectiveBorderRadius,
        border: (isFlat && !noBorder)
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
      );
    }

    Widget cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: decoration,
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
