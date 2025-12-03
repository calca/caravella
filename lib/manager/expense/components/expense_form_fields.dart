library;

import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../expense_form/amount_input_widget.dart';
import '../expense_form/participant_selector_widget.dart';
import '../expense_form/category_selector_widget.dart';
import '../state/expense_form_controller.dart';

/// Builds the core form fields: amount, name, paid-by, and category
/// These fields are always visible regardless of expansion state
class ExpenseFormFields extends StatelessWidget {
  final ExpenseFormController controller;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(String) onCategoryAdded;
  final bool fullEdit;
  final bool autoLocationEnabled;
  final ExpenseLocation? location;
  final bool isRetrievingLocation;
  final VoidCallback onClearLocation;
  final String? currency;
  final VoidCallback onSaveExpense;
  
  const ExpenseFormFields({
    super.key,
    required this.controller,
    required this.participants,
    required this.categories,
    required this.onCategoryAdded,
    required this.fullEdit,
    required this.autoLocationEnabled,
    required this.location,
    required this.isRetrievingLocation,
    required this.onClearLocation,
    required this.currency,
    required this.onSaveExpense,
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
              onParticipantSelected: (name) =>
                  controller.updatePaidBy(participants.firstWhere(
                (p) => p.name == name,
                orElse: () => participants.isNotEmpty
                    ? participants.first
                    : ExpenseParticipant(name: ''),
              )),
              textStyle: style,
              fullEdit: true,
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
              onAddCategoryInline: (name) => _onAddCategoryInline(context, name),
              textStyle: style,
              fullEdit: true,
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
            onParticipantSelected: (name) =>
                controller.updatePaidBy(participants.firstWhere(
              (p) => p.name == name,
              orElse: () => participants.isNotEmpty
                  ? participants.first
                  : ExpenseParticipant(name: ''),
            )),
            textStyle: style,
            fullEdit: false,
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
            ? Theme.of(context)
                .colorScheme
                .errorContainer
                .withValues(alpha: 0.08)
            : null,
      ),
      child: field,
    );
  }

  Future<void> _onAddCategory(BuildContext context) async {
    // This would need to be handled by showing the CategoryDialog
    // For now, this is a placeholder that calls the parent callback
    // The actual implementation should use CategoryDialog.show
  }

  Future<void> _onAddCategoryInline(
    BuildContext context,
    String categoryName,
  ) async {
    onCategoryAdded(categoryName);
    // Wait for the category to be added
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
