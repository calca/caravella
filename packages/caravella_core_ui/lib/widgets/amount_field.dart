import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../themes/form_theme.dart';

/// The amount field of the expense form and the budget sheet: the currency
/// symbol small on the left, the amount large, typed with the language's
/// decimal separator (a comma or a dot is accepted either way, two decimals
/// at most). Read it back with [AmountField.parse].
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  /// The currency symbol shown before the amount.
  final String currency;

  /// What the field is, for screen readers ("Amount", "Amount per month"),
  /// read with the currency.
  final String label;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final bool enabled;

  const AmountField({
    super.key,
    required this.controller,
    required this.currency,
    required this.label,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.onSubmitted,
    this.textInputAction,
    this.textStyle,
    this.enabled = true,
  });

  /// The amount in [text], with a comma or a dot as decimal separator;
  /// null when it isn't a number.
  static double? parse(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Amount field: large bold number with smaller currency symbol.
    final currencySymbol = currency;
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

    final decimalSeparator = decimalSeparatorFor(
      Localizations.localeOf(context),
    );

    final amountField = TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      style: amountStyle,
      textAlign: TextAlign.left,
      maxLines: 1,
      decoration: FormTheme.getBorderlessAmountDecoration(
        hintText: '0${decimalSeparator}00',
        hintStyle: amountStyle?.copyWith(color: color.withValues(alpha: 0.35)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction ?? TextInputAction.next,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        _SimpleDecimalFormatter(decimalSeparator),
      ],
    );

    // Merged into the text field's own node, so TalkBack reads "Amount (€)"
    // on the field instead of only its "0.00" hint.
    return MergeSemantics(
      child: Semantics(
        label: '${label.replaceAll(' *', '')} ($currencySymbol)',
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
      ),
    );
  }
}

/// The decimal separator of [locale], as the amount field shows it.
String decimalSeparatorFor(Locale locale) =>
    NumberFormat.decimalPattern(locale.toString()).symbols.DECIMAL_SEP;

/// Simple formatter for decimal input that handles basic decimal formatting
/// without complex locale-specific thousands separators
class _SimpleDecimalFormatter extends TextInputFormatter {
  /// What the field shows between units and decimals. The text is parsed by
  /// [AmountField.parse], which accepts both.
  final String decimalSeparator;

  const _SimpleDecimalFormatter(this.decimalSeparator);

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
      text: sanitized.replaceAll('.', decimalSeparator),
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
