import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;

  const NoteInputWidget({super.key, required this.controller, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            gen.AppLocalizations.of(context).note,
            style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: null, // auto-grow illimitato
          minLines: 4, // minimo 4 righe visibili
          style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: gen.AppLocalizations.of(context).note_hint,
            hintStyle:
                textStyle?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ) ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
