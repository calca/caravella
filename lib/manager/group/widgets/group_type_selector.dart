import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/settings/state/group_type_templates_notifier.dart';
import '../data/group_form_state.dart';
import '../group_type/group_type_localization.dart';
import '../group_type/group_type_selector_sheet.dart';
import 'section_flat.dart';
import 'selection_tile.dart';
import 'package:provider/provider.dart';

/// Widget for selecting the expense group type.
/// Shows only the selected type and opens a bottom sheet for selection.
class GroupTypeSelector extends StatelessWidget {
  const GroupTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return SectionFlat(
      title: '',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: gloc.group_type,
              description: gloc.group_type_description,
              padding: EdgeInsets.zero,
              spacing: 4,
            ),
            const SizedBox(height: 8),
            Selector<GroupFormState, (ExpenseGroupType?, String?, int?)>(
              selector: (context, state) =>
                  (
                    state.groupType,
                    state.customTemplateId,
                    state.customTemplateIconCodePoint,
                  ),
              builder: (context, selectedValue, child) {
                final selectedType = selectedValue.$1;
                final selectedTemplateId = selectedValue.$2;
                final selectedTemplateIcon = selectedValue.$3;
                List<GroupTypeTemplate> templates = const <GroupTypeTemplate>[];
                try {
                  templates = context.watch<GroupTypeTemplatesNotifier>().templates;
                } catch (_) {
                  templates = const <GroupTypeTemplate>[];
                }
                String? selectedTemplateName;
                if (selectedTemplateId != null) {
                  for (final template in templates) {
                    if (template.id == selectedTemplateId) {
                      selectedTemplateName = template.name;
                      break;
                    }
                  }
                }
                return SelectionTile(
                  leading: Icon(
                    selectedType?.icon ??
                        GroupTypeLocalization.iconFromCodePoint(
                          selectedTemplateIcon ?? 0,
                        ),
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: selectedType != null
                      ? GroupTypeLocalization.typeName(gloc, selectedType)
                      : (selectedTemplateName ?? gloc.group_type_description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showGroupTypeSelectorSheet(context),
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
