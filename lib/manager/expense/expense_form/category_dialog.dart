import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class CategoryDialog {
  static Future<String?> show({required BuildContext context}) async {
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CategoryBottomSheet(controller: controller),
    );
  }
}

class _CategoryBottomSheet extends StatelessWidget {
  final TextEditingController controller;

  const _CategoryBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return GroupBottomSheetScaffold(
      title: gloc.select_category,
      showHandle: true,
      scrollable: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              textField: true,
              label: gloc.category_name,
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: gloc.category_name,
                  semanticCounterText: '',
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.of(context).pop(val.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Semantics(
                  button: true,
                  label: '${gloc.cancel} dialog',
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(gloc.cancel),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: '${gloc.add} category',
                  child: FilledButton.tonal(
                    onPressed: () {
                      final val = controller.text.trim();
                      if (val.isNotEmpty) {
                        Navigator.of(context).pop(val);
                      }
                    },
                    child: Text(gloc.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
