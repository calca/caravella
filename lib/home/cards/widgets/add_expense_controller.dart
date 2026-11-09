import 'package:io_caravella_egm/services/permission_dialog.dart';
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

  /// Called right after the quick-add sheet persisted a new expense (before
  /// the group is refreshed), with the stored expense and its generated id.
  /// The group page uses it to highlight the new row.
  final void Function(ExpenseDetails expense)? onExpensePersisted;

  const AddExpenseController({
    required this.group,
    required this.onExpenseAdded,
    this.onCategoryAdded,
    this.onExpensePersisted,
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
    // Set once "More details" hands over to the full page, which then owns
    // the current group: the sheet closing underneath must not clear it.
    var expanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      // Taller now that the details are always there: keep it below the
      // status bar.
      useSafeArea: true,
      sheetAnimationStyle: AppMotion.sheet,
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
              onExpensePersisted?.call(expenseWithId);

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
              expanded = true;
              _expandToFullPage(context, currentGroup, currentState);
            },
          );
        },
      ),
    ).whenComplete(() {
      if (!expanded) notifier.clearCurrentGroup();
    });
  }

  /// Home's "Scan": opens the camera right away, reads the receipt, then
  /// shows the quick-add sheet pre-filled with its amount and description
  /// (still empty fields if nothing was recognised) and the photo attached.
  /// With [readReceipt] false — Home's "Photo" in builds without receipt
  /// reading (F-Droid) — the sheet opens with just the photo attached.
  Future<void> scanReceiptAndAdd(
    BuildContext context, {
    bool readReceipt = true,
  }) async {
    final gloc = gen.AppLocalizations.of(context);
    final failure = readReceipt
        ? gloc.receipt_scan_error
        : gloc.receipt_photo_error;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null || !context.mounted) return;
      double? amount;
      String? description;
      if (readReceipt) {
        AppToast.show(context, gloc.scanning_receipt);
        final result = await ReceiptScannerService().scanReceipt(
          File(picked.path),
        );
        if (!context.mounted) return;
        amount = result['amount'] as double?;
        description = result['description'] as String?;
        if (amount == null && description == null) {
          AppToast.show(context, gloc.no_text_found);
        }
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
          // Who paid last, as when adding an expense by hand.
          paidBy:
              group.getParticipantsByLastUsed().firstOrNull ??
              ExpenseParticipant(name: ''),
          category: ExpenseCategory(name: ''),
          date: DateTime.now(),
          attachments: [?receipt],
        ),
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final denied = switch (e.code) {
        'camera_access_denied' => DeniedPermission.camera,
        'photo_access_denied' => DeniedPermission.photos,
        _ => null,
      };
      if (denied != null) {
        await showPermissionDeniedDialog(context, denied);
      } else {
        AppToast.show(context, failure, type: ToastType.error);
      }
    } catch (e, st) {
      LoggerService.error(
        'Receipt scan from Home failed',
        name: 'ui.scan',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        AppToast.show(context, failure, type: ToastType.error);
      }
    }
  }

  /// "More details": the full page rises over the sheet like the sheet
  /// growing to full height, and the sheet is dropped underneath once the
  /// page covers it — instead of the sheet sliding down, the page zooming in
  /// and the keyboard closing and reopening all at once. The keyboard goes
  /// down once; the page doesn't grab the amount again.
  void _expandToFullPage(
    BuildContext sheetContext,
    ExpenseGroup currentGroup,
    ExpenseFormState partialState,
  ) {
    final sheetRoute = ModalRoute.of(sheetContext);
    final navigator = Navigator.of(sheetContext);
    FocusManager.instance.primaryFocus?.unfocus();
    final pageRoute = _openFullExpenseForm(
      sheetContext,
      currentGroup,
      partialState,
      fromSheet: true,
    );
    void dropSheet(AnimationStatus status) {
      if (status != AnimationStatus.completed) return;
      pageRoute.animation?.removeStatusListener(dropSheet);
      if (sheetRoute != null && sheetRoute.isActive) {
        navigator.removeRoute(sheetRoute);
      }
    }

    pageRoute.animation?.addStatusListener(dropSheet);
  }

  PageRoute<void> _openFullExpenseForm(
    BuildContext context,
    ExpenseGroup currentGroup,
    ExpenseFormState? partialState, {
    bool fromSheet = false,
  }) {
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    final parentContext = context;

    ExpenseDetails? partialExpense;
    if (partialState != null) {
      partialExpense = ExpenseDetails(
        id: '',
        name: partialState.name.isEmpty ? null : partialState.name,
        amount: partialState.amount,
        // Nothing picked yet (e.g. a group without participants): the
        // full page starts with nobody / no category selected.
        paidBy: partialState.paidBy ?? ExpenseParticipant(name: ''),
        category: partialState.category ?? ExpenseCategory(name: ''),
        date: partialState.date,
        location: partialState.location,
        note: partialState.note.isEmpty ? null : partialState.note,
        attachments: partialState.attachments,
      );
    }

    Widget buildPage(BuildContext context) => Consumer<ExpenseGroupNotifier>(
      builder: (context, groupNotifier, child) {
        final currentGroup = groupNotifier.currentGroup ?? group;
        return ExpenseFormPage(
          group: currentGroup,
          initialExpense: partialExpense,
          autofocusAmount: !fromSheet,
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
              await NotificationManager().updateNotificationForGroupById(
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
    );

    final PageRoute<void> route = fromSheet
        ? _SheetToPageRoute(builder: buildPage)
        : MaterialPageRoute<void>(builder: buildPage);
    Navigator.of(context).push(route).whenComplete(() {
      notifier.clearCurrentGroup();
    });
    return route;
  }
}

/// The full expense page opened from the quick-add sheet: it slides up from
/// the bottom with the sheet's own motion ([AppMotion.sheet]), opaque, so it
/// reads as the sheet growing to full screen.
class _SheetToPageRoute extends PageRoute<void> {
  _SheetToPageRoute({required this.builder});

  final WidgetBuilder builder;

  @override
  Duration get transitionDuration => AppMotion.sheet.duration!;

  @override
  Duration get reverseTransitionDuration => AppMotion.sheet.reverseDuration!;

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: AppMotion.sheet.curve!,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
      child: child,
    );
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
