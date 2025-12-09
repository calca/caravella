import 'package:flutter/material.dart';

/// A standardized bottom action bar with a primary action button.
/// Used across the app for consistent save/create/add actions.
///
/// Features:
/// - Material 3 styling with surface container
/// - Border top with outline variant color
/// - SafeArea padding
/// - Right-aligned primary action button
/// - Disabled state when action is invalid
class BottomActionBar extends StatelessWidget {
  /// The callback to execute when the button is pressed
  final VoidCallback? onPressed;

  /// The label text for the button (e.g., "CREATE", "SAVE", "ADD")
  final String label;

  /// Whether the action is currently enabled
  final bool enabled;

  const BottomActionBar({
    super.key,
    required this.onPressed,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Spacer(),
            FilledButton(
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
