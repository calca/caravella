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

  /// Text mode: the field as the page's title (large, bold, no box, a
  /// dashed line under it) instead of a card (the expense page's header).
  final bool headline;

  /// Amount mode: see [AmountField.currencyAfter].
  final bool currencyAfter;

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
    this.headline = false,
    this.currencyAfter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    if (isText) {
      final line = UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      );
      final textField = TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        style: headline
            ? theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
              )
            : textStyle ?? FormTheme.getFieldTextStyle(context),
        maxLines: headline ? null : 1,
        decoration: headline
            ? InputDecoration(
                hintText: label != null ? '${label!} *' : null,
                isDense: true,
                // 48 dp: a touch target, even with a short title.
                constraints: const BoxConstraints(minHeight: 48),
                contentPadding: const EdgeInsets.only(top: 4, bottom: 8),
                border: line,
                enabledBorder: line,
                disabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              )
            : FormTheme.getCardDecoration(
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
      currencyAfter: currencyAfter,
    );
  }
}
