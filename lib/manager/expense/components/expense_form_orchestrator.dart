import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'expense_form_config.dart';
import '../state/expense_form_controller.dart';

/// Orchestrates business logic for ExpenseFormComponent
/// 
/// Handles save/delete flows, form validation callbacks, and coordination
/// between controller and configuration.
class ExpenseFormOrchestrator {
  final ExpenseFormConfig config;
  final ExpenseFormController controller;
  final GlobalKey<FormState> formKey;

  ExpenseFormOrchestrator({
    required this.config,
    required this.controller,
    required this.formKey,
  });

  /// Initialize orchestrator and setup listeners
  void initialize() {
    // Setup form validity listener
    if (config.onFormValidityChanged != null) {
      controller.addListener(_notifyFormValidity);
      _notifyFormValidity(); // Initial state
    }

    // Setup save callback
    if (config.onSaveCallbackChanged != null) {
      controller.addListener(_notifySaveCallback);
      _notifySaveCallback(); // Initial state
    }
  }

  /// Save expense
  Future<void> saveExpense(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (!controller.isFormValid) return;

    formKey.currentState!.save();

    final expense = _buildExpenseFromState();
    config.onExpenseAdded(expense);

    if (config.shouldAutoClose && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Delete expense
  Future<void> deleteExpense(BuildContext context) async {
    if (config.onDelete == null) return;

    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed == true) {
      config.onDelete!();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Expand to full edit mode
  void expand() {
    controller.expandForm();
    config.onExpand?.call();
  }

  /// Cleanup
  void dispose() {
    if (config.onFormValidityChanged != null) {
      controller.removeListener(_notifyFormValidity);
    }
    if (config.onSaveCallbackChanged != null) {
      controller.removeListener(_notifySaveCallback);
    }
  }

  // Private methods

  void _notifyFormValidity() {
    config.onFormValidityChanged?.call(controller.isFormValid);
  }

  void _notifySaveCallback() {
    final callback = controller.isFormValid 
        ? () => saveExpense
        : null;
    config.onSaveCallbackChanged?.call(callback);
  }

  ExpenseDetails _buildExpenseFromState() {
    return ExpenseDetails(
      name: controller.state.name,
      amount: controller.state.amount,
      paidBy: controller.state.paidBy!,
      category: controller.state.category!,
      date: controller.state.date,
      note: controller.state.note,
      location: controller.state.location,
      attachments: controller.state.attachments,
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final loc = gen.AppLocalizations.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Material3Dialog(
        icon: Icon(
          Icons.warning_amber_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: Text(loc.delete_expense),
        content: Text(loc.delete_expense_confirm),
        actions: [
          Material3DialogActions.cancel(ctx, loc.cancel),
          Material3DialogActions.destructive(
            ctx,
            loc.delete,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }
}
