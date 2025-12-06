import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:share_plus/share_plus.dart';
import '../components/expense_form_component.dart';

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
    if (_isFormValid != isValid && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isFormValid = isValid;
          });
        }
      });
    }
  }

  void _updateSaveCallback(VoidCallback? callback) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _saveCallback = callback;
          });
        }
      });
    }
  }

  void _handleSave() {
    _saveCallback?.call();
  }

  Future<void> _handleShare() async {
    if (widget.initialExpense == null) return;

    final expense = widget.initialExpense!;
    final gloc = gen.AppLocalizations.of(context);

    final buffer = StringBuffer();
    buffer.writeln('${gloc.group}: ${widget.group.title}');
    buffer.writeln('');
    buffer.writeln('${gloc.expense_name}: ${expense.name ?? ""}');
    buffer.writeln(
      '${gloc.amount}: ${CurrencyDisplay.formatCurrencyText(expense.amount ?? 0, widget.group.currency)}',
    );
    buffer.writeln('${gloc.paid_by}: ${expense.paidBy.name}');
    buffer.writeln('${gloc.category}: ${expense.category.name}');
    buffer.writeln(
      '${gloc.csv_date}: ${expense.date.toIso8601String().split("T").first}',
    );
    if (expense.note != null && expense.note!.isNotEmpty) {
      buffer.writeln('${gloc.note}: ${expense.note}');
    }
    if (expense.location != null) {
      buffer.writeln('${gloc.location}: ${expense.location!.displayText}');
    }

    try {
      await SharePlus.instance.share(ShareParams(text: buffer.toString()));
    } catch (_) {
      // Gestione silenziosa errori
    }
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
        actions: [
          if (widget.initialExpense != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: gloc.share_label,
              onPressed: _handleShare,
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: gloc.delete_expense,
                onPressed: widget.onDelete,
              ),
          ],
        ],
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
                    ExpenseFormComponent.legacy(
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
                      onSaveCallbackChanged: _updateSaveCallback,
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
