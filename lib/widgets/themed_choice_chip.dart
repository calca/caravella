import 'package:flutter/material.dart';

class ThemedChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;
  final TextStyle? textStyle;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? selectedTextColor;
  final BorderSide? side;
  final bool showCheckmark;
  final Widget? avatar;

  const ThemedChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.textStyle,
    this.selectedColor,
    this.backgroundColor,
    this.selectedTextColor,
    this.side,
    this.showCheckmark = false,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? Theme.of(context).textTheme.bodySmall;
    final effectiveTextStyle = selected
        ? baseStyle?.copyWith(
            color: selectedTextColor ?? Theme.of(context).colorScheme.onPrimary)
        : baseStyle;
    return ChoiceChip(
      label: Text(label, style: effectiveTextStyle),
      selected: selected,
      avatar: avatar,
      showCheckmark: showCheckmark,
      labelStyle: effectiveTextStyle,
      backgroundColor: selected ? backgroundColor : backgroundColor,
      selectedColor: selectedColor ?? Theme.of(context).colorScheme.primary,
      side: side,
      onSelected: (_) {
        if (onSelected != null) onSelected!();
      },
    );
  }
}
