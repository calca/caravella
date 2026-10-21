import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';

import '../../../settings/state/group_type_templates_notifier.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../wizard/wizard_steps/wizard_type_step.dart';
import 'group_type_card.dart';
import 'group_type_localization.dart';

/// The kind of group as the creation wizard shows it: the four built-in
/// types and the user's templates as big cards in two columns. Picking one
/// closes the sheet (in create mode it also swaps the starting categories).
void showGroupTypeSelectorSheet(BuildContext context) {
  final gloc = gen.AppLocalizations.of(context);
  final controller = context.read<GroupFormController>();
  final state = context.read<GroupFormState>();
  final currentType = state.groupType;
  final currentTemplateId = state.customTemplateId;
  List<GroupTypeTemplate> templates = const <GroupTypeTemplate>[];
  try {
    templates = context.read<GroupTypeTemplatesNotifier>().templates;
  } catch (_) {
    LoggerService.warning(
      'Group templates notifier is unavailable',
      name: 'state.notifier',
    );
  }
  List<String>? previousSelectionCategories() {
    if (currentType != null) {
      return GroupTypeLocalization.localizedDefaultCategories(
        gloc,
        currentType,
      );
    }
    for (final template in templates) {
      if (template.id == currentTemplateId) return template.defaultCategories;
    }
    return null;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => CaravellaBottomSheetScaffold(
      title: gloc.group_type,
      scrollable: true,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: [
          for (final type in WizardTypeStep.order)
            GroupTypeCard(
              icon: type.icon,
              title: GroupTypeLocalization.typeName(gloc, type),
              subtitle: WizardTypeStep.description(gloc, type),
              selected: currentType == type,
              onTap: () {
                if (currentType != type) {
                  controller.setGroupType(
                    type,
                    defaultCategoryNames:
                        GroupTypeLocalization.localizedDefaultCategories(
                          gloc,
                          type,
                        ),
                    previousTypeCategoryNames: previousSelectionCategories(),
                  );
                }
                Navigator.of(sheetContext).pop();
              },
            ),
          for (final template in templates)
            GroupTypeCard(
              icon: GroupTypeLocalization.iconFromCodePoint(
                template.iconCodePoint,
              ),
              title: template.name,
              subtitle: template.defaultCategories.take(3).join(', '),
              selected: currentType == null && currentTemplateId == template.id,
              onTap: () {
                controller.applyCustomTemplate(
                  templateId: template.id,
                  iconCodePoint: template.iconCodePoint,
                  templateCategoryNames: template.defaultCategories,
                  previousTypeCategoryNames: previousSelectionCategories(),
                );
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}
