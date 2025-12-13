library;

import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../widgets/expense_form_actions_widget.dart';
import '../state/expense_form_controller.dart';
import '../state/expense_form_state.dart';
import 'expense_form_config.dart';
import 'expense_form_lifecycle_manager.dart';
import 'expense_form_orchestrator.dart';
import 'expense_form_fields.dart';
import 'expense_form_extended_fields.dart';
import 'expense_form_compact_header.dart';

/// Main expense form component - refactored to use config object pattern
///
/// This component now accepts a single ExpenseFormConfig parameter instead
/// of 43 individual parameters, improving maintainability and readability.
class ExpenseFormComponent extends StatefulWidget {
  final ExpenseFormConfig config;

  const ExpenseFormComponent({super.key, required this.config});

  /// Factory constructor for backward compatibility - creating new expense
  factory ExpenseFormComponent.create({
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
    ScrollController? scrollController,
    void Function(ExpenseFormState)? onExpand,
    bool showGroupHeader = true,
    bool showActionsRow = true,
    void Function(bool)? onFormValidityChanged,
    void Function(VoidCallback?)? onSaveCallbackChanged,
  }) {
    return ExpenseFormComponent(
      config: ExpenseFormConfig.create(
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
      ),
    );
  }

  /// Factory constructor for backward compatibility - editing existing expense
  factory ExpenseFormComponent.edit({
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
    ScrollController? scrollController,
  }) {
    return ExpenseFormComponent(
      config: ExpenseFormConfig.edit(
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
      ),
    );
  }

  // Legacy constructor for backward compatibility
  ExpenseFormComponent.legacy({
    super.key,
    ExpenseDetails? initialExpense,
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    VoidCallback? onDelete,
    bool shouldAutoClose = true,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? newlyAddedCategory,
    String? groupTitle,
    required String groupId,
    String? currency,
    required bool autoLocationEnabled,
    bool fullEdit = false,
    bool isReadOnly = false,
    ScrollController? scrollController,
    void Function(ExpenseFormState)? onExpand,
    bool showGroupHeader = true,
    bool showActionsRow = true,
    void Function(bool)? onFormValidityChanged,
    void Function(VoidCallback?)? onSaveCallbackChanged,
  }) : config = ExpenseFormConfig(
         initialExpense: initialExpense,
         participants: participants,
         categories: categories,
         groupId: groupId,
         onExpenseAdded: onExpenseAdded,
         onCategoryAdded: onCategoryAdded,
         onDelete: onDelete,
         shouldAutoClose: shouldAutoClose,
         tripStartDate: tripStartDate,
         tripEndDate: tripEndDate,
         newlyAddedCategory: newlyAddedCategory,
         groupTitle: groupTitle,
         currency: currency,
         autoLocationEnabled: autoLocationEnabled,
         fullEdit: fullEdit,
         scrollController: scrollController,
         onExpand: onExpand,
         showGroupHeader: showGroupHeader,
         showActionsRow: showActionsRow,
         onFormValidityChanged: onFormValidityChanged,
         onSaveCallbackChanged: onSaveCallbackChanged,
         isReadOnly: isReadOnly,
       );

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormLifecycleManager _lifecycleManager;
  late ExpenseFormOrchestrator _orchestrator;
  late ExpenseFormController _controller;

  // Getter per determinare se mostrare i campi estesi
  bool get _shouldShowExtendedFields =>
      widget.config.fullEdit ||
      widget.config.initialExpense != null ||
      _controller.isExpanded;

  @override
  void initState() {
    super.initState();

    // Initialize lifecycle manager
    _lifecycleManager = ExpenseFormLifecycleManager(
      config: widget.config,
      onControllerReady: (controller) {
        _controller = controller;

        // Initialize orchestrator after controller is ready
        _orchestrator = ExpenseFormOrchestrator(
          config: widget.config,
          controller: _controller,
          formKey: _formKey,
        );
        _orchestrator.initialize();

        // Setup save callback wrapper to provide context
        if (widget.config.onSaveCallbackChanged != null) {
          _controller.addListener(_notifySaveCallbackWithContext);
          _notifySaveCallbackWithContext(); // Initial state
        }

        // Setup focus listeners for scroll coordination
        _setupFocusListeners();

        // Autofocus after first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.amountFocus.requestFocus();
            _lifecycleManager.scrollCoordinator?.scrollToField(
              _controller.amountFieldKey,
            );
          }
        });
      },
    );

    // Initialize synchronously - no loader needed!
    _lifecycleManager.initializeSync(context);
  }

  void _setupFocusListeners() {
    final scrollCoordinator = _lifecycleManager.scrollCoordinator;
    if (scrollCoordinator == null) return;

    _controller.amountFocus.addListener(() {
      if (_controller.amountFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.amountFieldKey);
        });
      }
    });

    _controller.nameFocus.addListener(() {
      if (_controller.nameFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.nameFieldKey);
        });
      }
    });

    _controller.locationFocus.addListener(() {
      if (_controller.locationFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.locationFieldKey);
        });
      }
    });

    _controller.noteFocus.addListener(() {
      if (_controller.noteFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.noteFieldKey);
        });
      }
    });
  }

  void _notifySaveCallbackWithContext() {
    // Create a proper callback with context access
    final isValid = _controller.isFormValid;
    final callback = isValid ? () => _orchestrator.saveExpense(context) : null;
    widget.config.onSaveCallbackChanged?.call(callback);
  }

  Future<bool> _confirmDiscardChanges() async {
    final gloc = gen.AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Material3Dialog(
            icon: Icon(
              Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            title: Text(gloc.discard_changes_title),
            content: Text(gloc.discard_changes_message),
            actions: [
              Material3DialogActions.cancel(ctx, gloc.cancel),
              Material3DialogActions.destructive(
                ctx,
                gloc.discard,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final gloc = gen.AppLocalizations.of(context);
    final smallStyle = Theme.of(context).textTheme.bodyMedium;

    return PopScope(
      canPop: !_controller.state.isDirty,
      onPopInvokedWithResult: _handlePop,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpenseFormCompactHeader(
              groupTitle: widget.config.groupTitle,
              showGroupHeader: widget.config.showGroupHeader,
            ),
            ExpenseFormFields(
              controller: _controller,
              participants: widget.config.participants,
              categories: _lifecycleManager.categories,
              onCategoryAdded: _onCategoryAdded,
              onCategoriesUpdated: (newCategories) {
                _lifecycleManager.updateCategories(newCategories);
                setState(() {});
              },
              fullEdit: widget.config.fullEdit,
              autoLocationEnabled: widget.config.autoLocationEnabled,
              location: _controller.state.location,
              isRetrievingLocation: _lifecycleManager.isRetrievingLocation,
              onClearLocation: _clearLocation,
              currency: widget.config.currency,
              onSaveExpense: () => _orchestrator.saveExpense(context),
              isInitialExpense: widget.config.initialExpense != null,
              isReadOnly: widget.config.isReadOnly,
            ),
            if (_shouldShowExtendedFields)
              ExpenseFormExtendedFields(
                controller: _controller,
                tripStartDate: widget.config.tripStartDate,
                tripEndDate: widget.config.tripEndDate,
                locale: locale,
                groupId: widget.config.groupId,
                autoLocationEnabled: widget.config.autoLocationEnabled,
                isInitialExpense: widget.config.initialExpense != null,
                isFormValid: _controller.isFormValid,
                onSaveExpense: () => _orchestrator.saveExpense(context),
                isReadOnly: widget.config.isReadOnly,
              ),
            if (widget.config.showActionsRow) ...[
              _buildDivider(context),
              _buildActionsRow(gloc, smallStyle),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (_controller.state.isDirty) {
      final navigator = Navigator.of(context);
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && navigator.canPop()) navigator.pop();
    }
  }

  void _clearLocation() {
    _controller.updateLocation(null);
    _controller.setLocationRetrieving(false);
  }

  Future<void> _onCategoryAdded(String categoryName) async {
    widget.config.onCategoryAdded(categoryName);
    await Future.delayed(const Duration(milliseconds: 100));

    final categories = widget.config.categories;
    final found = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );

    final currentCategories = _lifecycleManager.categories;
    if (!currentCategories.contains(found)) {
      _lifecycleManager.updateCategories(List.from(categories));
      _controller.addCategory(found);
      setState(() {});
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );

    _lifecycleManager.updateCategories(List.from(categories));
    _controller.updateCategory(foundAfter);
    setState(() {});
  }

  Widget _buildDivider(BuildContext context) {
    if (_shouldShowExtendedFields) {
      // In full edit mode: reserve vertical space but no visual divider
      return const SizedBox(height: FormTheme.sectionSpacing);
    }
    return Divider(
      height: FormTheme.sectionSpacing,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }

  Widget _buildActionsRow(gen.AppLocalizations gloc, TextStyle? style) =>
      ExpenseFormActionsWidget(
        onSave: _controller.isFormValid
            ? () => _orchestrator.saveExpense(context)
            : null,
        isFormValid: _controller.isFormValid,
        isEdit: widget.config.initialExpense?.id != null && widget.config.initialExpense!.id.isNotEmpty,
        onDelete: widget.config.hasDeleteAction
            ? () => _orchestrator.deleteExpense(context)
            : null,
        textStyle: style,
        showExpandButton:
            !(widget.config.fullEdit ||
                widget.config.initialExpense != null ||
                _controller.isExpanded),
        onExpand: widget.config.onExpand != null
            ? () => widget.config.onExpand!(_controller.state)
            : null,
      );

  @override
  void dispose() {
    if (widget.config.onSaveCallbackChanged != null) {
      _controller.removeListener(_notifySaveCallbackWithContext);
    }
    _orchestrator.dispose();
    _lifecycleManager.dispose();
    super.dispose();
  }
}
