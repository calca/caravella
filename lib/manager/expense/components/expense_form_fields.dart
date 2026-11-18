library;

import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/amount_input_widget.dart';
import '../widgets/category_dialog.dart';
import '../widgets/participant_selector_widget.dart';
import '../widgets/category_selector_widget.dart';
import '../state/expense_form_controller.dart';

/// Builds the core form fields: amount, description, paid-by and category.
class ExpenseFormFields extends StatelessWidget {
  final ExpenseFormController controller;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(String) onCategoryAdded;
  final Function(String)? onParticipantAdded;
  final Function(List<ExpenseCategory>) onCategoriesUpdated;
  final Function(List<ExpenseParticipant>)? onParticipantsUpdated;
  final String? currency;

  /// The group's second currency: a quiet link under the amount types it
  /// in that currency instead.
  final SecondCurrency? secondCurrency;
  final VoidCallback onSaveExpense;
  final bool isReadOnly;

  /// Paid-by and category on one line each (quick-add sheet).
  final bool compactPills;

  /// See [ExpenseFormConfig.editHeader].
  final bool editHeader;

  /// The group's name, on the line above the title with [editHeader].
  final String? groupTitle;

  const ExpenseFormFields({
    super.key,
    required this.controller,
    required this.participants,
    required this.categories,
    required this.onCategoryAdded,
    this.onParticipantAdded,
    required this.currency,
    this.secondCurrency,
    required this.onSaveExpense,
    required this.onCategoriesUpdated,
    this.onParticipantsUpdated,
    this.isReadOnly = false,
    this.compactPills = false,
    this.editHeader = false,
    this.groupTitle,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (editHeader) return _buildEditHeader(context, gloc);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountField(context, gloc, style),
            if (_second case final second?)
              _EntryCurrencyLine(
                controller: controller,
                groupCurrency: currency ?? '',
                second: second,
                enabled: !isReadOnly,
              )
            else
              SizedBox(height: FormTheme.fieldSpacing),
            _buildNameField(context, gloc, style),
            _buildParticipantCategorySection(context),
          ],
        );
      },
    );
  }

  /// The expense page's top: "Norway · Tue 17 Nov", the description as the
  /// title, the amount with its currency after it, who paid and each one's
  /// share, then paid-by and category as in the sheet.
  Widget _buildEditHeader(BuildContext context, gen.AppLocalizations gloc) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final locale = Localizations.localeOf(context);
    final state = controller.state;
    final date = DateFormat.MMMEd(locale.toString()).format(state.date);
    final where = [?groupTitle, date].join(' · ');
    final share = _shareLine(gloc, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(where, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        KeyedSubtree(
          key: controller.nameFieldKey,
          child: AmountInputWidget(
            controller: controller.nameController,
            focusNode: controller.nameFocus,
            label: gloc.expense_name,
            textInputAction: controller.isFormValid
                ? TextInputAction.done
                : TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? gloc.enter_title : null,
            onSaved: (v) {},
            onSubmitted: controller.isFormValid ? onSaveExpense : null,
            isText: true,
            headline: true,
            enabled: !isReadOnly,
          ),
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: controller.amountFieldKey,
          child: AmountInputWidget(
            controller: controller.amountController,
            focusNode: controller.amountFocus,
            categories: categories,
            label: gloc.amount,
            currency: state.entryCurrency?.symbol ?? currency,
            currencyAfter: true,
            textStyle: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.05,
              letterSpacing: -0.5,
            ),
            textInputAction: controller.isFormValid
                ? TextInputAction.done
                : TextInputAction.next,
            validator: (v) {
              final parsed = controller.parseLocalizedAmount(v ?? '');
              if (parsed == null || parsed <= 0) return gloc.invalid_amount;
              return null;
            },
            onSaved: (v) {},
            onSubmitted: onSaveExpense,
            enabled: !isReadOnly,
          ),
        ),
        if (_second case final second?)
          _EntryCurrencyLine(
            controller: controller,
            groupCurrency: currency ?? '',
            second: second,
            enabled: !isReadOnly,
            alignStart: true,
          ),
        if (share != null) Text(share, style: muted),
        const SizedBox(height: 8),
        _buildParticipantCategorySection(context),
      ],
    );
  }

  /// "Paid by Anna · 21.00 € per person": the expense is split evenly among
  /// the group's people. Null with one person or no amount yet.
  String? _shareLine(gen.AppLocalizations gloc, Locale locale) {
    final paidBy = controller.state.paidBy;
    final total = controller.state.groupAmount;
    if (paidBy == null || total == null || total <= 0) return null;
    if (participants.length < 2) return null;
    final each = CurrencyDisplay.formatLocalizedText(
      total / participants.length,
      currency ?? '',
      locale,
    );
    return '${gloc.paid_by} ${paidBy.name} · ${gloc.stats_per_person(each)}';
  }

  /// The currency the link offers: the group's, or the one an older expense
  /// was entered in (the group may have changed or dropped it since).
  SecondCurrency? get _second =>
      controller.state.entryCurrency ?? secondCurrency;

  Widget _buildAmountField(
    BuildContext context,
    gen.AppLocalizations gloc,
    TextStyle? style,
  ) {
    return KeyedSubtree(
      key: controller.amountFieldKey,
      child: _buildFieldWithStatus(
        context,
        AmountInputWidget(
          controller: controller.amountController,
          focusNode: controller.amountFocus,
          categories: categories,
          label: gloc.amount,
          currency: controller.state.entryCurrency?.symbol ?? currency,
          textInputAction: controller.isFormValid
              ? TextInputAction.done
              : TextInputAction.next,
          validator: (v) {
            final parsed = controller.parseLocalizedAmount(v ?? '');
            if (parsed == null || parsed <= 0) return gloc.invalid_amount;
            return null;
          },
          onSaved: (v) {},
          onSubmitted: onSaveExpense,
          enabled: !isReadOnly,
        ),
        controller.isAmountValid,
        controller.amountTouched,
      ),
    );
  }

  Widget _buildNameField(
    BuildContext context,
    gen.AppLocalizations gloc,
    TextStyle? style,
  ) {
    return KeyedSubtree(
      key: controller.nameFieldKey,
      child: _buildFieldWithStatus(
        context,
        AmountInputWidget(
          controller: controller.nameController,
          focusNode: controller.nameFocus,
          label: gloc.expense_name,
          textInputAction: controller.isFormValid
              ? TextInputAction.done
              : TextInputAction.next,
          validator: (v) =>
              v == null || v.trim().isEmpty ? gloc.enter_title : null,
          onSaved: (v) {},
          onSubmitted: controller.isFormValid ? onSaveExpense : null,
          isText: true,
          textStyle: style,
          enabled: !isReadOnly,
        ),
        controller.isNameValid,
        controller.nameTouched,
      ),
    );
  }

  Widget _buildParticipantCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldWithStatus(
          context,
          ParticipantSelectorWidget(
            participants: participants,
            selectedParticipant: controller.state.paidBy,
            onParticipantSelected: controller.updatePaidBy,
            onAddParticipantInline: onParticipantAdded != null
                ? (name) => _onAddParticipantInline(context, name)
                : null,
            enabled: !isReadOnly,
            singleLine: compactPills,
          ),
          controller.isPaidByValid,
          controller.paidByTouched,
        ),
        _buildFieldWithStatus(
          context,
          CategorySelectorWidget(
            categories: categories,
            selectedCategory: controller.state.category,
            onCategorySelected: controller.updateCategory,
            onAddCategory: () => _onAddCategory(context),
            onAddCategoryInline: (name) => _onAddCategoryInline(context, name),
            enabled: !isReadOnly,
            singleLine: compactPills,
          ),
          controller.isCategoryValid(categories.isEmpty),
          controller.categoryTouched,
        ),
      ],
    );
  }

  Widget _buildFieldWithStatus(
    BuildContext context,
    Widget field,
    bool isValid,
    bool isTouched,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isTouched && !isValid
            ? Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.08)
            : null,
      ),
      child: field,
    );
  }

  Future<void> _onAddCategory(BuildContext context) async {
    final newCategoryName = await CategoryDialog.show(context: context);
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      onCategoryAdded(newCategoryName);
      await Future.delayed(const Duration(milliseconds: 100));
      // Notify parent to update categories list
      // The parent will handle finding the new category and updating the controller
    }
  }

  Future<void> _onAddCategoryInline(
    BuildContext context,
    String categoryName,
  ) async {
    onCategoryAdded(categoryName);
    await Future.delayed(const Duration(milliseconds: 100));
    // Notify parent to update categories list
    // The parent will handle finding the new category and updating the controller
  }

  Future<void> _onAddParticipantInline(
    BuildContext context,
    String participantName,
  ) async {
    if (onParticipantAdded == null) return;
    // Await the callback so the parent component (_onParticipantAdded) can update
    // the lifecycle manager and auto-select the participant before the sheet closes.
    await onParticipantAdded!(participantName);
  }
}

/// Under the amount, one quiet grey line with a fixed height (switching never
/// moves the form): "in kr" while the amount is in the group's currency;
/// "= 38,69 € · in €" while it is in [second].
class _EntryCurrencyLine extends StatelessWidget {
  final ExpenseFormController controller;
  final String groupCurrency;
  final SecondCurrency second;
  final bool enabled;

  /// At the start of the line, under an amount at the start (the expense
  /// page's header); centered otherwise.
  final bool alignStart;

  const _EntryCurrencyLine({
    required this.controller,
    required this.groupCurrency,
    required this.second,
    required this.enabled,
    this.alignStart = false,
  });

  /// The symbol, or the code where both currencies share a symbol ("\$").
  String get _secondLabel =>
      second.symbol == groupCurrency ? second.code : second.symbol;

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: muted);
    final state = controller.state;
    final inSecond = state.entryCurrency != null;
    final target = inSecond ? groupCurrency : _secondLabel;

    final VoidCallback? toggle = enabled
        ? () => controller.setEntryCurrency(inSecond ? null : second)
        : null;
    // excludeSemantics drops the InkWell's own tap action, so the button
    // carries it: without onTap here TalkBack reads the link but can't
    // activate it.
    final link = Semantics(
      button: true,
      label: gloc.entry_in_currency_label(target),
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          // 48 x 48 dp at least: "in kr" alone is narrower.
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              widthFactor: 1,
              child: Text(
                gloc.entry_in_currency(target),
                style: textStyle?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final converted = state.groupAmount;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: alignStart
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          if (inSecond && converted != null && converted > 0) ...[
            Text(
              '= ${CurrencyDisplay.formatLocalizedText(converted, groupCurrency, Localizations.localeOf(context))}',
              style: textStyle,
            ),
            Text('  ·', style: textStyle),
          ],
          if (enabled) link,
        ],
      ),
    );
  }
}
