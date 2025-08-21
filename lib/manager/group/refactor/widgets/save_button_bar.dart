import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../group_form_state.dart';
import '../group_form_controller.dart';

class SaveButtonBar extends StatelessWidget {
  const SaveButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return FilledButton(
        onPressed: state.isValid
            ? () async {
                final navContext = context; // capture before await
                await controller.save();
                // Defer pop to next microtask to let widget tree settle
                Future.microtask(() {
                  if (navContext.mounted) {
                    Navigator.of(navContext).pop(true);
                  }
                });
              }
            : null,
        child: const Text('Salva'));
  }
}
