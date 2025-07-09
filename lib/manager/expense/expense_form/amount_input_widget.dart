import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final VoidCallback? onSubmitted;
  final List<String> categories;
  final AppLocalizations loc;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loc,
    this.validator,
    this.onSaved,
    this.onSubmitted,
    this.categories = const [],
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            decoration: InputDecoration(
              labelText: '${loc.get('amount')} *',
              labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            validator: validator,
            onSaved: onSaved,
            onFieldSubmitted: (_) => onSubmitted?.call(),
          ),
        ),
        const SizedBox(width: 8),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            // Mostra la currency del viaggio se disponibile
            (categories.isNotEmpty && categories.first.startsWith('€'))
                ? categories.first
                : '€',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
