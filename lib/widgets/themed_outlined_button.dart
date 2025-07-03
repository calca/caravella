import 'package:flutter/material.dart';

/// Un OutlinedButton con stile predefinito che rispetta il tema dell'app.
/// Utilizzato per pulsanti con sfondo grigio, bordi arrotondati (24px) e senza bordi visibili.
class ThemedOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;

  const ThemedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.minimumSize,
  });

  /// Factory per pulsanti quadrati/iconici
  factory ThemedOutlinedButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    double size = 40.0,
  }) {
    return ThemedOutlinedButton(
      key: key,
      onPressed: onPressed,
      padding: const EdgeInsets.all(0),
      minimumSize: Size(size, size),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        side: const BorderSide(color: Colors.transparent),
        padding: padding,
        minimumSize: minimumSize,
      ),
      child: child,
    );
  }
}
