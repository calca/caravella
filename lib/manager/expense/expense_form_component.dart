library;

import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'location/location_service.dart';
import 'widgets/expense_form_actions_widget.dart';
import 'state/expense_form_controller.dart';
import 'state/expense_form_state.dart';
import 'coordination/form_scroll_coordinator.dart';
import 'components/expense_form_fields.dart';
import 'components/expense_form_extended_fields.dart';
import 'components/expense_form_compact_header.dart';

class ExpenseFormComponent extends StatefulWidget {
  // When true shows date, location and note fields (full edit mode). In edit mode (initialExpense != null) these are always shown.
  final bool fullEdit;
  final ExpenseDetails? initialExpense;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(ExpenseDetails) onExpenseAdded;
  final Function(String) onCategoryAdded;
  final VoidCallback? onDelete; // optional delete action for edit mode
  final bool shouldAutoClose;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? newlyAddedCategory; // Nuova proprietà
  final String? groupTitle; // Titolo del gruppo per la riga azioni
  final String groupId; // ID del gruppo per organizzare gli allegati
  final String? currency; // Currency del gruppo
  final bool autoLocationEnabled; // Impostazione per auto-recupero posizione
  final ScrollController?
  scrollController; // Controller for scrolling to focused fields
  final VoidCallback? onExpand; // Callback per espandere a full page
  final bool showGroupHeader; // Se mostrare l'intestazione del gruppo
  final bool
  showActionsRow; // Se mostrare la riga azioni (pulsanti aggiungi/salva)
  final void Function(bool)?
  onFormValidityChanged; // Notifica il parent quando cambia la validità del form
  final void Function(VoidCallback?)?
  onSaveCallbackChanged; // Fornisce al parent il callback per salvare

  const ExpenseFormComponent({
    super.key,
    this.initialExpense,
    required this.participants,
    required this.categories,
    required this.onExpenseAdded,
    required this.onCategoryAdded,
    this.onDelete,
    this.shouldAutoClose = true,
    this.tripStartDate,
    this.tripEndDate,
    this.newlyAddedCategory, // Nuova proprietà
    this.groupTitle,
    required this.groupId,
    this.currency,
    required this.autoLocationEnabled,
    this.fullEdit = false,
    this.scrollController,
    this.onExpand,
    this.showGroupHeader = true,
    this.showActionsRow = true,
    this.onFormValidityChanged,
    this.onSaveCallbackChanged,
  });

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormController _controller;
  late FormScrollCoordinator _scrollCoordinator;
  late List<ExpenseCategory> _categories;

  // Auto location preference
  bool _autoLocationEnabled = false;

  // Getter per determinare se mostrare i campi estesi
  bool get _shouldShowExtendedFields =>
      widget.fullEdit ||
      widget.initialExpense != null ||
      _controller.isExpanded;

  // Scroll controller callback per CategorySelectorWidget
  // Removed _scrollToCategoryEnd: no longer needed with new category selector bottom sheet.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _categories = List.from(widget.categories);
    _autoLocationEnabled = widget.autoLocationEnabled;

    // Initialize controller with initial state
    final initialState = widget.initialExpense != null
        ? ExpenseFormState.fromExpense(
            widget.initialExpense!,
            widget.categories,
          )
        : ExpenseFormState.initial(
            participants: widget.participants,
            categories: widget.categories,
          );

    _controller = ExpenseFormController(
      initialState: initialState,
      categories: widget.categories,
    );

    // Initialize scroll coordinator
    _scrollCoordinator = FormScrollCoordinator(
      scrollController: widget.scrollController,
      context: context,
    );

    // Listen to controller changes for form validity updates
    _controller.addListener(() {
      _notifyFormValidityChanged();
    });

    // Setup focus listeners for scroll coordination
    _controller.amountFocus.addListener(() {
      if (_controller.amountFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollCoordinator.scrollToField(_controller.amountFieldKey);
        });
      }
    });

    _controller.nameFocus.addListener(() {
      if (_controller.nameFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollCoordinator.scrollToField(_controller.nameFieldKey);
        });
      }
    });

    _controller.locationFocus.addListener(() {
      if (_controller.locationFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollCoordinator.scrollToField(_controller.locationFieldKey);
        });
      }
    });

    _controller.noteFocus.addListener(() {
      if (_controller.noteFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollCoordinator.scrollToField(_controller.noteFieldKey);
        });
      }
    });

    // Autofocus after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.amountFocus.requestFocus();
        _scrollCoordinator.scrollToField(_controller.amountFieldKey);
      }

      // Finish initialization
      _controller.finishInitialization();

      // Auto-retrieve location if enabled and creating a new expense
      if (widget.initialExpense == null && _autoLocationEnabled) {
        _retrieveCurrentLocation();
      }

      // Notify parent
      widget.onSaveCallbackChanged?.call(_saveExpense);
      widget.onFormValidityChanged?.call(_controller.isFormValid);
    });
  }

  Future<void> _retrieveCurrentLocation() async {
    if (!mounted) return;

    _controller.setLocationRetrieving(true);

    final location = await LocationService.getCurrentLocation(
      context,
      resolveAddress: true,
      onStatusChanged: (status) {
        if (mounted) {
          _controller.setLocationRetrieving(status);
        }
      },
    );

    if (location != null && mounted) {
      _controller.updateLocation(location);
    }

    if (mounted) {
      _controller.setLocationRetrieving(false);
    }
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

  void _notifyFormValidityChanged() {
    if (widget.onFormValidityChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFormValidityChanged?.call(_controller.isFormValid);
        }
      });
    }
  }

  void _saveExpense() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      // Mark all fields as touched for validation feedback
      return;
    }
    if (!_controller.isFormValid) return;

    final state = _controller.state;
    final expense = ExpenseDetails(
      id: widget.initialExpense?.id,
      amount: state.amount ?? 0,
      paidBy: state.paidBy ?? ExpenseParticipant(name: ''),
      category:
          state.category ??
          (_categories.isNotEmpty
              ? _categories.first
              : ExpenseCategory(name: '', id: '', createdAt: DateTime.now())),
      date: state.date,
      note: state.note.trim().isNotEmpty ? state.note.trim() : null,
      name: state.name,
      location: state.location,
      attachments: state.attachments,
    );
    widget.onExpenseAdded(expense);
    if (widget.shouldAutoClose && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => _buildRoot(context);

  Widget _buildRoot(BuildContext context) {
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
              groupTitle: widget.groupTitle,
              showGroupHeader: widget.showGroupHeader,
            ),
            ExpenseFormFields(
              controller: _controller,
              participants: widget.participants,
              categories: _categories,
              onCategoryAdded: _onCategoryAdded,
              onCategoriesUpdated: (newCategories) {
                setState(() {
                  _categories = newCategories;
                });
              },
              fullEdit: widget.fullEdit,
              autoLocationEnabled: _autoLocationEnabled,
              location: _controller.state.location,
              isRetrievingLocation: _controller.state.isRetrievingLocation,
              onClearLocation: _clearLocation,
              currency: widget.currency,
              onSaveExpense: _saveExpense,
              isInitialExpense: widget.initialExpense != null,
            ),
            if (_shouldShowExtendedFields)
              ExpenseFormExtendedFields(
                controller: _controller,
                tripStartDate: widget.tripStartDate,
                tripEndDate: widget.tripEndDate,
                locale: locale,
                groupId: widget.groupId,
                autoLocationEnabled: _autoLocationEnabled,
                isInitialExpense: widget.initialExpense != null,
                isFormValid: _controller.isFormValid,
                onSaveExpense: _saveExpense,
              ),
            if (widget.showActionsRow) ...[
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
    widget.onCategoryAdded(categoryName);
    await Future.delayed(const Duration(milliseconds: 100));
    final found = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    if (!_categories.contains(found)) {
      setState(() {
        _categories = List.from(widget.categories);
      });
      _controller.addCategory(found);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    setState(() {
      _categories = List.from(widget.categories);
    });
    _controller.updateCategory(foundAfter);
    _notifyFormValidityChanged();
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
        onSave: _controller.isFormValid ? _saveExpense : null,
        isFormValid: _controller.isFormValid,
        isEdit: widget.initialExpense != null,
        onDelete: widget.initialExpense != null ? widget.onDelete : null,
        textStyle: style,
        showExpandButton:
            !(widget.fullEdit ||
                widget.initialExpense != null ||
                _controller.isExpanded),
        onExpand: widget.onExpand ?? _controller.expandForm,
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
}
