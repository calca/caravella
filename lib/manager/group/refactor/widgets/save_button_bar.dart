import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../group_form_state.dart';
import '../group_form_controller.dart';

class SaveButtonBar extends StatelessWidget {
  final VoidCallback onSaved;
  const SaveButtonBar({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return FilledButton(
      onPressed: state.isValid
          ? () async {
              await controller.save();
              onSaved();
            }
          : null,
      child: const Text('Salva'),
    );
  }
}
