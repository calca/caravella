import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../services/receipt_scanner_service.dart';
import 'package:caravella_core/caravella_core.dart' hide ImageSource;
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

  /// Shows the quick add expense bottom sheet, optionally pre-filled with
  /// [initialExpense] (e.g. a scanned receipt).
  void showAddExpenseSheet(
    BuildContext context,
    ExpenseGroup currentGroup, {
    ExpenseDetails? initialExpense,
  }) {
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
            initialExpense: initialExpense,
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

              // Notify parent that expense was added
              onExpenseAdded();

              nav.pop();
            },
            onCategoryAdded: (categoryName) async {
              await notifier.addCategory(categoryName);
            },
            onParticipantAdded: (participantName) async {
              await notifier.addParticipant(participantName);
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

  /// Home's "Scan": opens the camera right away, reads the receipt, then
  /// shows the quick-add sheet pre-filled with its amount and description
  /// (still empty fields if nothing was recognised) and the photo attached.
  Future<void> scanReceiptAndAdd(BuildContext context) async {
    final gloc = gen.AppLocalizations.of(context);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null || !context.mounted) return;
      AppToast.show(
        context,
        gloc.scanning_receipt,
        duration: const Duration(seconds: 2),
      );
      final result = await ReceiptScannerService().scanReceipt(
        File(picked.path),
      );
      if (!context.mounted) return;
      final amount = result['amount'] as double?;
      final description = result['description'] as String?;
      if (amount == null && description == null) {
        AppToast.show(context, gloc.no_text_found);
      }
      // Keep the receipt photo as the expense's first attachment.
      String? receipt;
      try {
        receipt = await AttachmentsStorageService.getAttachmentPath(
          group.title,
          group.id,
          picked.name,
        );
        await File(picked.path).copy(receipt);
      } catch (e) {
        LoggerService.warning(
          'Could not keep the receipt photo: $e',
          name: 'ui.scan',
        );
        receipt = null;
      }
      if (!context.mounted) return;
      showAddExpenseSheet(
        context,
        group,
        initialExpense: ExpenseDetails(
          id: '',
          name: description,
          amount: amount,
          paidBy: ExpenseParticipant(name: ''),
          category: ExpenseCategory(name: ''),
          date: DateTime.now(),
          attachments: [?receipt],
        ),
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final denied =
          e.code == 'camera_access_denied' || e.code == 'photo_access_denied';
      AppToast.show(
        context,
        denied ? gloc.receipt_scan_permission_denied : gloc.receipt_scan_error,
        type: ToastType.error,
      );
    } catch (e, st) {
      LoggerService.error(
        'Receipt scan from Home failed',
        name: 'ui.scan',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        AppToast.show(context, gloc.receipt_scan_error, type: ToastType.error);
      }
    }
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

                    // Notify parent that expense was added
                    onExpenseAdded();
                  },
                  onCategoryAdded: (categoryName) async {
                    await notifier.addCategory(categoryName);
                  },
                  onParticipantAdded: (participantName) async {
                    await notifier.addParticipant(participantName);
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
  final void Function(String)? onParticipantAdded;
  final bool fullEdit;
  final void Function(ExpenseFormState)? onExpand;
  final bool showGroupHeader;
  final ExpenseDetails? initialExpense;

  const _ExpenseEntrySheetWithState({
    required this.group,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.onParticipantAdded,
    this.fullEdit = true,
    this.onExpand,
    this.showGroupHeader = true,
    this.initialExpense,
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
      onParticipantAdded: widget.onParticipantAdded,
      fullEdit: widget.fullEdit,
      onExpand: widget.onExpand,
      showGroupHeader: widget.showGroupHeader,
      onFormValidityChanged: _updateFormValidity,
      initialExpense: widget.initialExpense,
    );
  }
}
