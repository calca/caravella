import 'package:flutter/material.dart';

/// Un OutlinedButton con stile predefinito che rispetta il tema dell'app.
/// Utilizzato per pulsanti con sfondo grigio, bordi arrotondati (32px) e bordo sottile.
/// Se isPrimary=true, usa i colori primary del tema con bordo più prominente.
class ThemedOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final bool isPrimary;

  const ThemedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.minimumSize,
    this.isPrimary = false,
  });

  /// Factory per pulsanti quadrati/iconici
  factory ThemedOutlinedButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    double size = 40.0,
    bool isPrimary = false,
  }) {
    return ThemedOutlinedButton(
      key: key,
      onPressed: onPressed,
      padding: const EdgeInsets.all(0),
      minimumSize: Size(size, size),
      isPrimary: isPrimary,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isPrimary
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        foregroundColor:
            isPrimary ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        side: BorderSide(
          color: isPrimary
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        padding: padding,
        minimumSize: minimumSize,
      ),
      child: child,
    );
  }
}
