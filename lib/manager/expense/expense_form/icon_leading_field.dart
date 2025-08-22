import 'package:flutter/material.dart';
import '../../../themes/form_theme.dart';

/// Standard width reserved for leading icons (or currency symbol) in form rows.
const double kLeadingIconWidth = 32.0;

/// Reusable row layout ensuring a consistent horizontal space for a leading icon
/// (or any decorative marker) and the field/content widget.
class IconLeadingField extends StatelessWidget {
  final Widget icon;
  final Widget child;
  final String? semanticsLabel;
  final String? tooltip;
  final bool alignTop; // For multi-line fields like note
  final EdgeInsets?
  iconPadding; // Allow fine-tuned vertical alignment per field

  const IconLeadingField({
    super.key,
    required this.icon,
    required this.child,
    this.semanticsLabel,
    this.tooltip,
    this.alignTop = false,
    this.iconPadding,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Semantics(
      label: semanticsLabel,
      readOnly: true,
      child: Tooltip(
        message: tooltip ?? semanticsLabel ?? '',
        preferBelow: false,
        child: IconTheme(
          data: IconThemeData(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          ),
          child: icon,
        ),
      ),
    );

    return Row(
      crossAxisAlignment: alignTop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: kLeadingIconWidth,
          child: Align(
            alignment: alignTop ? Alignment.topLeft : Alignment.centerLeft,
            child: Padding(
              padding:
                  iconPadding ??
                  (alignTop 
                    ? FormTheme.topAlignedIconPadding 
                    : FormTheme.standardIconPadding),
              child: iconWidget,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
