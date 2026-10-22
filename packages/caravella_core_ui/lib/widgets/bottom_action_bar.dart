import 'package:material_ui/material_ui.dart';

/// The primary action of a full page form (e.g. "Save"), pinned at the
/// bottom: a wide stadium FilledButton straight on the page background, like
/// the group creation wizard's "Continue". Disabled when [enabled] is false
/// or [onPressed] is null.
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
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final active = enabled && onPressed != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton(
          onPressed: active ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: active ? s.onPrimary : s.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
