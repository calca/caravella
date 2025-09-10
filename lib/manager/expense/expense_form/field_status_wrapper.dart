import 'package:flutter/material.dart';

/// Wrapper that animates a subtle background for invalid touched fields.
class FieldStatusWrapper extends StatelessWidget {
  final Widget child;
  final bool isValid;
  final bool isTouched;

  const FieldStatusWrapper({
    super.key,
    required this.child,
    required this.isValid,
    required this.isTouched,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: isTouched && !isValid
          ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.08)
          : null,
    ),
    child: child,
  );
}
