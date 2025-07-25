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
    final isEnabled = onPressed != null;

    final ButtonStyle style = (isPrimary
        ? FilledButton.styleFrom(
            backgroundColor:
                isEnabled ? colorScheme.primary : colorScheme.onSurface,
            foregroundColor:
                isEnabled ? colorScheme.onPrimary : colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: padding,
            minimumSize: minimumSize,
            elevation: isEnabled ? 1 : 0,
            shadowColor: colorScheme.shadow,
          )
        : FilledButton.styleFrom(
            backgroundColor: isEnabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.onSurface,
            foregroundColor:
                isEnabled ? colorScheme.onSurface : colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            padding: padding,
            minimumSize: minimumSize,
            elevation: 0,
            shadowColor: colorScheme.shadow,
          ));

    return isPrimary
        ? FilledButton(
            onPressed: onPressed,
            style: style,
            child: child,
          )
        : FilledButton.tonal(
            onPressed: onPressed,
            style: style,
            child: child,
          );
  }
}
