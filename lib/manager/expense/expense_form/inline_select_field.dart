import 'package:flutter/material.dart';
import 'icon_leading_field.dart';

/// Generic inline (row style) selectable field used in fullEdit mode for
/// participant, category, date-like pickers. Provides consistent layout
/// with leading icon and tappable text region.
class InlineSelectField extends StatelessWidget {
  final IconData icon;
  final String label; // current value or placeholder
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final TextStyle? textStyle;
  final bool enabled;

  const InlineSelectField({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
    this.semanticsLabel,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = (textStyle ?? theme.textTheme.bodySmall)?.copyWith(
      color: enabled
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontWeight: FontWeight.w400,
    );

    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: effectiveStyle,
      ),
    );

    return IconLeadingField(
      icon: Icon(icon),
      semanticsLabel: semanticsLabel,
      tooltip: semanticsLabel,
      child: Semantics(
        label: semanticsLabel,
        button: enabled,
        enabled: enabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: enabled ? onTap : null,
          child: child,
        ),
      ),
    );
  }
}
