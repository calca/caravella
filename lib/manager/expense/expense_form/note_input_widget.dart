import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations loc;
  final TextStyle? textStyle;

  const NoteInputWidget({
    super.key,
    required this.controller,
    required this.loc,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.get('note'),
            style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 2,
          style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: loc.get('note_hint'),
            hintStyle: textStyle?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ) ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
