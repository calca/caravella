import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class CategoryDialog {
  static Future<String?> show({required BuildContext context}) async {
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
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

    return CaravellaBottomSheetScaffold(
      title: gloc.select_category,
      showHandle: true,
      scrollable: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              textField: true,
              label: gloc.category_name,
              child: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: FormTheme.getCardDecoration(
                  fillColor: Theme.of(context).colorScheme.raisedSurface,
                  borderColor: Theme.of(context).colorScheme.outlineVariant,
                  focusColor: Theme.of(context).colorScheme.primary,
                  errorColor: Theme.of(context).colorScheme.error,
                  hintText: gloc.category_name,
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.of(context).pop(val.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty) Navigator.of(context).pop(val);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(gloc.add),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(gloc.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
