import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../settings/state/group_type_templates_notifier.dart';
import '../../data/group_form_state.dart';
import '../../group_form_controller.dart';
import '../../group_type/group_type_localization.dart';
import '../../pages/group_creation_wizard_page.dart';

/// What kind of group: the four built-in types as big cards (travel first),
/// then the user's own templates. The choice sets the starting categories.
class WizardTypeStep extends StatelessWidget {
  const WizardTypeStep({super.key});

  static const _order = [
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
      for (final type in _order)
        _TypeCard(
          icon: type.icon,
          title: GroupTypeLocalization.typeName(gloc, type),
          subtitle: description(gloc, type),
          selected: state.groupType == type,
          onTap: () => pickType(type),
        ),
      for (final t in templates)
        _TypeCard(
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

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? s.primaryContainer : s.raisedSurface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? s.primary : s.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? s.primary : s.surfaceContainerHighest,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected ? s.onPrimary : s.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? s.onPrimaryContainer : s.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected
                          ? s.onPrimaryContainer
                          : s.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
