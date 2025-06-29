import 'package:flutter/material.dart';

class BaseFlatCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback? onTap;

  const BaseFlatCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14.0),
    this.elevation = 2,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Rimuovo qualsiasi forzatura di altezza interna: la dimensione viene gestita dal parent (TripSection)
    // e aggiungo un SingleChildScrollView di sicurezza per evitare overflow minimi su schermi piccoli
    final card = Card(
      elevation: elevation,
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
    if (onTap != null) {
      return Opacity(
        opacity: 0.9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: constraints.maxHeight,
                  minWidth: 0,
                  maxWidth: constraints.maxWidth,
                ),
                child: InkWell(
                  borderRadius: borderRadius is BorderRadius
                      ? borderRadius as BorderRadius
                      : null,
                  onTap: onTap,
                  child: card,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Opacity(
        opacity: 0.9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: constraints.maxHeight,
                  minWidth: 0,
                  maxWidth: constraints.maxWidth,
                ),
                child: card,
              ),
            );
          },
        ),
      );
    }
  }
}
