import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import '../state/expense_form_state.dart';

/// Configuration object for ExpenseFormComponent
///
/// Consolidates the 43 constructor parameters into a structured configuration
/// object for better maintainability and readability.
class ExpenseFormConfig {
  // Core data
  final ExpenseDetails? initialExpense;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final String groupId;

  // Callbacks
  final Function(ExpenseDetails) onExpenseAdded;
  final Function(String) onCategoryAdded;
  final VoidCallback? onDelete;
  final void Function(ExpenseFormState)? onExpand;
  final void Function(bool)? onFormValidityChanged;
  final void Function(VoidCallback?)? onSaveCallbackChanged;

  // Display options
  final bool fullEdit;
  final bool showGroupHeader;
  final bool showActionsRow;
  final bool shouldAutoClose;

  // Group context
  final String? groupTitle;
  final String? currency;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? newlyAddedCategory;

  // Settings
  final bool autoLocationEnabled;
  final bool isReadOnly;

  // Controllers
  final ScrollController? scrollController;

  const ExpenseFormConfig({
    // Core data
    this.initialExpense,
    required this.participants,
    required this.categories,
    required this.groupId,

    // Callbacks
    required this.onExpenseAdded,
    required this.onCategoryAdded,
    this.onDelete,
    this.onExpand,
    this.onFormValidityChanged,
    this.onSaveCallbackChanged,

    // Display options
    this.fullEdit = false,
    this.showGroupHeader = true,
    this.showActionsRow = true,
    this.shouldAutoClose = true,

    // Group context
    this.groupTitle,
    this.currency,
    this.tripStartDate,
    this.tripEndDate,
    this.newlyAddedCategory,

    // Settings
    required this.autoLocationEnabled,
    this.isReadOnly = false,

    // Controllers
    this.scrollController,
  });

  /// Creates a config for creating a new expense
  factory ExpenseFormConfig.create({
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required String groupId,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    required bool autoLocationEnabled,
    String? groupTitle,
    String? currency,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? newlyAddedCategory,
    bool fullEdit = false,
    bool isReadOnly = false,
    ScrollController? scrollController,
    void Function(ExpenseFormState)? onExpand,
    bool showGroupHeader = true,
    bool showActionsRow = true,
    void Function(bool)? onFormValidityChanged,
    void Function(VoidCallback?)? onSaveCallbackChanged,
  }) {
    return ExpenseFormConfig(
      participants: participants,
      categories: categories,
      groupId: groupId,
      onExpenseAdded: onExpenseAdded,
      onCategoryAdded: onCategoryAdded,
      autoLocationEnabled: autoLocationEnabled,
      groupTitle: groupTitle,
      currency: currency,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      newlyAddedCategory: newlyAddedCategory,
      fullEdit: fullEdit,
      scrollController: scrollController,
      onExpand: onExpand,
      showGroupHeader: showGroupHeader,
      showActionsRow: showActionsRow,
      onFormValidityChanged: onFormValidityChanged,
      onSaveCallbackChanged: onSaveCallbackChanged,
      isReadOnly: isReadOnly,
    );
  }

  /// Creates a config for editing an existing expense
  factory ExpenseFormConfig.edit({
    required ExpenseDetails initialExpense,
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required String groupId,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    required bool autoLocationEnabled,
    VoidCallback? onDelete,
    String? groupTitle,
    String? currency,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    bool shouldAutoClose = true,
    bool isReadOnly = false,
    ScrollController? scrollController,
  }) {
    return ExpenseFormConfig(
      initialExpense: initialExpense,
      participants: participants,
      categories: categories,
      groupId: groupId,
      onExpenseAdded: onExpenseAdded,
      onCategoryAdded: onCategoryAdded,
      autoLocationEnabled: autoLocationEnabled,
      onDelete: onDelete,
      groupTitle: groupTitle,
      currency: currency,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      shouldAutoClose: shouldAutoClose,
      scrollController: scrollController,
      fullEdit: true,
      showGroupHeader: false,
      isReadOnly: isReadOnly,
    );
  }

  bool get isEditMode => initialExpense?.id != null && initialExpense!.id.isNotEmpty;
  bool get isCreateMode => initialExpense?.id == null || initialExpense!.id.isEmpty;
  bool get hasDeleteAction => onDelete != null;
}
