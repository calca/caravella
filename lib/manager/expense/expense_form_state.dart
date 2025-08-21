import 'package:flutter/material.dart';
import '../../data/expense_category.dart';
import '../../data/expense_details.dart';
import '../../data/expense_participant.dart';
import '../../data/expense_location.dart';

/// Centralized state management for expense form
/// Handles original values storage, change detection, and validation
class ExpenseFormState {
  // Original values for change detection in edit mode
  ExpenseCategory? _originalCategory;
  double? _originalAmount;
  ExpenseParticipant? _originalPaidBy;
  DateTime? _originalDate;
  ExpenseLocation? _originalLocation;
  String? _originalName;
  String? _originalNote;

  // Current form state
  ExpenseCategory? category;
  double? amount;
  ExpenseParticipant? paidBy;
  DateTime? date;
  ExpenseLocation? location;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final List<ExpenseCategory> categories;

  // Touch state for validation
  bool amountTouched = false;
  bool paidByTouched = false;
  bool categoryTouched = false;

  ExpenseFormState({required this.categories});

  /// Initialize state from an existing expense for edit mode
  void initializeFromExpense(ExpenseDetails expense) {
    // Set current values
    category = categories.firstWhere(
      (c) => c.id == expense.category.id,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    amount = expense.amount;
    paidBy = expense.paidBy;
    date = expense.date;
    location = expense.location;
    nameController.text = expense.name ?? '';
    noteController.text = expense.note ?? '';

    // Store original values for change detection
    _originalCategory = category;
    _originalAmount = amount;
    _originalPaidBy = paidBy;
    _originalDate = date;
    _originalLocation = location;
    _originalName = expense.name;
    _originalNote = expense.note;
  }

  /// Initialize state for new expense
  void initializeForNewExpense() {
    date = DateTime.now();
    nameController.text = '';
    location = null;
    // Clear original values since this is a new expense
    _originalCategory = null;
    _originalAmount = null;
    _originalPaidBy = null;
    _originalDate = null;
    _originalLocation = null;
    _originalName = null;
    _originalNote = null;
  }

  /// Validation getters
  bool get isAmountValid => amount != null && amount! > 0;
  bool get isPaidByValid => paidBy != null;
  bool get isCategoryValid => categories.isEmpty || category != null;

  /// Check if actual changes have been made compared to original values
  bool get hasActualChanges {
    // For new expenses, any non-empty field is a change
    if (_originalAmount == null && _originalCategory == null && _originalPaidBy == null) {
      return amount != null && amount! > 0 ||
          nameController.text.trim().isNotEmpty ||
          noteController.text.trim().isNotEmpty;
    }

    // For editing existing expenses, compare with original values
    final originalLocationJson = _originalLocation?.toJson().toString();
    final currentLocationJson = location?.toJson().toString();

    return category?.id != _originalCategory?.id ||
        amount != _originalAmount ||
        paidBy?.name != _originalPaidBy?.name ||
        date != _originalDate ||
        currentLocationJson != originalLocationJson ||
        nameController.text.trim() != (_originalName ?? '') ||
        noteController.text.trim() != (_originalNote ?? '');
  }

  /// Check if form is valid for submission
  bool isFormValid() {
    bool hasPaidBy = paidBy != null && paidBy!.name.isNotEmpty;
    bool hasCategoryIfRequired = categories.isEmpty || category != null;
    final nameValue = nameController.text.trim();
    
    return isAmountValid &&
        hasPaidBy &&
        hasCategoryIfRequired &&
        nameValue.isNotEmpty;
  }

  /// Mark all fields as touched for validation display
  void markAllFieldsTouched() {
    amountTouched = true;
    paidByTouched = true;
    categoryTouched = true;
  }

  /// Dispose controllers when no longer needed
  void dispose() {
    nameController.dispose();
    noteController.dispose();
  }
}