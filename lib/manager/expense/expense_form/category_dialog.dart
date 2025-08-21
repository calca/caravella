import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class CategoryDialog {
  static Future<String?> show({required BuildContext context}) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => Semantics(
        label: gen.AppLocalizations.of(context).add_category,
        child: AlertDialog(
          title: Text(gen.AppLocalizations.of(context).add_category),
          content: Semantics(
            textField: true,
            label: gen.AppLocalizations.of(context).category_name,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: gen.AppLocalizations.of(context).category_name,
                semanticCounterText: '',
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  Navigator.of(context).pop(val.trim());
                }
              },
            ),
          ),
          actions: [
            Semantics(
              button: true,
              label: '${gen.AppLocalizations.of(context).cancel} dialog',
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(gen.AppLocalizations.of(context).cancel),
              ),
            ),
            Semantics(
              button: true,
              label: '${gen.AppLocalizations.of(context).add} category',
              child: TextButton(
                onPressed: () {
                  final val = controller.text.trim();
                  if (val.isNotEmpty) {
                    Navigator.of(context).pop(val);
                  }
                },
                child: Text(gen.AppLocalizations.of(context).add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
