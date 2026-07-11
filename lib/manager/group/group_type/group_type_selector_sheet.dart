import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';

import '../../../settings/state/group_type_templates_notifier.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../widgets/selection_tile.dart';
import 'group_type_localization.dart';

void showGroupTypeSelectorSheet(BuildContext context) {
  final gloc = gen.AppLocalizations.of(context);
  final controller = context.read<GroupFormController>();
  final state = context.read<GroupFormState>();
  final currentType = state.groupType;
  final currentTemplateId = state.customTemplateId;
  List<GroupTypeTemplate> templates = const <GroupTypeTemplate>[];
  if (controller.mode == GroupEditMode.create) {
    try {
      templates = context.read<GroupTypeTemplatesNotifier>().templates;
    } catch (_) {
      LoggerService.warning(
        'Group templates notifier is unavailable',
        name: 'state.notifier',
      );
      templates = const <GroupTypeTemplate>[];
    }
  }
  List<String>? previousSelectionCategories() {
    if (currentType != null) {
      return GroupTypeLocalization.localizedDefaultCategories(gloc, currentType);
    }
    if (currentTemplateId != null) {
      for (final template in templates) {
        if (template.id == currentTemplateId) {
          return template.defaultCategories;
        }
      }
    }
    return null;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => GroupBottomSheetScaffold(
      title: gloc.group_type,
      scrollable: false,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...ExpenseGroupType.values.map((type) {
            final isSelected = currentType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectionTile(
                leading: Icon(
                  type.icon,
                  size: 24,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                title: GroupTypeLocalization.typeName(gloc, type),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  controller.setGroupType(
                    isSelected ? null : type,
                    autoPopulateCategories: !isSelected,
                    defaultCategoryNames: !isSelected
                        ? GroupTypeLocalization.localizedDefaultCategories(
                            gloc,
                            type,
                          )
                        : null,
                    previousTypeCategoryNames: previousSelectionCategories(),
                  );
                  Navigator.of(context).pop();
                },
                borderRadius: 8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            );
          }),
          if (templates.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                gloc.settings_group_templates_section_title,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            ...templates.map((template) {
              final isSelected = currentType == null &&
                  currentTemplateId != null &&
                  currentTemplateId == template.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectionTile(
                  leading: Icon(
                    GroupTypeLocalization.iconFromCodePoint(
                      template.iconCodePoint,
                    ),
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  title: template.name,
                  subtitle: template.defaultCategories.join(', '),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.applyCustomTemplate(
                      templateId: template.id,
                      iconCodePoint: template.iconCodePoint,
                      templateCategoryNames: template.defaultCategories,
                      previousTypeCategoryNames: previousSelectionCategories(),
                    );
                    Navigator.of(context).pop();
                  },
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    ),
  );
}
