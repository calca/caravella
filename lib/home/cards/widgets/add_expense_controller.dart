import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/widgets/expense_entry_sheet.dart';
import '../../../manager/expense/pages/expense_form_page.dart';
import '../../../manager/expense/state/expense_form_state.dart';
import '../../../services/notification_manager.dart';
import '../../home_constants.dart';

/// Controller for adding expenses from a group card.
///
/// Handles showing the bottom sheet and full-page expense forms,
/// saving expenses, and updating notifications.
class AddExpenseController {
  final ExpenseGroup group;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  const AddExpenseController({
    required this.group,
    required this.onExpenseAdded,
    this.onCategoryAdded,
  });

  /// Shows the quick add expense bottom sheet.
  void showAddExpenseSheet(BuildContext context, ExpenseGroup currentGroup) {
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? group;
          return _ExpenseEntrySheetWithState(
            group: currentGroup,
            fullEdit: false,
            showGroupHeader: false,
            onExpenseSaved: (expense) async {
              final sheetCtx = context;
              final nav = Navigator.of(sheetCtx);

              final expenseWithId = expense.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              );

              await ExpenseGroupStorageV2.addExpenseToGroup(
                currentGroup.id,
                expenseWithId,
              );

              await groupNotifier.refreshGroup();
              groupNotifier.notifyGroupUpdated(currentGroup.id);

              if (parentContext.mounted) {
                final gloc = gen.AppLocalizations.of(parentContext);
                await NotificationManager().updateNotificationForGroupById(
                  currentGroup.id,
                  gloc,
                );
              }

              RatingService.checkAndPromptForRating();

              nav.pop();
            },
            onCategoryAdded: (categoryName) async {
              await notifier.addCategory(categoryName);
            },
            onExpand: (currentState) {
              Navigator.of(context).pop();
              _openFullExpenseForm(parentContext, currentGroup, currentState);
            },
          );
        },
      ),
    ).whenComplete(() {
      notifier.clearCurrentGroup();
    });
  }

  void _openFullExpenseForm(
    BuildContext context,
    ExpenseGroup currentGroup,
    ExpenseFormState? partialState,
  ) {
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    final parentContext = context;

    ExpenseDetails? partialExpense;
    if (partialState != null) {
      partialExpense = ExpenseDetails(
        id: '',
        name: partialState.name.isEmpty ? null : partialState.name,
        amount: partialState.amount,
        paidBy: partialState.paidBy!,
        category: partialState.category!,
        date: partialState.date,
        location: partialState.location,
        note: partialState.note.isEmpty ? null : partialState.note,
        attachments: partialState.attachments,
      );
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => Consumer<ExpenseGroupNotifier>(
              builder: (context, groupNotifier, child) {
                final currentGroup = groupNotifier.currentGroup ?? group;
                return ExpenseFormPage(
                  group: currentGroup,
                  initialExpense: partialExpense,
                  onExpenseSaved: (expense) async {
                    final expenseWithId = expense.copyWith(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    );

                    await ExpenseGroupStorageV2.addExpenseToGroup(
                      currentGroup.id,
                      expenseWithId,
                    );

                    await groupNotifier.refreshGroup();
                    groupNotifier.notifyGroupUpdated(currentGroup.id);

                    if (parentContext.mounted) {
                      final gloc = gen.AppLocalizations.of(parentContext);
                      await NotificationManager()
                          .updateNotificationForGroupById(
                            currentGroup.id,
                            gloc,
                          );
                    }

                    RatingService.checkAndPromptForRating();
                  },
                  onCategoryAdded: (categoryName) async {
                    await notifier.addCategory(categoryName);
                  },
                );
              },
            ),
          ),
        )
        .whenComplete(() {
          notifier.clearCurrentGroup();
        });
  }
}

/// The add expense button displayed at the bottom of group cards.
class GroupCardAddButton extends StatelessWidget {
  final ExpenseGroup group;
  final ThemeData theme;
  final AddExpenseController controller;

  const GroupCardAddButton({
    super.key,
    required this.group,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = gen.AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: localizations.accessibility_add_expense,
        child: TextButton(
          onPressed: () => controller.showAddExpenseSheet(context, group),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(
              vertical: HomeLayoutConstants.buttonBorderRadius,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                HomeLayoutConstants.buttonBorderRadius,
              ),
            ),
          ),
          child: Text(
            localizations.add_expense_fab.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stateful wrapper for ExpenseEntrySheet to manage form validity
class _ExpenseEntrySheetWithState extends StatefulWidget {
  final ExpenseGroup group;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final bool fullEdit;
  final void Function(ExpenseFormState)? onExpand;
  final bool showGroupHeader;

  const _ExpenseEntrySheetWithState({
    required this.group,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.fullEdit = true,
    this.onExpand,
    this.showGroupHeader = true,
  });

  @override
  State<_ExpenseEntrySheetWithState> createState() =>
      _ExpenseEntrySheetWithStateState();
}

class _ExpenseEntrySheetWithStateState
    extends State<_ExpenseEntrySheetWithState> {
  bool _isFormValid = false;

  void _updateFormValidity(bool isValid) {
    if (mounted && _isFormValid != isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isFormValid = isValid;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseEntrySheet(
      group: widget.group,
      onExpenseSaved: widget.onExpenseSaved,
      onCategoryAdded: widget.onCategoryAdded,
      fullEdit: widget.fullEdit,
      onExpand: widget.onExpand,
      showGroupHeader: widget.showGroupHeader,
      onFormValidityChanged: _updateFormValidity,
    );
  }
}
