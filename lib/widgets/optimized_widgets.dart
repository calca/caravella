import 'package:flutter/material.dart';

/// Widget ottimizzato per immagini con cache automatica
class OptimizedImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  const OptimizedImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.round(),
        cacheHeight: height?.round(),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }
}

/// ListView ottimizzata per prestazioni migliori
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Ottimizzazioni performance
      cacheExtent: 100.0, // Pre-carica solo alcuni elementi
      physics: const BouncingScrollPhysics(), // Scroll iOS-style
      addAutomaticKeepAlives: false, // Non mantiene widget fuori schermo
      addRepaintBoundaries: true, // Ottimizza il repaint
    );
  }
}
