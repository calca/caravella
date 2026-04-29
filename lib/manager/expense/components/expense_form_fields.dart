library;

import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/amount_input_widget.dart';
import '../widgets/category_dialog.dart';
import '../location/widgets/compact_location_indicator.dart';
import '../widgets/participant_selector_widget.dart';
import '../widgets/category_selector_widget.dart';
import '../state/expense_form_controller.dart';
import '../widgets/voice_input_button.dart';

/// Builds the core form fields: amount, name, paid-by, and category
/// These fields are always visible regardless of expansion state
class ExpenseFormFields extends StatelessWidget {
  final ExpenseFormController controller;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(String) onCategoryAdded;
  final Function(String)? onParticipantAdded;
  final Function(List<ExpenseCategory>) onCategoriesUpdated;
  final Function(List<ExpenseParticipant>)? onParticipantsUpdated;
  final bool fullEdit;
  final bool autoLocationEnabled;
  final ExpenseLocation? location;
  final bool isRetrievingLocation;
  final VoidCallback onClearLocation;
  final String? currency;
  final VoidCallback onSaveExpense;
  final bool isInitialExpense;
  final bool isReadOnly;

  const ExpenseFormFields({
    super.key,
    required this.controller,
    required this.participants,
    required this.categories,
    required this.onCategoryAdded,
    this.onParticipantAdded,
    required this.fullEdit,
    required this.autoLocationEnabled,
    required this.location,
    required this.isRetrievingLocation,
    required this.onClearLocation,
    required this.currency,
    required this.onSaveExpense,
    required this.onCategoriesUpdated,
    this.onParticipantsUpdated,
    required this.isInitialExpense,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isInitialExpense) _buildVoiceInputSection(context, gloc),
            _buildAmountField(context, gloc, style),
            SizedBox(height: FormTheme.fieldSpacing),
            _buildNameField(context, gloc, style),
            SizedBox(height: FormTheme.fieldSpacing),
            _buildParticipantCategorySection(context, style),
          ],
        );
      },
    );
  }

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
          currency: currency,
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
          textStyle: style,
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
          leading: Icon(
            Icons.description_outlined,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
        controller.amountTouched,
      ),
    );
  }

  Widget _buildParticipantCategorySection(
    BuildContext context,
    TextStyle? style,
  ) {
    if (fullEdit || controller.isExpanded) {
      return Column(
        children: [
          _buildFieldWithStatus(
            context,
            ParticipantSelectorWidget(
              participants: participants.map((p) => p.name).toList(),
              selectedParticipant: controller.state.paidBy?.name,
              onParticipantSelected: (name) {
                _selectParticipantByName(name);
              },
              onAddParticipantInline: onParticipantAdded != null
                  ? (name) => _onAddParticipantInline(context, name)
                  : null,
              textStyle: style,
              fullEdit: true,
              enabled: !isReadOnly,
            ),
            controller.isPaidByValid,
            controller.paidByTouched,
          ),
          SizedBox(height: FormTheme.fieldSpacing),
          _buildFieldWithStatus(
            context,
            CategorySelectorWidget(
              categories: categories,
              selectedCategory: controller.state.category,
              onCategorySelected: controller.updateCategory,
              onAddCategory: () => _onAddCategory(context),
              onAddCategoryInline: (name) =>
                  _onAddCategoryInline(context, name),
              textStyle: style,
              fullEdit: true,
              enabled: !isReadOnly,
            ),
            controller.isCategoryValid(categories.isEmpty),
            controller.categoryTouched,
          ),
        ],
      );
    }

    return _buildCompactParticipantCategory(context, style);
  }

  Widget _buildCompactParticipantCategory(
    BuildContext context,
    TextStyle? style,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldWithStatus(
          context,
          ParticipantSelectorWidget(
            participants: participants.map((p) => p.name).toList(),
            selectedParticipant: controller.state.paidBy?.name,
            onParticipantSelected: (name) {
              LoggerService.info(
                'Participant selected from modal: "$name". Current participants count: ${participants.length}',
                name: 'expense.participant',
              );
              _selectParticipantByName(name);
            },
            onAddParticipantInline: onParticipantAdded != null
                ? (name) => _onAddParticipantInline(context, name)
                : null,
            textStyle: style,
            fullEdit: false,
            enabled: !isReadOnly,
          ),
          controller.isPaidByValid,
          controller.paidByTouched,
        ),
        const SizedBox(width: 12),
        _buildFieldWithStatus(
          context,
          CategorySelectorWidget(
            categories: categories,
            selectedCategory: controller.state.category,
            onCategorySelected: controller.updateCategory,
            onAddCategory: () => _onAddCategory(context),
            onAddCategoryInline: (name) => _onAddCategoryInline(context, name),
            textStyle: style,
            fullEdit: false,
            enabled: !isReadOnly,
          ),
          controller.isCategoryValid(categories.isEmpty),
          controller.categoryTouched,
        ),
        // Show compact location indicator when auto-location is enabled
        if (!isInitialExpense && autoLocationEnabled) ...[
          const Spacer(),
          CompactLocationIndicator(
            isRetrieving: isRetrievingLocation,
            location: location,
            onCancel: onClearLocation,
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

  /// Selects a participant by name from the current list.
  /// For newly added participants the auto-selection is handled in the parent
  /// component's _onParticipantAdded handler: once the notifier update
  /// microtask completes, that handler calls _controller.updatePaidBy directly.
  /// This method therefore only acts immediately when the participant is already
  /// present in the list.
  void _selectParticipantByName(String name) {
    final found = participants.where((p) => p.name == name).firstOrNull;

    if (found != null) {
      controller.updatePaidBy(found);
    } else {
      // The participant was just added inline; _onParticipantAdded in
      // ExpenseFormComponent calls _controller.updatePaidBy once the notifier
      // update microtask has run, so no action is needed here.
      LoggerService.debug(
        'Participant "$name" not yet in list; selection will be handled by onParticipantAdded.',
        name: 'expense.participant',
      );
    }
  }

  Widget _buildVoiceInputSection(
    BuildContext context,
    gen.AppLocalizations gloc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          VoiceInputButton(
            participantNames: participants.map((p) => p.name).toList(),
            onVoiceResult: (parsed) => _handleVoiceInput(context, parsed, gloc),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gloc.voice_input_hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput(
    BuildContext context,
    Map<String, dynamic> parsed,
    gen.AppLocalizations gloc,
  ) {
    final amount = parsed['amount'] as double?;
    if (amount != null && amount > 0) {
      controller.amountController.text = amount.toString();
    }
    final name = parsed['name'] as String?;
    if (name != null && name.isNotEmpty) {
      controller.nameController.text = name;
    }
    final category = parsed['category'] as String?;
    if (category != null && categories.isNotEmpty) {
      final match = categories.firstWhere(
        (c) => c.name.toLowerCase() == category.toLowerCase(),
        orElse: () => categories.first,
      );
      controller.updateCategory(match);
    }
    final paidBy = parsed['paidBy'] as String?;
    if (paidBy != null && participants.isNotEmpty) {
      final match = participants.firstWhere(
        (p) => p.name.toLowerCase() == paidBy.toLowerCase(),
        orElse: () => participants.first,
      );
      controller.updatePaidBy(match);
    }
    final date = parsed['date'] as DateTime?;
    if (date != null) {
      controller.updateDate(date);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(gloc.voice_input_tap_to_speak),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
