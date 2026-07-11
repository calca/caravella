import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';

import '../../manager/group/group_type/group_type_localization.dart';
import '../state/group_type_templates_notifier.dart';
import '../widgets/settings_card.dart';

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
                        onPressed: () => _openEditor(
                          context,
                          notifier,
                          template: template,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, context.read<GroupTypeTemplatesNotifier>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GroupTypeTemplatesNotifier notifier, {
    required GroupTypeTemplate template,
  }) async {
    final loc = gen.AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.settings_group_templates_delete_title),
        content: Text(
          loc.settings_group_templates_delete_message(template.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loc.delete),
          ),
        ],
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
    final loc = gen.AppLocalizations.of(context);
    final nameController = TextEditingController(text: template?.name ?? '');
    final categoryController = TextEditingController();
    final categories = <String>[...?template?.defaultCategories];
    var iconCodePoint =
        template?.iconCodePoint ?? GroupTypeLocalization.availableIcons.first.codePoint;
    var validationMessage = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            template == null
                ? loc.settings_group_templates_add_title
                : loc.settings_group_templates_edit_title,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.settings_group_templates_name_label,
                    hintText: loc.settings_group_templates_name_hint,
                  ),
                  maxLength: 40,
                ),
                const SizedBox(height: 12),
                Text(loc.settings_group_templates_icon_label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GroupTypeLocalization.availableIcons.map((icon) {
                    final selected = icon.codePoint == iconCodePoint;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setDialogState(() {
                          iconCodePoint = icon.codePoint;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Icon(icon),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(loc.settings_group_templates_categories_label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          hintText: loc.settings_group_templates_category_hint,
                        ),
                        onSubmitted: (_) {
                          _addCategory(
                            categoryController,
                            categories,
                            setDialogState,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _addCategory(
                          categoryController,
                          categories,
                          setDialogState,
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return Chip(
                      label: Text(category),
                      onDeleted: () {
                        setDialogState(() {
                          categories.remove(category);
                        });
                      },
                    );
                  }).toList(),
                ),
                if (validationMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    validationMessage,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || categories.isEmpty) {
                  setDialogState(() {
                    validationMessage =
                        loc.settings_group_templates_validation_error;
                  });
                  return;
                }

                final nextTemplate = GroupTypeTemplate(
                  id: template?.id,
                  createdAt: template?.createdAt,
                  name: name,
                  iconCodePoint: iconCodePoint,
                  defaultCategories: categories,
                );

                await notifier.upsert(nextTemplate);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory(
    TextEditingController controller,
    List<String> categories,
    void Function(void Function()) setDialogState,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty || categories.contains(value)) return;
    setDialogState(() {
      categories.add(value);
      controller.clear();
    });
  }
}
