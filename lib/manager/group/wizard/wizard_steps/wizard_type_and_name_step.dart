import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../../group_form_controller.dart';
import '../../widgets/group_name_with_icon_field.dart';
import '../../widgets/selection_tile.dart';

class WizardTypeAndNameStep extends StatefulWidget {
  const WizardTypeAndNameStep({super.key});

  @override
  State<WizardTypeAndNameStep> createState() => _WizardTypeAndNameStepState();
}

class _WizardTypeAndNameStepState extends State<WizardTypeAndNameStep> {
  static const List<String> _friendlyEmojis = [
    '✨',
    '🎯',
    '🚀',
    '🌟',
    '🎊',
    '📝',
  ];
  late final String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = _friendlyEmojis[Random().nextInt(_friendlyEmojis.length)];
  }

  void _showGroupTypeSelector(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final controller = context.read<GroupFormController>();
    final currentType = context.read<GroupFormState>().groupType;

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
                  title: _getGroupTypeName(gloc, type),
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
                          ? _getLocalizedCategories(gloc, type)
                          : null,
                      previousTypeCategoryNames: currentType != null
                          ? _getLocalizedCategories(gloc, currentType)
                          : null,
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
        ),
      ),
    );
  }

  String _getGroupTypeName(gen.AppLocalizations gloc, ExpenseGroupType type) {
    switch (type) {
      case ExpenseGroupType.travel:
        return gloc.group_type_travel;
      case ExpenseGroupType.personal:
        return gloc.group_type_personal;
      case ExpenseGroupType.family:
        return gloc.group_type_family;
      case ExpenseGroupType.other:
        return gloc.group_type_other;
    }
  }

  List<String> _getLocalizedCategories(
    gen.AppLocalizations gloc,
    ExpenseGroupType type,
  ) {
    switch (type) {
      case ExpenseGroupType.travel:
        return [
          gloc.category_travel_transport,
          gloc.category_travel_accommodation,
          gloc.category_travel_restaurants,
        ];
      case ExpenseGroupType.personal:
        return [
          gloc.category_personal_shopping,
          gloc.category_personal_health,
          gloc.category_personal_entertainment,
        ];
      case ExpenseGroupType.family:
        return [
          gloc.category_family_groceries,
          gloc.category_family_home,
          gloc.category_family_bills,
        ];
      case ExpenseGroupType.other:
        return [
          gloc.category_other_misc,
          gloc.category_other_utilities,
          gloc.category_other_services,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Friendly emoji icon (random selection)
            Text(_selectedEmoji, style: const TextStyle(fontSize: 72)),

            const SizedBox(height: 24),

            // Step description
            Text(
              gloc.wizard_type_and_name_description,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Compact content container
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Group name input with type icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          gloc.wizard_name_description,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      GroupNameWithIconField(
                        onIconTap: () => _showGroupTypeSelector(context),
                      ),
                      // Error message
                      Consumer<GroupFormState>(
                        builder: (context, state, child) {
                          return state.title.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        gloc.enter_title,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
