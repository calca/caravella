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
  final Gradient? backgroundGradient;

  /// Accessible name announced for the whole card when [onTap] is set. When
  /// provided, the card's own text content is excluded from the semantics
  /// tree in favor of this single label (avoids double-announcing);
  /// otherwise the card's descendant text nodes are merged into one
  /// button-role announcement via [MergeSemantics].
  final String? semanticLabel;

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
    this.backgroundGradient,
    this.semanticLabel,
  });

  /// Wraps a tappable card's content so it's announced as a single button
  /// node instead of a loose collection of its child text nodes.
  Widget _wrapTappable(Widget card) {
    if (semanticLabel != null) {
      return Semantics(
        button: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: card),
      );
    }
    return Semantics(button: true, child: MergeSemantics(child: card));
  }

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

    // Image + gradient overlay: Stack-based approach for richer visuals
    if (hasBackgroundImage && backgroundGradient != null) {
      return _buildImageGradientCard(
        theme,
        effectiveBorderRadius,
        padding ?? const EdgeInsets.all(20),
      );
    }

    // Gradient-only background (no image)
    if (backgroundGradient != null && !hasBackgroundImage) {
      return _buildGradientCard(
        theme,
        effectiveBorderRadius,
        padding ?? const EdgeInsets.all(20),
      );
    }

    // Build the decoration
    BoxDecoration decoration;
    if (hasBackgroundImage) {
      decoration = BoxDecoration(
        borderRadius: effectiveBorderRadius,
        image: DecorationImage(
          image: FileImage(File(backgroundImage!)),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.surface.withValues(alpha: 0.9),
            BlendMode.srcOver,
          ),
        ),
        border: (!isFlat && !noBorder)
            ? Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              )
            : null,
      );
    } else {
      decoration = BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainer,
        borderRadius: effectiveBorderRadius,
        border: (!isFlat && !noBorder)
            ? Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              )
            : null,
      );
    }

    Widget cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return _wrapTappable(
        Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: Material(
              color: backgroundColor ?? theme.colorScheme.surfaceContainer,
              child: InkWell(
                onTap: onTap,
                splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                highlightColor: theme.colorScheme.primary.withValues(
                  alpha: 0.05,
                ),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(20),
                  decoration: decoration.copyWith(color: Colors.transparent),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return cardContent;
  }

  /// Builds a card with a background image and a gradient overlay on top.
  /// Uses a [Stack] to layer image, gradient, and content for a rich visual.
  Widget _buildImageGradientCard(
    ThemeData theme,
    BorderRadius borderRadius,
    EdgeInsetsGeometry padding,
  ) {
    final content = onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
              child: Padding(padding: padding, child: child),
            ),
          )
        : Padding(padding: padding, child: child);

    final card = Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(backgroundImage!)),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: backgroundGradient),
              ),
            ),
            content,
          ],
        ),
      ),
    );
    return onTap != null ? _wrapTappable(card) : card;
  }

  /// Builds a card with a gradient background (no image).
  Widget _buildGradientCard(
    ThemeData theme,
    BorderRadius borderRadius,
    EdgeInsetsGeometry padding,
  ) {
    if (onTap != null) {
      return _wrapTappable(
        Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: backgroundGradient),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor: theme.colorScheme.primary.withValues(
                    alpha: 0.05,
                  ),
                  child: Padding(padding: padding, child: child),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
