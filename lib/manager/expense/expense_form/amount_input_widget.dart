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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isText) {
      final textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: textStyle ?? FormTheme.getFieldTextStyle(context),
        decoration: InputDecoration(
          hintText: label != null ? '${label!} *' : null,
          // rely on theme hintStyle
          floatingLabelBehavior: FloatingLabelBehavior.never,
          isDense: true,
          suffixIcon: leading == null && trailing != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: trailing,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minHeight: 32,
            minWidth: 32,
          ),
          contentPadding: FormTheme.standardContentPadding,
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

    // Campo importo: valuta sempre visibile anche senza focus o testo
    final currencySymbol = currency ?? '€';
    // Style the currency symbol to visually match the 22px icon size used elsewhere
    final currencyStyle = TextStyle(
      fontSize: 20, // user requested slightly smaller than icon size
      height: 1.0, // compact to center vertically inside padding
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    final amountField = TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: textStyle ?? FormTheme.getAmountTextStyle(context),
      decoration: InputDecoration(
        hintText: label != null ? '${label!} *' : null,
        // rely on theme hintStyle
        floatingLabelBehavior: FloatingLabelBehavior.never,
        isDense: true,
        contentPadding: FormTheme.standardContentPadding,
        semanticCounterText: '',
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

    return IconLeadingField(
      icon: Text(currencySymbol, style: currencyStyle),
      semanticsLabel: label,
      tooltip: label,
      child: Semantics(
        textField: true,
        label: label != null
            ? '${label!.replaceAll(' *', '')} amount in $currencySymbol'
            : 'Amount input',
        child: amountField,
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
