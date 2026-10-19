import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import '../../expense/components/expense_form_component.dart';
import '../../expense/state/expense_form_state.dart';
import '../../expense/widgets/expense_form_actions_widget.dart';

/// Unified sheet for creating or editing an expense.
/// If [initialExpense] is provided we are editing, otherwise creating a new one.
class ExpenseEntrySheet extends StatefulWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved; // add or update
  final void Function(String) onCategoryAdded;
  final void Function(String)? onParticipantAdded;
  final VoidCallback? onDelete; // only used in edit mode
  final bool fullEdit;
  final void Function(ExpenseFormState)?
  onExpand; // callback to expand to full page
  final bool showGroupHeader; // whether to show group header in form
  final void Function(bool)? onFormValidityChanged;
  final void Function(VoidCallback?)? onSaveCallbackChanged;

  const ExpenseEntrySheet({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.onParticipantAdded,
    this.onDelete,
    this.fullEdit = true,
    this.onExpand,
    this.showGroupHeader = true,
    this.onFormValidityChanged,
    this.onSaveCallbackChanged,
  });

  @override
  State<ExpenseEntrySheet> createState() => _ExpenseEntrySheetState();
}

class _ExpenseEntrySheetState extends State<ExpenseEntrySheet> {
  late ScrollController _scrollController;
  bool _isFormValid = false;
  VoidCallback? _saveCallback;
  VoidCallback? _voiceCallback;
  VoidCallback? _scanCallback;
  VoidCallback? _scanFromGalleryCallback;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // The form reports these while building: apply them after the frame.
  void _later(VoidCallback update) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(update);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final isEdit =
        widget.initialExpense != null && widget.initialExpense!.id.isNotEmpty;
    final readOnly = widget.group.archived;

    // Handle, then the form scrolling, then Add/Save pinned at the bottom so
    // it stays above the keyboard however tall the form gets.
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ExpenseFormComponent.legacy(
                  initialExpense: widget.initialExpense,
                  participants: widget.group.getParticipantsByLastUsed(),
                  categories: widget.group.getCategoriesByLastUsed(),
                  tripStartDate: widget.group.startDate,
                  tripEndDate: widget.group.endDate,
                  shouldAutoClose: false,
                  fullEdit: widget.fullEdit,
                  showGroupHeader: widget.showGroupHeader,
                  showActionsRow: false,
                  groupTitle: widget.group.title,
                  groupId: widget.group.id,
                  currency: widget.group.currency,
                  autoLocationEnabled: widget.group.autoLocationEnabled,
                  onExpenseAdded: widget.onExpenseSaved,
                  onCategoryAdded: widget.onCategoryAdded,
                  onParticipantAdded: widget.onParticipantAdded,
                  onDelete: widget.onDelete,
                  scrollController: _scrollController,
                  onExpand: widget.onExpand,
                  isReadOnly: readOnly,
                  onFormValidityChanged: (valid) {
                    widget.onFormValidityChanged?.call(valid);
                    if (valid != _isFormValid) {
                      _later(() => _isFormValid = valid);
                    }
                  },
                  onSaveCallbackChanged: (callback) {
                    widget.onSaveCallbackChanged?.call(callback);
                    _later(() {
                      _saveCallback = callback;
                      _isFormValid = callback != null;
                    });
                  },
                  onVoiceCallbackChanged: (callback) =>
                      _later(() => _voiceCallback = callback),
                  onScanReceiptCallbackChanged: (callback) =>
                      _later(() => _scanCallback = callback),
                  onScanReceiptFromGalleryCallbackChanged: (callback) =>
                      _later(() => _scanFromGalleryCallback = callback),
                ),
              ),
            ),
            if (!readOnly)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: ExpenseFormActionsWidget(
                  onSave: _saveCallback,
                  isFormValid: _isFormValid,
                  isEdit: isEdit,
                  onDelete: isEdit ? widget.onDelete : null,
                  showVoiceButton: !isEdit,
                  onVoiceTap: _voiceCallback,
                  onScanReceipt: _scanCallback,
                  onScanReceiptFromGallery: _scanFromGalleryCallback,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
