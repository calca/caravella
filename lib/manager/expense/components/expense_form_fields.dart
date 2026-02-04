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
                // First try to find the participant in the current list
                final found = participants
                    .where((p) => p.name == name)
                    .firstOrNull;

                if (found != null) {
                  // Participant found in list, use it
                  controller.updatePaidBy(found);
                } else {
                  // Participant not yet in list (newly added), create temporary participant
                  // The list will be updated soon by the notifier
                  final tempParticipant = ExpenseParticipant(name: name);
                  controller.updatePaidBy(tempParticipant);
                }
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
              // First try to find the participant in the current list
              final found = participants
                  .where((p) => p.name == name)
                  .firstOrNull;

              if (found != null) {
                // Participant found in list, use it
                controller.updatePaidBy(found);
              } else {
                // Participant not yet in list (newly added), create temporary participant
                // The list will be updated soon by the notifier
                final tempParticipant = ExpenseParticipant(name: name);
                controller.updatePaidBy(tempParticipant);
              }
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
}
