import 'package:material_ui/material_ui.dart';

/// Filled round action at the end of a card field (the "+" of an add field,
/// the "✓" of an inline add): a 36dp circle in the primary color, centered
/// in the 48dp field with a margin, while its touch target stays 48dp.
/// Use it as (part of) the field's `suffixIcon`.
class FieldActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;

  /// Null greys the button out.
  final VoidCallback? onPressed;

  const FieldActionButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    // The field lays its suffix out at its own height: centered, the
    // button keeps its size instead of stretching into a tall stadium.
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          fixedSize: const Size.square(36),
          minimumSize: const Size.square(36),
          padding: EdgeInsets.zero,
          iconSize: 20,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        icon: Icon(icon),
      ),
    );
  }
}
