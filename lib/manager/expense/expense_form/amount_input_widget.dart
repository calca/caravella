import 'package:flutter/material.dart';
import '../../../data/expense_category.dart';
import '../../../app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final VoidCallback? onSubmitted;
  final List<ExpenseCategory> categories;
  final AppLocalizations loc;
  final String? label;
  final bool isText;
  final TextStyle? textStyle;

  const AmountInputWidget({
    super.key,
    required this.controller,
    this.focusNode,
    required this.loc,
    this.validator,
    this.onSaved,
    this.onSubmitted,
    this.categories = const <ExpenseCategory>[],
    this.label,
    this.isText = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        (!isText &&
            categories.isNotEmpty &&
            categories.first.name.startsWith('€'))
        ? categories.first.name
        : (!isText ? '€' : null);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style:
          textStyle ??
          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: label != null ? '${label!} *' : null,
        hintStyle: (textStyle ?? theme.textTheme.titleLarge)?.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.outline,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixText: currency != null ? '$currency ' : null,
        prefixStyle: (textStyle ?? theme.textTheme.titleLarge)?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      keyboardType: isText
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: isText
          ? null
          : [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              _AmountFormatter(),
            ],
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
