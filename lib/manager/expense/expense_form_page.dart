import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'expense_form_component.dart';

/// Full-screen page for creating or editing an expense
class ExpenseFormPage extends StatefulWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final VoidCallback? onDelete;

  const ExpenseFormPage({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.onDelete,
  });

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  bool _isFormValid = false;
  VoidCallback? _saveCallback;

  void _updateFormValidity(bool isValid) {
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _handleSave() {
    _saveCallback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: widget.initialExpense != null
                          ? gloc.edit_expense
                          : gloc.new_expense,
                      description: '${gloc.group} ${widget.group.title}',
                    ),
                    const SizedBox(height: 24),
                    ExpenseFormComponent(
                      initialExpense: widget.initialExpense,
                      participants: widget.group.participants,
                      categories: widget.group.categories,
                      tripStartDate: widget.group.startDate,
                      tripEndDate: widget.group.endDate,
                      shouldAutoClose: true,
                      fullEdit: true,
                      showGroupHeader: false,
                      showActionsRow: false,
                      currency: widget.group.currency,
                      autoLocationEnabled: widget.group.autoLocationEnabled,
                      onExpenseAdded: widget.onExpenseSaved,
                      onCategoryAdded: widget.onCategoryAdded,
                      onDelete: widget.onDelete,
                      onFormValidityChanged: _updateFormValidity,
                      onSaveCallbackChanged: (callback) =>
                          _saveCallback = callback,
                      groupId: widget.group.id,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (widget.initialExpense != null &&
                      widget.onDelete != null) ...[
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                      tooltip: gloc.delete_expense,
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Spacer(),
                  FilledButton(
                    onPressed: _isFormValid ? _handleSave : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      widget.initialExpense != null
                          ? gloc.save.toUpperCase()
                          : gloc.add.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
