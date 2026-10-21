import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../settings/state/group_type_templates_notifier.dart';
import '../../data/group_form_state.dart';
import '../../group_form_controller.dart';
import '../../group_type/group_type_card.dart';
import '../../group_type/group_type_localization.dart';
import '../../pages/group_creation_wizard_page.dart';

/// What kind of group: the four built-in types as big cards (travel first),
/// then the user's own templates. The choice sets the starting categories.
class WizardTypeStep extends StatelessWidget {
  const WizardTypeStep({super.key});

  static const order = [
    ExpenseGroupType.travel,
    ExpenseGroupType.family,
    ExpenseGroupType.personal,
    ExpenseGroupType.other,
  ];

  static String description(gen.AppLocalizations gloc, ExpenseGroupType t) =>
      switch (t) {
        ExpenseGroupType.travel => gloc.group_type_travel_desc,
        ExpenseGroupType.family => gloc.group_type_family_desc,
        ExpenseGroupType.personal => gloc.group_type_personal_desc,
        ExpenseGroupType.other => gloc.group_type_other_desc,
      };

  List<GroupTypeTemplate> _templates(BuildContext context) {
    try {
      return context.watch<GroupTypeTemplatesNotifier>().templates;
    } catch (_) {
      return const [];
    }
  }

  /// The categories of the current choice, replaced by the new one's.
  List<String>? _currentCategories(
    gen.AppLocalizations gloc,
    GroupFormState state,
    List<GroupTypeTemplate> templates,
  ) {
    final type = state.groupType;
    if (type != null) {
      return GroupTypeLocalization.localizedDefaultCategories(gloc, type);
    }
    for (final t in templates) {
      if (t.id == state.customTemplateId) return t.defaultCategories;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    final templates = _templates(context);

    void pickType(ExpenseGroupType type) {
      if (state.groupType == type) return;
      controller.setGroupType(
        type,
        defaultCategoryNames: GroupTypeLocalization.localizedDefaultCategories(
          gloc,
          type,
        ),
        previousTypeCategoryNames: _currentCategories(gloc, state, templates),
      );
    }

    void pickTemplate(GroupTypeTemplate t) {
      if (state.groupType == null && state.customTemplateId == t.id) return;
      controller.applyCustomTemplate(
        templateId: t.id,
        iconCodePoint: t.iconCodePoint,
        templateCategoryNames: t.defaultCategories,
        previousTypeCategoryNames: _currentCategories(gloc, state, templates),
      );
    }

    final cards = [
      for (final type in order)
        GroupTypeCard(
          icon: type.icon,
          title: GroupTypeLocalization.typeName(gloc, type),
          subtitle: description(gloc, type),
          selected: state.groupType == type,
          onTap: () => pickType(type),
        ),
      for (final t in templates)
        GroupTypeCard(
          icon: GroupTypeLocalization.iconFromCodePoint(t.iconCodePoint),
          title: t.name,
          subtitle: t.defaultCategories.take(3).join(', '),
          selected: state.groupType == null && state.customTemplateId == t.id,
          onTap: () => pickTemplate(t),
        ),
    ];

    return WizardStepLayout(
      eyebrow: gloc.wizard_group_creation_title,
      title: gloc.wizard_type_title,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: cards,
        ),
        const SizedBox(height: 16),
        WizardNote(gloc.wizard_type_note),
      ],
    );
  }
}
