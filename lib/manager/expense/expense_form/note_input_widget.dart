import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;

  const NoteInputWidget({
    super.key,
    required this.controller,
    this.textStyle,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null, // auto-grow illimitato
      minLines: 6, // minimo 4 righe visibili
      style: textStyle ?? FormTheme.getMultilineTextStyle(context),
      decoration: FormTheme.getMultilineDecoration(hintText: gloc.note_hint),
      textInputAction: textInputAction ?? TextInputAction.newline,
      onFieldSubmitted: onFieldSubmitted != null
          ? (_) => onFieldSubmitted!()
          : null,
    );

    return IconLeadingField(
      icon: const Icon(Icons.sticky_note_2_outlined),
      semanticsLabel: gloc.note,
      tooltip: gloc.note,
      alignTop: true,
      child: field,
    );
  }
}
