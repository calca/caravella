import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  const NoteInputWidget({
    super.key,
    required this.controller,
    this.textStyle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null, // auto-grow illimitato
      minLines: 4, // minimo 4 righe visibili
      style: textStyle ?? Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: gloc.note_hint,
        // rely on theme hintStyle and borders
        isDense: true,
      ),
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
