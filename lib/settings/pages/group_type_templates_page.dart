import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
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
    final s = Theme.of(context).colorScheme;
    return AppSystemUI.edgeToEdge(
      child: Consumer<GroupTypeTemplatesNotifier>(
        builder: (context, notifier, _) {
          final templates = notifier.templates;
          return SettingsScaffold(
            eyebrow: loc.settings,
            title: loc.settings_group_templates_page_title,
            floatingActionButton: AddFab(
              onPressed: () => _openEditor(context, notifier),
              tooltip: loc.settings_group_templates_add_title,
            ),
            children: [
              if (templates.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
                  child: Text(
                    loc.settings_group_templates_empty_state,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: s.onSurfaceVariant),
                  ),
                )
              else
                SettingsGroup(
                  children: [
                    for (final template in templates)
                      SettingsTile(
                        icon: GroupTypeLocalization.iconFromCodePoint(
                          template.iconCodePoint,
                        ),
                        title: template.name,
                        subtitle: template.defaultCategories.join(', '),
                        onTap: () =>
                            _openEditor(context, notifier, template: template),
                        trailing: IconButton(
                          tooltip: loc.settings_group_templates_delete_title,
                          onPressed: () => _confirmDelete(
                            context,
                            notifier,
                            template: template,
                          ),
                          icon: Icon(
                            Icons.delete_outline,
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              // Room for the add button.
              const SizedBox(height: 88),
            ],
          );
        },
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

    if (shouldDelete != true) return;

    try {
      await notifier.delete(template.id);
    } catch (e, st) {
      LoggerService.error(
        'Failed to delete group type template',
        name: 'settings.group_templates',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        AppToast.show(
          context,
          loc.error_saving_group(e),
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    GroupTypeTemplatesNotifier notifier, {
    GroupTypeTemplate? template,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GroupTypeTemplateFormPage(notifier: notifier, template: template),
      ),
    );
  }
}
