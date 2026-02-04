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
    onParticipantAdded!(participantName);
    await Future.delayed(const Duration(milliseconds: 100));
    // Notify parent to update participants list
    // The parent will handle finding the new participant and updating the controller
  }

  /// Selects a participant by name with retry mechanism for newly added participants
  void _selectParticipantByName(String name) {
    LoggerService.info(
      'Selecting participant by name: "$name", current participants: ${participants.map((p) => p.name).toList()}',
      name: 'expense.participant',
    );

    // First try to find the participant in the current list
    final found = participants.where((p) => p.name == name).firstOrNull;

    if (found != null) {
      // Participant found in list, use it immediately
      LoggerService.info(
        'Found participant immediately: ${found.name} (ID: ${found.id})',
        name: 'expense.participant',
      );
      controller.updatePaidBy(found);
    } else {
      // Participant not yet in list (newly added), wait for list update
      LoggerService.warning(
        'Participant not found immediately, starting retry mechanism',
        name: 'expense.participant',
      );
      _waitForParticipantAndSelect(name);
    }
  }

  /// Waits for participant to appear in list and then selects it
  Future<void> _waitForParticipantAndSelect(String name) async {
    // Try multiple times with progressive delays - increased timeouts
    final delays = [50, 100, 150, 200, 300, 500, 700]; // Total: 2 seconds max

    LoggerService.info(
      'Starting participant wait cycle for: "$name"',
      name: 'expense.participant',
    );

    for (int i = 0; i < delays.length; i++) {
      await Future.delayed(Duration(milliseconds: delays[i]));

      // Refresh the participant list to get the latest state
      onParticipantsUpdated?.call(participants);

      final found = participants.where((p) => p.name == name).firstOrNull;
      if (found != null) {
        LoggerService.info(
          'Found participant after ${i + 1} retries: ${found.name} (ID: ${found.id})',
          name: 'expense.participant',
        );
        controller.updatePaidBy(found);
        return;
      }

      LoggerService.debug(
        'Retry ${i + 1}/${delays.length}: Participant "$name" not yet available. Current participants: ${participants.map((p) => p.name).toList()}',
        name: 'expense.participant',
      );
    }

    // If still not found after all retries, log error but don't create temp participant
    LoggerService.error(
      'Failed to find participant "$name" after all retries. This indicates a synchronization issue.',
      name: 'expense.participant',
    );
  }
}
