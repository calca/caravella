library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'widgets/location/location_service.dart';
import 'widgets/location/location_input_widget.dart';
import 'widgets/location/compact_location_indicator.dart';
import 'expense_form/amount_input_widget.dart';
import 'expense_form/participant_selector_widget.dart';
import 'expense_form/category_selector_widget.dart';
import 'expense_form/date_selector_widget.dart';
import 'expense_form/note_input_widget.dart';
import 'expense_form/expense_form_actions_widget.dart';
import 'expense_form/category_dialog.dart';
import 'expense_form/attachment_input_widget.dart';
import 'widgets/attachment_viewer_page.dart';
import 'state/expense_form_controller.dart';
import 'state/expense_form_state.dart';
import 'coordination/form_scroll_coordinator.dart';

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

  // Widget per indicatori di stato - versione minimalista
  Widget _buildFieldWithStatus(Widget field, bool isValid, bool isTouched) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // Solo sfondo colorato se c'è un errore
        color: isTouched && !isValid
            ? Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.08)
            : null,
      ),
      child: field,
    );
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
            _buildGroupHeader(),
            _buildAmountField(gloc, smallStyle),
            _spacer(),
            _buildNameField(gloc, smallStyle),
            _spacer(),
            _buildParticipantCategorySection(smallStyle),
            _buildExtendedFields(locale, smallStyle),
            if (widget.showActionsRow) ...[
              _buildDivider(context),
              _buildActionsRow(gloc, smallStyle),
            ],
          ],
        ),
      ),
    );
  }

  /// Intestazione con il titolo del gruppo (solo se showGroupHeader è true e presente)
  Widget _buildGroupHeader() {
    if (!(widget.showGroupHeader && widget.groupTitle != null)) {
      return const SizedBox.shrink();
    }
    final gloc = gen.AppLocalizations.of(context);
    final title = widget.groupTitle!.trim();
    if (title.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prefixStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    );
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      overflow: TextOverflow.ellipsis,
    );
    return Semantics(
      container: true,
      header: true,
      label: '${gloc.in_group_prefix} $title',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Tooltip(
                message: title,
                waitDuration: const Duration(milliseconds: 400),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${gloc.in_group_prefix} ',
                        style: prefixStyle,
                      ),
                      TextSpan(text: title, style: titleStyle),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _spacer() => const SizedBox(height: FormTheme.fieldSpacing);

  Widget _buildAmountField(gen.AppLocalizations gloc, TextStyle? style) =>
      KeyedSubtree(
        key: _controller.amountFieldKey,
        child: _buildFieldWithStatus(
          AmountInputWidget(
            controller: _controller.amountController,
            focusNode: _controller.amountFocus,
            categories: _categories,
            label: gloc.amount,
            currency: widget.currency,
            textInputAction: _controller.isFormValid
                ? TextInputAction.done
                : TextInputAction.next,
            validator: (v) {
              final parsed = _controller.parseLocalizedAmount(v ?? '');
              if (parsed == null || parsed <= 0) return gloc.invalid_amount;
              return null;
            },
            onSaved: (v) {},
            onSubmitted: _saveExpense,
            textStyle: style,
          ),
          _controller.isAmountValid,
          _controller.amountTouched,
        ),
      );

  Widget _buildNameField(gen.AppLocalizations gloc, TextStyle? style) =>
      KeyedSubtree(
        key: _controller.nameFieldKey,
        child: _buildFieldWithStatus(
          AmountInputWidget(
            controller: _controller.nameController,
            focusNode: _controller.nameFocus,
            label: gloc.expense_name,
            leading: Icon(
              Icons.description_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textInputAction: _controller.isFormValid
                ? TextInputAction.done
                : TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? gloc.enter_title : null,
            onSaved: (v) {},
            onSubmitted: _controller.isFormValid ? _saveExpense : null,
            isText: true,
            textStyle: style,
          ),
          _controller.isNameValid,
          _controller.amountTouched,
        ),
      );

  Widget _buildParticipantCategorySection(TextStyle? style) {
    if (_shouldShowExtendedFields) {
      return Column(
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: widget.participants.map((p) => p.name).toList(),
              selectedParticipant: _controller.state.paidBy?.name,
              onParticipantSelected: _onParticipantSelected,
              textStyle: style,
              fullEdit: true,
            ),
            _controller.isPaidByValid,
            _controller.paidByTouched,
          ),
          _spacer(),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: _categories,
              selectedCategory: _controller.state.category,
              onCategorySelected: _onCategorySelected,
              onAddCategory: _onAddCategory,
              onAddCategoryInline: _onAddCategoryInline,
              textStyle: style,
              fullEdit: true,
            ),
            _controller.isCategoryValid(_categories.isEmpty),
            _controller.categoryTouched,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldWithStatus(
              ParticipantSelectorWidget(
                participants: widget.participants.map((p) => p.name).toList(),
                selectedParticipant: _controller.state.paidBy?.name,
                onParticipantSelected: _onParticipantSelected,
                textStyle: style,
                fullEdit: false,
              ),
              _controller.isPaidByValid,
              _controller.paidByTouched,
            ),
            const SizedBox(width: 12),
            _buildFieldWithStatus(
              CategorySelectorWidget(
                categories: _categories,
                selectedCategory: _controller.state.category,
                onCategorySelected: _onCategorySelected,
                onAddCategory: _onAddCategory,
                onAddCategoryInline: _onAddCategoryInline,
                textStyle: style,
                fullEdit: false,
              ),
              _controller.isCategoryValid(_categories.isEmpty),
              _controller.categoryTouched,
            ),
            // Show compact location indicator when auto-location is enabled
            if (widget.initialExpense == null && _autoLocationEnabled) ...[
              const Spacer(),
              CompactLocationIndicator(
                isRetrieving: _controller.state.isRetrievingLocation,
                location: _controller.state.location,
                onCancel: _clearLocation,
                textStyle: style,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // (Expand button moved into ExpenseFormActionsWidget)

  void _clearLocation() {
    _controller.updateLocation(null);
    _controller.setLocationRetrieving(false);
  }

  void _onParticipantSelected(String selectedName) {
    final participant = widget.participants.firstWhere(
      (p) => p.name == selectedName,
      orElse: () => widget.participants.isNotEmpty
          ? widget.participants.first
          : ExpenseParticipant(name: ''),
    );
    _controller.updatePaidBy(participant);
    _notifyFormValidityChanged();
  }

  void _onCategorySelected(ExpenseCategory? selected) {
    _controller.updateCategory(selected);
    _notifyFormValidityChanged();
  }

  Future<void> _onAddCategory() async {
    final newCategoryName = await CategoryDialog.show(context: context);
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      widget.onCategoryAdded(newCategoryName);
      final found = widget.categories.firstWhere(
        (c) => c.name == newCategoryName,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      if (!_categories.contains(found)) {
        _categories.add(found);
        _controller.addCategory(found);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      final foundAfter = widget.categories.firstWhere(
        (c) => c.name == newCategoryName,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      _categories = List.from(widget.categories);
      _controller.updateCategory(foundAfter);
    }
  }

  Future<void> _onAddCategoryInline(String categoryName) async {
    widget.onCategoryAdded(categoryName);
    await Future.delayed(const Duration(milliseconds: 100));
    final found = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    if (!_categories.contains(found)) {
      _categories.add(found);
      _controller.addCategory(found);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    _categories = List.from(widget.categories);
    _controller.updateCategory(foundAfter);
  }

  Widget _buildExtendedFields(String locale, TextStyle? style) {
    if (!_shouldShowExtendedFields) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacer(),
        DateSelectorWidget(
          selectedDate: _controller.state.date,
          tripStartDate: widget.tripStartDate,
          tripEndDate: widget.tripEndDate,
          onDateSelected: _controller.updateDate,
          locale: locale,
          textStyle: style,
        ),
        _spacer(),
        KeyedSubtree(
          key: _controller.locationFieldKey,
          child: LocationInputWidget(
            initialLocation: _controller.state.location,
            textStyle: style,
            onLocationChanged: _controller.updateLocation,
            externalFocusNode: _controller.locationFocus,
            autoRetrieve: widget.initialExpense == null && _autoLocationEnabled,
            onRetrievalStatusChanged: _controller.setLocationRetrieving,
          ),
        ),
        _spacer(),
        AttachmentInputWidget(
          groupId: widget.groupId,
          attachments: _controller.state.attachments,
          onAttachmentAdded: _controller.addAttachment,
          onAttachmentRemoved: (index) {
            // Delete the file from storage
            final filePath = _controller.state.attachments[index];
            try {
              File(filePath).deleteSync();
            } catch (e) {
              // File might not exist, ignore error
            }
            _controller.removeAttachment(index);
          },
          onAttachmentTapped: (path) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AttachmentViewerPage(
                  attachments: _controller.state.attachments,
                  initialIndex: _controller.state.attachments.indexOf(path),
                  onDelete: (index) {
                    // Delete the file from storage
                    final filePath = _controller.state.attachments[index];
                    try {
                      File(filePath).deleteSync();
                    } catch (e) {
                      // File might not exist, ignore error
                    }
                    _controller.removeAttachment(index);
                  },
                ),
              ),
            );
          },
        ),
        _spacer(),
        KeyedSubtree(
          key: _controller.noteFieldKey,
          child: NoteInputWidget(
            controller: _controller.noteController,
            textStyle: style,
            focusNode: _controller.noteFocus,
            textInputAction: _controller.isFormValid
                ? TextInputAction.done
                : TextInputAction.newline,
            onFieldSubmitted: _controller.isFormValid ? _saveExpense : null,
          ),
        ),
      ],
    );
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
