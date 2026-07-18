import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';

import '../../manager/group/group_type/group_type_localization.dart';
import '../state/group_type_templates_notifier.dart';
import 'group_type_template_form_page.dart';

class GroupTypeTemplatesPage extends StatelessWidget {
  const GroupTypeTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings_group_templates_page_title)),
      body: Consumer<GroupTypeTemplatesNotifier>(
        builder: (context, notifier, _) {
          final templates = notifier.templates;
          if (templates.isEmpty) {
            return Center(child: Text(loc.settings_group_templates_empty_state));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final template = templates[index];
              return SettingsCard(
                context: context,
                color: Theme.of(context).colorScheme.surface,
                onTap: () => _openEditor(
                  context,
                  notifier,
                  template: template,
                ),
                child: ListTile(
                  leading: Icon(
                    GroupTypeLocalization.iconFromCodePoint(
                      template.iconCodePoint,
                    ),
                  ),
                  title: Text(template.name),
                  subtitle: Text(template.defaultCategories.join(', ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: loc.settings_group_templates_edit_title,
                        onPressed: () => _openEditor(
                          context,
                          notifier,
                          template: template,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: loc.settings_group_templates_delete_title,
                        onPressed: () => _confirmDelete(
                          context,
                          notifier,
                          template: template,
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: AddFab(
        onPressed: () =>
            _openEditor(context, context.read<GroupTypeTemplatesNotifier>()),
        tooltip: loc.settings_group_templates_add_title,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GroupTypeTemplatesNotifier notifier, {
    required GroupTypeTemplate template,
  }) async {
    final loc = gen.AppLocalizations.of(context);
    final shouldDelete = await Material3Dialogs.showConfirmation(
      context,
      title: loc.settings_group_templates_delete_title,
      content: loc.settings_group_templates_delete_message(template.name),
      confirmText: loc.delete,
      cancelText: loc.cancel,
      isDestructive: true,
      icon: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
    );

    if (shouldDelete == true) {
      await notifier.delete(template.id);
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    GroupTypeTemplatesNotifier notifier, {
    GroupTypeTemplate? template,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupTypeTemplateFormPage(
          notifier: notifier,
          template: template,
        ),
      ),
    );
  }
}
