import 'package:flutter/material.dart';
import '../../../data/expense_category.dart';
import '../../../app_localizations.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: textStyle ??
                Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            decoration: InputDecoration(
              labelText: label != null ? '${label!} *' : null,
              labelStyle: textStyle ??
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
            ),
            keyboardType: isText
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: validator,
            onSaved: onSaved,
            onFieldSubmitted: (_) => onSubmitted?.call(),
          ),
        ),
        if (!isText) ...[
          const SizedBox(width: 8),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              // Mostra la currency del viaggio se disponibile
              (categories.isNotEmpty && categories.first.name.startsWith('€'))
                  ? categories.first.name
                  : '€',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
