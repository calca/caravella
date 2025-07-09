import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class CategoryDialog {
  static Future<String?> show({
    required BuildContext context,
    required AppLocalizations loc,
  }) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('add_category')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: loc.get('category_name'),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Navigator.of(context).pop(val.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(context).pop(val);
              }
            },
            child: Text(loc.get('add')),
          ),
        ],
      ),
    );
  }
}
