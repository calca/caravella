import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_category.dart';
import '../../../data/model/expense_participant.dart';
import '../../../themes/form_theme.dart';
import 'amount_input_widget.dart';
import 'participant_selector_widget.dart';
import 'category_selector_widget.dart';
import 'category_dialog.dart';
import 'expense_form_state.dart';
import 'expense_form_validation.dart';

/// Basic section of the expense form containing name, amount, category, and paid by fields
class ExpenseFormBasicSection extends StatelessWidget {
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(String) onCategoryAdded;
  final String? currency;
  final bool shouldShowExtendedFields;
  final TextStyle? textStyle;
  
  const ExpenseFormBasicSection({
    super.key,
    required this.participants,
    required this.categories,
    required this.onCategoryAdded,
    this.currency,
    this.shouldShowExtendedFields = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    
    return Consumer<ExpenseFormState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountField(context, gloc, state),
            _spacer(),
            _buildNameField(context, gloc, state),
            _spacer(),
            _buildParticipantCategorySection(context, state),
          ],
        );
      },
    );
  }
  
  Widget _spacer() => const SizedBox(height: FormTheme.fieldSpacing);
  
  Widget _buildAmountField(BuildContext context, gen.AppLocalizations gloc, ExpenseFormState state) {
    return _buildFieldWithStatus(
      AmountInputWidget(
        controller: state.amountController,
        focusNode: state.amountFocus,
        categories: state.categories,
        label: gloc.amount,
        currency: currency,
        validator: (v) => ExpenseFormValidation.validateAmount(v, gloc),
        onSaved: (v) {},
        onSubmitted: () {}, // Will be handled by parent form
        textStyle: textStyle,
      ),
      state.isAmountValid,
      state.amountTouched,
    );
  }
  
  Widget _buildNameField(BuildContext context, gen.AppLocalizations gloc, ExpenseFormState state) {
    return _buildFieldWithStatus(
      AmountInputWidget(
        controller: state.nameController,
        focusNode: state.nameFocus,
        label: gloc.expense_name,
        leading: Icon(
          Icons.description_outlined,
          size: 22,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        validator: (v) => ExpenseFormValidation.validateName(v, gloc),
        onSaved: (v) {},
        onSubmitted: () {},
        isText: true,
        textStyle: textStyle,
      ),
      state.nameController.text.trim().isNotEmpty,
      state.amountTouched,
    );
  }
  
  Widget _buildParticipantCategorySection(BuildContext context, ExpenseFormState state) {
    if (shouldShowExtendedFields) {
      return Column(
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: participants.map((p) => p.name).toList(),
              selectedParticipant: state.paidBy?.name,
              onParticipantSelected: (selectedName) => _onParticipantSelected(selectedName, state),
              textStyle: textStyle,
              fullEdit: true,
            ),
            state.isPaidByValid,
            state.paidByTouched,
          ),
          _spacer(),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: state.categories,
              selectedCategory: state.category,
              onCategorySelected: (category) => state.setCategory(category),
              onAddCategory: () => _onAddCategory(context, state),
              onAddCategoryInline: (name) => _onAddCategoryInline(name, state),
              textStyle: textStyle,
              fullEdit: true,
            ),
            state.isCategoryValid,
            state.categoryTouched,
          ),
        ],
      );
    }
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: participants.map((p) => p.name).toList(),
              selectedParticipant: state.paidBy?.name,
              onParticipantSelected: (selectedName) => _onParticipantSelected(selectedName, state),
              textStyle: textStyle,
              fullEdit: false,
            ),
            state.isPaidByValid,
            state.paidByTouched,
          ),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: state.categories,
              selectedCategory: state.category,
              onCategorySelected: (category) => state.setCategory(category),
              onAddCategory: () => _onAddCategory(context, state),
              onAddCategoryInline: (name) => _onAddCategoryInline(name, state),
              textStyle: textStyle,
              fullEdit: false,
            ),
            state.isCategoryValid,
            state.categoryTouched,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFieldWithStatus(Widget field, bool isValid, bool isTouched) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        // Space for validation indicators could be added here in the future
      ],
    );
  }
  
  void _onParticipantSelected(String selectedName, ExpenseFormState state) {
    final participant = participants.firstWhere(
      (p) => p.name == selectedName,
      orElse: () => participants.isNotEmpty
          ? participants.first
          : ExpenseParticipant(name: ''),
    );
    state.setPaidBy(participant);
  }
  
  Future<void> _onAddCategory(BuildContext context, ExpenseFormState state) async {
    final newCategoryName = await CategoryDialog.show(context: context);
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      onCategoryAdded(newCategoryName);
      await _selectCategoryByName(newCategoryName, state);
    }
  }
  
  Future<void> _onAddCategoryInline(String categoryName, ExpenseFormState state) async {
    onCategoryAdded(categoryName);
    await _selectCategoryByName(categoryName, state);
  }
  
  Future<void> _selectCategoryByName(String categoryName, ExpenseFormState state) async {
    // Wait for the category to be added to the list
    await Future.delayed(const Duration(milliseconds: 50));
    final found = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    state.setCategory(found);
    
    // Update the state's category list and select the new category
    state.updateCategories(categories);
    
    // Wait again to ensure the state has settled
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    state.setCategory(foundAfter);
  }
}