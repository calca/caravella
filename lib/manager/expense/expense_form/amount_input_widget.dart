import 'package:flutter/material.dart';
import '../../../data/model/expense_category.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'icon_leading_field.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isText) {
      final textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        style:
            textStyle ??
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          semanticCounterText: '',
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
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
      style:
          textStyle ??
          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: label != null ? '${label!} *' : null,
        // rely on theme hintStyle
        floatingLabelBehavior: FloatingLabelBehavior.never,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        semanticCounterText: '',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        _AmountFormatter(),
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

/// Formatter che formatta live il numero secondo la locale corrente
class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Preserve selection index relative to numeric characters
    final oldDigitsBeforeCursor = _countDigitsBefore(
      oldValue.text,
      oldValue.selection.baseOffset,
    );

    // Normalize new raw input (allow both , and . as decimal separators)
    String sanitized = newValue.text.replaceAll(RegExp(r'[^0-9,\.]'), '');
    // If user just typed separator at start -> ignore
    if (sanitized == ',' || sanitized == '.') {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Track if user is typing decimal part (keeps trailing comma or partial decimals)
    bool endsWithSeparator = sanitized.endsWith(',') || sanitized.endsWith('.');

    // Replace commas with dot for parsing
    String parseCandidate = sanitized.replaceAll(',', '.');
    // Allow single dot at end (partial decimal) without formatting yet
    final partialDecimal =
        endsWithSeparator && !parseCandidate.contains(RegExp(r'\.[0-9]{1,}'));

    if (parseCandidate.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    double? value = double.tryParse(parseCandidate);
    if (value == null) {
      // Invalid new char: revert
      return oldValue;
    }

    final locale = Intl.getCurrentLocale();
    final formatter = NumberFormat.decimalPattern(locale);
    final decimalSep = formatter.symbols.DECIMAL_SEP; // e.g. , or .

    // Determine decimal digits typed (max 2)
    String decimalPart = '';
    final match = RegExp(r'[.,](\d{0,2})').firstMatch(parseCandidate);
    if (match != null) {
      decimalPart = match.group(1)!;
    }

    final intPart = value.truncate();
    final formattedInt = formatter.format(intPart);
    String rebuilt;
    if (partialDecimal) {
      rebuilt = '$formattedInt$decimalSep';
    } else if (decimalPart.isNotEmpty) {
      rebuilt = '$formattedInt$decimalSep$decimalPart';
    } else {
      rebuilt = formattedInt;
    }

    // Compute new cursor: place after same count of digits as before (approx)
    int targetDigitIndex = oldDigitsBeforeCursor;
    int seenDigits = 0;
    int caret = 0;
    while (caret < rebuilt.length && seenDigits < targetDigitIndex) {
      if (RegExp(r'\d').hasMatch(rebuilt[caret])) seenDigits++;
      caret++;
    }
    // If user was at end typing
    if (oldValue.selection.baseOffset == oldValue.text.length &&
        newValue.selection.baseOffset == newValue.text.length) {
      caret = rebuilt.length; // keep at end
    }

    return TextEditingValue(
      text: rebuilt,
      selection: TextSelection.collapsed(
        offset: caret.clamp(0, rebuilt.length),
      ),
    );
  }

  int _countDigitsBefore(String text, int offset) {
    if (offset <= 0) return 0;
    offset = offset.clamp(0, text.length);
    int count = 0;
    for (int i = 0; i < offset; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) count++;
    }
    return count;
  }
}
