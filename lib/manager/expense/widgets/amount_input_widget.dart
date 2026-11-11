import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
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
    final gloc = gen.AppLocalizations.of(context);
    if (isText) {
      final textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        style: textStyle ?? FormTheme.getFieldTextStyle(context),
        decoration:
            FormTheme.getCardDecoration(
              fillColor: theme.colorScheme.raisedSurface,
              borderColor: CardOutline.colorFor(theme.brightness),
              focusColor: theme.colorScheme.primary,
              errorColor: theme.colorScheme.error,
              hintText: label != null ? '${label!} *' : null,
            ).copyWith(
              suffixIcon: leading == null && trailing != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: trailing,
                    )
                  : null,
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

    return AmountField(
      controller: controller,
      focusNode: focusNode,
      currency: currency ?? '€',
      label: label ?? gloc.amount,
      validator: validator,
      onSaved: onSaved,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      textStyle: textStyle,
      enabled: enabled,
    );
  }
}
