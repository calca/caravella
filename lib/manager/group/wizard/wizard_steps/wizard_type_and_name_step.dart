import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../../group_type/group_type_selector_sheet.dart';
import '../../pages/group_creation_wizard_page.dart';
import '../../widgets/group_name_with_icon_field.dart';

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
    showGroupTypeSelectorSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    const stepContentPadding = 24.0;
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final titleFieldStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
    final titleFieldDecoration = FormTheme.getBorderlessDecoration(
      hintText: gloc.enter_title,
    ).copyWith(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(stepContentPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: max(0, constraints.maxHeight - (stepContentPadding * 2)),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Friendly emoji icon (random selection)
                  Text(_selectedEmoji, style: AppTextStyles.emojiDisplay),

                  const SizedBox(height: 24),

                  // Step description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      gloc.wizard_type_and_name_description,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Group name input with type icon
                  Consumer<GroupFormState>(
                    builder: (context, state, child) {
                      final showError = state.title.isEmpty;
                      return GroupNameWithIconField(
                        onIconTap: () => _showGroupTypeSelector(context),
                        onSubmitted: () {
                          // Proceed to next step if title is valid
                          if (state.title.trim().isNotEmpty) {
                            final wizardState = context.read<WizardState>();
                            wizardState.nextStep();
                          }
                        },
                        hintText: gloc.enter_title,
                        textAlign: TextAlign.start,
                        textStyle: titleFieldStyle,
                        decoration: titleFieldDecoration.copyWith(
                          errorText: showError ? gloc.enter_title : null,
                          errorMaxLines: 2,
                        ),
                      );
                    },
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
