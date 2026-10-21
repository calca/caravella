import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../details/pages/tabs/usecase/date_range_formatter.dart';
import '../../data/group_form_state.dart';
import '../../group_type/group_type_localization.dart';
import '../../pages/group_creation_wizard_page.dart';
import '../../widgets/currency_selector_sheet.dart';
import '../../widgets/period_selection_bottom_sheet.dart';

/// The group's name (the only required field), then its dates and currency
/// as pills, like the expense form's details.
class WizardDetailsStep extends StatefulWidget {
  final VoidCallback onSubmitted;

  const WizardDetailsStep({super.key, required this.onSubmitted});

  @override
  State<WizardDetailsStep> createState() => _WizardDetailsStepState();
}

class _WizardDetailsStepState extends State<WizardDetailsStep> {
  final _title = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title.text = context.read<GroupFormState>().title;
    _title.addListener(
      () => context.read<GroupFormState>().setTitle(_title.text),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// The same calendar sheet as the group's settings.
  Future<void> _pickDates(GroupFormState state) =>
      showPeriodSelectionBottomSheet(
        context: context,
        initialStartDate: state.startDate,
        initialEndDate: state.endDate,
        onSelectionChanged: (start, end) =>
            state.setDates(start: start, end: end),
      );

  Future<void> _pickCurrency(GroupFormState state) async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CurrencySelectorSheet(
        selectedCode: context.read<GroupFormState>().currency['code'],
      ),
    );
    if (selected != null) state.setCurrency(selected);
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<GroupFormState>();
    final type = state.groupType;
    final eyebrow = type != null
        ? GroupTypeLocalization.typeName(gloc, type)
        : gloc.wizard_group_creation_title;
    final hasDates = state.startDate != null || state.endDate != null;
    final currency = state.currency;

    return WizardStepLayout(
      eyebrow: eyebrow,
      title: gloc.wizard_details_title,
      children: [
        WizardCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_title.text.trim().isNotEmpty) widget.onSubmitted();
            },
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: gloc.enter_title,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        FormSectionLabel(gloc.expense_details_section),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FormPill(
              icon: Icons.event_outlined,
              label: hasDates
                  ? formatDateRange(
                      start: state.startDate,
                      end: state.endDate,
                      locale: Localizations.localeOf(context),
                    )
                  : gloc.wizard_dates_add,
              style: hasDates ? FormPillStyle.selected : FormPillStyle.add,
              onTap: () => _pickDates(state),
            ),
            if (hasDates)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: gloc.clear_dates,
                onPressed: state.clearDates,
              ),
            FormPill(
              leading: Text(
                currency['symbol'] ?? '',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              label: currency['name'] ?? currency['code'] ?? '',
              semanticsLabel:
                  '${gloc.currency}: ${currency['name'] ?? currency['code']}',
              onTap: () => _pickCurrency(state),
            ),
          ],
        ),
        const SizedBox(height: 16),
        WizardNote(gloc.wizard_details_note),
      ],
    );
  }
}
