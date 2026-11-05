import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../details/pages/tabs/usecase/date_range_formatter.dart';
import '../../data/group_form_state.dart';
import '../../group_type/group_type_localization.dart';
import '../../pages/group_creation_wizard_page.dart';
import '../../widgets/background_picker.dart';
import '../../widgets/currency_selector_sheet.dart';
import '../../widgets/period_selection_bottom_sheet.dart';
import '../wizard_group_preview.dart';

/// A preview of the group and its name (the only required field). Its dates,
/// currency and background are [WizardDetailsPills], outside this step.
class WizardDetailsStep extends StatefulWidget {
  final VoidCallback onSubmitted;

  /// With the keyboard up there's room for the preview and the name only.
  final bool keyboardOpen;

  const WizardDetailsStep({
    super.key,
    required this.onSubmitted,
    this.keyboardOpen = false,
  });

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

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final type = context.select((GroupFormState s) => s.groupType);
    final eyebrow = type != null
        ? GroupTypeLocalization.typeName(gloc, type)
        : gloc.wizard_group_creation_title;

    return WizardStepLayout(
      eyebrow: eyebrow,
      title: gloc.wizard_details_title,
      // With the keyboard up every pixel goes to the card and the field.
      bottomPadding: widget.keyboardOpen ? 0 : 20,
      children: [
        WizardGroupPreview(
          fallbackTitle: eyebrow,
          compact: widget.keyboardOpen,
        ),
        const SizedBox(height: 16),
        // Same outlined field as the group's General settings and an
        // expense's description.
        TextField(
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
          decoration: FormTheme.getCardDecoration(
            fillColor: theme.colorScheme.raisedSurface,
            borderColor: CardOutline.colorFor(theme.brightness),
            focusColor: theme.colorScheme.primary,
            errorColor: theme.colorScheme.error,
            hintText: gloc.enter_title,
          ),
        ),
        if (!widget.keyboardOpen) ...[
          const SizedBox(height: 16),
          WizardNote(gloc.wizard_details_note),
        ],
      ],
    );
  }
}

/// The group's dates, currency and background as pills, like the expense
/// form's details. Kept above the wizard's button, outside the part that
/// scrolls, so the keyboard never hides them.
class WizardDetailsPills extends StatelessWidget {
  const WizardDetailsPills({super.key});

  /// The same calendar sheet as the group's settings.
  Future<void> _pickDates(BuildContext context, GroupFormState state) =>
      showPeriodSelectionBottomSheet(
        context: context,
        initialStartDate: state.startDate,
        initialEndDate: state.endDate,
        onSelectionChanged: (start, end) =>
            state.setDates(start: start, end: end),
      );

  Future<void> _pickCurrency(BuildContext context, GroupFormState state) async {
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

  /// "Background" until one is chosen, then the photo or the color.
  Widget _backgroundPill(
    BuildContext context,
    GroupFormState state,
    gen.AppLocalizations gloc,
  ) {
    void pick() => showBackgroundPickerSheet(context);
    final image = state.imagePath;
    final color = ExpenseGroupColorPalette.resolveColor(
      state.color,
      Theme.of(context).colorScheme,
    );
    if (image == null && color == null) {
      return FormPill(
        icon: Icons.image_outlined,
        label: gloc.background,
        style: FormPillStyle.add,
        onTap: pick,
      );
    }
    final label = image != null ? gloc.image : gloc.color;
    return FormPill(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox.square(
          dimension: 22,
          child: image != null
              ? Image.file(
                  File(image),
                  fit: BoxFit.cover,
                  cacheWidth: 66,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                )
              : ColoredBox(color: color!),
        ),
      ),
      label: label,
      semanticsLabel: '${gloc.background}: $label',
      style: FormPillStyle.selected,
      onTap: pick,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = context.watch<GroupFormState>();
    final hasDates = state.startDate != null || state.endDate != null;
    final currency = state.currency;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
          onTap: () => _pickDates(context, state),
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
          onTap: () => _pickCurrency(context, state),
        ),
        _backgroundPill(context, state, gloc),
      ],
    );
  }
}
