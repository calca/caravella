import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/services.dart';
import 'icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final VoidCallback? onSubmitted;
  final List<ExpenseCategory> categories;
  final String? label;
  final bool isText;
  final TextStyle? textStyle;
  final String? currency; // currency override
  final Widget? trailing; // optional trailing icon for text mode
  final Widget?
  leading; // optional leading icon for text mode aligned like currency
  final TextInputAction? textInputAction; // override default textInputAction
  final bool enabled;

  const AmountInputWidget({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.onSubmitted,
    this.categories = const <ExpenseCategory>[],
    this.label,
    this.isText = false,
    this.textStyle,
    this.currency,
    this.trailing,
    this.leading,
    this.textInputAction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isText) {
      final textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        style: textStyle ?? FormTheme.getFieldTextStyle(context),
        decoration:
            FormTheme.getStandardDecoration(
              hintText: label != null ? '${label!} *' : null,
              isDense: true,
              suffixIcon: leading == null && trailing != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: trailing,
                    )
                  : null,
            ).copyWith(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              suffixIconConstraints: const BoxConstraints(
                minHeight: 32,
                minWidth: 32,
              ),
              semanticCounterText: '',
            ),
        keyboardType: TextInputType.text,
        textInputAction: textInputAction ?? TextInputAction.next,
        validator: validator,
        onSaved: onSaved,
        onFieldSubmitted: (_) => onSubmitted?.call(),
      );

      if (leading == null) {
        return Semantics(
          textField: true,
          label: label?.replaceAll(' *', ''),
          child: textField,
        );
      }

      return IconLeadingField(
        icon: leading!,
        semanticsLabel: (label ?? '').replaceAll(' *', ''),
        tooltip: (label ?? '').replaceAll(' *', ''),
        child: Semantics(
          textField: true,
          label: label?.replaceAll(' *', ''),
          child: textField,
        ),
      );
    }

    // Amount field: large bold number with smaller currency symbol.
    final currencySymbol = currency ?? '€';
    final baseFontSize = theme.textTheme.displayMedium?.fontSize ?? 45.0;
    final decimalFontSize = baseFontSize * 0.40;
    final color = theme.colorScheme.onSurface;

    final amountStyle =
        textStyle ??
        theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: color,
          height: 1.05,
          letterSpacing: -0.5,
        );
    final currencyStyle = theme.textTheme.displaySmall?.copyWith(
      fontSize: decimalFontSize,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.05,
      letterSpacing: 0,
    );

    final amountField = TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      style: amountStyle,
      textAlign: TextAlign.left,
      maxLines: 1,
      decoration: FormTheme.getBorderlessAmountDecoration(
        hintText: '0.00',
        hintStyle: amountStyle?.copyWith(color: color.withValues(alpha: 0.35)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction ?? TextInputAction.next,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        _SimpleDecimalFormatter(),
      ],
    );

    return Semantics(
      textField: true,
      label: label != null
          ? '${label!.replaceAll(' *', '')} amount in $currencySymbol'
          : 'Amount input',
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(currencySymbol, style: currencyStyle),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: IntrinsicWidth(child: amountField),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple formatter for decimal input that handles basic decimal formatting
/// without complex locale-specific thousands separators
class _SimpleDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Basic filtering - remove invalid characters
    String sanitized = newValue.text.replaceAll(RegExp(r'[^0-9.,]'), '');

    // Handle empty input
    if (sanitized.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Convert commas to dots for consistent decimal handling
    sanitized = sanitized.replaceAll(',', '.');

    // Only allow one decimal point
    final parts = sanitized.split('.');
    if (parts.length > 2) {
      // If more than one decimal point, keep only the first one and combine the rest
      sanitized = '${parts[0]}.${parts.sublist(1).join('')}';
      // Re-split after combining
      final newParts = sanitized.split('.');
      if (newParts.length == 2 && newParts[1].length > 2) {
        sanitized = '${newParts[0]}.${newParts[1].substring(0, 2)}';
      }
    } else if (parts.length == 2 && parts[1].length > 2) {
      // Limit decimal places to 2
      sanitized = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    // Don't allow leading decimal point without a number
    if (sanitized.startsWith('.')) {
      sanitized = '0$sanitized';
    }

    // Preserve cursor position at end if user was typing at end
    int cursorPosition = sanitized.length;
    if (oldValue.selection.baseOffset == oldValue.text.length &&
        newValue.selection.baseOffset == newValue.text.length) {
      cursorPosition = sanitized.length;
    } else {
      // Try to maintain relative cursor position
      cursorPosition = (newValue.selection.baseOffset).clamp(
        0,
        sanitized.length,
      );
    }

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
