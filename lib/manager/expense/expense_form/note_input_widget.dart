import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;

  const NoteInputWidget({super.key, required this.controller, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final field = TextFormField(
      controller: controller,
      maxLines: null, // auto-grow illimitato
      minLines: 4, // minimo 4 righe visibili
      style: textStyle ?? Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: gloc.note_hint,
        hintStyle: textStyle?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ) ??
            Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
