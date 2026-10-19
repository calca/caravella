import 'package:material_ui/material_ui.dart';

/// Reusable round FAB (64 dp, primary) matching the "+" beside the floating
/// navigation.
class AddFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final String? heroTag;
  final IconData icon;
  final double iconSize;
  final String? semanticLabel;

  const AddFab({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    this.icon = Icons.add_rounded,
    this.iconSize = 30,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    // Same size and shadow as the round action beside FloatingNavBar.
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.45 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Semantics(
        button: true,
        label: semanticLabel ?? tooltip,
        child: SizedBox.square(
          dimension: 64,
          child: FloatingActionButton(
            heroTag: heroTag,
            onPressed: onPressed,
            tooltip: tooltip,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(icon, size: iconSize),
          ),
        ),
      ),
    );
  }
}
