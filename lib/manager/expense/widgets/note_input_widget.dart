import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;
  final bool enabled;

  const NoteInputWidget({
    super.key,
    required this.controller,
    this.textStyle,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Semantics(
      textField: true,
      label: gloc.note,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        maxLines: null,
        // Longer than the description: room for a few lines at a glance.
        minLines: 4,
        style: textStyle ?? FormTheme.getMultilineTextStyle(context),
        decoration: FormTheme.getCardDecoration(
          fillColor: s.raisedSurface,
          borderColor: CardOutline.colorFor(theme.brightness),
          focusColor: s.primary,
          errorColor: s.error,
          hintText: gloc.note_hint,
        ),
        textInputAction: textInputAction ?? TextInputAction.newline,
        onFieldSubmitted: onFieldSubmitted != null
            ? (_) => onFieldSubmitted!()
            : null,
      ),
    );
  }
}
