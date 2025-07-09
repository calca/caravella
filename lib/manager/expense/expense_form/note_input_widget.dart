import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations loc;

  const NoteInputWidget({
    super.key,
    required this.controller,
    required this.loc,
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 2,
          decoration: InputDecoration(
            hintText: loc.get('note_hint'),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
